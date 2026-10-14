package app.inkbridge.rm

import app.inkbridge.rm.io.SceneStream
import app.inkbridge.rm.library.*
import app.inkbridge.rm.render.PageRenderer
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import java.io.File

class LibraryTest {
    @get:Rule val tmp = TemporaryFolder()

    private fun meta(name: String, type: String, parent: String = "", extra: String = "") =
        """{"deleted":false,"lastModified":"1700000000123","metadatamodified":false,"modified":false,
           "parent":"$parent","pinned":false,"synced":true,"type":"$type","version":1,"visibleName":"$name"$extra}"""

    private fun File.put(name: String, text: String) = File(this, name).apply { writeText(text) }

    /** Lay out a fake xochitl folder in the same shape the tablet uses. */
    private fun fakeXochitl(): File {
        val d = tmp.newFolder("xochitl")
        d.put("folder-1.metadata", meta("Work", "CollectionType"))
        d.put("nb-1.metadata", meta("Meeting notes", "DocumentType", parent = "folder-1"))
        d.put("nb-1.content", """{"fileType":"notebook","cPages":{"pages":[
            {"id":"page-a","idx":{"timestamp":"1:2","value":"ba"}},
            {"id":"page-gone","idx":{"timestamp":"1:2","value":"bb"},"deleted":{"timestamp":"1:3","value":1}},
            {"id":"page-b","idx":{"timestamp":"1:2","value":"bc"}}]}}""")
        File(d, "nb-1").mkdirs()
        javaClass.getResourceAsStream("/rmscene/Lines_v2.rm")!!.use { File(d, "nb-1/page-a.rm").outputStream().use { o -> it.copyTo(o) } }
        // page-b was never drawn on: no .rm file
        d.put("pdf-1.metadata", meta("Paper", "DocumentType"))
        d.put("pdf-1.content", """{"fileType":"pdf","pages":["p1","p2","p3"],"redirectMap":[0,1,-1]}""")
        d.put("old.metadata", meta("Old stuff", "DocumentType", parent = "trash"))
        d.put("dead.metadata", meta("Purged", "DocumentType").replace("\"deleted\":false", "\"deleted\":true"))
        d.put("broken.metadata", "{not json")
        return d
    }

    @Test fun buildsTreeFromMetadataParents() {
        val problems = mutableListOf<String>()
        val lib = LibraryScanner.scan(fakeXochitl()) { f, _ -> problems += f.name }
        assertEquals(listOf("broken.metadata"), problems)

        assertEquals(listOf("Work", "Paper"), lib.children("").map { it.name }) // folders first
        assertEquals(listOf("Meeting notes"), lib.children("folder-1").map { it.name })
        assertEquals(listOf("Old stuff"), lib.trash.map { it.name })
        assertNull("purged entries are hidden", lib["dead"])
        assertEquals(listOf("Work"), lib.path("nb-1"))
        assertEquals(1700000000123L, lib["nb-1"]!!.lastModified)
    }

    @Test fun readsPageListsFromBothContentFormats() {
        val lib = LibraryScanner.scan(fakeXochitl())
        val nb = lib["nb-1"]!!
        assertEquals("notebook", nb.fileType)
        assertEquals(listOf("page-a", "page-b"), nb.pageIds) // deleted page dropped, order kept
        val pdf = lib["pdf-1"]!!
        assertEquals("pdf", pdf.fileType)
        assertEquals(listOf("p1", "p2", "p3"), pdf.pageIds)
        assertEquals(listOf(0, 1, -1), pdf.redirectMap)
    }

    @Test fun opensAndRendersAPageFromTheLibrary() {
        val dir = fakeXochitl()
        val nb = LibraryScanner.scan(dir)["nb-1"]!!
        val f = LibraryScanner.pageFile(dir, nb, 0)
        assertTrue(f.isFile)
        val r = PageRenderer(SceneStream.readTree(f.readBytes()))
        val c = Java2DCanvas(r.layout)
        r.render(c)
        assertFalse(LibraryScanner.pageFile(dir, nb, 1).exists())
    }
}

class PageFilesTest {
    @get:Rule val tmp = TemporaryFolder()

    @Test fun savesAtomicallyAndKeepsOneBackupOfTheOriginal() {
        val dir = tmp.newFolder("doc")
        val page = File(dir, "page.rm")
        PageFiles.save(page, byteArrayOf(1, 2, 3))                 // new page: nothing to back up
        assertFalse(File(dir, "page.rm.orig").exists())
        PageFiles.save(page, byteArrayOf(4, 5))                    // first overwrite: back up v1
        assertArrayEquals(byteArrayOf(1, 2, 3), File(dir, "page.rm.orig").readBytes())
        PageFiles.save(page, byteArrayOf(6))                       // later overwrites keep the first backup
        assertArrayEquals(byteArrayOf(1, 2, 3), File(dir, "page.rm.orig").readBytes())
        assertArrayEquals(byteArrayOf(6), page.readBytes())
        assertFalse(File(dir, "page.rm.tmp").exists())
    }

    @Test fun createsMissingFolders() {
        val page = File(tmp.root, "a/b/page.rm")
        PageFiles.save(page, byteArrayOf(9))
        assertArrayEquals(byteArrayOf(9), page.readBytes())
    }
}
