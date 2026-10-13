package app.inkbridge.rm.edit

import app.inkbridge.rm.scene.PenColorId
import app.inkbridge.rm.scene.PenId

/**
 * The pen set, in the order of the reMarkable 2's toolbar. Each maps to the pen id written into the file.
 * (Pencil, mechanical pencil, paintbrush, calligraphy and marker have no sample data for their widths;
 * see [StrokeBuilder.widthRaw].)
 */
enum class PenTool(val label: String, val toolId: Int) {
    BALLPOINT("Ballpoint", PenId.BALLPOINT_2),
    FINELINER("Fineliner", PenId.FINELINER_2),
    MARKER("Marker", PenId.MARKER_2),
    PENCIL("Pencil", PenId.PENCIL_2),
    MECHANICAL_PENCIL("Mechanical pencil", PenId.MECHANICAL_PENCIL_2),
    PAINTBRUSH("Paintbrush", PenId.PAINTBRUSH_2),
    CALLIGRAPHY("Calligraphy pen", PenId.CALLIGRAPHY),
    HIGHLIGHTER("Highlighter", PenId.HIGHLIGHTER_2),
    /** Not a pen: removes whole strokes it touches. */
    ERASER("Eraser", PenId.ERASER);

    val isPen: Boolean get() = this != ERASER

    /** Highlighters use their own colour set and a fixed width. */
    val isHighlighter: Boolean get() = this == HIGHLIGHTER

    companion object {
        val PENS: List<PenTool> = entries.filter { it.isPen }
    }
}

/**
 * A pen setup. [colorId] uses the classic pen-colour ids every firmware understands
 * (black=0, gray=1, yellow=3, green=4, pink=5, blue=6, red=7). [thickness] is the file's
 * thickness scale: 1 = thin, 2 = medium, 3 = thick.
 */
data class PenSpec(val tool: PenTool, val colorId: Int = PenColorId.BLACK, val thickness: Int = 2) {
    init {
        require(thickness in 1..3) { "thickness must be 1..3" }
    }

    companion object {
        val HIGHLIGHTER_COLORS = intArrayOf(PenColorId.YELLOW, PenColorId.GREEN, PenColorId.PINK, PenColorId.BLUE, PenColorId.GRAY)
        val INK_COLORS = intArrayOf(PenColorId.BLACK, PenColorId.GRAY, PenColorId.BLUE, PenColorId.RED, PenColorId.GREEN, PenColorId.PINK)

        /** Display names for the colour ids above. */
        fun colorName(id: Int): String = when (id) {
            PenColorId.BLACK -> "Black"; PenColorId.GRAY -> "Gray"; PenColorId.WHITE -> "White"
            PenColorId.YELLOW -> "Yellow"; PenColorId.GREEN -> "Green"; PenColorId.PINK -> "Pink"
            PenColorId.BLUE -> "Blue"; PenColorId.RED -> "Red"; else -> "Colour $id"
        }
    }
}
