package app.inkbridge

import kotlin.math.hypot

/** Works out which text a highlighter stroke covers (the highlighter's "Snap to text"). All positions are PDF points, y down. */
object SnapToText {
    /** The box to highlight on one text line: the characters from the first to the last one the stroke passes through. */
    class Pick(val line: PdfStructure.TextLine, val left: Float, val top: Float, val right: Float, val bottom: Float, val text: String)

    /**
     * For each line the [stroke] crosses, the span from the first to the last character that the stroke passes through (a character
     * counts when a point of the stroke lies inside its box). The stroke is densified first so a fast stroke cannot skip a character,
     * and a line whose boxes the stroke only grazes by one character is still a pick: a tap on a word highlights the word.
     */
    fun pick(lines: List<PdfStructure.TextLine>, stroke: List<Pair<Float, Float>>): List<Pick> {
        if (stroke.isEmpty()) return emptyList()
        val pts = densify(stroke)
        val out = ArrayList<Pick>()
        for (line in lines) {
            val g = line.glyphs
            val first = g.indexOfFirst { hit(it, pts) }
            if (first < 0) continue
            val last = g.indexOfLast { hit(it, pts) }
            val span = g.subList(first, last + 1)
            out += Pick(line, span.minOf { it.left }, line.top, span.maxOf { it.right }, line.bottom, span.joinToString("") { it.text }.trim())
        }
        return out.filter { it.text.isNotEmpty() }
    }

    private fun hit(c: PdfStructure.Glyph, pts: List<Pair<Float, Float>>): Boolean =
        pts.any { (x, y) -> x in c.left..c.right && y in c.top..c.bottom }

    private fun densify(p: List<Pair<Float, Float>>, step: Float = 1.5f): List<Pair<Float, Float>> {
        if (p.size < 2) return p
        val out = ArrayList<Pair<Float, Float>>()
        for (i in 0 until p.size - 1) {
            val (x0, y0) = p[i]; val (x1, y1) = p[i + 1]
            val n = (hypot(x1 - x0, y1 - y0) / step).toInt().coerceAtLeast(1)
            for (k in 0 until n) out += (x0 + (x1 - x0) * k / n) to (y0 + (y1 - y0) * k / n)
        }
        out += p.last()
        return out
    }
}
