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
    fun onErase(samples: List<PenSample>)
    /** A finger swiped across the page: [forward] = towards the next page. */
    fun onSwipe(forward: Boolean) {}
    /** A stroke made with the selection tool (a lasso, or a drag of the current selection). */
    fun onLasso(samples: List<PenSample>) {}
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
    private var bitmapLeft = 0f

    private var touchHelper: TouchHelper? = null
    private val useOnyx = Build.MANUFACTURER.equals("onyx", ignoreCase = true) || Build.BRAND.equals("onyx", ignoreCase = true)

    var penEnabled = false
        set(value) { field = value; applyEnabled() }

    /** Finger swipes left/right turn pages (reported through [PenListener.onSwipe]). */
    var swipeEnabled = true

    /** Let a finger draw as well; only honoured on non-Onyx devices (on a BOOX the stylus draws, the finger swipes). */
    var fingerDraws = false

    private val gestures = android.view.GestureDetector(context, object : android.view.GestureDetector.SimpleOnGestureListener() {
        override fun onFling(e1: MotionEvent?, e2: MotionEvent, vx: Float, vy: Float): Boolean {
            if (!swipeEnabled || e1 == null) return false
            val dx = e2.x - e1.x
            val dy = e2.y - e1.y
            // A deliberate, mostly horizontal swipe.
            if (kotlin.math.abs(dx) > width * 0.18f && kotlin.math.abs(dx) > kotlin.math.abs(dy) * 1.6f) {
                listener.onSwipe(forward = dx < 0)
                return true
            }
            return false
        }
    })

    // Pinch to zoom and drag with two fingers to pan: reported once, when the fingers lift (e-ink can't follow a live zoom).
    private var gestureScale = 1f
    private var gestureFocusX = 0f
    private var gestureFocusY = 0f
    private var gesturePanX = 0f
    private var gesturePanY = 0f
    private var lastFocusX = 0f
    private var lastFocusY = 0f
    private var multiTouch = false
    private val scaleDetector = android.view.ScaleGestureDetector(context, object : android.view.ScaleGestureDetector.SimpleOnScaleGestureListener() {
        override fun onScaleBegin(d: android.view.ScaleGestureDetector): Boolean {
            gestureScale = 1f; gesturePanX = 0f; gesturePanY = 0f
            gestureFocusX = d.focusX; gestureFocusY = d.focusY; lastFocusX = d.focusX; lastFocusY = d.focusY
            return true
        }
        override fun onScale(d: android.view.ScaleGestureDetector): Boolean {
            gestureScale *= d.scaleFactor
            gesturePanX += d.focusX - lastFocusX; gesturePanY += d.focusY - lastFocusY
            lastFocusX = d.focusX; lastFocusY = d.focusY
            return true
        }
        override fun onScaleEnd(d: android.view.ScaleGestureDetector) {
            if (kotlin.math.abs(gestureScale - 1f) > 0.04f || kotlin.math.hypot(gesturePanX, gesturePanY) > 24f) {
                listener.onViewGesture(gestureScale, gestureFocusX, gestureFocusY, gesturePanX, gesturePanY)
            }
        }
    })

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
    fun setPageArea(rect: Rect) {
        pageArea = rect
        if (width > 0 && useOnyx) reopenHelper()
    }
    private var pageArea: Rect? = null

    // ---- Onyx raw drawing ----

    private fun reopenHelper() {
        touchHelper?.let { runCatching { it.closeRawDrawing() } }
        touchHelper = null
        val limit = pageArea ?: Rect(0, 0, width, height)
        if (limit.isEmpty) return
        val helper = TouchHelper.create(this, callback)
        helper.setStrokeWidth(3f).setLimitRect(limit, emptyList()).openRawDrawing()
        applyToolToHelper(helper)
        touchHelper = helper
        applyEnabled()
    }

    private fun applyToolToHelper(helper: TouchHelper) {
        val widthPx = when (tool.tool) {
            PenTool.HIGHLIGHTER -> 15f
            PenTool.SELECTION -> 2f
            else -> 2f * tool.thickness
        } * pageScale
        helper.setStrokeWidth(widthPx.coerceAtLeast(1f))
        // Live preview style only (what is saved comes from our own pen model). Guesses; tune on the device.
        helper.setStrokeStyle(
            when (tool.tool) {
                PenTool.FINELINER, PenTool.MECHANICAL_PENCIL, PenTool.SELECTION -> TouchHelper.STROKE_STYLE_PENCIL   // constant width
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

    private fun applyEnabled() {
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
        override fun onBeginRawDrawing(b: Boolean, p: TouchPoint) {}
        override fun onEndRawDrawing(b: Boolean, p: TouchPoint) {}
        override fun onRawDrawingTouchPointMoveReceived(p: TouchPoint) {}
        override fun onRawDrawingTouchPointListReceived(list: TouchPointList) {
            val samples = toSamples(list.points)
            if (samples.isEmpty()) return
            when (tool.tool) {
                PenTool.ERASER -> listener.onErase(samples)
                PenTool.SELECTION -> listener.onLasso(samples)
                else -> listener.onStroke(samples)
            }
        }

        override fun onBeginRawErasing(b: Boolean, p: TouchPoint) {}
        override fun onEndRawErasing(b: Boolean, p: TouchPoint) {}
        override fun onRawErasingTouchPointMoveReceived(p: TouchPoint) {}
        // The stylus's own eraser end/button always erases, whatever tool is selected.
        override fun onRawErasingTouchPointListReceived(list: TouchPointList) {
            val samples = toSamples(list.points)
            if (samples.isNotEmpty()) listener.onErase(samples)
        }
    }

    // ---- Fallback for non-Onyx devices ----

    override fun onTouchEvent(event: MotionEvent): Boolean {
        val isFinger = event.getToolType(0) == MotionEvent.TOOL_TYPE_FINGER
        // A finger swipes (turns pages) unless this is a non-Onyx device with finger drawing switched on.
        if (isFinger && !(fingerDraws && !useOnyx && penEnabled)) {
            scaleDetector.onTouchEvent(event)
            if (event.pointerCount > 1 || scaleDetector.isInProgress) multiTouch = true
            // A pinch or two-finger drag must not also count as a page-turning swipe.
            if (!multiTouch) gestures.onTouchEvent(event)
            if (event.actionMasked == MotionEvent.ACTION_UP || event.actionMasked == MotionEvent.ACTION_CANCEL) multiTouch = false
            return true
        }
        if (useOnyx || !penEnabled) return super.onTouchEvent(event)
        val area = pageArea
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> touchSamples.clear()
        }
        for (i in 0 until event.historySize) addTouch(event.getHistoricalX(i), event.getHistoricalY(i), event.getHistoricalPressure(i), event.getHistoricalEventTime(i), area)
        addTouch(event.x, event.y, event.pressure, event.eventTime, area)
        if (event.actionMasked == MotionEvent.ACTION_UP && touchSamples.isNotEmpty()) {
            val done = touchSamples.toList()
            touchSamples.clear()
            when (tool.tool) {
                PenTool.ERASER -> listener.onErase(done)
                PenTool.SELECTION -> listener.onLasso(done)
                else -> listener.onStroke(done)
            }
        }
        return true
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
        val canvas = runCatching { holder.lockCanvas() }.getOrNull() ?: return
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
        if (useOnyx) reopenHelper()
        draw()
    }
    override fun surfaceDestroyed(holder: SurfaceHolder) {
        touchHelper?.let { runCatching { it.setRawDrawingEnabled(false); it.closeRawDrawing() } }
        touchHelper = null
    }

    /** Clear e-ink ghosting with a full-quality refresh of the panel. */
    fun fullRefresh() {
        runCatching { EpdController.refreshScreen(this, com.onyx.android.sdk.api.device.epd.UpdateMode.GC) }
    }

    /** Pause/resume raw drawing with the activity (the panel must be released when we're not on screen). */
    fun onPause() { touchHelper?.let { runCatching { it.setRawDrawingEnabled(false) } } }
    fun onResume() { applyEnabled() }
}
