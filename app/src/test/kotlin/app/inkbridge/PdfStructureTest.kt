package app.inkbridge

import androidx.test.core.app.ApplicationProvider
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPage
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.common.PDRectangle
import com.tom_roush.pdfbox.pdmodel.font.PDType1Font
import com.tom_roush.pdfbox.pdmodel.interactive.action.PDActionGoTo
import com.tom_roush.pdfbox.pdmodel.interactive.annotation.PDAnnotationLink
import com.tom_roush.pdfbox.pdmodel.interactive.documentnavigation.destination.PDPageFitDestination
import com.tom_roush.pdfbox.pdmodel.interactive.documentnavigation.outline.PDDocumentOutline
import com.tom_roush.pdfbox.pdmodel.interactive.documentnavigation.outline.PDOutlineItem
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/** The PDF outline, internal links and positioned text that the table of contents, link taps and highlighter snapping rely on. */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class PdfStructureTest {
    @get:Rule val tmp = TemporaryFolder()

    /** Three Letter pages; page 1 says "Hello world" and carries a link to page 3; the outline has Intro > Details and Appendix. */
    private fun pdf(): java.io.File {
        PdfStructure.init(ApplicationProvider.getApplicationContext())
        val doc = PDDocument()
        val pages = List(3) { PDPage(PDRectangle.LETTER).also { doc.addPage(it) } }
        PDPageContentStream(doc, pages[0]).use { c ->
            c.beginText(); c.setFont(PDType1Font.HELVETICA, 20f); c.newLineAtOffset(72f, 700f); c.showText("Hello world"); c.endText()
        }
        val link = PDAnnotationLink().apply {
            rectangle = PDRectangle(100f, 100f, 200f, 50f) // x 100..300, y 100..150 from the bottom
            action = PDActionGoTo().apply { destination = PDPageFitDestination().also { it.page = pages[2] } }
        }
        pages[0].annotations.add(link)
        val outline = PDDocumentOutline().also { doc.documentCatalog.documentOutline = it }
        val intro = PDOutlineItem().apply { title = "Intro"; destination = PDPageFitDestination().also { it.page = pages[0] } }
        val details = PDOutlineItem().apply { title = "Details"; destination = PDPageFitDestination().also { it.page = pages[1] } }
        val appendix = PDOutlineItem().apply { title = "Appendix"; destination = PDPageFitDestination().also { it.page = pages[2] } }
        outline.addLast(intro); intro.addLast(details); outline.addLast(appendix)
        return tmp.newFile("t.pdf").also { doc.save(it); doc.close() }
    }

    @Test fun outlineIsFlattenedWithLevels() {
        assertEquals(
            listOf(PdfStructure.TocItem("Intro", 0, 0), PdfStructure.TocItem("Details", 1, 1), PdfStructure.TocItem("Appendix", 0, 2)),
            PdfStructure.outline(pdf()),
        )
    }

    @Test fun linksUseTopLeftPoints() {
        val file = pdf()
        val links = PdfStructure.links(file, 0)
        assertEquals(1, links.size)
        val l = links[0]
        assertEquals(2, l.page)
        assertEquals(100f, l.left, 0.5f); assertEquals(300f, l.right, 0.5f)
        // Letter is 792 high: the box 100..150 from the bottom is 642..692 from the top.
        assertEquals(642f, l.top, 0.5f); assertEquals(692f, l.bottom, 0.5f)
        assertTrue(l.contains(150f, 650f)); assertFalse(l.contains(150f, 300f))
        assertTrue(PdfStructure.links(file, 1).isEmpty())
    }

    @Test fun textComesWithPositions() {
        val lines = PdfStructure.lines(pdf(), 0)
        assertEquals(1, lines.size)
        val line = lines[0]
        assertEquals("Hello world", line.text.trim())
        // Baseline at 700 from the bottom = 92 from the top; the first glyph starts at x = 72.
        assertEquals(72f, line.glyphs.first().left, 1f)
        assertTrue(line.bottom in 85f..100f); assertTrue(line.top < line.bottom)
    }
}
