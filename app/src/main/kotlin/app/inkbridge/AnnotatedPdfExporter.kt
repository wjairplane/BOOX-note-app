package app.inkbridge

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.pdf.PdfDocument
import app.inkbridge.rm.io.SceneStream
import app.inkbridge.rm.library.DocumentFactory
import app.inkbridge.rm.library.LibraryEntry
import app.inkbridge.rm.library.LibraryScanner
import app.inkbridge.rm.render.PageRenderer
import app.inkbridge.rm.render.PdfPlacement
import app.inkbridge.rm.scene.SceneTree
import java.io.File

/**
 * Writes a PDF document with its handwriting flattened in. Pages keep their original size; the
 * original page is drawn as a ~144 dpi image (text is no longer selectable) and the ink on top stays vector.
 */
object AnnotatedPdfExporter {
    /** Background resolution: pixels per PDF point (2 = 144 dpi). */
    private const val PIXELS_PER_POINT = 2f

    /** Size used for inserted blank pages (the tablet's page at its 226 dpi, in points). */
    private const val BLANK_W = 1404f * 72f / 226f
    private const val BLANK_H = 1872f * 72f / 226f

    fun export(store: LibraryStore, doc: LibraryEntry, out: File, onProgress: (done: Int, total: Int) -> Unit = { _, _ -> }) {
        val pdfFile = DocumentFactory.pdfFile(store.dir, doc)
        val pdf = PdfDocument()
        val paint = Paint(Paint.FILTER_BITMAP_FLAG)
        try {
            for (i in doc.pageIds.indices) {
                val bg = DocumentFactory.pdfPageFor(doc, i).takeIf { it >= 0 }?.let { PdfBackground(pdfFile, it) }
                val (wPt, hPt) = bg?.sizeInPoints() ?: (BLANK_W to BLANK_H)
                val rm = LibraryScanner.pageFile(store.dir, doc, i)
                val renderer = PageRenderer(if (rm.isFile) SceneStream.readTree(rm.readBytes()) else SceneTree())
                val place = PdfPlacement(wPt, hPt)

                val page = pdf.startPage(PdfDocument.PageInfo.Builder(wPt.toInt(), hPt.toInt(), i + 1).create())
                val canvas = page.canvas
                canvas.drawColor(Color.WHITE)
                if (bg != null) {
                    val bmp: Bitmap = bg.render((wPt * PIXELS_PER_POINT).toInt())
                    canvas.drawBitmap(bmp, null, RectF(0f, 0f, wPt, hPt), paint)
                    bmp.recycle()
                }
                // Page units -> PDF points: p_pt = (p - origin) / scale.
                canvas.save()
                canvas.scale(1f / place.scale, 1f / place.scale)
                canvas.translate(-place.left, -place.top)
                renderer.render(AndroidPageCanvas(canvas))
                canvas.restore()
                pdf.finishPage(page)
                onProgress(i + 1, doc.pageIds.size)
            }
            out.parentFile?.mkdirs()
            out.outputStream().use { pdf.writeTo(it) }
        } finally {
            pdf.close()
        }
    }

    private fun PdfBackground.sizeInPoints() = sizePoints
}
