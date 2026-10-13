package app.inkbridge

import android.content.Context
import android.net.Uri
import android.provider.OpenableColumns
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
     * Copy a PDF picked by the user into the library as a new document in [parentId] ("" = top level).
     * Throws with a readable message if the file isn't a usable PDF (corrupt or password-protected).
     */
    fun importPdf(uri: Uri, parentId: String = ""): LibraryEntry {
        val id = UUID.randomUUID().toString()
        val target = File(dir, "$id.pdf")
        try {
            val input = context.contentResolver.openInputStream(uri) ?: error("Cannot open the selected file")
            input.use { src -> target.outputStream().use { src.copyTo(it) } }
            val pages = try {
                PdfBackground.pageCount(target)
            } catch (e: SecurityException) {
                throw IllegalStateException("This PDF is password-protected, which isn't supported yet")
            } catch (e: Exception) {
                throw IllegalStateException("Couldn't read this PDF (${e.message ?: e.javaClass.simpleName})")
            }
            check(pages > 0) { "This PDF has no pages" }
            DocumentFactory.createPdfDocument(dir, displayName(uri).removeSuffix(".pdf").removeSuffix(".PDF"), pages, target.length(), parentId, id)
            return load()[id] ?: error("Imported PDF could not be found afterwards")
        } catch (e: Exception) {
            target.delete()
            throw e
        }
    }

    private fun displayName(uri: Uri): String =
        context.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c ->
            if (c.moveToFirst()) c.getString(0) else null
        } ?: "Document"
}
