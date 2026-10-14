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
import app.inkbridge.rm.export.PageExport
import app.inkbridge.rm.export.SvgCanvas
import app.inkbridge.rm.library.PageFiles
import app.inkbridge.rm.render.PageTemplate
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
        val wanted = background?.let { (it.placement.width * t.scale).coerceAtMost(2600f).roundToInt() } ?: 0
        if (background != null && (backgroundBitmap == null || wanted != renderedBackgroundWidth)) {
            backgroundBitmap = background.render(wanted)
            renderedBackgroundWidth = wanted
        }
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
        applyView(next)
    }

    @Synchronized fun fitPage() { val t = transform ?: return; applyView(PageTransform(t.layout, t.viewWidth, t.viewHeight)) }
    @Synchronized fun fitWidth() { val t = transform ?: return; applyView(t.fitWidth()) }
    @Synchronized fun fitHeight() { val t = transform ?: return; applyView(t.fitHeight()) }

    /** Go back to the zoom and pan the user last chose by pinching. */
    @Synchronized
    fun fitCustom() {
        val (z, x, y) = customView ?: return
        val t = transform ?: return
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
        if (samples.size < 2) { val had = selection.isNotEmpty(); selection = emptySet(); if (had) redrawAll(); return had }
        val pagePath = samples.map { t.toPageX(it.x) to t.toPageY(it.y) }
        val bounds = if (selection.isEmpty()) null else editor.boundsOf(selection)
        if (bounds != null) {
            val pad = 24f
            val (sx, sy) = pagePath.first()
            if (sx in (bounds.left - pad)..(bounds.right + pad) && sy in (bounds.top - pad)..(bounds.bottom + pad)) {
                val dx = pagePath.last().first - sx; val dy = pagePath.last().second - sy
                if (kotlin.math.hypot(dx, dy) > 8f) { editor.moveStrokes(selection, dx, dy); redrawAll() }
                return true
            }
        }
        selection = editor.selectInside(pagePath)
        redrawAll()
        return true
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

    // ---- layers ----

    @Synchronized fun layers(): List<PageEditor.LayerInfo> = editor.layers()
    @Synchronized fun addLayer(label: String) { editor.addLayer(label); redrawAll() }
    @Synchronized fun selectLayer(id: CrdtId) { editor.setCurrentLayer(id); redrawAll() }
    @Synchronized fun setLayerVisible(id: CrdtId, visible: Boolean) { editor.setLayerVisible(id, visible); redrawAll() }
    @Synchronized fun deleteLayer(id: CrdtId): Boolean = editor.deleteLayer(id).also { if (it) { selection = emptySet(); redrawAll() } }

    /** Add a stroke from view-pixel [samples]. Returns true if the page changed. */
    @Synchronized
    fun addStroke(spec: PenSpec, samples: List<PenSample>): Boolean {
        val t = transform ?: return false
        val added = editor.addStroke(spec, samples.map { toInput(t, it) }) ?: return false
        withPageCanvas { canvas ->
            editor.renderer.renderLine(added.line, added.ox, added.oy, AndroidPageCanvas(canvas))
        }
        return true
    }

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
        val pl = background?.placement
        val bg = background?.render(pl!!.width.roundToInt())
        fun drawBackground(c: Canvas) {
            if (bg != null && pl != null) c.drawBitmap(bg, null, RectF(pl.left, pl.top, pl.left + pl.width, pl.top + pl.height), Paint(Paint.FILTER_BITMAP_FLAG))
        }

        val svgBackground = if (bg != null && pl != null) {
            val png = java.io.ByteArrayOutputStream().also { bg.compress(Bitmap.CompressFormat.PNG, 100, it) }.toByteArray()
            SvgCanvas.Background(png, pl.left, pl.top, pl.width, pl.height)
        } else null
        val svg = File(dir, "$baseName.svg").also { it.writeText(PageExport.svg(renderer, svgBackground, template.takeIf { background == null })) }

        val png = File(dir, "$baseName.png")
        val full = Bitmap.createBitmap(layout.width.toInt(), layout.height.toInt(), Bitmap.Config.ARGB_8888)
        Canvas(full).also { c ->
            c.drawColor(Color.WHITE)
            c.translate(-layout.xMin, -layout.yMin)
            drawBackground(c)
            if (background == null) template.draw(AndroidPageCanvas(c), layout)
            renderer.render(AndroidPageCanvas(c))
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
            if (background == null) template.draw(AndroidPageCanvas(page.canvas), layout)
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

    private fun redrawAll() = withPageCanvas(clear = true) { canvas ->
        val bg = backgroundBitmap
        val p = background?.placement
        if (bg != null && p != null) {
            canvas.drawBitmap(bg, null, RectF(p.left, p.top, p.left + p.width, p.top + p.height), Paint(Paint.FILTER_BITMAP_FLAG))
        }
        if (background == null) template.draw(AndroidPageCanvas(canvas), editor.renderer.layout)
        editor.renderer.render(AndroidPageCanvas(canvas))
        // The selection is shown as a dashed frame (no colour: it has to read on e-ink).
        val b = if (selection.isEmpty()) null else editor.boundsOf(selection)
        if (b != null) {
            val s = transform?.scale ?: 1f
            val frame = Paint().apply { style = Paint.Style.STROKE; color = Color.BLACK; strokeWidth = 3f / s; pathEffect = DashPathEffect(floatArrayOf(14f / s, 10f / s), 0f) }
            val pad = 14f
            canvas.drawRect(b.left - pad, b.top - pad, b.right + pad, b.bottom + pad, frame)
        } else if (selection.isNotEmpty()) selection = emptySet()
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
