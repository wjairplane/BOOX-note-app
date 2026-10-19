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
import kotlinx.coroutines.withContext

/** Which list of the file browser is showing. */
enum class Section(val title: String) { MY_FILES("My files"), NOTEBOOKS("Notebooks"), PDFS("PDFs"), FAVORITES("Favorites"), TAGS("Tags"), TRASH("Trash") }

/** Header and text of the black "Unable to open" sheet. */
data class InfoMessage(val header: String, val text: String)

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
    private var shownScreen by mutableStateOf<Screen>(Screen.Files())
    var screen: Screen
        get() = shownScreen
        set(v) {
            val was = shownScreen
            shownScreen = v
            if (v is Screen.Notebook && (was as? Screen.Notebook)?.docId != v.docId) scheduleOpenedStamp(v.docId)
        }
    /** The panel floating over the current screen (quick settings, the document drawer), opened by an edge swipe. */
    /** Set by the open notebook so "Refresh screen" in quick settings can clear its pen layer too. */
    var onRefresh: (() -> Unit)? = null
    var overlay by mutableStateOf<app.inkbridge.ui.Overlay?>(null)
    /** The bottom notification bar's text ("3 items were moved to Trash", errors, progress); empty = no bar. */
    var message by mutableStateOf("")

    /** True when [message] reports a success (a white bar); errors and progress texts get the firmware's default black bar. */
    var messageIsSuccess by mutableStateOf(false)

    /** Serialises the read-modify-write edits of the metadata files (closing a page and saving it both write them). */
    private val fileLock = Any()

    /** Ids of the items being moved while the file browser is in its Move mode (null = not moving). */
    var moving by mutableStateOf<List<String>?>(null)

    /** An item to select when the file browser next opens (search results reveal an item in its folder). */
    var pendingSelect by mutableStateOf<String?>(null)

    /** The list the search was opened from; its filter is the search's first one ("Notebooks", "Favorites", ...). */
    var searchFrom: Section = Section.MY_FILES

    val thumbnails = Thumbnails(store)

    /** The black "Unable to open" sheet (InfoDialog) over the current screen; null = none. */
    var info by mutableStateOf<InfoMessage?>(null)

    /** True on BOOX/Onyx tablets, where the stylus goes through the Onyx pen SDK. */
    val isBoox: Boolean = android.os.Build.MANUFACTURER.equals("onyx", ignoreCase = true) || android.os.Build.BRAND.equals("onyx", ignoreCase = true)

    init {
        // The very first start: fill an empty library with the documents a new reMarkable ships with.
        scope.launch(Dispatchers.IO) { runCatching { synchronized(fileLock) { store.seedDefaultLibraryOnce() } }; publish(store.load()) }
    }

    /** Run [block] on the main thread and wait for it (Compose state should only be written there). Call from background threads. */
    private fun <T> onMain(block: () -> T): T = kotlinx.coroutines.runBlocking(Dispatchers.Main) { block() }

    private fun publish(lib: Library) = onMain { library = lib }

    private fun say(text: String, success: Boolean = false) = onMain { message = text; messageIsSuccess = success }

    fun reload() {
        scope.launch(Dispatchers.IO) { publish(store.load()) }
    }

    /** Run [block] off the main thread, then refresh. [onDone] runs after the library has been reloaded. */
    private fun io(failure: String, onDone: (() -> Unit)? = null, notice: String? = null, block: () -> Unit) {
        scope.launch(Dispatchers.IO) {
            try {
                synchronized(fileLock) { block() }
                publish(store.load())
                notice?.let { say(it, success = true) }
                onDone?.let { done -> onMain { done() } }
            } catch (e: Exception) {
                say(failure)
            }
        }
    }

    /** Create a notebook and open it. [coverPage] is -1 (the last visited page) or 0 (the first page). */
    fun newNotebook(name: String, template: PageTemplate, parentId: String, coverPage: Int = -1) {
        io("Unable to create '$name'", onDone = null) {
            val id = LibraryOps.createNotebook(store.dir, name, parentId, template, coverPage = coverPage)
            publish(store.load())
            onMain { screen = Screen.Notebook(id, 0) }
        }
    }

    /**
     * The one "Quick sheets" notebook: a blank page is added only when the last page has ink, otherwise the last (empty)
     * page is reused; the notebook opens on that page.
     */
    fun newQuickSheet() {
        io("Unable to create '$QUICK_SHEETS'") {
            val lib = store.load()
            val existing = lib.entries.firstOrNull { !it.isFolder && it.fileType == "notebook" && it.name == QUICK_SHEETS && it.parentId != Library.TRASH }
            val id: String
            val page: Int
            if (existing == null) {
                id = LibraryOps.createNotebook(store.dir, QUICK_SHEETS, "", PageTemplate.BLANK)
                page = 0
            } else {
                id = existing.id
                val last = existing.pageIds.lastIndex
                val f = app.inkbridge.rm.library.LibraryScanner.pageFile(store.dir, existing, last)
                if (f.isFile && f.length() > 0) { LibraryOps.addPage(store.dir, existing, last); page = last + 1 } else page = last
            }
            publish(store.load())
            onMain { screen = Screen.Notebook(id, page) }
        }
    }

    /** Copy notebooks and folders next to the originals. */
    fun duplicate(es: List<LibraryEntry>) = io("Unable to duplicate", notice = plural(es.size, "%n item(s) were duplicated")) { es.forEach { LibraryOps.duplicate(store.dir, it.id) } }

    /**
     * The firmware's plural texts, e.g. "%n item(s) were deleted": the English file has the same text for every count (it is the source
     * string), so the device shows "1 item(s) were deleted" too.
     */
    private fun plural(n: Int, text: String) = text.replace("%n", n.toString())

    fun trashAll(es: List<LibraryEntry>) = io("Unable to move to Trash", notice = plural(es.size, "%n item(s) were moved to Trash")) { es.forEach { LibraryOps.trash(store.dir, it.id) } }

    fun restoreAll(es: List<LibraryEntry>) = io("Unable to restore", notice = plural(es.size, "%n item(s) were restored to My files")) { es.forEach { LibraryOps.restore(store.dir, it.id) } }

    fun deleteAll(es: List<LibraryEntry>) = io("Unable to delete", notice = plural(es.size, "%n item(s) were deleted")) { es.forEach { LibraryOps.deletePermanently(store.dir, it.id) } }

    fun moveAll(es: List<LibraryEntry>, parentId: String) = io("Unable to move") { es.forEach { LibraryOps.moveTo(store.dir, it.id, parentId) } }

    fun setPinned(es: List<LibraryEntry>, pinned: Boolean) = io("Unable to change favorites") { es.forEach { LibraryOps.setPinned(store.dir, it.id, pinned) } }

    /** Export every page of the given notebooks and PDFs (SVG, PNG and PDF per page) into [outDir]. */
    fun exportDocuments(es: List<LibraryEntry>, outDir: java.io.File) {
        val docs = es.filter { !it.isFolder }
        say(if (docs.size == 1) "Exporting file..." else "Exporting ${docs.size} files...")
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
                say("Finished exporting '${docs.singleOrNull()?.name ?: "$files files"}' to '${outDir.absolutePath}'", success = true)
            } catch (e: Exception) { say("Unable to export document") }
        }
    }

    fun setTags(e: LibraryEntry, tags: List<String>) = io("Unable to change tags") { LibraryOps.setTags(store.dir, e.id, tags) }

    /** Tag single pages (the firmware's "Tag" action in the page overview); each page's earlier tags are replaced. */
    fun setPageTags(e: LibraryEntry, pageIndices: Collection<Int>, tags: List<String>) = io("Unable to change tags") {
        LibraryOps.setPageTags(store.dir, e.id, pageIndices.mapNotNull { e.pageIds.getOrNull(it) }, tags)
    }

    /** Rename a tag on every item that carries it (merging with an existing tag of that name). */
    fun renameTag(old: String, new: String) {
        val name = new.trim()
        if (name.isEmpty() || name == old) return
        io("Unable to rename tag") {
            for (e in store.load().entries.filter { old in it.tags }) LibraryOps.setTags(store.dir, e.id, e.tags.map { if (it == old) name else it })
            for (e in store.load().entries.filter { en -> en.pageTags.values.any { old in it } }) LibraryOps.mapPageTags(store.dir, e.id) { if (it == old) name else it }
        }
    }

    /** Remove tags from every item that carries them. */
    fun deleteTags(names: Set<String>) =
        io("Unable to delete tags", notice = plural(names.size, "%n tag(s) were deleted")) {
            for (e in store.load().entries.filter { it.tags.any { t -> t in names } }) LibraryOps.setTags(store.dir, e.id, e.tags.filter { it !in names })
            for (e in store.load().entries.filter { en -> en.pageTags.values.any { l -> l.any { it in names } } }) LibraryOps.mapPageTags(store.dir, e.id) { if (it in names) null else it }
        }

    fun newFolder(name: String, parentId: String, tags: List<String> = emptyList(), onCreated: ((String) -> Unit)? = null) {
        var id = ""
        io("Unable to create '$name'", onDone = { onCreated?.invoke(id) }) {
            id = LibraryOps.createFolder(store.dir, name, parentId)
            if (tags.isNotEmpty()) LibraryOps.setTags(store.dir, id, tags)
        }
    }

    fun setCoverPage(e: LibraryEntry, cover: Int) = io("Unable to change cover") { LibraryOps.setCoverPage(store.dir, e.id, cover) }

    fun rename(e: LibraryEntry, name: String) = io("Unable to rename") { LibraryOps.rename(store.dir, e.id, name) }

    fun togglePinned(e: LibraryEntry) = io("Unable to change favorites") { LibraryOps.setPinned(store.dir, e.id, !e.pinned) }

    fun move(e: LibraryEntry, parentId: String) = io("Unable to move") { LibraryOps.moveTo(store.dir, e.id, parentId) }

    fun trash(e: LibraryEntry) = io("Unable to move to Trash") { LibraryOps.trash(store.dir, e.id) }

    fun restore(e: LibraryEntry) = io("Unable to restore") { LibraryOps.restore(store.dir, e.id) }

    fun deleteForever(e: LibraryEntry) = io("Unable to delete") { LibraryOps.deletePermanently(store.dir, e.id) }

    fun emptyTrash() {
        val n = library.trash.size
        io("Unable to delete", notice = plural(n, "%n item(s) were deleted")) { LibraryOps.emptyTrash(store.dir) }
    }

    fun setTemplate(e: LibraryEntry, t: PageTemplate) = io("Unable to change template") { LibraryOps.setTemplate(store.dir, e.id, t) }

    /** Add a page after [afterIndex]; [onAdded] gets the new page's index. */
    fun addPage(e: LibraryEntry, afterIndex: Int, onAdded: (Int) -> Unit) =
        io("Unable to add page") { LibraryOps.addPage(store.dir, e, afterIndex); publish(store.load()); onMain { onAdded(afterIndex + 1) } }

    /** Delete several pages at once (highest first, so the indices stay valid); at least one page always remains. */
    fun deletePages(e: LibraryEntry, indices: Set<Int>, onDone: () -> Unit) =
        io("Unable to delete pages") {
            var deleted = false
            for (i in indices.sortedDescending()) deleted = LibraryOps.deletePage(store.dir, store.load()[e.id] ?: e, i) || deleted
            if (deleted) onMain { onDone() }
        }

    fun deletePage(e: LibraryEntry, index: Int, onDone: () -> Unit) =
        io("Unable to delete page") { if (LibraryOps.deletePage(store.dir, e, index)) { publish(store.load()); onMain { onDone() } } }

    /** Mark a notebook as edited (bumps its modified time so it sorts to the top). */
    fun touch(e: LibraryEntry) { scope.launch(Dispatchers.IO) { runCatching { synchronized(fileLock) { LibraryOps.touch(store.dir, e.id) }; publish(store.load()) } } }

    /**
     * Remember the page a document was closed on: it drives the cover thumbnail and the "Page N of M" caption. The "last opened"
     * time is not touched here: like the firmware, [scheduleOpenedStamp] sets it only once the document has stayed open for 5 s.
     */
    fun markOpened(docId: String, page: Int) {
        scope.launch(Dispatchers.IO) { runCatching { synchronized(fileLock) { LibraryOps.setLastOpened(store.dir, docId, page, stamp = false) }; publish(store.load()) } }
    }

    private var openedStamp: kotlinx.coroutines.Job? = null

    /** xochitl's `updateLastOpened` timer: a document that is still the open one after [LibraryOps.OPEN_STAMP_DELAY_MS] gets its `lastOpened` time. */
    private fun scheduleOpenedStamp(docId: String) {
        openedStamp?.cancel()
        openedStamp = scope.launch {
            kotlinx.coroutines.delay(LibraryOps.OPEN_STAMP_DELAY_MS)
            if ((shownScreen as? Screen.Notebook)?.docId != docId) return@launch
            withContext(Dispatchers.IO) {
                runCatching {
                    synchronized(fileLock) {
                        LibraryOps.setLastOpenedTime(store.dir, docId)
                    }
                    publish(store.load())
                }
            }
        }
    }

    fun importPdf(uri: Uri, parentId: String) {
        message = "Importing file..."; messageIsSuccess = false
        scope.launch(Dispatchers.IO) {
            try {
                val entry = store.importPdf(uri, parentId)
                publish(store.load())
                say("File imported", success = true)
            } catch (e: Exception) {
                // The firmware's black "Unable to open" sheet, with the reason as its text.
                onMain { message = ""; info = InfoMessage("Unable to open", importFailureText(e)) }
            }
        }
    }

    /** Next untitled name: "Notebook", then "Notebook 2", ... unique within [parentId]. */
    fun suggestName(parentId: String, base: String = "Notebook"): String {
        val taken = library.children(parentId).map { it.name }.toSet()
        if (base !in taken) return base
        return generateSequence(2) { it + 1 }.map { "$base $it" }.first { it !in taken }
    }

    /** Erase the whole library (the passcode reset, like the firmware's reset, deletes the files on the device). */
    fun eraseEverything() {
        scope.launch(Dispatchers.IO) {
            synchronized(fileLock) { store.dir.listFiles()?.forEach { it.deleteRecursively() } }
            publish(store.load())
        }
    }

    companion object {
        /** The InfoDialog text for a PDF that could not be imported ([LibraryStore.importPdf] throws these messages). */
        fun importFailureText(e: Exception): String = when (e.message) {
            LibraryStore.PASSWORD_PROTECTED -> "Password protected PDF"
            else -> "This document contains data that is not supported."
        }

        const val QUICK_SHEETS = "Quick sheets"
    }
}
