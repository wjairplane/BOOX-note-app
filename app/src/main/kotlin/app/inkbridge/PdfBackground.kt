package app.inkbridge

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import app.inkbridge.rm.render.PdfPlacement
import java.io.File
import kotlin.math.roundToInt

/** One page of a PDF file, rendered with Android's built-in `PdfRenderer`. */
class PdfBackground(private val file: File, private val pageIndex: Int) {

    /** Where the page sits in `.rm` page space (see [PdfPlacement] for the alignment assumption). */
    val placement: PdfPlacement by lazy {
        withPage { PdfPlacement(it.width.toFloat(), it.height.toFloat()) }
    }

    /** The page's size in PDF points. */
    val sizePoints: Pair<Float, Float> get() = placement.pdfWidth to placement.pdfHeight

    /** Render the page, white-backed, [widthPx] pixels wide (height follows the page's aspect ratio). */
    fun render(widthPx: Int): Bitmap = withPage { page ->
        val w = widthPx.coerceAtLeast(1)
        val h = (w * page.height.toFloat() / page.width).roundToInt().coerceAtLeast(1)
        Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888).also {
            it.eraseColor(Color.WHITE) // PdfRenderer leaves unpainted areas transparent
            page.render(it, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
        }
    }

    // A renderer is not thread-safe and only allows one open page, so each call gets its own.
    private fun <T> withPage(block: (PdfRenderer.Page) -> T): T = open(file) { renderer ->
        val page = renderer.openPage(pageIndex)
        try { block(page) } finally { page.close() }
    }

    companion object {
        /** Number of pages; throws if the file isn't a readable (unencrypted) PDF. */
        fun pageCount(file: File): Int = open(file) { it.pageCount }

        private fun <T> open(file: File, block: (PdfRenderer) -> T): T {
            val fd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
            val renderer = try { PdfRenderer(fd) } catch (e: Exception) { fd.close(); throw e }
            try { return block(renderer) } finally { renderer.close(); fd.close() }
        }
    }
}
