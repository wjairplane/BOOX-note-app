package app.inkbridge.rm.render

/**
 * Minimal drawing surface. All coordinates and sizes are in reMarkable page units
 * (1404 x 1872 for a standard page, x=0 at the left edge once [PageLayout.xMin] is applied by the
 * implementation); the implementation owns the scale to its real pixels.
 * Colours are ARGB ints.
 */
interface PageCanvas {
    /** How a stroke's ends are drawn. BUTT matters for translucent segments: round/square caps overlap and leave dots. */
    enum class Cap { BUTT, ROUND, SQUARE }

    /** Stroked polyline through the first [pointCount] (x, y) pairs of [xy]. */
    fun polyline(xy: FloatArray, pointCount: Int, width: Float, argb: Int, cap: Cap)

    fun fillRect(x: Float, y: Float, w: Float, h: Float, argb: Int)

    /** Draw a single line of text with its baseline at [y]. */
    fun text(s: String, x: Float, y: Float, size: Float, bold: Boolean, italic: Boolean, argb: Int)

    /** [text] in one of the page fonts; canvases without font support draw it in their default font. */
    fun styledText(s: String, x: Float, y: Float, size: Float, bold: Boolean, italic: Boolean, font: app.inkbridge.rm.text.TextFont, argb: Int) =
        text(s, x, y, size, bold, italic, argb)

    /**
     * Fill the polygon through the first [pointCount] (x, y) pairs of [xy]. Implementations without a path fill
     * fall back to the bounding box, which is exact for the axis-aligned boxes templates fill.
     */
    fun fillPolygon(xy: FloatArray, pointCount: Int, argb: Int) {
        if (pointCount < 1) return
        var x0 = xy[0]; var x1 = xy[0]; var y0 = xy[1]; var y1 = xy[1]
        for (i in 1 until pointCount) {
            x0 = minOf(x0, xy[i * 2]); x1 = maxOf(x1, xy[i * 2]); y0 = minOf(y0, xy[i * 2 + 1]); y1 = maxOf(y1, xy[i * 2 + 1])
        }
        fillRect(x0, y0, x1 - x0, y1 - y0, argb)
    }

    /** Width of [s] set with the font [text] uses; the default is a rough average for sans text. */
    fun measureText(s: String, size: Float, bold: Boolean = false): Float = s.length * size * 0.52f
}
