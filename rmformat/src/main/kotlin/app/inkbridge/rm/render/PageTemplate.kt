package app.inkbridge.rm.render

/**
 * A page background: one entry of the reMarkable firmware's template list (see [TemplateCatalog]).
 * Drawn through [PageCanvas], so it appears on screen and in SVG/PDF exports alike.
 *
 * [id] is what notebooks store in `.content` (`template`): the template's file name, with `@landscape` added
 * for the landscape variant of a file that serves both orientations. Ids of the app's original four templates
 * (`blank`, `lines`, `grid`, `dots`) still resolve, to the nearest firmware templates.
 */
data class PageTemplate(
    val id: String,
    /** Display name as the firmware's picker shows it, e.g. "Lined medium". */
    val label: String,
    /** Template file name without extension, e.g. "P Lines medium"; "Blank" has no file. */
    val filename: String,
    val landscape: Boolean = false,
    val categories: List<String> = emptyList(),
    /** Glyph code of the firmware's icon font for this template (informational). */
    val iconCode: String = "",
    /** False when the firmware lists the template but its definition file is not bundled (it then draws as blank). */
    val available: Boolean = true,
) {
    val isBlank: Boolean get() = filename == "Blank"

    fun draw(canvas: PageCanvas, layout: PageLayout) {
        // Hexagon and Calligraphy have no file: the firmware draws them in code (see NativeTemplates).
        if (NativeTemplates.has(filename)) { NativeTemplates.draw(filename, landscape, canvas, layout); return }
        val def = TemplateCatalog.definition(this) ?: return
        TemplateRenderer.draw(def, landscape, canvas, layout)
    }

    /** The page area of this template's own orientation, for thumbnails. */
    val pageLayout: PageLayout
        get() { val w = TemplateRenderer.templateWidth(landscape); return PageLayout(-w / 2f, w / 2f, 0f, TemplateRenderer.templateHeight(landscape)) }

    companion object {
        /** Resolve a stored id (see class doc); anything unknown gives Blank. */
        fun fromId(id: String?): PageTemplate = TemplateCatalog.resolve(id)

        val BLANK: PageTemplate get() = TemplateCatalog.blank
        /** The old "Lined", "Grid" and "Dotted": the firmware's medium lines, medium grid and small dots. */
        val LINES: PageTemplate get() = fromId("lines")
        val GRID: PageTemplate get() = fromId("grid")
        val DOTS: PageTemplate get() = fromId("dots")

        /** Every template the picker offers. */
        val entries: List<PageTemplate> get() = TemplateCatalog.selectable
    }
}
