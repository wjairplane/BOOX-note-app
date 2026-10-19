package app.inkbridge

import androidx.test.core.app.ApplicationProvider
import app.inkbridge.pen.PenSample
import app.inkbridge.rm.edit.PageEditor
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.scene.PenColorId
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPage
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.common.PDRectangle
import com.tom_roush.pdfbox.pdmodel.font.PDType1Font
import com.tom_roush.pdfbox.pdmodel.interactive.action.PDActionGoTo
import com.tom_roush.pdfbox.pdmodel.interactive.annotation.PDAnnotationLink
import com.tom_roush.pdfbox.pdmodel.interactive.documentnavigation.destination.PDPageFitDestination
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.io.File

/** Link taps and "Snap to text" on a real PDF page, through the page session (view pixels in, page model out). */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34])
class PdfTextHighlightTest {
    @get:Rule val tmp = TemporaryFolder()

    private fun pdf(): File {
        PdfStructure.init(ApplicationProvider.getApplicationContext())
        val doc = PDDocument()
        val pages = List(2) { PDPage(PDRectangle.LETTER).also { doc.addPage(it) } }
        PDPageContentStream(doc, pages[0]).use { c ->
            c.beginText(); c.setFont(PDType1Font.HELVETICA, 20f); c.newLineAtOffset(72f, 700f); c.showText("Hello world and more"); c.endText()
            c.beginText(); c.setFont(PDType1Font.HELVETICA, 20f); c.newLineAtOffset(72f, 660f); c.showText("Second line here"); c.endText()
        }
        pages[0].annotations.add(PDAnnotationLink().apply {
            rectangle = PDRectangle(72f, 100f, 200f, 40f)
            action = PDActionGoTo().apply { destination = PDPageFitDestination().also { it.page = pages[1] } }
        })
        return tmp.newFile("doc.pdf").also { doc.save(it); doc.close() }
    }

    private fun session(): PageSession {
        val page = tmp.newFile("p.rm").also { it.writeBytes(PageEditor.blank().toBytes()) }
        return PageSession(page, PdfBackground(pdf(), 0, sizeForTests = 612f to 792f)).also { it.resize(1000, 1400) }
    }

    /** View pixels for PDF point (x, y from the top). */
    private fun view(s: PageSession, x: Float, y: Float): Pair<Float, Float> {
        val pl = PdfBackground(File(tmp.root, "doc.pdf"), 0, sizeForTests = 612f to 792f).placement
        val t = s.transform!!
        return t.toViewX(pl.pdfToPageX(x)) to t.toViewY(pl.pdfToPageY(y))
    }

    private fun stroke(s: PageSession, x0: Float, x1: Float, y: Float): List<PenSample> =
        (0..10).map { i -> val (vx, vy) = view(s, x0 + (x1 - x0) * i / 10f, y); PenSample(vx, vy, 0.5f, 0f, 0f, i * 5L) }

    @Test fun aTapOnALinkNamesItsTargetPage() {
        val s = session()
        val (x, y) = view(s, 150f, 792f - 120f) // inside the box 100..140 from the bottom
        assertEquals(1, s.pdfLinkAt(x, y))
        val (ox, oy) = view(s, 150f, 300f)
        assertNull(s.pdfLinkAt(ox, oy))
    }

    @Test fun snapHighlightsTheWordsUnderTheStrokeOnTheLinesItCrosses() {
        val s = session()
        val spec = PenSpec(PenTool.HIGHLIGHTER, colorId = PenColorId.YELLOW)
        // Along the first line from the start of "Hello" to somewhere in "world": the baseline is 92 from the top, glyphs ~ 14 tall.
        assertTrue(s.addSnappedHighlight(spec, stroke(s, 75f, 125f, 86f)))
        val g = s.glyphHighlightsForTest().single().glyph
        assertTrue(g.text, g.text.startsWith("Hello"))
        assertFalse(g.text, g.text.contains("more"))
        assertEquals(1, g.rectangles.size)
        // A stroke through empty space adds nothing.
        assertFalse(s.addSnappedHighlight(spec, stroke(s, 75f, 125f, 400f)))
        assertEquals(1, s.glyphHighlightsForTest().size)
    }
}
