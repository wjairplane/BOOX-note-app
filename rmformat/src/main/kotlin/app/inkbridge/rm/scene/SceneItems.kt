package app.inkbridge.rm.scene

/** Anything that can sit inside a [Group]. */
sealed interface SceneItem

/** A layer or nested group. Layers are the children of the root group. */
class Group(val nodeId: CrdtId) : SceneItem {
    val children = CrdtSequence<SceneItem?>()
    var label: Lww<String> = Lww(CrdtId.END_MARKER, "")
    var visible: Lww<Boolean> = Lww(CrdtId.END_MARKER, true)

    // Anchor: the group is translated by (anchorOriginX, y-position of the anchored text line).
    var anchorId: Lww<CrdtId>? = null
    var anchorType: Lww<Int>? = null
    var anchorThreshold: Lww<Float>? = null
    var anchorOriginX: Lww<Float>? = null

    /** Visible, non-deleted children in order. */
    fun childItems(): List<SceneItem> = children.values().filterNotNull()
}

/** reMarkable pen ids as they appear in the file (kept as raw ints for lossless round-trip). */
object PenId {
    const val PAINTBRUSH_1 = 0
    const val PENCIL_1 = 1
    const val BALLPOINT_1 = 2
    const val MARKER_1 = 3
    const val FINELINER_1 = 4
    const val HIGHLIGHTER_1 = 5
    const val ERASER = 6
    const val MECHANICAL_PENCIL_1 = 7
    const val ERASER_AREA = 8
    const val PAINTBRUSH_2 = 12
    const val MECHANICAL_PENCIL_2 = 13
    const val PENCIL_2 = 14
    const val BALLPOINT_2 = 15
    const val MARKER_2 = 16
    const val FINELINER_2 = 17
    const val HIGHLIGHTER_2 = 18
    const val CALLIGRAPHY = 21
    const val SHADER = 23
}

/** Pen colour ids as they appear in the file. */
object PenColorId {
    const val BLACK = 0
    const val GRAY = 1
    const val WHITE = 2
    const val YELLOW = 3
    const val GREEN = 4
    const val PINK = 5
    const val BLUE = 6
    const val RED = 7
    const val GRAY_OVERLAP = 8
    const val HIGHLIGHT = 9
    const val GREEN_2 = 10
    const val CYAN = 11
    const val MAGENTA = 12
    const val YELLOW_2 = 13
}

/**
 * One sample of a stroke, in the file's v2 units: speed/width are uint16, direction/pressure
 * uint8. v1 files are converted to the same units on read.
 */
data class Point(
    val x: Float,
    val y: Float,
    val speed: Int,
    val direction: Int,
    val width: Int,
    val pressure: Int,
)

class Line(
    val tool: Int,
    val color: Int,
    val points: List<Point>,
    val thicknessScale: Double,
    val startingLength: Float,
    val moveId: CrdtId? = null,
    /** Explicit RGBA (r, g, b, a), present for newer colours such as highlighter shades. */
    val colorRgba: IntArray? = null,
) : SceneItem

class Rectangle(val x: Double, val y: Double, val w: Double, val h: Double)

/** Highlighted text from an annotated PDF/EPUB. */
class GlyphRange(
    val start: Int?,
    val length: Int,
    val text: String,
    val color: Int,
    val rectangles: List<Rectangle>,
    val colorRgba: IntArray? = null,
) : SceneItem

enum class ParagraphStyle(val code: Int) {
    BASIC(0), PLAIN(1), HEADING(2), BOLD(3), BULLET(4), BULLET2(5), CHECKBOX(6), CHECKBOX_CHECKED(7);

    companion object {
        fun of(code: Int): ParagraphStyle = entries.firstOrNull { it.code == code } ?: PLAIN
    }
}

/** A text-sequence element: either characters or an inline formatting code. */
sealed interface TextValue {
    data class Chars(val s: String) : TextValue
    /** 1 = bold on, 2 = bold off, 3 = italic on, 4 = italic off. */
    data class Format(val code: Int) : TextValue
}

/** The page's typed-text block (positions are in page units, x relative to page centre). */
class Text(
    val items: CrdtSequence<TextValue>,
    val styles: Map<CrdtId, Lww<ParagraphStyle>>,
    val posX: Double,
    val posY: Double,
    val width: Float,
)
