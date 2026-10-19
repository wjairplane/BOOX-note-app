package app.inkbridge.pen

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.Rect
import android.os.Build
import android.view.MotionEvent
import android.view.SurfaceHolder
import android.view.SurfaceView
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.edit.SelectionGesture
import com.onyx.android.sdk.api.device.epd.EpdController
import com.onyx.android.sdk.data.note.TouchPoint
import com.onyx.android.sdk.pen.RawInputCallback
import com.onyx.android.sdk.pen.TouchHelper
import com.onyx.android.sdk.pen.data.TouchPointList

/** One pen sample in view pixels. [pressure] is 0..1, tilt in degrees (0 if unknown). */
data class PenSample(val x: Float, val y: Float, val pressure: Float, val tiltX: Float, val tiltY: Float, val timeMs: Long)

/** Receives finished gestures. May be called on a non-UI thread. */
interface PenListener {
    fun onStroke(samples: List<PenSample>)
    fun onErase(samples: List<PenSample>, hardware: Boolean = false)
    /** Exact pen preview of the eraser: the pixels it has passed over fade to grey; [from] is how many samples the last frame had. */
    fun onLiveErase(samples: List<PenSample>, from: Int, hardware: Boolean) {}
    /** A finger swiped across the page: [forward] = towards the next page. */
    fun onSwipe(forward: Boolean) {}
    /** A one-finger vertical swipe: scroll a screen [down] (or up) inside a zoomed page. */
    fun onJump(down: Boolean) {}
    /** Exact pen preview: the stroke written so far (view px); [from] is how many samples the last frame already had. */
    fun onLiveStroke(samples: List<PenSample>, from: Int) {}
    /** The pen lifted (or the touch was cancelled): take the live stroke off the picture. */
    fun onLiveEnd() {}
    /** A swipe from a screen edge: close the document, quick settings, the document drawer, quick browse. */
    fun onEdgeSwipe(edge: FingerGestures.Edge) {}
    /** A quick tap with [fingers] (2 or 3) fingers: the tablet's undo / redo shortcuts. */
    fun onFingerTap(fingers: Int) {}
    /** A stroke made with the selection tool (a lasso, or a drag of the current selection). */
    fun onLasso(samples: List<PenSample>) {}
    /** A stroke made with "Erase selection": erase what the lasso encloses. */
    fun onEraseArea(samples: List<PenSample>) {}
    /** The selection is being dragged, resized or rotated ([active]) or the gesture ended. */
    fun onSelectionGesture(active: Boolean) {}
    /** A pinch / two-finger drag ended: zoom by [factor] around ([focusX], [focusY]), then pan by ([panX], [panY]) view pixels. */
    fun onViewGesture(factor: Float, focusX: Float, focusY: Float, panX: Float, panY: Float) {}
}

/**
 * Page surface: shows a bitmap and collects pen input.
 *
 * On BOOX devices it uses Onyx's `TouchHelper` raw-drawing mode, which draws a fast live preview of
 * the stroke on the e-ink panel; when the stroke ends we hand the samples to [PenListener] and the
 * caller updates the bitmap, which [show] pushes to the surface. On other Android devices it falls
 * back to ordinary touch events, so the app can be exercised without a BOOX.
 *
 * Everything touching the Onyx SDK is isolated here: pen *feel* (preview style, refresh behaviour)
 * can only be tuned on a real device.
 */
class PenSurface(context: Context, private val listener: PenListener) : SurfaceView(context), SurfaceHolder.Callback {
    private var bitmap: Bitmap? = null

    internal fun listenerForTest(): PenListener = listener

    /** What is currently shown (a SurfaceView's content isn't part of a normal view capture, so screenshot tests draw this themselves). */
    internal val shownBitmap: Bitmap? get() = bitmap
    private var bitmapLeft = 0f

    private var touchHelper: TouchHelper? = null
    private val useOnyx = Build.MANUFACTURER.equals("onyx", ignoreCase = true) || Build.BRAND.equals("onyx", ignoreCase = true)

    /**
     * "Exact" pen preview: the Onyx raw-drawing layer is not used. The stylus comes in as ordinary touch events and the stroke is drawn
     * while it is written with the firmware's own pen renderer, into the page under the toolbar and menus (so nothing can be drawn
     * over a button), and only the part that changed is sent to the panel. The default "Fast" mode lets the SDK draw its own trail.
     */
    var exactMode = false
        set(value) {
            if (field == value) return
            field = value
            if (useOnyx) {
                if (value) closeHelper() else if (width > 0) reopenHelper()
            }
            applyEnabled()
        }
    private val useRaw: Boolean get() = useOnyx && !exactMode

    var penEnabled = false
        set(value) { field = value; applyEnabled() }

    /** Finger swipes left/right turn pages (reported through [PenListener.onSwipe]). */
    var swipeEnabled = true

    /** Let a finger draw as well; only honoured on non-Onyx devices (on a BOOX the stylus draws, the finger swipes). */
    var fingerDraws = false

    // Finger gestures (the reMarkable's set: flip, jump, pinch / pan, undo / redo taps, edge swipes); see [FingerGestures].
    private var gestureScale = 1f
    private var gestureFocusX = 0f
    private var gestureFocusY = 0f
    private var gesturePanX = 0f
    private var gesturePanY = 0f
    private var lastPreviewMs = 0L
    @Volatile private var lastPenMs = 0L

    /** The current zoom (1 = whole page), so the live pinch preview can stop where the real zoom would. */
    var zoomProvider: () -> Float = { 1f }
    private val zoomNow: Float get() = zoomProvider()

    /** Gestures that need the finger to start near the edges are switched off with the swipes. */
    private val fingerGestures = FingerGestures(
        (resources.displayMetrics.xdpi.takeIf { it > 50f } ?: (160f * resources.displayMetrics.density)) / 2.54f,
        object : FingerGestures.Host {
            override val viewWidth: Int get() = width
            override val viewHeight: Int get() = height
            override fun msSincePen(): Long = android.os.SystemClock.uptimeMillis() - lastPenMs
            override fun onTap(fingers: Int) = listener.onFingerTap(fingers)
            override fun onPageSwipe(forward: Boolean) { if (swipeEnabled) listener.onSwipe(forward) }
            override fun onJump(down: Boolean) = listener.onJump(down)
            override fun onEdgeSwipe(edge: FingerGestures.Edge) = listener.onEdgeSwipe(edge)
            override fun onViewBegin() {
                gestureScale = 1f; gesturePanX = 0f; gesturePanY = 0f
                beginFastPreview()
            }
            override fun onViewUpdate(scale: Float, focusX: Float, focusY: Float, panX: Float, panY: Float) {
                gestureScale = scale.coerceIn(MIN_ZOOM / zoomNow, MAX_ZOOM / zoomNow)
                gestureFocusX = focusX; gestureFocusY = focusY; gesturePanX = panX; gesturePanY = panY
                val now = android.os.SystemClock.uptimeMillis()
                if (now - lastPreviewMs >= PREVIEW_INTERVAL_MS) { lastPreviewMs = now; drawZoomPreview() }
            }
            override fun onViewEnd(scale: Float, focusX: Float, focusY: Float, panX: Float, panY: Float) {
                endFastPreview()
                val f = scale.coerceIn(MIN_ZOOM / zoomNow, MAX_ZOOM / zoomNow)
                if (kotlin.math.abs(f - 1f) > 0.04f || kotlin.math.hypot(panX, panY) > 24f) listener.onViewGesture(f, focusX, focusY, panX, panY) else draw()
                scheduleClear()
            }
        },
    )

    private var fastPreview = false

    /** Switch the panel to a fast, low-fidelity update mode and park the pen layer while something is being previewed. */
    private fun beginFastPreview() {
        if (fastPreview) return
        fastPreview = true
        runCatching { EpdController.setViewDefaultUpdateMode(this, com.onyx.android.sdk.api.device.epd.UpdateMode.DU) }
        touchHelper?.let { runCatching { it.setRawDrawingEnabled(false) } }
    }

    private fun endFastPreview() {
        if (!fastPreview) return
        fastPreview = false
        runCatching { EpdController.resetViewUpdateMode(this) }
        applyEnabled()
    }

    private fun drawZoomPreview() {
        val bmp = bitmap ?: return
        val m = android.graphics.Matrix().apply {
            postTranslate(bitmapLeft, 0f)
            postScale(gestureScale, gestureScale, gestureFocusX, gestureFocusY)
            postTranslate(gesturePanX, gesturePanY)
        }
        drawPreviewCanvas { it.drawBitmap(bmp, m, null) }
    }

    // Selection drag preview: the frame follows the pen (move / resize / rotate) while the strokes stay put until the pen lifts.
    private var dragHit: SelectionGesture.Hit? = null
    private var dragStartX = 0f
    private var dragStartY = 0f
    private var dragMode = false

    /** The selection frame in view px (null when nothing is selected), for the live drag preview. */
    var selectionFrameProvider: () -> SelectionGesture.Frame? = { null }

    private fun beginSelectionDrag(x: Float, y: Float) {
        dragHit = null
        if (tool.tool != PenTool.SELECTION) return
        val hit = selectionFrameProvider()?.let { SelectionGesture.hit(it, x, y) } ?: return
        if (hit.mode == SelectionGesture.Mode.NONE) return
        dragHit = hit; dragStartX = x; dragStartY = y
        // While a selection is dragged the pen trail would be noise: only the frame is shown.
        touchHelper?.let { runCatching { it.setRawDrawingRenderEnabled(false) } }
        runCatching { EpdController.setViewDefaultUpdateMode(this, com.onyx.android.sdk.api.device.epd.UpdateMode.DU) }
        dragMode = true
        listener.onSelectionGesture(true)
    }

    private fun moveSelectionDrag(x: Float, y: Float) {
        val hit = dragHit ?: return
        val frame = selectionFrameProvider() ?: return
        val now = android.os.SystemClock.uptimeMillis()
        if (now - lastPreviewMs < PREVIEW_INTERVAL_MS) return
        lastPreviewMs = now
        val outline = SelectionGesture.mapped(frame, SelectionGesture.transform(hit, dragStartX, dragStartY, x, y))
        val bmp = bitmap
        drawPreviewCanvas { c ->
            bmp?.let { c.drawBitmap(it, bitmapLeft, 0f, null) }
            val paint = android.graphics.Paint().apply { style = android.graphics.Paint.Style.STROKE; color = Color.BLACK; strokeWidth = 2f }
            val path = android.graphics.Path().apply { moveTo(outline[0].first, outline[0].second); outline.drop(1).forEach { lineTo(it.first, it.second) }; close() }
            c.drawPath(path, paint)
        }
    }

    private fun endSelectionDrag() {
        if (!dragMode) return
        dragMode = false; dragHit = null
        listener.onSelectionGesture(false)
        runCatching { EpdController.resetViewUpdateMode(this) }
        touchHelper?.let { runCatching { it.setRawDrawingRenderEnabled(tool.tool != PenTool.ERASER) } }
    }

    /**
     * Which kind of canvas this surface uses, fixed on the first draw (a surface refuses to switch between a hardware and a software
     * canvas). Exact pen mode draws small parts of the page often, which a software canvas can do through a dirty rectangle; the
     * hardware one would have to upload the whole page bitmap to the GPU for every frame of a stroke.
     */
    private var softwareCanvas: Boolean? = null

    /** A hardware-accelerated canvas when there is one (much faster for scaled bitmaps), else a software one. */
    private fun lock(): android.graphics.Canvas? {
        val software = softwareCanvas ?: exactMode.also { softwareCanvas = it }
        if (software) return runCatching { holder.lockCanvas() }.getOrNull()
        return runCatching { if (Build.VERSION.SDK_INT >= 26) holder.lockHardwareCanvas() else holder.lockCanvas() }.getOrNull()
            ?: runCatching { holder.lockCanvas() }.getOrNull()
    }

    /** Draw one preview frame (no pen-layer toggling: that is only for the final, sharp picture). */
    private fun drawPreviewCanvas(content: (android.graphics.Canvas) -> Unit) {
        val surface = holder.surface ?: return
        if (!surface.isValid) return
        val canvas = lock() ?: return
        try { canvas.drawColor(Color.WHITE); content(canvas) } finally { holder.unlockCanvasAndPost(canvas) }
    }

    private var tool: PenSpec = PenSpec(PenTool.FINELINER)

    /** The pen currently selected; used for strokes that finish after the selection changed. */
    val currentSpec: PenSpec get() = tool
    private var pageScale = 1f

    // Fallback (non-Onyx) gesture collection.
    private val touchSamples = ArrayList<PenSample>()

    init {
        holder.addCallback(this)
        setZOrderOnTop(false)
    }

    /** Replace what's displayed; [left] is the bitmap's x offset inside the view. */
    fun show(bmp: Bitmap?, left: Float) {
        bitmap = bmp
        bitmapLeft = left
        draw()
    }

    /** Re-show the current bitmap (after the page changed in place). */
    fun refresh() = draw()

    /**
     * Select the pen. [pageScale] = view pixels per page unit, used to size the live preview;
     * [preview] selects the SDK's live-preview style (it does not affect what is saved).
     */
    fun setTool(spec: PenSpec, pageScale: Float) {
        tool = spec
        this.pageScale = pageScale
        touchHelper?.let { applyToolToHelper(it) }
        applyEnabled()
    }

    /** Limit pen input to the page area (view px) so strokes can't start in the margins. */
    /** Parts of the screen the pen must not draw on (the toolbar, which floats over the page). */
    fun setExcludeRects(rects: List<Rect>) {
        if (rects == excludeRects) return
        excludeRects = rects
        scheduleReopen()
    }
    private var excludeRects: List<Rect> = emptyList()

    fun setPageArea(rect: Rect) {
        if (rect == pageArea) return
        pageArea = rect
        scheduleReopen()
    }

    // Re-opening the Onyx raw-drawing layer is slow, so changes made together (page area, excluded buttons) share one reopen.
    private val reopenTask = Runnable { if (width > 0 && useRaw) reopenHelper() }
    private fun scheduleReopen() {
        if (!useRaw) return
        removeCallbacks(reopenTask)
        postDelayed(reopenTask, 60)
    }
    private var pageArea: Rect? = null

    // ---- Onyx raw drawing ----

    private fun reopenHelper() {
        touchHelper?.let { runCatching { it.closeRawDrawing() } }
        touchHelper = null
        val limit = pageArea ?: Rect(0, 0, width, height)
        if (limit.isEmpty) return
        val helper = TouchHelper.create(this, callback)
        helper.setStrokeWidth(3f).setLimitRect(limit, excludeRects).openRawDrawing()
        applyToolToHelper(helper)
        touchHelper = helper
        applyEnabled()
    }

    private fun applyToolToHelper(helper: TouchHelper) {
        val widthPx = when (tool.tool) {
            PenTool.HIGHLIGHTER -> 15f
            PenTool.SELECTION, PenTool.ERASE_AREA -> 2f
            else -> 2f * tool.thickness
        } * pageScale
        helper.setStrokeWidth(widthPx.coerceAtLeast(1f))
        // Live preview style only (what is saved comes from our own pen model). Guesses; tune on the device.
        helper.setStrokeStyle(
            when (tool.tool) {
                PenTool.SELECTION, PenTool.ERASE_AREA -> TouchHelper.STROKE_STYLE_DASH                                       // the lasso is a dotted line
                PenTool.FINELINER, PenTool.MECHANICAL_PENCIL -> TouchHelper.STROKE_STYLE_PENCIL   // constant width
                PenTool.MARKER, PenTool.HIGHLIGHTER -> TouchHelper.STROKE_STYLE_MARKER
                PenTool.PENCIL -> TouchHelper.STROKE_STYLE_CHARCOAL
                PenTool.PAINTBRUSH -> TouchHelper.STROKE_STYLE_NEO_BRUSH
                PenTool.CALLIGRAPHY -> TouchHelper.STROKE_STYLE_SQUARE_PEN
                else -> TouchHelper.STROKE_STYLE_FOUNTAIN                                           // ballpoint: pressure-sensitive
            },
        )
        helper.setStrokeColor(previewColor(tool))
    }

    private fun previewColor(spec: PenSpec): Int = when (spec.colorId) {
        1 -> Color.DKGRAY
        3 -> Color.rgb(251, 247, 25)
        4 -> Color.rgb(0, 160, 0)
        5 -> Color.rgb(255, 130, 170)
        6 -> Color.rgb(78, 105, 201)
        7 -> Color.rgb(179, 62, 57)
        else -> Color.BLACK
    }

    /**
     * A quick, tiny pen touch on a button the SDK still let through (it can, for a moment after the layout changes) is a tap on that
     * button, not a dot: pass it to the views and draw nothing.
     */
    private fun tapOnControl(samples: List<PenSample>): Boolean {
        val first = samples.first(); val last = samples.last()
        val extent = kotlin.math.hypot(samples.maxOf { it.x } - samples.minOf { it.x }, samples.maxOf { it.y } - samples.minOf { it.y })
        if (extent > 14f || last.timeMs - first.timeMs > 400) return false
        val slop = 6
        if (excludeRects.none { it.left - slop <= first.x && first.x <= it.right + slop && it.top - slop <= first.y && first.y <= it.bottom + slop }) return false
        post {
            val now = android.os.SystemClock.uptimeMillis()
            val root = rootView
            for (action in intArrayOf(MotionEvent.ACTION_DOWN, MotionEvent.ACTION_UP)) {
                val e = MotionEvent.obtain(now, now + if (action == MotionEvent.ACTION_UP) 40 else 0, action, first.x, first.y, 0)
                e.source = android.view.InputDevice.SOURCE_TOUCHSCREEN
                root.dispatchTouchEvent(e)
                e.recycle()
            }
        }
        return true
    }

    private fun closeHelper() {
        touchHelper?.let { runCatching { it.setRawDrawingEnabled(false); it.closeRawDrawing() } }
        touchHelper = null
    }

    private fun applyEnabled() {
        if (exactMode && useOnyx) {
            // The page is redrawn in small pieces as the pen moves, so the panel stays in a fast update mode while writing is on.
            runCatching { if (penEnabled) EpdController.setViewDefaultUpdateMode(this, com.onyx.android.sdk.api.device.epd.UpdateMode.DU) else EpdController.resetViewUpdateMode(this) }
            return
        }
        val helper = touchHelper ?: return
        runCatching {
            helper.setRawDrawingEnabled(penEnabled)
            // The eraser must not leave ink behind: let the SDK track the pen but draw nothing.
            helper.setRawDrawingRenderEnabled(tool.tool != PenTool.ERASER)
        }
    }

    private fun maxPressure(): Float = runCatching { EpdController.getMaxTouchPressure() }.getOrDefault(4096f).coerceAtLeast(1f)

    private fun toSamples(points: List<TouchPoint>): List<PenSample> {
        val max = maxPressure()
        return points.map { PenSample(it.x, it.y, (it.pressure / max).coerceIn(0f, 1f), it.tiltX.toFloat(), it.tiltY.toFloat(), it.timestamp) }
    }

    private val callback = object : RawInputCallback() {
        override fun onBeginRawDrawing(b: Boolean, p: TouchPoint) { lastPenMs = android.os.SystemClock.uptimeMillis(); beginSelectionDrag(p.x, p.y) }
        override fun onEndRawDrawing(b: Boolean, p: TouchPoint) { lastPenMs = android.os.SystemClock.uptimeMillis(); endSelectionDrag() }
        override fun onRawDrawingTouchPointMoveReceived(p: TouchPoint) { lastPenMs = android.os.SystemClock.uptimeMillis(); moveSelectionDrag(p.x, p.y) }
        override fun onRawDrawingTouchPointListReceived(list: TouchPointList) {
            val samples = toSamples(list.points)
            if (samples.isEmpty()) return
            if (tapOnControl(samples)) return
            when (tool.tool) {
                PenTool.ERASER -> listener.onErase(samples)
                PenTool.SELECTION -> listener.onLasso(samples)
                PenTool.ERASE_AREA -> listener.onEraseArea(samples)
                else -> listener.onStroke(samples)
            }
        }

        override fun onBeginRawErasing(b: Boolean, p: TouchPoint) {}
        override fun onEndRawErasing(b: Boolean, p: TouchPoint) {}
        override fun onRawErasingTouchPointMoveReceived(p: TouchPoint) {}
        // The stylus's own eraser end/button always erases, whatever tool is selected.
        override fun onRawErasingTouchPointListReceived(list: TouchPointList) {
            val samples = toSamples(list.points)
            if (samples.isNotEmpty()) listener.onErase(samples, hardware = true)
        }
    }

    // ---- Fallback for non-Onyx devices ----

    override fun onTouchEvent(event: MotionEvent): Boolean {
        val isFinger = event.getToolType(0) == MotionEvent.TOOL_TYPE_FINGER
        if (!isFinger) lastPenMs = android.os.SystemClock.uptimeMillis()
        // A finger gestures (turns pages, pinches...) unless this is a non-Onyx device with finger drawing switched on.
        if (isFinger && !(fingerDraws && !useOnyx && penEnabled)) {
            fingerGestures.onTouchEvent(event)
            return true
        }
        if (useRaw || !penEnabled) return super.onTouchEvent(event)
        val area = pageArea
        val eraserEnd = event.getToolType(0) == MotionEvent.TOOL_TYPE_ERASER
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> { touchSamples.clear(); liveCount = 0; beginSelectionDrag(event.x, event.y) }
            MotionEvent.ACTION_MOVE -> moveSelectionDrag(event.x, event.y)
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> endSelectionDrag()
        }
        for (i in 0 until event.historySize) addTouch(event.getHistoricalX(i), event.getHistoricalY(i), event.getHistoricalPressure(i), event.getHistoricalEventTime(i), area)
        addTouch(event.x, event.y, event.pressure, event.eventTime, area)
        if (event.actionMasked == MotionEvent.ACTION_MOVE && !dragMode) liveUpdate(eraserEnd)
        if (event.actionMasked == MotionEvent.ACTION_CANCEL) { liveCount = 0; if (liveShown) { liveShown = false; listener.onLiveEnd() } }
        if (event.actionMasked == MotionEvent.ACTION_UP && touchSamples.isNotEmpty()) {
            val done = touchSamples.toList()
            touchSamples.clear()
            if (liveShown) { liveShown = false; listener.onLiveEnd() }
            liveCount = 0
            if (eraserEnd) listener.onErase(done, hardware = true) else when (tool.tool) {
                PenTool.ERASER -> listener.onErase(done)
                PenTool.SELECTION -> listener.onLasso(done)
                PenTool.ERASE_AREA -> listener.onEraseArea(done)
                else -> listener.onStroke(done)
            }
        }
        return true
    }

    // The stroke so far, drawn live in exact mode: at most every [LIVE_INTERVAL_MS], the whole stroke from its start.
    private var liveCount = 0
    private var liveShown = false
    private var lastLiveMs = 0L

    private fun liveUpdate(eraserEnd: Boolean) {
        val erasing = eraserEnd || tool.tool == PenTool.ERASER
        if (!exactMode || (!erasing && (tool.tool == PenTool.SELECTION || tool.tool == PenTool.ERASE_AREA))) return
        val now = android.os.SystemClock.uptimeMillis()
        if (now - lastLiveMs < LIVE_INTERVAL_MS || touchSamples.isEmpty()) return
        lastLiveMs = now
        val snapshot = touchSamples.toList()
        liveShown = true
        if (erasing) listener.onLiveErase(snapshot, liveCount, eraserEnd) else if (snapshot.size >= 2) listener.onLiveStroke(snapshot, liveCount)
        liveCount = snapshot.size
    }

    /**
     * Send just [r] (view px) of the bitmap to the panel. [live] frames of a stroke being written use the fastest update mode (the
     * panel is cleaned up by the final, [live] = false refresh when the pen lifts).
     */
    fun refreshRect(r: Rect?, live: Boolean = false) {
        if (r == null || r.isEmpty) { draw(); return }
        val surface = holder.surface ?: return
        if (!surface.isValid) return
        val bmp = bitmap ?: return
        if (softwareCanvas ?: exactMode.also { softwareCanvas = it }) {
            // Only the rectangle that changed is drawn: the rest of the surface keeps its pixels.
            val dirty = Rect(r)
            val canvas = runCatching { holder.lockCanvas(dirty) }.getOrNull() ?: return
            try { canvas.clipRect(dirty); canvas.drawColor(Color.WHITE); canvas.drawBitmap(bmp, bitmapLeft, 0f, null) } finally { holder.unlockCanvasAndPost(canvas) }
        } else {
            val canvas = lock() ?: return
            try { canvas.drawColor(Color.WHITE); canvas.drawBitmap(bmp, bitmapLeft, 0f, null) } finally { holder.unlockCanvasAndPost(canvas) }
        }
        val mode = if (live) com.onyx.android.sdk.api.device.epd.UpdateMode.ANIMATION else com.onyx.android.sdk.api.device.epd.UpdateMode.DU
        runCatching { EpdController.refreshScreenRegion(this, r.left, r.top, r.width(), r.height(), mode) }
    }

    override fun onHoverEvent(event: MotionEvent): Boolean {
        if (event.getToolType(0) == MotionEvent.TOOL_TYPE_STYLUS) lastPenMs = android.os.SystemClock.uptimeMillis()
        return super.onHoverEvent(event)
    }

    private fun addTouch(x: Float, y: Float, pressure: Float, time: Long, area: Rect?) {
        if (area != null && !area.contains(x.toInt(), y.toInt())) return
        touchSamples += PenSample(x, y, pressure.coerceIn(0f, 1f), 0f, 0f, time)
    }

    // ---- drawing / lifecycle ----

    private fun draw() {
        val holder = holder
        val surface = holder.surface ?: return
        if (!surface.isValid) return
        val canvas = lock() ?: return
        try {
            canvas.drawColor(Color.WHITE)
            bitmap?.let { canvas.drawBitmap(it, bitmapLeft, 0f, null) }
        } finally {
            holder.unlockCanvasAndPost(canvas)
        }
        // Raw-drawing mode keeps its own layer on screen; toggling it makes the panel show our bitmap.
        touchHelper?.let { h ->
            if (penEnabled) runCatching { h.setRawDrawingEnabled(false); h.setRawDrawingEnabled(true) }
        }
    }

    override fun surfaceCreated(holder: SurfaceHolder) { draw() }
    override fun surfaceChanged(holder: SurfaceHolder, format: Int, w: Int, h: Int) {
        if (useRaw) reopenHelper()
        draw()
    }
    override fun surfaceDestroyed(holder: SurfaceHolder) {
        touchHelper?.let { runCatching { it.setRawDrawingEnabled(false); it.closeRawDrawing() } }
        touchHelper = null
    }

    // The firmware's ghost-clear policy (xochitl GhostBuster / ScreenDriver): a flashing refresh on the next frame after a pan, zoom,
    // selection drag or shape preview, after any dialog, overview or settings page opens or closes, on the first page of a
    // document, and on a page turn after 30 s on the previous page. There is no stroke counter.
    private var lastClearMs = android.os.SystemClock.uptimeMillis()
    private val clearRunnable = Runnable {
        // Wait while the pen is still near the screen (the firmware delays its hold phase the same way).
        if (android.os.SystemClock.uptimeMillis() - lastPenMs < PEN_QUIET_MS) scheduleClear() else fullRefresh()
    }

    /** Flash-clear the panel soon (once the pen is away); repeated calls collapse into one. */
    fun scheduleClear(delayMs: Long = CLEAR_DELAY_MS) { removeCallbacks(clearRunnable); postDelayed(clearRunnable, delayMs) }

    /** A page was turned (or the document was just opened): clear after 30 s on the previous page, and on the first page. */
    fun pageTurned(first: Boolean = false) {
        if (first || android.os.SystemClock.uptimeMillis() - lastClearMs >= LONG_STAY_MS) scheduleClear(0L)
    }

    // Coloured, grey and highlighter strokes are drawn fast (black and white) while the pen moves, then re-rendered at quality
    // 1000 ms after the last one (the firmware's viewportUpdateTimer).
    private val qualityRect = Rect()
    private val qualityRunnable = Runnable {
        if (android.os.SystemClock.uptimeMillis() - lastPenMs < QUALITY_PEN_QUIET_MS) { postQuality(); return@Runnable }
        val r = Rect(qualityRect); qualityRect.setEmpty()
        if (!r.isEmpty) runCatching { EpdController.refreshScreenRegion(this, r.left, r.top, r.width(), r.height(), com.onyx.android.sdk.api.device.epd.UpdateMode.GU) }
    }
    private fun postQuality() { removeCallbacks(qualityRunnable); postDelayed(qualityRunnable, QUALITY_DELAY_MS) }

    /** [r] (view px) holds a coloured stroke: repaint it at quality after the pen has been idle for a second. */
    fun scheduleQuality(r: Rect?) {
        if (r == null || r.isEmpty) return
        if (qualityRect.isEmpty) qualityRect.set(r) else qualityRect.union(r)
        postQuality()
    }

    /** Clear e-ink ghosting with a full-quality refresh of the panel. */
    fun fullRefresh() {
        lastClearMs = android.os.SystemClock.uptimeMillis()
        runCatching { EpdController.refreshScreen(this, com.onyx.android.sdk.api.device.epd.UpdateMode.GC) }
    }

    /** Pause/resume raw drawing with the activity (the panel must be released when we're not on screen). */
    fun onPause() { touchHelper?.let { runCatching { it.setRawDrawingEnabled(false) } } }
    fun onResume() { applyEnabled() }

    private companion object {
        const val MIN_ZOOM = 0.5f
        const val MAX_ZOOM = 5f
        const val PREVIEW_INTERVAL_MS = 45L
        const val LIVE_INTERVAL_MS = 24L
        const val CLEAR_DELAY_MS = 700L
        const val LONG_STAY_MS = 30_000L
        const val PEN_QUIET_MS = 500L
        const val QUALITY_DELAY_MS = 1000L
        const val QUALITY_PEN_QUIET_MS = 100L
    }
}
