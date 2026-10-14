package app.inkbridge.rm.render

import kotlin.math.min

/**
 * Where a PDF page sits inside the 1404 x 1872 page space that annotations are stored in.
 *
 * The PDF page is scaled uniformly to fit the page, centred horizontally (x is measured from the
 * page centre in `.rm` files) and aligned to the top.
 *
 * UNVERIFIED ASSUMPTION: horizontal centring follows from the file format, but top alignment is a
 * guess. It only matters when annotated PDFs are exchanged with a real reMarkable; annotations made
 * and viewed inside this app are always self-consistent. Check against a real annotated PDF
 * (a PDF whose aspect ratio differs from 3:4, e.g. US Letter) and adjust [top] if it is off.
 */
class PdfPlacement(val pdfWidth: Float, val pdfHeight: Float) {
    init {
        require(pdfWidth > 0 && pdfHeight > 0) { "PDF page must have a positive size" }
    }

    /** Page units per PDF point. */
    val scale: Float = min(PageLayout.PAGE_WIDTH / pdfWidth, PageLayout.PAGE_HEIGHT / pdfHeight)

    val width: Float = pdfWidth * scale
    val height: Float = pdfHeight * scale

    /** Page-space x of the PDF's left edge. */
    val left: Float = -width / 2f

    /** Page-space y of the PDF's top edge. */
    val top: Float = 0f

    fun pdfToPageX(x: Float) = left + x * scale
    fun pdfToPageY(y: Float) = top + y * scale
    fun pageToPdfX(x: Float) = (x - left) / scale
    fun pageToPdfY(y: Float) = (y - top) / scale
}
