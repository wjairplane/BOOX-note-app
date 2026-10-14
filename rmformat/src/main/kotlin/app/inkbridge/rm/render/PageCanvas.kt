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
}
