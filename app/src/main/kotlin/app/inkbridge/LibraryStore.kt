package app.inkbridge

import android.content.Context
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import app.inkbridge.rm.library.Library
import app.inkbridge.rm.library.LibraryScanner
import java.io.File

/**
 * Local mirror of the tablet's files. Import copies a user-picked folder into app storage, so
 * the app only ever reads its own copy and never writes into the original or the tablet's folder.
 */
class LibraryStore(private val context: Context) {
    val dir: File = File(context.filesDir, "library").apply { mkdirs() }

    fun load(): Library = LibraryScanner.scan(dir)

    /** Copy everything under [tree] (a SAF tree URI) into the local mirror. Returns files copied. */
    fun import(tree: Uri, onProgress: (Int) -> Unit = {}): Int {
        val root = DocumentFile.fromTreeUri(context, tree) ?: error("Cannot open $tree")
        var count = 0
        fun copy(src: DocumentFile, dst: File) {
            if (src.isDirectory) {
                dst.mkdirs()
                src.listFiles().forEach { child -> child.name?.let { copy(child, File(dst, it)) } }
            } else if (src.isFile) {
                context.contentResolver.openInputStream(src.uri)?.use { input ->
                    dst.outputStream().use { input.copyTo(it) }
                }
                onProgress(++count)
            }
        }
        copy(root, dir)
        return count
    }
}
