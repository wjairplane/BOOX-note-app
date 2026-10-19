package app.inkbridge

import android.content.Context
import android.net.Uri
import android.provider.OpenableColumns
import app.inkbridge.rm.library.DefaultLibrary
import app.inkbridge.rm.library.DocumentFactory
import app.inkbridge.rm.library.Library
import app.inkbridge.rm.library.LibraryEntry
import app.inkbridge.rm.library.LibraryScanner
import java.io.File
import java.util.UUID

/** The app's own library folder: notebooks, folders and imported PDFs live here, in app-private storage. */
class LibraryStore(private val context: Context) {
    val dir: File = File(context.filesDir, "library").apply { mkdirs() }

    fun load(): Library = LibraryScanner.scan(dir)

    /**
     * First run only: put the documents a new reMarkable ships with ("Learn the basics", "Go further") into an empty library.
     * Remembered in its own preference, so documents the user deletes never come back. Returns true if they were installed.
     */
    fun seedDefaultLibraryOnce(): Boolean {
        val sp = context.getSharedPreferences("library_state", Context.MODE_PRIVATE)
        if (sp.getBoolean(SEEDED, false)) return false
        val empty = dir.listFiles { f -> f.name.endsWith(".metadata") }.isNullOrEmpty()
        val installed = empty && runCatching { DefaultLibrary.install(dir) }.isSuccess
        // A failed install is retried on the next start; a non-empty library is never touched.
        if (installed || !empty) sp.edit().putBoolean(SEEDED, true).apply()
        return installed
    }

    /**
     * Copy a PDF picked by the user into the library as a new document in [parentId] ("" = top level).
     * Throws with a readable message if the file isn't a usable PDF (corrupt or password-protected).
     */
    fun importPdf(uri: Uri, parentId: String = ""): LibraryEntry {
        val id = UUID.randomUUID().toString()
        val target = File(dir, "$id.pdf")
        try {
            val input = context.contentResolver.openInputStream(uri) ?: error(UNREADABLE)
            input.use { src -> target.outputStream().use { src.copyTo(it) } }
            val pages = try {
                PdfBackground.pageCount(target)
            } catch (e: SecurityException) {
                throw IllegalStateException(PASSWORD_PROTECTED)
            } catch (e: Exception) {
                throw IllegalStateException(UNREADABLE)
            }
            check(pages > 0) { UNREADABLE }
            DocumentFactory.createPdfDocument(dir, displayName(uri).removeSuffix(".pdf").removeSuffix(".PDF"), pages, target.length(), parentId, id)
            return load()[id] ?: error(UNREADABLE)
        } catch (e: Exception) {
            target.delete()
            throw e
        }
    }

    private fun displayName(uri: Uri): String =
        context.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c ->
            if (c.moveToFirst()) c.getString(0) else null
        } ?: "Document"

    companion object {
        /** The failure reasons [importPdf] throws. */
        const val PASSWORD_PROTECTED = "Password protected PDF"
        const val UNREADABLE = "Unable to open"
        private const val SEEDED = "defaultLibrarySeeded"
    }
}
