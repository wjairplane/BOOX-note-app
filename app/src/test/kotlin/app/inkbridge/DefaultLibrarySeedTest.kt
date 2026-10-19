package app.inkbridge

import android.app.Application
import app.inkbridge.rm.library.LibraryOps
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class DefaultLibrarySeedTest {
    @Test fun seedsAnEmptyLibraryOnceAndNeverAgain() {
        val store = LibraryStore(RuntimeEnvironment.getApplication() as Application)
        assertTrue(store.seedDefaultLibraryOnce())
        val lib = store.load()
        assertEquals(setOf("Learn the basics", "Go further"), lib.entries.map { it.name }.toSet())
        // Deleting them must not bring them back on the next start.
        for (e in lib.entries) LibraryOps.deletePermanently(store.dir, e.id)
        assertFalse(store.seedDefaultLibraryOnce())
        assertEquals(0, store.load().entries.size)
    }

    @Test fun leavesAnExistingLibraryAlone() {
        val store = LibraryStore(RuntimeEnvironment.getApplication() as Application)
        LibraryOps.createNotebook(store.dir, "Mine")
        assertFalse(store.seedDefaultLibraryOnce())
        assertEquals(listOf("Mine"), store.load().entries.map { it.name })
    }
}
