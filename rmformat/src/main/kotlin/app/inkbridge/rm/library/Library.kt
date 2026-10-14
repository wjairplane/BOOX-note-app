package app.inkbridge.rm.library

import kotlinx.serialization.json.*
import java.io.File

enum class EntryType { FOLDER, DOCUMENT }

/** A folder or document from the tablet's `xochitl` directory. */
data class LibraryEntry(
    val id: String,
    val name: String,
    val type: EntryType,
    /** Parent folder id; "" = top level, "trash" = trash. */
    val parentId: String,
    val lastModified: Long,
    val pinned: Boolean,
    /** `notebook`, `pdf`, `epub`, ... from `.content`; null for folders. */
    val fileType: String?,
    /** Page ids in display order (deleted pages removed). Page `i` is `<id>/<pageId>.rm`. */
    val pageIds: List<String>,
    /** For PDFs: page index → PDF page number (-1 = inserted blank page), when `.content` has a redirect map. */
    val redirectMap: List<Int>,
    /** Page background for notebooks (an app extension key in `.content`; blank when absent). */
    val template: app.inkbridge.rm.render.PageTemplate = app.inkbridge.rm.render.PageTemplate.BLANK,
    /** Tag names, from `.content` `tags` (the tablet keeps `{name, timestamp}` objects there). */
    val tags: List<String> = emptyList(),
) {
    val isFolder get() = type == EntryType.FOLDER
}

/**
 * The document library. The tablet stores a flat set of `<uuid>.metadata` files; the folder tree
 * only exists as each entry's `parent` field.
 */
class Library(entries: Collection<LibraryEntry>) {
    private val byId = entries.associateBy { it.id }
    val entries: List<LibraryEntry> get() = byId.values.toList()

    operator fun get(id: String): LibraryEntry? = byId[id]

    /** Entries directly inside [parentId] ("" for top level), folders first, then by name. */
    fun children(parentId: String = ""): List<LibraryEntry> =
        byId.values.filter { it.parentId == parentId }
            .sortedWith(compareBy<LibraryEntry>({ !it.isFolder }, { it.name.lowercase() }))

    val trash: List<LibraryEntry> get() = children(TRASH)

    /** Folder names from the top level down to (not including) the entry itself. */
    fun path(id: String): List<String> {
        val out = ArrayDeque<String>()
        var cur = byId[id]?.parentId
        val seen = HashSet<String>()
        while (!cur.isNullOrEmpty() && cur != TRASH && seen.add(cur)) {
            val f = byId[cur] ?: break
            out.addFirst(f.name)
            cur = f.parentId
        }
        return out.toList()
    }

    companion object {
        const val TRASH = "trash"
    }
}

object LibraryScanner {
    /**
     * Read every `<uuid>.metadata` (and its `.content`) in [dir], a local copy of the tablet's
     * xochitl folder. Entries marked deleted are skipped; unreadable files are skipped and
     * reported through [onProblem].
     */
    fun scan(dir: File, onProblem: (File, Exception) -> Unit = { _, _ -> }): Library {
        val entries = ArrayList<LibraryEntry>()
        val metas = dir.listFiles { f -> f.isFile && f.name.endsWith(".metadata") }.orEmpty()
        for (meta in metas.sortedBy { it.name }) {
            try {
                parseEntry(meta.name.removeSuffix(".metadata"), meta.readText(), File(dir, meta.name.removeSuffix(".metadata") + ".content").takeIf { it.isFile }?.readText())
                    ?.let { entries += it }
            } catch (e: Exception) {
                onProblem(meta, e)
            }
        }
        return Library(entries)
    }

    /** Parse one entry from its `.metadata` and (optional) `.content` JSON text. Null if marked deleted. */
    fun parseEntry(id: String, metadataJson: String, contentJson: String?): LibraryEntry? {
        val m = Json.parseToJsonElement(metadataJson).jsonObject
        if (m.bool("deleted")) return null
        val isFolder = m.str("type") == "CollectionType"
        val content = contentJson?.let { runCatching { Json.parseToJsonElement(it).jsonObject }.getOrNull() }
        return LibraryEntry(
            id = id,
            name = m.str("visibleName") ?: id,
            type = if (isFolder) EntryType.FOLDER else EntryType.DOCUMENT,
            parentId = m.str("parent") ?: "",
            lastModified = m.str("lastModified")?.toLongOrNull() ?: 0L,
            pinned = m.bool("pinned"),
            fileType = if (isFolder) null else content?.str("fileType")?.ifEmpty { null } ?: "notebook",
            pageIds = if (isFolder) emptyList() else content?.let(::pageIds).orEmpty(),
            redirectMap = content?.get("redirectMap")?.let { it as? JsonArray }
                ?.mapNotNull { (it as? JsonPrimitive)?.intOrNull }.orEmpty(),
            template = app.inkbridge.rm.render.PageTemplate.fromId(content?.str("template")),
            tags = (content?.get("tags") as? JsonArray).orEmpty().mapNotNull { t ->
                (t as? JsonObject)?.str("name") ?: (t as? JsonPrimitive)?.contentOrNull
            }.distinct(),
        )
    }

    /** Newer firmware lists pages under `cPages.pages[]` (with per-page `deleted` markers); older uses `pages[]`. */
    private fun pageIds(content: JsonObject): List<String> {
        val cPages = (content["cPages"] as? JsonObject)?.get("pages") as? JsonArray
        if (cPages != null) {
            return cPages.mapNotNull { p ->
                val o = p as? JsonObject ?: return@mapNotNull null
                if (o["deleted"] != null) null else o.str("id")
            }
        }
        return (content["pages"] as? JsonArray)?.mapNotNull { (it as? JsonPrimitive)?.contentOrNull }.orEmpty()
    }

    /** `<dir>/<docId>/<pageId>.rm`, which doesn't exist for pages that were never drawn on. */
    fun pageFile(dir: File, entry: LibraryEntry, pageIndex: Int): File =
        File(File(dir, entry.id), entry.pageIds[pageIndex] + ".rm")

    private fun JsonObject.str(key: String) = (this[key] as? JsonPrimitive)?.contentOrNull
    private fun JsonObject.bool(key: String) = (this[key] as? JsonPrimitive)?.booleanOrNull ?: false
}
