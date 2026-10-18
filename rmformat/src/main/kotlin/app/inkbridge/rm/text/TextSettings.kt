package app.inkbridge.rm.text

/** The fonts of the "Font" page of the text settings: the firmware's own Sans plus the four reading fonts. */
enum class TextFont(val label: String, val css: String) {
    RM_SANS("reMarkable Sans", "reMarkable Sans, sans-serif"),
    EB_GARAMOND("EB Garamond", "EB Garamond, serif"),
    NOTO_SANS("Noto Sans", "Noto Sans, sans-serif"),
    NOTO_MONO("Noto Mono", "Noto Mono, monospace"),
    NOTO_SERIF("Noto Serif", "Noto Serif, serif"),
}

/** "Line spacing" page: the three line heights of the firmware (percent of the font size). */
enum class LineSpacing(val percent: Int) { MINIMUM(100), MEDIUM(150), MAXIMUM(200) }

/** "Page margins" page: the three side margins of the firmware, in page units. */
enum class PageMargins(val margin: Int) { MINIMUM(50), MEDIUM(125), MAXIMUM(225) }

/**
 * How typed text is set on the page: the choices of the firmware's "Text settings" (Font, Font size, Justification, Page margins,
 * Line spacing). The margin is stored in the page itself (the text block's position and width); the others are the app's.
 */
data class TextSettings(
    val font: TextFont = TextFont.RM_SANS,
    /** One of [FONT_SCALES]. */
    val scale: Float = 1.0f,
    val lineSpacing: LineSpacing = LineSpacing.MEDIUM,
    val justify: Boolean = false,
) {
    /** Body text size in page units. */
    val bodySize: Float get() = BODY_SIZE * scale

    companion object {
        const val BODY_SIZE = 36f
        val FONT_SCALES = floatArrayOf(0.7f, 0.8f, 1.0f, 1.2f, 1.5f, 2.0f)

        /** The default side margin of the typed-text block (`documentViewTextEditSideMargin`). */
        const val DEFAULT_SIDE_MARGIN = 200f
        /** Distance from the top of the page to the top of the text (`documentViewTextEditTopMargin`). */
        const val TOP_MARGIN = 108f
        const val PAGE_WIDTH = 1404f

        val DEFAULT = TextSettings()

        /** Settings the renderer uses when it isn't given any; the app sets this from its preferences. */
        @Volatile var current: TextSettings = DEFAULT
    }
}

/** Measures text for layout. The app installs the platform's font metrics; the default is a rough per-character width. */
fun interface TextMeasurer {
    fun width(s: String, size: Float, bold: Boolean, italic: Boolean, font: TextFont): Float
}

object TextMetrics {
    private val approximate = TextMeasurer { s, size, bold, _, font ->
        val per = when (font) { TextFont.NOTO_MONO -> 0.6f; TextFont.EB_GARAMOND -> 0.42f; else -> 0.52f }
        s.length * size * per * (if (bold) 1.06f else 1f)
    }

    @Volatile var measurer: TextMeasurer = approximate
    fun width(s: String, size: Float, bold: Boolean, italic: Boolean, font: TextFont): Float =
        if (s.isEmpty()) 0f else measurer.width(s, size, bold, italic, font)
}
