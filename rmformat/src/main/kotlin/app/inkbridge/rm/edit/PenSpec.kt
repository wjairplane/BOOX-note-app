package app.inkbridge.rm.edit

import app.inkbridge.rm.scene.PenColorId
import app.inkbridge.rm.scene.PenId

/** Tools the editor offers. Each maps to the reMarkable pen id written into the file. */
enum class PenTool(val label: String, val toolId: Int) {
    FINELINER("Fineliner", PenId.FINELINER_2),
    BALLPOINT("Ballpoint", PenId.BALLPOINT_2),
    PENCIL("Pencil", PenId.PENCIL_2),
    HIGHLIGHTER("Highlighter", PenId.HIGHLIGHTER_2),
    /** Not a pen: removes whole strokes it touches. */
    ERASER("Eraser", PenId.ERASER);

    val isPen: Boolean get() = this != ERASER
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
        val HIGHLIGHTER_COLORS = intArrayOf(PenColorId.YELLOW, PenColorId.GREEN, PenColorId.PINK)
        val INK_COLORS = intArrayOf(PenColorId.BLACK, PenColorId.GRAY, PenColorId.BLUE, PenColorId.RED, PenColorId.GREEN)
    }
}
