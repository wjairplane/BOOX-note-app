package app.inkbridge.rm.render

/** Page backgrounds. Drawn through [PageCanvas], so they appear on screen and in SVG/PDF exports alike. */
enum class PageTemplate(val id: String, val label: String) {
    BLANK("blank", "Blank"),
    LINES("lines", "Lined"),
    GRID("grid", "Grid"),
    DOTS("dots", "Dotted");

    companion object {
        fun fromId(id: String?): PageTemplate = entries.firstOrNull { it.id == id } ?: BLANK

        /** Distance between rules/dots, in page units (about 7 mm). */
        const val SPACING = 62f

        private const val RULE_COLOR = 0xFFB4B4B4.toInt()
        private const val RULE_WIDTH = 1.4f
        private const val DOT_COLOR = 0xFF8C8C8C.toInt()
        private const val DOT_SIZE = 3.6f
        private const val TOP_MARGIN = 124f
        private const val SIDE_MARGIN = 62f
    }

    fun draw(canvas: PageCanvas, layout: PageLayout) {
        if (this == BLANK) return
        val left = layout.xMin + SIDE_MARGIN
        val right = layout.xMax - SIDE_MARGIN
        val top = layout.yMin + TOP_MARGIN
        val bottom = layout.yMax - SPACING / 2
        val xy = FloatArray(4)

        fun line(x1: Float, y1: Float, x2: Float, y2: Float) {
            xy[0] = x1; xy[1] = y1; xy[2] = x2; xy[3] = y2
            canvas.polyline(xy, 2, RULE_WIDTH, RULE_COLOR, PageCanvas.Cap.BUTT)
        }

        when (this) {
            LINES -> {
                var y = top
                while (y <= bottom) { line(layout.xMin + SIDE_MARGIN / 2, y, layout.xMax - SIDE_MARGIN / 2, y); y += SPACING }
            }
            GRID -> {
                var y = top
                while (y <= bottom) { line(left, y, right, y); y += SPACING }
                var x = left
                while (x <= right + 0.5f) { line(x, top, x, y - SPACING); x += SPACING }
            }
            DOTS -> {
                var y = top
                while (y <= bottom) {
                    var x = left
                    while (x <= right + 0.5f) {
                        xy[0] = x; xy[1] = y; xy[2] = x + 0.01f; xy[3] = y
                        canvas.polyline(xy, 2, DOT_SIZE, DOT_COLOR, PageCanvas.Cap.ROUND)
                        x += SPACING
                    }
                    y += SPACING
                }
            }
            BLANK -> Unit
        }
    }
}
