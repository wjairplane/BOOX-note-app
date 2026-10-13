package app.inkbridge.rm.library

import java.io.File
import java.io.IOException
import java.nio.file.Files
import java.nio.file.StandardCopyOption

/** Safe reads and writes of page files in the local library mirror. */
object PageFiles {
    /** Suffix of the one-time backup made before a page is first overwritten. */
    const val BACKUP_SUFFIX = ".orig"

    /**
     * Write [bytes] to [file] without ever leaving a half-written page: write a temp file next to it,
     * then move it into place. The first time an existing page is overwritten, its previous content
     * is kept as `<name>.rm.orig`.
     */
    @Throws(IOException::class)
    fun save(file: File, bytes: ByteArray) {
        val parent = file.absoluteFile.parentFile ?: throw IOException("No parent folder for $file")
        if (!parent.isDirectory && !parent.mkdirs()) throw IOException("Cannot create $parent")

        if (file.isFile) {
            val backup = File(parent, file.name + BACKUP_SUFFIX)
            if (!backup.exists()) Files.copy(file.toPath(), backup.toPath())
        }

        val tmp = File(parent, file.name + ".tmp")
        tmp.writeBytes(bytes)
        try {
            Files.move(tmp.toPath(), file.toPath(), StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE)
        } catch (e: java.nio.file.AtomicMoveNotSupportedException) {
            Files.move(tmp.toPath(), file.toPath(), StandardCopyOption.REPLACE_EXISTING)
        }
    }
}
