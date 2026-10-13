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
import android.graphics.pdf.PdfDocument
import java.io.File
import kotlin.math.roundToInt

/**
 * One open page: the editable model, the on-screen bitmap, and the screen↔page mapping.
 * Pen callbacks may arrive on a non-UI thread, so everything that touches state is synchronized.
 */
class PageSession(private val file: File, private val background: PdfBackground? = null) {
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

    /** Size the page to a view of [width] x [height] px and redraw it. */
    @Synchronized
    fun resize(width: Int, height: Int) {
        if (width <= 0 || height <= 0) return
        val layout = editor.renderer.layout
        val t = PageTransform(layout, width.toFloat(), height.toFloat())
        transform = t
        // Not recycled: the surface may still be showing the previous bitmap; the GC frees it.
        bitmap = Bitmap.createBitmap(
            (layout.width * t.scale).toInt().coerceAtLeast(1),
            (layout.height * t.scale).toInt().coerceAtLeast(1),
            Bitmap.Config.ARGB_8888,
        )
        backgroundBitmap = background?.let { b ->
            val p = b.placement
            b.render((p.width * t.scale).roundToInt())
        }
        redrawAll()
    }

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

    @Synchronized fun undo(): Boolean = editor.undo().also { if (it) redrawAll() }
    @Synchronized fun redo(): Boolean = editor.redo().also { if (it) redrawAll() }

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
        val svg = File(dir, "$baseName.svg").also { it.writeText(PageExport.svg(renderer, svgBackground)) }

        val png = File(dir, "$baseName.png")
        val full = Bitmap.createBitmap(layout.width.toInt(), layout.height.toInt(), Bitmap.Config.ARGB_8888)
        Canvas(full).also { c ->
            c.drawColor(Color.WHITE)
            c.translate(-layout.xMin, -layout.yMin)
            drawBackground(c)
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
        editor.renderer.render(AndroidPageCanvas(canvas))
    }

    private fun withPageCanvas(clear: Boolean = false, draw: (Canvas) -> Unit) {
        val bmp = bitmap ?: return
        val t = transform ?: return
        val canvas = Canvas(bmp)
        if (clear) canvas.drawColor(Color.WHITE)
        canvas.scale(t.scale, t.scale)
        canvas.translate(-t.layout.xMin, -t.layout.yMin)
        draw(canvas)
    }
}
