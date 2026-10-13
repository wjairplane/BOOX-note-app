package app.inkbridge

import android.net.Uri
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import app.inkbridge.rm.library.Library
import app.inkbridge.rm.library.LibraryEntry
import app.inkbridge.rm.library.LibraryOps
import app.inkbridge.rm.render.PageTemplate
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/** Which list of the file browser is showing. */
enum class Section(val title: String) { MY_FILES("My files"), FAVORITES("Favorites"), TRASH("Trash") }

sealed interface Screen {
    data class Files(val section: Section = Section.MY_FILES, val folderId: String = "") : Screen
    data object Settings : Screen
    data class Notebook(val docId: String, val page: Int = 0) : Screen
}

/**
 * App-wide state: navigation, the library, and every file operation. Operations run on a
 * background thread and refresh the library when done; failures surface in [message].
 */
class AppController(val store: LibraryStore, val prefs: Prefs, private val scope: CoroutineScope) {
    var library by mutableStateOf(Library(emptyList()))
        private set
    var screen by mutableStateOf<Screen>(Screen.Files())
    var message by mutableStateOf("")

    val thumbnails = Thumbnails(store)

    /** True on BOOX/Onyx tablets, where the stylus goes through the Onyx pen SDK. */
    val isBoox: Boolean = android.os.Build.MANUFACTURER.equals("onyx", ignoreCase = true) || android.os.Build.BRAND.equals("onyx", ignoreCase = true)

    init { reload() }

    fun reload() {
        scope.launch(Dispatchers.IO) { library = store.load() }
    }

    /** Run [block] off the main thread, then refresh. [onDone] runs after the library has been reloaded. */
    private fun io(failure: String, onDone: (() -> Unit)? = null, block: () -> Unit) {
        scope.launch(Dispatchers.IO) {
            try {
                block()
                library = store.load()
                onDone?.invoke()
            } catch (e: Exception) {
                message = "$failure: ${e.message ?: e.javaClass.simpleName}"
            }
        }
    }

    fun newNotebook(name: String, template: PageTemplate, parentId: String) {
        io("Couldn't create the notebook", onDone = null) {
            val id = LibraryOps.createNotebook(store.dir, name, parentId, template)
            library = store.load()
            screen = Screen.Notebook(id, 0)
        }
    }

    fun newFolder(name: String, parentId: String) = io("Couldn't create the folder") { LibraryOps.createFolder(store.dir, name, parentId) }

    fun rename(e: LibraryEntry, name: String) = io("Couldn't rename") { LibraryOps.rename(store.dir, e.id, name) }

    fun togglePinned(e: LibraryEntry) = io("Couldn't change the favourite") { LibraryOps.setPinned(store.dir, e.id, !e.pinned) }

    fun move(e: LibraryEntry, parentId: String) = io("Couldn't move") { LibraryOps.moveTo(store.dir, e.id, parentId) }

    fun trash(e: LibraryEntry) = io("Couldn't move to the trash") { LibraryOps.trash(store.dir, e.id) }

    fun restore(e: LibraryEntry) = io("Couldn't restore") { LibraryOps.restore(store.dir, e.id) }

    fun deleteForever(e: LibraryEntry) = io("Couldn't delete") { LibraryOps.deletePermanently(store.dir, e.id) }

    fun emptyTrash() = io("Couldn't empty the trash") { LibraryOps.emptyTrash(store.dir) }

    fun setTemplate(e: LibraryEntry, t: PageTemplate) = io("Couldn't change the template") { LibraryOps.setTemplate(store.dir, e.id, t) }

    /** Add a page after [afterIndex]; [onAdded] gets the new page's index. */
    fun addPage(e: LibraryEntry, afterIndex: Int, onAdded: (Int) -> Unit) =
        io("Couldn't add a page") { LibraryOps.addPage(store.dir, e, afterIndex); library = store.load(); onAdded(afterIndex + 1) }

    fun deletePage(e: LibraryEntry, index: Int, onDone: () -> Unit) =
        io("Couldn't delete the page") { if (LibraryOps.deletePage(store.dir, e, index)) { library = store.load(); onDone() } }

    /** Mark a notebook as edited (bumps its modified time so it sorts to the top). */
    fun touch(e: LibraryEntry) { scope.launch(Dispatchers.IO) { runCatching { LibraryOps.touch(store.dir, e.id); library = store.load() } } }

    fun importPdf(uri: Uri, parentId: String) {
        message = "Importing PDF…"
        scope.launch(Dispatchers.IO) {
            message = try {
                val entry = store.importPdf(uri, parentId)
                library = store.load()
                "Imported “${entry.name}” (${entry.pageIds.size} pages)"
            } catch (e: Exception) {
                "PDF import failed: ${e.message}"
            }
        }
    }

    /** Next untitled name: "Notebook", then "Notebook 2", ... unique within [parentId]. */
    fun suggestName(parentId: String, base: String = "Notebook"): String {
        val taken = library.children(parentId).map { it.name }.toSet()
        if (base !in taken) return base
        return generateSequence(2) { it + 1 }.map { "$base $it" }.first { it !in taken }
    }
}
