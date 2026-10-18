package app.inkbridge.rm.library

import kotlinx.serialization.json.*
import java.io.File
import java.io.IOException
import java.util.zip.ZipInputStream

/**
 * The documents a new reMarkable shows in My files ("Learn the basics", "Go further"): the firmware's own `library.zip`
 * (PDFs, `.rm` v6 pages, `.content`/`.metadata`), shipped as a resource and copied into the library folder.
 *
 * The shipped `.content` files are normalised to the page-list form every [LibraryOps] edit works on (`pages` +
 * `redirectMap`): "Learn the basics" uses the newer CRDT page list, where page 1 is the PDF cover and the other
 * pages are inserted blank pages carrying only typed text and pen strokes.
 */
object DefaultLibrary {
    private const val RESOURCE = "/firmware/library.zip"

    /** Copy the default documents into [dir]. Returns the ids of the installed documents. Existing files with the same ids are replaced. */
    @Throws(IOException::class)
    fun install(dir: File): List<String> {
        val stream = DefaultLibrary::class.java.getResourceAsStream(RESOURCE) ?: throw IOException("Default library resource is missing")
        val staging = File(dir.absoluteFile.parentFile ?: dir, dir.name + ".seed").apply { deleteRecursively(); mkdirs() }
        try {
            ZipInputStream(stream.buffered()).use { zip ->
                while (true) {
                    val e = zip.nextEntry ?: break
                    val target = File(staging, e.name)
                    // Never write outside the staging folder, whatever the archive says.
                    require(target.canonicalPath.startsWith(staging.canonicalPath + File.separator)) { "Bad entry ${e.name}" }
                    if (e.isDirectory) target.mkdirs()
                    else { target.parentFile.mkdirs(); target.outputStream().use { zip.copyTo(it) } }
                }
            }
            val ids = staging.listFiles { f -> f.isFile && f.name.endsWith(".metadata") }.orEmpty().map { it.name.removeSuffix(".metadata") }.sorted()
            dir.mkdirs()
            for (id in ids) {
                File(staging, "$id.content").takeIf { it.isFile }?.let { it.writeText(normaliseContent(it.readText())) }
                // The page folder and the other files first, the .metadata last, so a half-copied document never shows up in the library.
                File(dir, id).deleteRecursively()
                File(staging, id).takeIf { it.isDirectory }?.copyRecursively(File(dir, id), overwrite = true)
                for (ext in listOf("pdf", "pagedata", "content")) File(staging, "$id.$ext").takeIf { it.isFile }?.copyTo(File(dir, "$id.$ext"), overwrite = true)
                File(staging, "$id.metadata").copyTo(File(dir, "$id.metadata"), overwrite = true)
            }
            return ids
        } finally {
            staging.deleteRecursively()
        }
    }

    /** Rewrite a shipped `.content` to the `pages` + `redirectMap` form. Content already in that form passes through. */
    fun normaliseContent(json: String): String {
        val c = Json.parseToJsonElement(json).jsonObject
        val cPages = (c["cPages"] as? JsonObject)?.get("pages") as? JsonArray
        val out = LinkedHashMap<String, JsonElement>(c)
        if (cPages != null) {
            val live = cPages.mapNotNull { it as? JsonObject }.filter { it["deleted"] == null }
            out.remove("cPages")
            out["pages"] = JsonArray(live.map { JsonPrimitive((it["id"] as JsonPrimitive).content) })
            val redirs = live.map { ((it["redir"] as? JsonObject)?.get("value") as? JsonPrimitive)?.intOrNull }
            if (redirs.any { it != null }) out["redirectMap"] = JsonArray(redirs.map { JsonPrimitive(it ?: -1) })
            out["pageCount"] = JsonPrimitive(live.size)
            out["formatVersion"] = JsonPrimitive(1)
        }
        (out.remove("redirectionPageMap"))?.let { out.putIfAbsent("redirectMap", it) }
        return JsonObject(out).toString()
    }
}
