package app.inkbridge

import android.content.Context
import com.tom_roush.pdfbox.android.PDFBoxResourceLoader
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPage
import com.tom_roush.pdfbox.pdmodel.interactive.action.PDActionGoTo
import com.tom_roush.pdfbox.pdmodel.interactive.annotation.PDAnnotationLink
import com.tom_roush.pdfbox.pdmodel.interactive.documentnavigation.destination.PDNamedDestination
import com.tom_roush.pdfbox.pdmodel.interactive.documentnavigation.destination.PDPageDestination
import com.tom_roush.pdfbox.pdmodel.interactive.documentnavigation.outline.PDOutlineItem
import com.tom_roush.pdfbox.pdmodel.interactive.documentnavigation.outline.PDOutlineNode
import com.tom_roush.pdfbox.text.PDFTextStripper
import com.tom_roush.pdfbox.text.TextPosition
import java.io.File

/**
 * What the PDF itself says about a page beyond its pixels: the outline (the table of contents), the internal links and the text with
 * the position of every character. Android's `PdfRenderer` exposes none of these, so they come from PdfBox. All positions are in PDF
 * points with the origin at the page's top-left corner and y pointing down (the same space as [PdfBackground.sizePoints]).
 */
object PdfStructure {
    data class TocItem(val title: String, val level: Int, val page: Int)

    /** A link to another page of the same file. */
    data class Link(val left: Float, val top: Float, val right: Float, val bottom: Float, val page: Int) {
        fun contains(x: Float, y: Float) = x in left..right && y in top..bottom
    }

    class Glyph(val text: String, val left: Float, val top: Float, val right: Float, val bottom: Float)

    /** One line of text as the extractor reads it: its characters left to right. */
    class TextLine(val glyphs: List<Glyph>) {
        val text: String get() = glyphs.joinToString("") { it.text }
        val top: Float get() = glyphs.minOf { it.top }
        val bottom: Float get() = glyphs.maxOf { it.bottom }
    }

    @Volatile private var initialised = false
    private var cachedFile: File? = null
    private var cachedStamp = 0L
    private var cachedDoc: PDDocument? = null

    fun init(context: Context) {
        if (!initialised) { PDFBoxResourceLoader.init(context.applicationContext); initialised = true }
    }

    /** The document outline, flattened with the nesting level; entries that point nowhere inside the file are left out. */
    fun outline(file: File): List<TocItem> = withDoc(file) { doc ->
        val out = ArrayList<TocItem>()
        fun walk(node: PDOutlineNode, level: Int) {
            var item: PDOutlineItem? = node.firstChild
            while (item != null) {
                val page = runCatching { pageOf(doc, item!!) }.getOrNull()
                if (page != null && page >= 0) out += TocItem(item.title.orEmpty().trim().ifEmpty { "Page ${page + 1}" }, level, page)
                walk(item, level + 1)
                item = item.nextSibling
            }
        }
        doc.documentCatalog.documentOutline?.let { walk(it, 0) }
        out
    }.orEmpty()

    /** The links of PDF page [pageIndex] (0-based) that lead to another page of the file. */
    fun links(file: File, pageIndex: Int): List<Link> = withDoc(file) { doc ->
        val page = doc.getPage(pageIndex)
        val box = page.cropBox
        val h = box.height
        page.annotations.filterIsInstance<PDAnnotationLink>().mapNotNull { a ->
            val target = runCatching { targetPage(doc, a) }.getOrNull() ?: return@mapNotNull null
            val r = a.rectangle ?: return@mapNotNull null
            Link(r.lowerLeftX - box.lowerLeftX, h - (r.upperRightY - box.lowerLeftY), r.upperRightX - box.lowerLeftX, h - (r.lowerLeftY - box.lowerLeftY), target)
        }
    }.orEmpty()

    /** The text of PDF page [pageIndex] as lines of positioned characters, top to bottom. */
    fun lines(file: File, pageIndex: Int): List<TextLine> = withDoc(file) { doc ->
        val out = ArrayList<TextLine>()
        val stripper = object : PDFTextStripper() {
            override fun writeString(text: String, positions: MutableList<TextPosition>) {
                val glyphs = positions.filter { it.unicode.isNotBlank() || it.widthDirAdj > 0f }.map {
                    Glyph(it.unicode, it.xDirAdj, it.yDirAdj - it.heightDir, it.xDirAdj + it.widthDirAdj, it.yDirAdj)
                }
                if (glyphs.isNotEmpty()) out += TextLine(glyphs)
            }
        }
        stripper.sortByPosition = true
        stripper.startPage = pageIndex + 1
        stripper.endPage = pageIndex + 1
        stripper.getText(doc)
        out.sortedBy { it.top }
    }.orEmpty()

    private fun pageOf(doc: PDDocument, item: PDOutlineItem): Int? {
        item.destination?.let { return destinationPage(doc, it) }
        (item.action as? PDActionGoTo)?.destination?.let { return destinationPage(doc, it) }
        return null
    }

    private fun targetPage(doc: PDDocument, a: PDAnnotationLink): Int? {
        a.destination?.let { return destinationPage(doc, it) }
        (a.action as? PDActionGoTo)?.destination?.let { return destinationPage(doc, it) }
        return null
    }

    private fun destinationPage(doc: PDDocument, d: com.tom_roush.pdfbox.pdmodel.interactive.documentnavigation.destination.PDDestination): Int? {
        val dest = if (d is PDNamedDestination) doc.documentCatalog.findNamedDestinationPage(d) else d as? PDPageDestination
        dest ?: return null
        val n = dest.retrievePageNumber()
        if (n >= 0) return n
        return dest.page?.let { doc.pages.indexOf(it as PDPage) }?.takeIf { it >= 0 }
    }

    /** One document stays open between calls (the TOC, links and text of a page are asked for one after another). */
    @Synchronized private fun <T> withDoc(file: File, block: (PDDocument) -> T): T? = try {
        if (cachedFile != file || cachedStamp != file.lastModified() || cachedDoc == null) {
            runCatching { cachedDoc?.close() }
            cachedDoc = PDDocument.load(file); cachedFile = file; cachedStamp = file.lastModified()
        }
        block(cachedDoc!!)
    } catch (e: Throwable) {
        // An unreadable or encrypted file has no outline, links or text; the page itself still draws.
        runCatching { cachedDoc?.close() }; cachedDoc = null; cachedFile = null
        null
    }
}
