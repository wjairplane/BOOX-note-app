package app.inkbridge.rm.library

import kotlinx.serialization.json.*
import java.io.File
import java.util.UUID

/**
 * Creates documents in the same on-disk layout the tablet uses (`<id>.metadata`, `<id>.content`,
 * `<id>.pdf`, `<id>/<page>.rm`), inside the app's local library mirror.
 *
 * NOTE: documents created here are read correctly by this app. Whether the tablet itself accepts
 * them when copied over has not been verified against a real device; the `.content` written is the
 * older `pages`-list form.
 */
object DocumentFactory {
    /**
     * Register a PDF already copied to `<dir>/<id>.pdf` as a document of [pageCount] pages.
     * Returns the new entry's id. Annotation pages are created lazily when first drawn on.
     */
    fun createPdfDocument(
        dir: File,
        name: String,
        pageCount: Int,
        sizeInBytes: Long,
        parentId: String = "",
        id: String = UUID.randomUUID().toString(),
        now: Long = System.currentTimeMillis(),
        pageIds: List<String> = List(pageCount) { UUID.randomUUID().toString() },
    ): String {
        require(pageCount > 0) { "PDF has no pages" }
        require(pageIds.size == pageCount) { "need one page id per page" }

        val metadata = buildJsonObject {
            put("deleted", false)
            put("lastModified", now.toString())
            put("lastOpened", "")
            put("lastOpenedPage", 0)
            put("metadatamodified", false)
            put("modified", false)
            put("parent", parentId)
            put("pinned", false)
            put("synced", false)
            put("type", "DocumentType")
            put("version", 0)
            put("visibleName", name)
        }
        val content = buildJsonObject {
            put("coverPageNumber", 0)
            put("dummyDocument", false)
            putJsonObject("extraMetadata") {}
            put("fileType", "pdf")
            put("fontName", "")
            put("lastOpenedPage", 0)
            put("lineHeight", -1)
            put("margins", 125)
            put("orientation", "portrait")
            put("originalPageCount", pageCount)
            put("pageCount", pageCount)
            putJsonArray("pageTags") {}
            putJsonArray("pages") { pageIds.forEach { add(it) } }
            putJsonArray("redirectMap") { repeat(pageCount) { add(it) } }
            put("sizeInBytes", sizeInBytes.toString())
            putJsonArray("tags") {}
            put("textAlignment", "left")
            put("textScale", 1)
            put("zoomMode", "bestFit")
        }
        File(dir, "$id.metadata").writeText(metadata.toString())
        File(dir, "$id.content").writeText(content.toString())
        File(dir, id).mkdirs()
        return id
    }

    /** Local path of a PDF document's source file. */
    fun pdfFile(dir: File, entry: LibraryEntry): File = File(dir, entry.id + ".pdf")

    /** PDF page index shown for notebook page [pageIndex]: the redirect map entry, or the index itself. -1 = blank inserted page. */
    fun pdfPageFor(entry: LibraryEntry, pageIndex: Int): Int = entry.redirectMap.getOrNull(pageIndex) ?: pageIndex
}
