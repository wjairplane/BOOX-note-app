package app.inkbridge.rm.text

/** The firmware's typed-text fonts: reMarkable Sans (body, lists, Subheading 2 in its Medium weight) and reMarkable Serif Small (Title). */
enum class TextFont(val label: String, val css: String) {
    RM_SANS("reMarkable Sans", "reMarkable Sans, sans-serif"),
    RM_SANS_MEDIUM("reMarkable Sans Medium", "reMarkable Sans, sans-serif"),
    RM_SERIF("reMarkable Serif Small", "reMarkable Serif Small, serif"),
}

/**
 * The text column choices of the typing foldout (`TextWidthModel`): width in page px. The text box is centred on the page
 * (x = -width / 2) with its top at y = 234; the default is the medium column.
 */
enum class TextColumn(val layout: Int, val width: Float, val label: String) {
    NARROW(0, 740f, "Narrow column"),
    MEDIUM(1, 936f, "Medium column"),
    WIDE(2, 1152f, "Wide column");

    val posX: Double get() = -width / 2.0

    companion object {
        /** The column whose width is exactly [width] (a stored width of 740 / 936 / 1152), or null for a custom width. */
        fun ofWidth(width: Float): TextColumn? = entries.firstOrNull { it.width == width }
        val DEFAULT = MEDIUM
    }
}

/** Fixed layout constants of typed text on a page (firmware 3.27.1.0, page px). */
object TextStyles {
    const val PAGE_WIDTH = 1404f
    /** Where the top of the text box sits (`pos_y`). */
    const val POS_Y = 234.0
    /** Qt's default document margin around the text. */
    const val DOCUMENT_MARGIN = 4f
    const val LIST_INDENT = 48f
    /** Extra distance below the page's last line before the page ends. */
    const val BOTTOM_MARGIN = 108f

    const val BODY_SIZE = 32f
    /** Font height as a multiple of the pixel size (the fonts' ascender 925 + descender 255 per 1000 em). */
    const val HEIGHT_FACTOR = 1.18f
    const val ASCENT_FACTOR = 0.925f

    /** Extra distance between body lines: 0.2 x the body font's height. */
    const val BODY_LINE_GAP = 0.2f * HEIGHT_FACTOR * BODY_SIZE
}

/** Measures text for layout. The app installs the platform's font metrics; the default is a rough per-character width. */
fun interface TextMeasurer {
    fun width(s: String, size: Float, bold: Boolean, italic: Boolean, font: TextFont): Float
}

object TextMetrics {
    private val approximate = TextMeasurer { s, size, bold, _, _ -> s.length * size * 0.52f * (if (bold) 1.06f else 1f) }

    @Volatile var measurer: TextMeasurer = approximate
    fun width(s: String, size: Float, bold: Boolean, italic: Boolean, font: TextFont): Float =
        if (s.isEmpty()) 0f else measurer.width(s, size, bold, italic, font)
}
