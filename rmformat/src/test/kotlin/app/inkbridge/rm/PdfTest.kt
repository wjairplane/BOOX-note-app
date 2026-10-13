package app.inkbridge.rm

import app.inkbridge.rm.library.*
import app.inkbridge.rm.render.PdfPlacement
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

class PdfTest {
    @get:Rule val tmp = TemporaryFolder()

    @Test fun a4FitsByHeightAndIsCentredHorizontally() {
        val p = PdfPlacement(595f, 842f) // A4 in points: narrower than 3:4, so height limits
        assertEquals(1872f / 842f, p.scale, 1e-4f)
        assertEquals(1872f, p.height, 0.01f)
        assertTrue(p.width < 1404f)
        assertEquals(-p.width / 2f, p.left, 1e-4f)
        assertEquals(0f, p.top, 0f)
    }

    @Test fun usLetterFitsByWidth() {
        val p = PdfPlacement(612f, 792f) // wider than 3:4, so width limits
        assertEquals(1404f / 612f, p.scale, 1e-4f)
        assertEquals(1404f, p.width, 0.01f)
        assertEquals(-702f, p.left, 0.01f)
        assertTrue(p.height < 1872f)
    }

    @Test fun pdfAndPageCoordinatesRoundTrip() {
        val p = PdfPlacement(612f, 792f)
        assertEquals(100f, p.pageToPdfX(p.pdfToPageX(100f)), 1e-3f)
        assertEquals(300f, p.pageToPdfY(p.pdfToPageY(300f)), 1e-3f)
        assertEquals(-702f, p.pdfToPageX(0f), 0.01f)       // left edge of the PDF = left edge of the page
        assertEquals(702f, p.pdfToPageX(612f), 0.01f)       // right edge
    }

    @Test fun createdPdfDocumentIsReadBackByTheScanner() {
        val dir = tmp.newFolder("lib")
        val id = DocumentFactory.createPdfDocument(dir, "Paper", pageCount = 3, sizeInBytes = 1234, parentId = "folder-1", id = "doc-1", now = 1700000000000L, pageIds = listOf("a", "b", "c"))
        assertEquals("doc-1", id)

        val lib = LibraryScanner.scan(dir)
        val e = lib["doc-1"]!!
        assertEquals("Paper", e.name)
        assertEquals("pdf", e.fileType)
        assertEquals("folder-1", e.parentId)
        assertEquals(listOf("a", "b", "c"), e.pageIds)
        assertEquals(listOf(0, 1, 2), e.redirectMap)
        assertEquals(1700000000000L, e.lastModified)
        assertTrue(java.io.File(dir, "doc-1").isDirectory)
        assertEquals(java.io.File(dir, "doc-1.pdf"), DocumentFactory.pdfFile(dir, e))
        assertEquals(1, DocumentFactory.pdfPageFor(e, 1))
    }

    @Test fun redirectMapCanHideInsertedBlankPages() {
        val e = LibraryScanner.parseEntry("x", """{"type":"DocumentType","visibleName":"n"}""",
            """{"fileType":"pdf","pages":["a","b","c"],"redirectMap":[0,-1,1]}""")!!
        assertEquals(listOf(0, -1, 1), listOf(0, 1, 2).map { DocumentFactory.pdfPageFor(e, it) })
    }
}
