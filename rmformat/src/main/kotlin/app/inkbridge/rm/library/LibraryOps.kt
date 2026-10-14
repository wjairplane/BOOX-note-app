package app.inkbridge.rm.library

import app.inkbridge.rm.render.PageTemplate
import kotlinx.serialization.json.*
import java.io.File
import java.util.UUID

/**
 * Creating and managing notebooks and folders in the local library, using the tablet-style layout
 * (`<id>.metadata`, `<id>.content`, `<id>/<page>.rm`). All operations act on files directly and
 * rewrite the small JSON documents atomically enough for a single-user app (write, then rename).
 */
object LibraryOps {

    fun createFolder(dir: File, name: String, parentId: String = "", id: String = newId(), now: Long = now()): String {
        writeJson(File(dir, "$id.metadata"), metadata(name, parentId, "CollectionType", now))
        writeJson(File(dir, "$id.content"), buildJsonObject {})
        return id
    }

    fun createNotebook(
        dir: File, name: String, parentId: String = "", template: PageTemplate = PageTemplate.BLANK,
        id: String = newId(), now: Long = now(), firstPageId: String = newId(),
    ): String {
        writeJson(File(dir, "$id.metadata"), metadata(name, parentId, "DocumentType", now))
        writeJson(File(dir, "$id.content"), buildJsonObject {
            put("fileType", "notebook")
            put("orientation", "portrait")
            put("pageCount", 1)
            putJsonArray("pages") { add(firstPageId) }
            putJsonArray("tags") {}
            put("template", template.id)
        })
        File(dir, id).mkdirs()
        return id
    }

    // ---- metadata edits ----

    fun rename(dir: File, id: String, newName: String) = editMetadata(dir, id) { it + ("visibleName" to JsonPrimitive(newName.trim())) }

    fun setPinned(dir: File, id: String, pinned: Boolean) = editMetadata(dir, id) { it + ("pinned" to JsonPrimitive(pinned)) }

    fun moveTo(dir: File, id: String, parentId: String) = editMetadata(dir, id) { it + ("parent" to JsonPrimitive(parentId)) }

    /** Replace the tags of a notebook or folder (stored as the tablet does: `tags: [{name, timestamp}]` in `.content`). */
    fun setTags(dir: File, id: String, tags: List<String>, now: Long = now()) = editContent(dir, id) { c ->
        c + ("tags" to buildJsonArray { tags.map { it.trim() }.filter { it.isNotEmpty() }.distinct().forEach { n -> add(buildJsonObject { put("name", n); put("timestamp", now) }) } })
    }

    /**
     * Copy a notebook, PDF or folder (with everything inside it) next to the original, named "<name> (copy)".
     * Returns the id of the copy.
     */
    fun duplicate(dir: File, id: String, now: Long = now()): String {
        fun copy(srcId: String, parentId: String, rename: Boolean): String {
            val newId = newId()
            File(dir, "$srcId.metadata").readText().let { Json.parseToJsonElement(it).jsonObject }.let { m ->
                val name = (m["visibleName"] as? JsonPrimitive)?.contentOrNull ?: srcId
                writeJson(File(dir, "$newId.metadata"), JsonObject(m + mapOf(
                    "visibleName" to JsonPrimitive(if (rename) "$name (copy)" else name),
                    "parent" to JsonPrimitive(parentId),
                    "lastModified" to JsonPrimitive(now.toString()),
                    "pinned" to JsonPrimitive(false),
                ) - "trashedFrom"))
            }
            File(dir, "$srcId.content").takeIf { it.isFile }?.copyTo(File(dir, "$newId.content"), overwrite = true)
            File(dir, "$srcId.pdf").takeIf { it.isFile }?.copyTo(File(dir, "$newId.pdf"), overwrite = true)
            File(dir, "$srcId.epub").takeIf { it.isFile }?.copyTo(File(dir, "$newId.epub"), overwrite = true)
            File(dir, srcId).takeIf { it.isDirectory }?.copyRecursively(File(dir, newId), overwrite = true)
            for (child in LibraryScanner.scan(dir).children(srcId)) copy(child.id, newId, rename = false)
            return newId
        }
        val parent = (Json.parseToJsonElement(File(dir, "$id.metadata").readText()).jsonObject["parent"] as? JsonPrimitive)?.contentOrNull ?: ""
        return copy(id, parent, rename = true)
    }

    /** Record that the document changed (bumps `lastModified`). */
    fun touch(dir: File, id: String, now: Long = now()) = editMetadata(dir, id) { it + ("lastModified" to JsonPrimitive(now.toString())) }

    /** Move to the trash, remembering where it came from so [restore] can put it back. */
    fun trash(dir: File, id: String) = editMetadata(dir, id) { m ->
        val parent = (m["parent"] as? JsonPrimitive)?.contentOrNull ?: ""
        if (parent == Library.TRASH) m
        else m + ("parent" to JsonPrimitive(Library.TRASH)) + ("trashedFrom" to JsonPrimitive(parent))
    }

    /** Put a trashed item back where it was (top level if that folder no longer exists). */
    fun restore(dir: File, id: String) = editMetadata(dir, id) { m ->
        val from = (m["trashedFrom"] as? JsonPrimitive)?.contentOrNull ?: ""
        val target = if (from.isEmpty() || File(dir, "$from.metadata").isFile) from else ""
        (m - "trashedFrom") + ("parent" to JsonPrimitive(target))
    }

    /** Permanently delete an item; for folders, everything inside them too. Returns how many items were removed. */
    fun deletePermanently(dir: File, id: String): Int {
        val ids = LinkedHashSet<String>().also { collect(dir, id, it) }
        for (x in ids) {
            File(dir, "$x.metadata").delete(); File(dir, "$x.content").delete()
            File(dir, "$x.pdf").delete(); File(dir, "$x.epub").delete()
            File(dir, x).deleteRecursively()
        }
        return ids.size
    }

    fun emptyTrash(dir: File): Int = LibraryScanner.scan(dir).trash.sumOf { deletePermanently(dir, it.id) }

    private fun collect(dir: File, id: String, out: MutableSet<String>) {
        if (!out.add(id)) return
        dir.listFiles { f -> f.name.endsWith(".metadata") }.orEmpty().forEach { f ->
            val child = f.name.removeSuffix(".metadata")
            val parent = runCatching { (Json.parseToJsonElement(f.readText()).jsonObject["parent"] as? JsonPrimitive)?.contentOrNull }.getOrNull()
            if (parent == id) collect(dir, child, out)
        }
    }

    /** Change a notebook's page background (applies to all its pages). */
    fun setTemplate(dir: File, id: String, template: PageTemplate) {
        editContent(dir, id) { it + ("template" to JsonPrimitive(template.id)) }
        touch(dir, id)
    }

    // ---- pages ----

    /** Insert a new blank page after [afterIndex] (-1 = at the start). Returns its id. */
    fun addPage(dir: File, doc: LibraryEntry, afterIndex: Int = doc.pageIds.lastIndex, pageId: String = newId()): String {
        editContent(dir, doc.id) { c ->
            val ids = pageIdsOf(c).toMutableList()
            ids.add((afterIndex + 1).coerceIn(0, ids.size), pageId)
            c + ("pages" to JsonArray(ids.map(::JsonPrimitive))) + ("pageCount" to JsonPrimitive(ids.size))
        }
        touch(dir, doc.id)
        return pageId
    }

    /** Remove a page and its ink. A notebook always keeps at least one page; returns false if refused. */
    fun deletePage(dir: File, doc: LibraryEntry, index: Int): Boolean {
        if (doc.pageIds.size <= 1 || index !in doc.pageIds.indices) return false
        val pageId = doc.pageIds[index]
        editContent(dir, doc.id) { c ->
            val ids = pageIdsOf(c).filterIndexed { i, _ -> i != index }
            c + ("pages" to JsonArray(ids.map(::JsonPrimitive))) + ("pageCount" to JsonPrimitive(ids.size))
        }
        File(File(dir, doc.id), "$pageId.rm").delete()
        File(File(dir, doc.id), "$pageId.rm.orig").delete()
        touch(dir, doc.id)
        return true
    }

    // ---- helpers ----

    private fun pageIdsOf(c: JsonObject): List<String> =
        (c["pages"] as? JsonArray)?.mapNotNull { (it as? JsonPrimitive)?.contentOrNull }.orEmpty()

    private fun metadata(name: String, parentId: String, type: String, now: Long) = buildJsonObject {
        put("deleted", false)
        put("lastModified", now.toString())
        put("metadatamodified", false)
        put("modified", false)
        put("parent", parentId)
        put("pinned", false)
        put("synced", false)
        put("type", type)
        put("version", 0)
        put("visibleName", name.trim())
    }

    private fun editMetadata(dir: File, id: String, edit: (Map<String, JsonElement>) -> Map<String, JsonElement>) =
        editJson(File(dir, "$id.metadata"), edit)

    private fun editContent(dir: File, id: String, edit: (JsonObject) -> Map<String, JsonElement>) =
        editJson(File(dir, "$id.content")) { edit(JsonObject(it)) }

    private fun editJson(file: File, edit: (Map<String, JsonElement>) -> Map<String, JsonElement>) {
        require(file.isFile) { "No such document file: ${file.name}" }
        writeJson(file, JsonObject(edit(Json.parseToJsonElement(file.readText()).jsonObject)))
    }

    private fun writeJson(file: File, obj: JsonObject) {
        val tmp = File(file.parentFile, file.name + ".tmp")
        tmp.writeText(obj.toString())
        java.nio.file.Files.move(tmp.toPath(), file.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING)
    }

    private fun newId() = UUID.randomUUID().toString()
    private fun now() = System.currentTimeMillis()
}
