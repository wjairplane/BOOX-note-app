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
enum class Section(val title: String) { MY_FILES("My files"), NOTEBOOKS("Notebooks"), PDFS("PDFs"), FAVORITES("Favorites"), TAGS("Tags"), TRASH("Trash") }

sealed interface Screen {
    data class Files(val section: Section = Section.MY_FILES, val folderId: String = "") : Screen
    data object Settings : Screen
    data object Search : Screen
    data object Guides : Screen
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

    /** Run [block] on the main thread and wait for it (Compose state should only be written there). Call from background threads. */
    private fun <T> onMain(block: () -> T): T = kotlinx.coroutines.runBlocking(Dispatchers.Main) { block() }

    private fun publish(lib: Library) = onMain { library = lib }

    private fun say(text: String) = onMain { message = text }

    fun reload() {
        scope.launch(Dispatchers.IO) { publish(store.load()) }
    }

    /** Run [block] off the main thread, then refresh. [onDone] runs after the library has been reloaded. */
    private fun io(failure: String, onDone: (() -> Unit)? = null, block: () -> Unit) {
        scope.launch(Dispatchers.IO) {
            try {
                block()
                publish(store.load())
                onDone?.let { done -> onMain { done() } }
            } catch (e: Exception) {
                say("$failure: ${e.message ?: e.javaClass.simpleName}")
            }
        }
    }

    fun newNotebook(name: String, template: PageTemplate, parentId: String) {
        io("Couldn't create the notebook", onDone = null) {
            val id = LibraryOps.createNotebook(store.dir, name, parentId, template)
            publish(store.load())
            onMain { screen = Screen.Notebook(id, 0) }
        }
    }

    /** A one-page notebook to jot something down: created at the top level and opened straight away. */
    fun newQuickSheet() = newNotebook(suggestName("", "Quick sheet"), PageTemplate.BLANK, "")

    /** Copy notebooks and folders next to the originals. */
    fun duplicate(es: List<LibraryEntry>) = io("Couldn't duplicate") { es.forEach { LibraryOps.duplicate(store.dir, it.id) } }

    /** Export every page of the given notebooks and PDFs (SVG, PNG and PDF per page) into [outDir]. */
    fun exportDocuments(es: List<LibraryEntry>, outDir: java.io.File) {
        say("Exporting…")
        scope.launch(Dispatchers.IO) {
            try {
                var files = 0
                for (doc in es.filter { !it.isFolder }) {
                    val safe = doc.name.replace(Regex("[^A-Za-z0-9._-]+"), "_").trim('_').ifEmpty { "document" }
                    for (i in doc.pageIds.indices) {
                        val bg = if (doc.fileType == "pdf") app.inkbridge.rm.library.DocumentFactory.pdfPageFor(doc, i).takeIf { it >= 0 }
                            ?.let { PdfBackground(app.inkbridge.rm.library.DocumentFactory.pdfFile(store.dir, doc), it) } else null
                        val session = PageSession(app.inkbridge.rm.library.LibraryScanner.pageFile(store.dir, doc, i), bg, doc.template)
                        files += session.export(outDir, "${safe}_p${i + 1}").size
                    }
                }
                say("Exported $files files to ${outDir.absolutePath}")
            } catch (e: Exception) { say("Export failed: ${e.message}") }
        }
    }

    fun setTags(e: LibraryEntry, tags: List<String>) = io("Couldn't change the tags") { LibraryOps.setTags(store.dir, e.id, tags) }

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
        io("Couldn't add a page") { LibraryOps.addPage(store.dir, e, afterIndex); publish(store.load()); onMain { onAdded(afterIndex + 1) } }

    /** Delete several pages at once (highest first, so the indices stay valid); at least one page always remains. */
    fun deletePages(e: LibraryEntry, indices: Set<Int>, onDone: () -> Unit) =
        io("Couldn't delete the pages") {
            var deleted = false
            for (i in indices.sortedDescending()) deleted = LibraryOps.deletePage(store.dir, store.load()[e.id] ?: e, i) || deleted
            if (deleted) onMain { onDone() }
        }

    fun deletePage(e: LibraryEntry, index: Int, onDone: () -> Unit) =
        io("Couldn't delete the page") { if (LibraryOps.deletePage(store.dir, e, index)) { publish(store.load()); onMain { onDone() } } }

    /** Mark a notebook as edited (bumps its modified time so it sorts to the top). */
    fun touch(e: LibraryEntry) { scope.launch(Dispatchers.IO) { runCatching { LibraryOps.touch(store.dir, e.id); publish(store.load()) } } }

    fun importPdf(uri: Uri, parentId: String) {
        message = "Importing PDF…"
        scope.launch(Dispatchers.IO) {
            try {
                val entry = store.importPdf(uri, parentId)
                publish(store.load())
                say("Imported “${entry.name}” (${entry.pageIds.size} pages)")
            } catch (e: Exception) {
                say("PDF import failed: ${e.message}")
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
