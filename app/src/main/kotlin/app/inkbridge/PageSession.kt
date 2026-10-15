package app.inkbridge

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import app.inkbridge.pen.PenSample
import app.inkbridge.rm.edit.InputPoint
import app.inkbridge.rm.edit.PageEditor
import app.inkbridge.rm.edit.PageTransform
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.edit.SelectionGesture
import app.inkbridge.rm.export.PageExport
import app.inkbridge.rm.export.SvgCanvas
import app.inkbridge.rm.library.PageFiles
import app.inkbridge.rm.render.PageTemplate
import app.inkbridge.rm.render.PixelInk
import app.inkbridge.rm.scene.CrdtId
import android.graphics.DashPathEffect
import android.graphics.RectF as AndroidRectF
import android.graphics.pdf.PdfDocument
import java.io.File
import kotlin.math.roundToInt

/**
 * One open page: the editable model, the on-screen bitmap, and the screen↔page mapping.
 * Pen callbacks may arrive on a non-UI thread, so everything that touches state is synchronized.
 */
class PageSession(
    private val file: File,
    private val background: PdfBackground? = null,
    private val template: PageTemplate = PageTemplate.BLANK,
) {
    private val editor: PageEditor = if (file.isFile) PageEditor.fromBytes(file.readBytes()) else PageEditor.blank()

    var transform: PageTransform? = null
        private set
    var bitmap: Bitmap? = null
        private set

    // The strokes are drawn pixel by pixel with the firmware's pen renderer into [ink]; [basePx] is the page under them
    // (paper, template, PDF, text), and the shown bitmap is the two together.
    private var ink: PixelInk? = null
    private var basePx: IntArray? = null
    private var shownPx: IntArray? = null

    /** The PDF page under the ink (rendered for the current view size), or null for plain pages. */
    private var backgroundBitmap: Bitmap? = null

    val isDirty: Boolean @Synchronized get() = editor.isDirty
    val canUndo: Boolean @Synchronized get() = editor.canUndo
    val canRedo: Boolean @Synchronized get() = editor.canRedo

    // ---- the view: the bitmap is as big as the view, and the page is placed (and zoomed) inside it ----

    private var viewW = 0
    private var viewH = 0
    private var panX = 0f
    private var panY = 0f
    private var zoomLevel = 1f
    private var renderedBackgroundWidth = 0

    /** [basePx] holds the paper, template, PDF and text for the current view; only a change of view or background invalidates it, not strokes. */
    private var baseValid = false

    /** The zoom level (1 = the whole page fits the view). */
    val zoom: Float @Synchronized get() = zoomLevel

    /** A zoom and pan the user chose by pinching, so "Fit to custom view" can come back to it. */
    @Volatile var customView: Triple<Float, Float, Float>? = null
        private set

    /** Size the view to [width] x [height] px and redraw the page. */
    @Synchronized
    fun resize(width: Int, height: Int) {
        if (width <= 0 || height <= 0) return
        viewW = width; viewH = height
        rebuild(newBitmap = true)
    }

    private fun rebuild(newBitmap: Boolean) {
        val layout = editor.renderer.layout
        val t = PageTransform(layout, viewW.toFloat(), viewH.toFloat(), zoomLevel, panX, panY)
        transform = t
        zoomLevel = t.zoom; panX = t.offsetX; panY = t.offsetY
        // Not recycled when replaced: the surface may still be showing the previous bitmap; the GC frees it.
        if (newBitmap || bitmap == null) bitmap = Bitmap.createBitmap(viewW, viewH, Bitmap.Config.ARGB_8888)
        // A PDF page is rendered at the on-screen size, but never wider than 2600 px (zoomed far in it is scaled up instead).
        // The render is kept while the zoom moves a little (it is scaled to fit); a new one is made when it would look soft or wasteful.
        val wanted = background?.let { (it.placement.width * t.scale).coerceAtMost(2600f).roundToInt() } ?: 0
        if (background != null && (backgroundBitmap == null || wanted > renderedBackgroundWidth * 1.05f || wanted < renderedBackgroundWidth * 0.55f)) {
            backgroundBitmap = background.render(wanted)
            renderedBackgroundWidth = wanted
        }
        baseValid = false
        redrawAll()
    }

    private fun applyView(t: PageTransform) {
        zoomLevel = t.zoom; panX = t.offsetX; panY = t.offsetY
        rebuild(newBitmap = false)
    }

    /** A pinch / two-finger drag finished: zoom by [factor] around ([fx], [fy]), then pan by ([dx], [dy]) view pixels. */
    @Synchronized
    fun viewGesture(factor: Float, fx: Float, fy: Float, dx: Float, dy: Float) {
        val t = transform ?: return
        val next = t.zoomedAround(t.zoom * factor, fx, fy).pannedBy(dx, dy)
        customView = Triple(next.zoom, next.offsetX, next.offsetY)
        fitMode = null
        applyView(next)
    }

    /** The "jump" gesture: scroll a screen up or down inside a zoomed page. False when the page can't move that way. */
    @Synchronized
    fun jump(down: Boolean): Boolean {
        val t = transform ?: return false
        if (t.zoom <= 1.01f) return false
        val next = t.pannedBy(0f, if (down) -t.viewHeight * 0.85f else t.viewHeight * 0.85f)
        if (next.offsetY == t.offsetY) return false
        applyView(next)
        return true
    }

    /** Which "Adjust view" mode the view is in: "width", "height", "custom", or null after a pinch or a reset. */
    @Volatile var fitMode: String? = null
        private set

    @Synchronized fun fitPage() { val t = transform ?: return; fitMode = null; applyView(PageTransform(t.layout, t.viewWidth, t.viewHeight)) }
    @Synchronized fun fitWidth() { val t = transform ?: return; fitMode = "width"; applyView(t.fitWidth()) }
    @Synchronized fun fitHeight() { val t = transform ?: return; fitMode = "height"; applyView(t.fitHeight()) }

    /** Go back to the zoom and pan the user last chose by pinching. */
    @Synchronized
    fun fitCustom() {
        val (z, x, y) = customView ?: return
        val t = transform ?: return
        fitMode = "custom"
        applyView(PageTransform(t.layout, t.viewWidth, t.viewHeight, z, x, y))
    }

    // ---- selection (the lasso tool) ----

    private var selection: Set<CrdtId> = emptySet()

    val hasSelection: Boolean @Synchronized get() = selection.isNotEmpty()

    /**
     * A pen stroke made with the selection tool. A stroke that starts inside the current selection drags it; any other
     * stroke is a lasso that replaces the selection. Returns true if the page or the selection changed.
     */
    @Synchronized
    fun selectionStroke(samples: List<PenSample>): Boolean {
        val t = transform ?: return false
        val extent = if (samples.size < 2) 0f else kotlin.math.hypot(samples.maxOf { it.x } - samples.minOf { it.x }, samples.maxOf { it.y } - samples.minOf { it.y })
        if (extent < 16f) {
            // A tap: it ends the selection, or (nothing selected, something copied) pastes the clipboard there.
            val at = samples.firstOrNull()
            if (selection.isEmpty() && at != null && StrokeClipboard.hasContent) return pasteAt(at.x, at.y)
            val had = selection.isNotEmpty(); selection = emptySet(); if (had) redrawAll(); return had
        }
        val frame = selectionFrame()
        if (frame != null) {
            val first = samples.first(); val last = samples.last()
            val hit = SelectionGesture.hit(frame, first.x, first.y)
            if (hit.mode != SelectionGesture.Mode.NONE) {
                val m = SelectionGesture.transform(hit, first.x, first.y, last.x, last.y)
                // Too short to be a deliberate move: leave the selection as it is.
                if (kotlin.math.hypot(last.x - first.x, last.y - first.y) > 8f * t.scale) {
                    val o = viewOrigin(t)
                    editor.transformStrokes(selection, SelectionGesture.viewToPage(m, t.scale, o.first, o.second))
                    redrawAll()
                }
                return true
            }
        }
        selection = editor.selectInside(samples.map { t.toPageX(it.x) to t.toPageY(it.y) })
        redrawAll()
        return true
    }

    /** `view = scale * page + origin` for the current transform. */
    private fun viewOrigin(t: PageTransform) = (t.offsetX - t.scale * t.layout.xMin) to (t.offsetY - t.scale * t.layout.yMin)

    /** The selection's frame in view pixels (the dashed rectangle, with a little room), or null when nothing is selected. */
    @Synchronized
    fun selectionFrame(): SelectionGesture.Frame? {
        val t = transform ?: return null
        val b = (if (selection.isEmpty()) null else editor.boundsOf(selection)) ?: return null
        val pad = 14f
        var l = t.toViewX(b.left - pad); var tp = t.toViewY(b.top - pad); var r = t.toViewX(b.right + pad); var bt = t.toViewY(b.bottom + pad)
        // As in the firmware, the frame is never smaller than 100 px, so a small selection's handles don't cover it.
        val min = 100f
        if (r - l < min) { val c = (l + r) / 2; l = c - min / 2; r = c + min / 2 }
        if (bt - tp < min) { val c = (tp + bt) / 2; tp = c - min / 2; bt = c + min / 2 }
        return SelectionGesture.Frame(l, tp, r, bt)
    }

    /** The selection's bounds in view pixels, or null when nothing is selected. */
    @Synchronized
    fun selectionRect(): AndroidRectF? {
        val t = transform ?: return null
        val b = (if (selection.isEmpty()) null else editor.boundsOf(selection)) ?: return null
        return AndroidRectF(t.toViewX(b.left), t.toViewY(b.top), t.toViewX(b.right), t.toViewY(b.bottom))
    }

    @Synchronized fun clearSelection() { if (selection.isNotEmpty()) { selection = emptySet(); redrawAll() } }

    @Synchronized
    fun deleteSelection(): Boolean {
        val n = editor.deleteStrokes(selection)
        selection = emptySet()
        redrawAll()
        return n > 0
    }

    /** Copy the selected strokes a little down and to the right and select the copies. */
    @Synchronized
    fun duplicateSelection(): Boolean {
        val copies = editor.duplicateStrokes(selection, 40f, 40f)
        if (copies.isEmpty()) return false
        selection = copies
        redrawAll()
        return true
    }

    @Synchronized
    fun copySelection(): Boolean {
        if (selection.isEmpty()) return false
        val lines = editor.copyStrokes(selection)
        if (lines.isEmpty()) return false
        StrokeClipboard.lines = lines
        // As on the tablet, copying ends the selection; the strokes are pasted by tapping the page with the selection tool.
        selection = emptySet()
        redrawAll()
        return true
    }

    @Synchronized
    fun cutSelection(): Boolean {
        val ids = selection
        if (!copySelection()) return false
        editor.deleteStrokes(ids)
        redrawAll()
        return true
    }

    /** Paste the clipboard onto the current layer with its centre at the view point ([x], [y]); selects the pasted strokes. */
    @Synchronized
    fun pasteAt(x: Float, y: Float): Boolean {
        val t = transform ?: return false
        val pts = StrokeClipboard.lines.flatMap { it.points }
        if (pts.isEmpty()) return false
        val cx = (pts.minOf { it.x } + pts.maxOf { it.x }) / 2; val cy = (pts.minOf { it.y } + pts.maxOf { it.y }) / 2
        val ids = editor.pasteStrokes(StrokeClipboard.lines, t.toPageX(x) - cx, t.toPageY(y) - cy)
        if (ids.isEmpty()) return false
        selection = ids
        redrawAll()
        return true
    }

    /** Paste the clipboard a little down and to the right of where it was copied (used by tests and menus). */
    @Synchronized
    fun pasteClipboard(): Boolean {
        val ids = editor.pasteStrokes(StrokeClipboard.lines, 40f, 40f)
        if (ids.isEmpty()) return false
        selection = ids
        redrawAll()
        return true
    }

    /** "Select below": select everything on the page that lies under the view-pixel line at [y]. */
    @Synchronized
    fun selectBelow(y: Float): Boolean {
        val t = transform ?: return false
        val py = t.toPageY(y); val l = t.layout
        val ids = editor.selectInside(listOf(l.xMin to py, l.xMax to py, l.xMax to l.yMax, l.xMin to l.yMax))
        if (ids.isEmpty()) return false
        selection = ids
        redrawAll()
        return true
    }

    /** The "Erase selection" tool: erase the strokes a lasso encloses. */
    @Synchronized
    fun eraseInside(samples: List<PenSample>): Boolean {
        val t = transform ?: return false
        val ids = editor.selectInside(samples.map { t.toPageX(it.x) to t.toPageY(it.y) })
        if (editor.deleteStrokes(ids) == 0) return false
        redrawAll()
        return true
    }

    /** "Erase all strokes": the current layer only. */
    @Synchronized
    fun eraseCurrentLayer(): Boolean {
        if (editor.eraseCurrentLayer() == 0) return false
        selection = emptySet()
        redrawAll()
        return true
    }

    // ---- layers ----

    @Synchronized fun layers(): List<PageEditor.LayerInfo> = editor.layers()
    @Synchronized fun addLayer(label: String) { editor.addLayer(label); redrawAll() }
    @Synchronized fun selectLayer(id: CrdtId) { editor.setCurrentLayer(id); redrawAll() }
    @Synchronized fun setLayerVisible(id: CrdtId, visible: Boolean) { editor.setLayerVisible(id, visible); redrawAll() }
    @Synchronized fun renameLayer(id: CrdtId, label: String) { editor.renameLayer(id, label); redrawAll() }
    @Synchronized fun moveLayer(id: CrdtId, up: Boolean): Boolean = editor.moveLayer(id, up).also { if (it) redrawAll() }
    @Synchronized fun mergeLayerDown(id: CrdtId): Boolean = editor.mergeLayerDown(id).also { if (it) { selection = emptySet(); redrawAll() } }
    @Synchronized fun backgroundVisible(): Boolean = editor.backgroundVisible
    @Synchronized fun setBackgroundVisible(v: Boolean) { editor.setBackgroundVisible(v); baseValid = false; redrawAll() }
    @Synchronized fun deleteLayer(id: CrdtId): Boolean = editor.deleteLayer(id).also { if (it) { selection = emptySet(); redrawAll() } }

    /** Add a stroke from view-pixel [samples]. Returns true if the page changed. */
    @Synchronized
    fun addStroke(spec: PenSpec, samples: List<PenSample>, select: Boolean = false): Boolean {
        val t = transform ?: return false
        lastStrokeRect = null
        val added = editor.addStroke(spec, samples.map { toInput(t, it) }) ?: return false
        if (select) { selection = setOf(added.itemId); redrawAll(); return true }
        val layer = ink; val base = basePx; val shown = shownPx; val bmp = bitmap; val tf = inkTransform()
        if (layer == null || base == null || shown == null || bmp == null || tf == null) { redrawAll(); return true }
        layer.drawLine(added.line, added.ox, added.oy, tf)
        if (layer.isDirty) {
            val l = layer.dirtyLeft; val tp = layer.dirtyTop; val r = layer.dirtyRight + 1; val b = layer.dirtyBottom + 1
            lastStrokeRect = android.graphics.Rect(l, tp, r, b)
            layer.compositeInto(base, shown, l, tp, r, b)
            bmp.setPixels(shown, tp * bmp.width + l, bmp.width, l, tp, r - l, b - tp)
            layer.resetDirty()
        }
        return true
    }

    // ---- the stroke being written (drawn live with the firmware pen renderer while the pen is still down) ----

    private var liveInk: PixelInk? = null
    private var liveOut: IntArray? = null
    private var liveBounds: android.graphics.Rect? = null

    /**
     * Draw the stroke written so far ([samples], view px) over the page without adding it. Returns the view rectangle the panel must
     * refresh: around the points from [from] on (the part that is new), or null if nothing was drawn.
     */
    @Synchronized
    fun previewStroke(spec: PenSpec, samples: List<PenSample>, from: Int): android.graphics.Rect? {
        val t = transform ?: return null
        val bmp = bitmap ?: return null
        val shown = shownPx ?: return null
        val tf = inkTransform() ?: return null
        if (samples.size < 2) return null
        val added = editor.previewLine(spec, samples.map { toInput(t, it) }) ?: return null
        val w = bmp.width; val h = bmp.height
        val live = (if (liveInk?.width == w && liveInk?.height == h) liveInk else null) ?: PixelInk(w, h).also { liveInk = it }
        val out = (if (liveOut?.size == w * h) liveOut else null) ?: IntArray(w * h).also { liveOut = it }
        // Take back what the previous frame drew, then draw the stroke from the start (so joins and caps are exactly the firmware's).
        liveBounds?.let { b -> live.clearRect(b.left, b.top, b.right, b.bottom) }
        live.resetDirty()
        live.drawLine(added.line, added.ox, added.oy, tf)
        if (!live.isDirty) return null
        val now = android.graphics.Rect(live.dirtyLeft, live.dirtyTop, live.dirtyRight + 1, live.dirtyBottom + 1)
        val union = android.graphics.Rect(now).also { r -> liveBounds?.let { r.union(it) } }
        live.compositeInto(shown, out, union.left, union.top, union.right, union.bottom)
        bmp.setPixels(out, union.top * w + union.left, w, union.left, union.top, union.width(), union.height())
        liveBounds = now
        // The panel only needs the newest part: the points since the last frame, padded by the pen's width.
        var l = Float.MAX_VALUE; var tp = Float.MAX_VALUE; var r = -Float.MAX_VALUE; var b = -Float.MAX_VALUE
        for (i in (from - 3).coerceAtLeast(0) until samples.size) { l = minOf(l, samples[i].x); r = maxOf(r, samples[i].x); tp = minOf(tp, samples[i].y); b = maxOf(b, samples[i].y) }
        val pad = (spec.thickness * 8f + 12f) * t.scale + 6f
        return android.graphics.Rect((l - pad).toInt(), (tp - pad).toInt(), (r + pad).toInt() + 1, (b + pad).toInt() + 1).also { it.intersect(0, 0, w, h) }
    }

    /** Remove the live stroke from the picture (the finished stroke is added next, or the gesture was cancelled). */
    @Synchronized
    fun endPreview(): android.graphics.Rect? {
        val b = liveBounds ?: return null
        liveBounds = null
        val bmp = bitmap ?: return null
        val shown = shownPx ?: return null
        liveInk?.clearRect(b.left, b.top, b.right, b.bottom)
        liveInk?.resetDirty()
        val w = bmp.width
        bmp.setPixels(shown, b.top * w + b.left, w, b.left, b.top, b.width(), b.height())
        return b
    }

    /** The view rectangle [addStroke] last changed on the bitmap (for refreshing just that part of the panel). */
    @Volatile private var lastStrokeRect: android.graphics.Rect? = null

    /** The rectangle the last [addStroke] changed (once); null after any other edit, meaning the whole page may have changed. */
    fun takeStrokeRect(): android.graphics.Rect? = lastStrokeRect.also { lastStrokeRect = null }

    /** Erase strokes touched by the dragged view-pixel [samples]. Returns true if anything was erased. */
    @Synchronized
    fun erase(samples: List<PenSample>, radiusPx: Float): Boolean {
        val t = transform ?: return false
        val path = samples.map { t.toPageX(it.x) to t.toPageY(it.y) }
        if (editor.eraseAlong(path, radiusPx * t.pagePerPixel()) == 0) return false
        redrawAll()
        return true
    }

    /** Erase every stroke on the page. Returns true if anything was erased. */
    @Synchronized
    fun eraseAll(): Boolean {
        if (editor.eraseAll() == 0) return false
        redrawAll()
        return true
    }

    @Synchronized fun undo(): Boolean = editor.undo().also { if (it) { selection = emptySet(); redrawAll() } }
    @Synchronized fun redo(): Boolean = editor.redo().also { if (it) { selection = emptySet(); redrawAll() } }

    /** Write the page to its file (keeping a one-time `.orig` backup). No-op when nothing changed. */
    @Synchronized
    fun save() {
        if (!editor.isDirty) return
        PageFiles.save(file, editor.toBytes())
        editor.markSaved()
    }

    /**
     * Export the page as `<baseName>.svg`, `.png` and `.pdf` into [dir]. SVG and PDF are vector;
     * PNG is 1 pixel per page unit. Returns the files written.
     */
    @Synchronized
    fun export(dir: File, baseName: String): List<File> {
        dir.mkdirs()
        val renderer = editor.renderer
        val layout = renderer.layout

        // The PDF page (if any) at 1 pixel per page unit; used by all three formats.
        val showBackground = editor.backgroundVisible
        val pl = background?.placement
        val bg = if (showBackground) background?.render(pl!!.width.roundToInt()) else null
        fun drawBackground(c: Canvas) {
            if (bg != null && pl != null) c.drawBitmap(bg, null, RectF(pl.left, pl.top, pl.left + pl.width, pl.top + pl.height), Paint(Paint.FILTER_BITMAP_FLAG))
        }

        val svgBackground = if (bg != null && pl != null) {
            val png = java.io.ByteArrayOutputStream().also { bg.compress(Bitmap.CompressFormat.PNG, 100, it) }.toByteArray()
            SvgCanvas.Background(png, pl.left, pl.top, pl.width, pl.height)
        } else null
        val svg = File(dir, "$baseName.svg").also { it.writeText(PageExport.svg(renderer, svgBackground, template.takeIf { background == null && showBackground })) }

        val png = File(dir, "$baseName.png")
        val full = Bitmap.createBitmap(layout.width.toInt(), layout.height.toInt(), Bitmap.Config.ARGB_8888)
        Canvas(full).also { c ->
            c.drawColor(Color.WHITE)
            c.translate(-layout.xMin, -layout.yMin)
            drawBackground(c)
            if (background == null && showBackground) template.draw(AndroidPageCanvas(c), layout)
            renderer.render(AndroidPageCanvas(c), strokes = false)
        }
        // The strokes go on with the tablet's pen renderer, one device pixel per page unit.
        run {
            val w = full.width; val h = full.height
            val base = IntArray(w * h).also { full.getPixels(it, 0, w, 0, 0, w, h) }
            val layer = PixelInk(w, h).also { renderer.renderInk(it, PixelInk.Transform(1f, -layout.xMin, -layout.yMin)) }
            val out = IntArray(w * h)
            layer.compositeInto(base, out, 0, 0, w, h)
            full.setPixels(out, 0, w, 0, 0, w, h)
        }
        png.outputStream().use { full.compress(Bitmap.CompressFormat.PNG, 100, it) }
        full.recycle()

        val pdf = File(dir, "$baseName.pdf")
        val pt = 72f / 226f // page units are ~226 dpi
        val doc = PdfDocument()
        try {
            val page = doc.startPage(PdfDocument.PageInfo.Builder((layout.width * pt).toInt(), (layout.height * pt).toInt(), 1).create())
            page.canvas.drawColor(Color.WHITE)
            page.canvas.scale(pt, pt)
            page.canvas.translate(-layout.xMin, -layout.yMin)
            drawBackground(page.canvas)
            if (background == null && showBackground) template.draw(AndroidPageCanvas(page.canvas), layout)
            renderer.render(AndroidPageCanvas(page.canvas))
            doc.finishPage(page)
            pdf.outputStream().use { doc.writeTo(it) }
        } finally {
            doc.close()
        }
        return listOf(svg, png, pdf)
    }

    private fun toInput(t: PageTransform, s: PenSample) = InputPoint(
        x = t.toPageX(s.x), y = t.toPageY(s.y), pressure = s.pressure,
        tiltX = s.tiltX, tiltY = s.tiltY, timeMs = s.timeMs,
    )

    private fun redrawAll() {
        val bmp = bitmap ?: return
        val w = bmp.width; val h = bmp.height
        val base = (if (basePx?.size == w * h) basePx else null) ?: IntArray(w * h).also { basePx = it; baseValid = false }
        if (!baseValid) {
            withPageCanvas(clear = true) { canvas ->
                val bg = backgroundBitmap
                val p = background?.placement
                val showBackground = editor.backgroundVisible
                if (bg != null && p != null && showBackground) {
                    canvas.drawBitmap(bg, null, RectF(p.left, p.top, p.left + p.width, p.top + p.height), Paint(Paint.FILTER_BITMAP_FLAG))
                }
                if (background == null && showBackground) template.draw(AndroidPageCanvas(canvas), editor.renderer.layout)
                editor.renderer.render(AndroidPageCanvas(canvas), strokes = false)
            }
            bmp.getPixels(base, 0, w, 0, 0, w, h)
            baseValid = true
        }
        if (selection.isNotEmpty() && editor.boundsOf(selection) == null) selection = emptySet()
        val layer = (if (ink?.width == w && ink?.height == h) ink else null) ?: PixelInk(w, h).also { ink = it }
        layer.clear()
        val tf = inkTransform() ?: return
        editor.renderer.renderInk(layer, tf)
        val shown = (if (shownPx?.size == w * h) shownPx else null) ?: IntArray(w * h).also { shownPx = it }
        layer.compositeInto(base, shown, 0, 0, w, h)
        bmp.setPixels(shown, 0, w, 0, 0, w, h)
        layer.resetDirty()
        drawSelectionFrame()
    }

    /** Page units to view pixels, for the pen renderer. */
    private fun inkTransform(): PixelInk.Transform? {
        val t = transform ?: return null
        return PixelInk.Transform(t.scale, t.offsetX - t.layout.xMin * t.scale, t.offsetY - t.layout.yMin * t.scale)
    }

    /** The selection: a solid 2 px frame with white square handles on the corners and a white circle on the middle of the top edge (as in the firmware). */
    private fun drawSelectionFrame() {
        val bmp = bitmap ?: return
        val f = selectionFrame() ?: return
        val canvas = Canvas(bmp)
        val border = Paint().apply { style = Paint.Style.STROKE; color = Color.BLACK; strokeWidth = 2f }
        val fill = Paint().apply { style = Paint.Style.FILL; color = Color.WHITE }
        canvas.drawRect(f.left, f.top, f.right, f.bottom, border)
        val half = SelectionGesture.HANDLE_SIZE / 2
        for ((x, y) in f.corners()) {
            canvas.drawRect(x - half, y - half, x + half, y + half, fill); canvas.drawRect(x - half, y - half, x + half, y + half, border)
        }
        val (rx, ry) = f.rotateHandle(SelectionGesture.ROTATE_OFFSET)
        canvas.drawCircle(rx, ry, SelectionGesture.ROTATE_SIZE / 2, fill); canvas.drawCircle(rx, ry, SelectionGesture.ROTATE_SIZE / 2, border)
    }

    private fun withPageCanvas(clear: Boolean = false, draw: (Canvas) -> Unit) {
        val bmp = bitmap ?: return
        val t = transform ?: return
        val canvas = Canvas(bmp)
        if (clear) canvas.drawColor(Color.WHITE)
        canvas.translate(t.offsetX, t.offsetY)
        canvas.scale(t.scale, t.scale)
        canvas.translate(-t.layout.xMin, -t.layout.yMin)
        draw(canvas)
    }
}

/** The strokes last copied or cut, shared by every page so they can be pasted into another one. */
object StrokeClipboard {
    @Volatile var lines: List<app.inkbridge.rm.scene.Line> = emptyList()
    val hasContent: Boolean get() = lines.isNotEmpty()
}
