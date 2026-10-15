package app.inkbridge.rm.render

import kotlinx.serialization.json.*
import java.util.concurrent.ConcurrentHashMap

/**
 * The firmware's template list (`templates.json`) and its `.template` definitions, bundled as resources under
 * `templates/`. Lookup by id, file name or legacy name; filtering by category and orientation like the firmware's
 * "Choose template" screen. Pure Kotlin.
 */
object TemplateCatalog {
    /** The category tab that shows everything. */
    const val ALL = "All"

    private const val DIR = "templates/"

    /** The legacy app-template ids, mapped to the nearest firmware template (by file name). */
    private val LEGACY = mapOf(
        "blank" to "Blank",
        "lines" to "P Lines medium",
        "grid" to "P Grid medium",
        "dots" to "P Dots S",
    )

    private fun read(name: String): String? =
        TemplateCatalog::class.java.classLoader?.getResourceAsStream(DIR + name)?.use { it.readBytes().toString(Charsets.UTF_8) }

    private fun idOf(filename: String, landscape: Boolean) =
        if (landscape && !filename.startsWith("LS ")) "$filename@landscape" else filename

    private val fallbackBlank = PageTemplate("Blank", "Blank", "Blank", categories = listOf("Creative"))

    /** All 79 firmware entries in firmware order (portrait and landscape variants are separate entries). */
    val all: List<PageTemplate> by lazy {
        val root = read("templates.json")?.let { Json.parseToJsonElement(it).jsonObject } ?: return@lazy listOf(fallbackBlank)
        (root["templates"] as? JsonArray).orEmpty().mapNotNull { e ->
            val o = e as? JsonObject ?: return@mapNotNull null
            val filename = (o["filename"] as? JsonPrimitive)?.contentOrNull ?: return@mapNotNull null
            val landscape = (o["landscape"] as? JsonPrimitive)?.booleanOrNull ?: false
            PageTemplate(
                id = idOf(filename, landscape),
                label = (o["name"] as? JsonPrimitive)?.contentOrNull ?: filename,
                filename = filename,
                landscape = landscape,
                categories = (o["categories"] as? JsonArray).orEmpty().mapNotNull { (it as? JsonPrimitive)?.contentOrNull },
                iconCode = (o["iconCode"] as? JsonPrimitive)?.contentOrNull.orEmpty(),
                available = filename == "Blank" || read("$filename.template") != null,
            )
        }
    }

    /** The portrait Blank page. */
    val blank: PageTemplate by lazy { all.firstOrNull { it.id == "Blank" } ?: fallbackBlank }

    /** Entries the picker can offer: those whose definition is bundled. */
    val selectable: List<PageTemplate> by lazy { all.filter { it.available } }

    /** Category names in firmware order of first appearance (without [ALL]). */
    val categories: List<String> by lazy { selectable.flatMap { it.categories }.distinct() }

    private val byId: Map<String, PageTemplate> by lazy { all.associateBy { it.id } }

    /** Resolve a stored id: an exact id, a legacy id, a file name (portrait) or a display name; otherwise Blank. */
    fun resolve(id: String?): PageTemplate {
        if (id.isNullOrBlank()) return blank
        byId[id]?.let { return it }
        LEGACY[id.lowercase()]?.let { f -> return all.firstOrNull { it.filename == f && !it.landscape } ?: blank }
        all.firstOrNull { it.filename.equals(id, true) && !it.landscape }?.let { return it }
        all.firstOrNull { it.label.equals(id, true) && !it.landscape && it.available }?.let { return it }
        return blank
    }

    fun byFilename(filename: String, landscape: Boolean = false): PageTemplate? =
        all.firstOrNull { it.filename == filename && it.landscape == landscape }

    /** Selectable templates of [category] ([ALL] or null for every one) in the given orientation. */
    fun filter(category: String?, landscape: Boolean): List<PageTemplate> =
        selectable.filter { it.landscape == landscape && (category == null || category == ALL || category in it.categories) }

    /** Whether any template of [category] exists in the given orientation (the picker hides an orientation without any). */
    fun hasOrientation(category: String?, landscape: Boolean) = filter(category, landscape).isNotEmpty()

    private val defs = ConcurrentHashMap<String, Any>()
    private object None

    /** The parsed definition behind [t]; null for Blank, an unbundled template or a file that fails to parse. */
    fun definition(t: PageTemplate): TemplateDef? {
        if (t.isBlank) return null
        val v = defs.getOrPut(t.filename) {
            runCatching { read("${t.filename}.template")?.let { TemplateDef.parse(it) } }.getOrNull() ?: None
        }
        return v as? TemplateDef
    }
}
