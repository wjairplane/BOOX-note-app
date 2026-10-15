package app.inkbridge.rm

import app.inkbridge.rm.library.*
import app.inkbridge.rm.render.*
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import java.io.File
import javax.imageio.ImageIO

class LibraryOpsTest {
    @get:Rule val tmp = TemporaryFolder()
    private fun dir() = tmp.newFolder()
    private fun scan(d: File) = LibraryScanner.scan(d)

    @Test fun createsFoldersAndNotebooksThatTheScannerReads() {
        val d = dir()
        val f = LibraryOps.createFolder(d, "School", id = "f1", now = 1000)
        val n = LibraryOps.createNotebook(d, "Maths", parentId = f, template = PageTemplate.GRID, id = "n1", firstPageId = "p1", now = 2000)
        val lib = scan(d)
        assertEquals(listOf("School"), lib.children("").map { it.name })
        val nb = lib["n1"]!!
        assertEquals("Maths", nb.name); assertEquals("f1", nb.parentId); assertEquals("notebook", nb.fileType)
        assertEquals(listOf("p1"), nb.pageIds); assertEquals(PageTemplate.GRID, nb.template)
        assertTrue(lib["f1"]!!.isFolder)
        assertEquals(n, nb.id)
    }

    @Test fun lastOpenedPageAndTimeArePersistedAndSizeIsSummed() {
        val d = dir()
        LibraryOps.createNotebook(d, "N", id = "n", firstPageId = "p1", now = 5)
        LibraryOps.addPage(d, scan(d)["n"]!!, pageId = "p2")
        assertEquals(0, scan(d)["n"]!!.lastOpened)
        File(File(d, "n"), "p1.rm").writeBytes(ByteArray(100))
        File(File(d, "n"), "p2.rm").writeBytes(ByteArray(23))
        LibraryOps.setLastOpened(d, "n", 1, now = 9000)
        val n = scan(d)["n"]!!
        assertEquals(1, n.lastOpenedPage); assertEquals(9000L, n.lastOpened); assertEquals(123L, n.sizeBytes)
        assertNotEquals(9000L, n.lastModified)
    }

    @Test fun renamePinAndMove() {
        val d = dir()
        LibraryOps.createFolder(d, "A", id = "a"); LibraryOps.createNotebook(d, "N", id = "n")
        LibraryOps.rename(d, "n", "  Renamed  "); LibraryOps.setPinned(d, "n", true); LibraryOps.moveTo(d, "n", "a")
        val n = scan(d)["n"]!!
        assertEquals("Renamed", n.name); assertTrue(n.pinned); assertEquals("a", n.parentId)
    }

    @Test fun trashRestoreAndPermanentDelete() {
        val d = dir()
        LibraryOps.createFolder(d, "A", id = "a")
        LibraryOps.createNotebook(d, "N", parentId = "a", id = "n", firstPageId = "p")
        File(d, "n/p.rm").apply { parentFile.mkdirs(); writeBytes(byteArrayOf(1)) }

        LibraryOps.trash(d, "n")
        assertEquals(listOf("N"), scan(d).trash.map { it.name })
        assertTrue(scan(d).children("a").isEmpty())
        LibraryOps.restore(d, "n")
        assertEquals(listOf("N"), scan(d).children("a").map { it.name })

        // Deleting a folder removes what is inside it, including page files.
        LibraryOps.trash(d, "a")
        assertEquals(2, LibraryOps.deletePermanently(d, "a"))
        assertTrue(scan(d).entries.isEmpty())
        assertFalse(File(d, "n").exists()); assertFalse(File(d, "n.metadata").exists())
    }

    @Test fun restoreFallsBackToTopLevelWhenTheFolderIsGone() {
        val d = dir()
        LibraryOps.createFolder(d, "A", id = "a"); LibraryOps.createNotebook(d, "N", parentId = "a", id = "n")
        LibraryOps.trash(d, "n"); LibraryOps.deletePermanently(d, "a"); LibraryOps.restore(d, "n")
        assertEquals("", scan(d)["n"]!!.parentId)
    }

    @Test fun emptyTrashOnlyRemovesTrashedItems() {
        val d = dir()
        LibraryOps.createNotebook(d, "Keep", id = "k"); LibraryOps.createNotebook(d, "Bin", id = "b")
        LibraryOps.trash(d, "b")
        assertEquals(1, LibraryOps.emptyTrash(d))
        assertEquals(listOf("k"), scan(d).entries.map { it.id })
    }

    @Test fun addAndDeletePages() {
        val d = dir()
        LibraryOps.createNotebook(d, "N", id = "n", firstPageId = "p1")
        var nb = scan(d)["n"]!!
        LibraryOps.addPage(d, nb, pageId = "p2"); nb = scan(d)["n"]!!
        LibraryOps.addPage(d, nb, afterIndex = 0, pageId = "p1b"); nb = scan(d)["n"]!!
        assertEquals(listOf("p1", "p1b", "p2"), nb.pageIds)

        File(d, "n/p1b.rm").writeBytes(byteArrayOf(1))
        assertTrue(LibraryOps.deletePage(d, nb, 1)); nb = scan(d)["n"]!!
        assertEquals(listOf("p1", "p2"), nb.pageIds)
        assertFalse(File(d, "n/p1b.rm").exists())

        assertTrue(LibraryOps.deletePage(d, nb, 0)); nb = scan(d)["n"]!!
        assertFalse("the last page can't be deleted", LibraryOps.deletePage(d, nb, 0))
        assertEquals(listOf("p2"), scan(d)["n"]!!.pageIds)
    }

    @Test fun templatesDrawAndExport() {
        for (t in PageTemplate.entries.take(8)) {
            val layout = PageLayout(-702f, 702f, 0f, 1872f)
            val c = Java2DCanvas(layout, 0.4f); t.draw(c, layout)
            System.getProperty("rm.renderOut")?.let { File(it).mkdirs(); ImageIO.write(c.finish(), "png", File(it, "template_${t.id}.png")) }
        }
        val svg = app.inkbridge.rm.export.SvgCanvas(PageLayout(-702f, 702f, 0f, 1872f)).also { PageTemplate.LINES.draw(it, PageLayout(-702f, 702f, 0f, 1872f)) }.toSvg()
        assertTrue(svg.contains("<polyline"))
        assertEquals(PageTemplate.BLANK, PageTemplate.fromId("nonsense"))
    }

    @Test fun tagsRoundTripInTheTabletFormat() {
        val d = dir()
        LibraryOps.createNotebook(d, "N", id = "n", firstPageId = "p"); LibraryOps.createFolder(d, "F", id = "f")
        LibraryOps.setTags(d, "n", listOf(" work ", "ideas", "work", ""), now = 5)
        LibraryOps.setTags(d, "f", listOf("archive"))
        assertEquals(listOf("work", "ideas"), scan(d)["n"]!!.tags)
        assertEquals(listOf("archive"), scan(d)["f"]!!.tags)
        assertTrue(File(d, "n.content").readText().contains("\"timestamp\""))
        LibraryOps.setTags(d, "n", emptyList())
        assertEquals(emptyList<String>(), scan(d)["n"]!!.tags)
    }

    @Test fun duplicateCopiesNotebooksAndFoldersWithTheirContents() {
        val d = dir()
        LibraryOps.createFolder(d, "F", id = "f")
        LibraryOps.createNotebook(d, "N", parentId = "f", id = "n", firstPageId = "p")
        File(File(d, "n"), "p.rm").writeText("ink")
        LibraryOps.setPinned(d, "n", true); LibraryOps.setTags(d, "n", listOf("t"))
        val nCopy = LibraryOps.duplicate(d, "n", now = 9)
        var lib = scan(d)
        assertEquals("N (copy)", lib[nCopy]!!.name); assertEquals("f", lib[nCopy]!!.parentId)
        assertFalse(lib[nCopy]!!.pinned); assertEquals(listOf("t"), lib[nCopy]!!.tags)
        assertEquals("ink", File(File(d, nCopy), "p.rm").readText())
        assertTrue(lib["n"]!!.pinned) // the original is untouched
        val fCopy = LibraryOps.duplicate(d, "f")
        lib = scan(d)
        assertEquals("F (copy)", lib[fCopy]!!.name)
        val inside = lib.children(fCopy)
        assertEquals(2, inside.size.takeIf { it == 2 } ?: inside.size) // the notebook and its earlier copy
        assertTrue(inside.all { it.id != "n" && it.id != nCopy })
        assertTrue(inside.any { it.name == "N" } && inside.any { it.name == "N (copy)" })
    }
}
