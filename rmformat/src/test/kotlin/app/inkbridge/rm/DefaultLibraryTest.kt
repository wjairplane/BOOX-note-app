package app.inkbridge.rm

import app.inkbridge.rm.io.SceneStream
import app.inkbridge.rm.library.DefaultLibrary
import app.inkbridge.rm.library.DocumentFactory
import app.inkbridge.rm.library.LibraryOps
import app.inkbridge.rm.library.LibraryScanner
import app.inkbridge.rm.render.PageLayout
import app.inkbridge.rm.render.PageRenderer
import app.inkbridge.rm.render.PixelInk
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import java.io.File
import javax.imageio.ImageIO

class DefaultLibraryTest {
    @get:Rule val tmp = TemporaryFolder()

    private fun installed(): File = tmp.newFolder("library").also { DefaultLibrary.install(it) }

    @Test fun installsTheTwoShippedDocuments() {
        val dir = installed()
        val lib = LibraryScanner.scan(dir)
        val basics = lib.children("").single { it.name == "Learn the basics" }
        val further = lib.children("").single { it.name == "Go further" }
        assertEquals(2, lib.entries.size)
        assertEquals("pdf", basics.fileType); assertEquals("pdf", further.fileType)
        assertEquals(9, basics.pageIds.size)
        assertEquals(2, further.pageIds.size)
        // Page 1 is the PDF cover; the other eight are inserted blank pages that hold the typed text and pen strokes.
        assertEquals(listOf(0) + List(8) { -1 }, basics.redirectMap)
        assertEquals(listOf(0, 1), further.redirectMap)
        assertTrue(DocumentFactory.pdfFile(dir, basics).length() > 10_000)
        assertTrue(DocumentFactory.pdfFile(dir, further).length() > 10_000)
        for (i in 1 until 9) assertTrue("page ${i + 1} has no .rm", LibraryScanner.pageFile(dir, basics, i).isFile)
        assertFalse("the cover page has no ink", LibraryScanner.pageFile(dir, basics, 0).isFile)
        assertEquals(-1, DocumentFactory.pdfPageFor(basics, 3))
        assertEquals(0, DocumentFactory.pdfPageFor(basics, 0))
    }

    @Test fun everyShippedPageParsesAndStaysInsideTheStandardPage() {
        val dir = installed()
        val basics = LibraryScanner.scan(dir).children("").single { it.name == "Learn the basics" }
        for (i in 1 until basics.pageIds.size) {
            val tree = SceneStream.readTree(LibraryScanner.pageFile(dir, basics, i).readBytes())
            // The pages say 1620 x 2160 (the Paper Pro's pixels) but are laid out in the same units as every page: text 936 wide, centred.
            assertEquals(1620L to 2160L, tree.sceneInfo!!.paperSize)
            val text = tree.rootText!!
            assertEquals(936f, text.width, 0.5f)
            assertEquals(-468.0, text.posX, 0.5)
            val layout = PageRenderer(tree).layout
            assertEquals("page ${i + 1} grows the page", PageLayout.PAGE_WIDTH, layout.width, 0.5f)
        }
    }

    @Test fun shippedDocumentsCanBeEditedAndDeleted() {
        val dir = installed()
        val basics = LibraryScanner.scan(dir).children("").single { it.name == "Learn the basics" }
        LibraryOps.addPage(dir, basics, afterIndex = 1)
        val edited = LibraryScanner.scan(dir)[basics.id]!!
        assertEquals(10, edited.pageIds.size)
        assertEquals(listOf(0, -1, -1) + List(7) { -1 }, edited.redirectMap)
        LibraryOps.deletePage(dir, edited, 0)
        assertEquals(List(9) { -1 }, LibraryScanner.scan(dir)[basics.id]!!.redirectMap)

        for (e in LibraryScanner.scan(dir).entries) { LibraryOps.trash(dir, e.id); LibraryOps.deletePermanently(dir, e.id) }
        assertEquals(0, LibraryScanner.scan(dir).entries.size)
        assertEquals(emptyList<String>(), dir.list()!!.toList())
    }

    @Test fun lastOpenedIsOnlyStampedByTheTimerNotByTheClose() {
        val dir = installed()
        val doc = LibraryScanner.scan(dir).children("").first()
        val before = doc.lastOpened
        LibraryOps.setLastOpened(dir, doc.id, 3, stamp = false)
        assertEquals(before, LibraryScanner.scan(dir)[doc.id]!!.lastOpened)
        assertEquals(3, LibraryScanner.scan(dir)[doc.id]!!.lastOpenedPage)
        LibraryOps.setLastOpenedTime(dir, doc.id, now = 1234L)
        assertEquals(1234L, LibraryScanner.scan(dir)[doc.id]!!.lastOpened)
        assertEquals(5000L, LibraryOps.OPEN_STAMP_DELAY_MS)
    }

    /** Draws page 4 ("Draw shapes") the way the app does: text on white, then the strokes with the firmware pen renderer. */
    @Test fun rendersShippedPagesToPng() {
        System.setProperty("java.awt.headless", "true")
        val out = System.getProperty("rm.renderOut")?.let { File(it).apply { mkdirs() } }
        val dir = installed()
        val basics = LibraryScanner.scan(dir).children("").single { it.name == "Learn the basics" }
        for (i in listOf(1, 3, 5, 7)) {
            val r = PageRenderer(SceneStream.readTree(LibraryScanner.pageFile(dir, basics, i).readBytes()))
            val layout = r.layout
            val c = Java2DCanvas(layout, 1f)
            r.render(c, strokes = false)
            val img = c.finish()
            val w = img.width; val h = img.height
            val base = IntArray(w * h).also { img.getRGB(0, 0, w, h, it, 0, w) }
            val ink = PixelInk(w, h).also { r.renderInk(it, PixelInk.Transform(1f, -layout.xMin, -layout.yMin)) }
            val res = IntArray(w * h)
            ink.compositeInto(base, res, 0, 0, w, h)
            img.setRGB(0, 0, w, h, res, 0, w)
            var dark = 0
            for (p in res) if (p and 0xFFFFFF != 0xFFFFFF) dark++
            assertTrue("page ${i + 1} is empty", dark > 3000)
            out?.let { ImageIO.write(img, "png", File(it, "learn_the_basics_p${i + 1}.png")) }
        }
    }
}
