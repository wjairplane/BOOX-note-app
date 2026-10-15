package app.inkbridge

import app.inkbridge.rm.library.EntryType
import app.inkbridge.rm.library.Library
import app.inkbridge.rm.library.LibraryEntry
import app.inkbridge.ui.formatSize
import app.inkbridge.ui.naturalDescending
import app.inkbridge.ui.pageCaption
import app.inkbridge.ui.visibleEntries
import org.junit.Assert.assertEquals
import org.junit.Test

class FilesLogicTest {
    private fun nb(id: String, opened: Long = 0, size: Long = 0, page: Int = 0, pages: Int = 3) = LibraryEntry(
        id, id, EntryType.DOCUMENT, "", 0, false, "notebook", List(pages) { "p$it" }, emptyList(),
        lastOpenedPage = page, lastOpened = opened, sizeBytes = size,
    )

    private val lib = Library(listOf(nb("a", opened = 10, size = 500), nb("b", opened = 30, size = 100), nb("c", opened = 20, size = 900)))
    private fun order(sort: SortBy, reversed: Boolean = false) =
        visibleEntries(lib, Screen.Files(), sort, reversed, emptySet(), false).map { it.id }

    @Test fun lastOpenedSortsMostRecentFirst() {
        assertEquals(listOf("b", "c", "a"), order(SortBy.LAST_OPENED))
        assertEquals(listOf("a", "c", "b"), order(SortBy.LAST_OPENED, reversed = true))
    }

    @Test fun fileSizeSortsLargestFirst() {
        assertEquals(listOf("c", "a", "b"), order(SortBy.SIZE))
        assertEquals(true, naturalDescending(SortBy.SIZE) && naturalDescending(SortBy.LAST_OPENED))
    }

    @Test fun captionShowsTheLastOpenedPageWithinRange() {
        assertEquals("Page 1 of 3", pageCaption(nb("x")))
        assertEquals("Page 3 of 3", pageCaption(nb("x", page = 2)))
        assertEquals("Page 3 of 3", pageCaption(nb("x", page = 9)))
    }

    @Test fun sizesAreWrittenLikeTheFirmware() {
        assertEquals("0 B", formatSize(0))
        assertEquals("845 kB", formatSize(845_000))
        assertEquals("3.2 MB", formatSize(3_200_000))
    }
}
