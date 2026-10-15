package app.inkbridge.rm.render

import kotlin.math.ceil
import kotlin.math.floor

/**
 * Draws a [TemplateDef] onto a [PageCanvas] the way the firmware lays templates out: a coordinate space of
 * templateWidth x templateHeight (1404 x 1872, or swapped for landscape) centred on the page's x = 0,
 * groups that repeat their bounding box down / right / up / both ways until the page edge, and children placed
 * relative to their group's cell. Pure Kotlin; works on any [PageCanvas] (screen, SVG, PDF, bitmap).
 */
object TemplateRenderer {
    /** Rule colour and width: the look of the app's original lined / grid / dotted backgrounds. */
    const val RULE_COLOR = 0xFFB4B4B4.toInt()
    const val RULE_WIDTH = 1.4f
    const val TEXT_COLOR = 0xFF6E6E6E.toInt()

    const val PORTRAIT_WIDTH = 1404f
    const val PORTRAIT_HEIGHT = 1872f

    /** Hard stop for a runaway repeat. */
    private const val MAX_CELLS_PER_AXIS = 4000

    /** Template-space size of a page of the given orientation. */
    fun templateWidth(landscape: Boolean) = if (landscape) PORTRAIT_HEIGHT else PORTRAIT_WIDTH
    fun templateHeight(landscape: Boolean) = if (landscape) PORTRAIT_WIDTH else PORTRAIT_HEIGHT

    /**
     * Draw [def] over [layout] (page units, x = 0 at the page centre). Only the part inside [layout] is drawn,
     * so repeats cover pages that scroll past the standard height.
     */
    fun draw(def: TemplateDef, landscape: Boolean, canvas: PageCanvas, layout: PageLayout) {
        val tw = templateWidth(landscape)
        val th = templateHeight(landscape)
        val ox = -tw / 2f
        Run(def, tw, th, canvas, ox, 0f, layout.xMin - ox, layout.yMin, layout.xMax - ox, layout.yMax).run()
    }

    private class Cell(val x: Float, val y: Float, val w: Float, val h: Float)

    private class Run(
        val def: TemplateDef, val tw: Float, val th: Float, val canvas: PageCanvas,
        val ox: Float, val oy: Float,
        // The visible area in template coordinates.
        val visL: Float, val visT: Float, val visR: Float, val visB: Float,
    ) {
        private val raw = HashMap<String, Expr>().also { m -> def.constants.forEach { (k, v) -> m[k] = v } }
        private val values = HashMap<String, Double>()
        private val resolving = HashSet<String>()
        private val globalEnv = Expr.Env { n ->
            when (n) { "templateWidth", "parentWidth" -> tw.toDouble(); "templateHeight", "parentHeight" -> th.toDouble(); "textWidth" -> 0.0; else -> constant(n) }
        }

        private fun constant(name: String): Double? {
            values[name]?.let { return it }
            val e = raw[name] ?: return null
            if (!resolving.add(name)) return 0.0 // a cycle: the firmware would not terminate either; give 0
            val v = e.eval(globalEnv)
            resolving.remove(name)
            values[name] = v
            return v
        }

        private fun env(cell: Cell, textWidth: Float = 0f) = Expr.Env { n ->
            when (n) {
                "templateWidth" -> tw.toDouble()
                "templateHeight" -> th.toDouble()
                "parentWidth" -> cell.w.toDouble()
                "parentHeight" -> cell.h.toDouble()
                "textWidth" -> textWidth.toDouble()
                else -> constant(n)
            }
        }

        fun run() {
            // Constants first, so a broken one fails the same way for every use.
            raw.keys.forEach { constant(it) }
            val root = Cell(0f, 0f, tw, th)
            def.items.forEach { drawItem(it, root) }
        }

        private fun drawItem(item: TemplateItem, parent: Cell) {
            when (item) {
                is TemplateItem.Group -> drawGroup(item, parent)
                is TemplateItem.Path -> drawPath(item, parent)
                is TemplateItem.Text -> drawText(item, parent)
            }
        }

        private fun f(e: Expr, env: Expr.Env) = e.eval(env).toFloat()

        private fun drawGroup(g: TemplateItem.Group, parent: Cell) {
            val pe = env(parent)
            val gx = parent.x + f(g.x, pe)
            val gy = parent.y + f(g.y, pe)
            val gw = f(g.width, pe)
            val gh = f(g.height, pe)
            val cols = range(g.columns, gx, gw, visL, visR, pe)
            val rows = range(g.rows, gy, gh, visT, visB, pe)
            for (r in rows) for (c in cols) {
                val cell = Cell(gx + c * gw, gy + r * gh, gw, gh)
                g.children.forEach { drawItem(it, cell) }
            }
        }

        /** Cell indices along one axis. Index 0 is the group's own box. */
        private fun range(rep: Repeat, start: Float, size: Float, visMin: Float, visMax: Float, pe: Expr.Env): IntRange = when (rep) {
            is Repeat.Count -> 0 until rep.n.eval(pe).let { if (it.isNaN()) 0 else it.toInt() }.coerceIn(0, MAX_CELLS_PER_AXIS)
            is Repeat.Fill -> if (size < 0.01f) 0..0 else {
                val lo = if (rep.backward) floor((visMin - start) / size).toInt() else 0
                val hi = if (rep.forward) ceil((visMax - start) / size).toInt() - 1 else 0
                val l = lo.coerceAtLeast(-MAX_CELLS_PER_AXIS)
                l..hi.coerceAtMost(l + MAX_CELLS_PER_AXIS)
            }
        }

        private var buf = FloatArray(256)

        private fun drawPath(p: TemplateItem.Path, cell: Cell) {
            val e = env(cell)
            val strokeColor = p.strokeColor ?: p.fillColor ?: RULE_COLOR
            val strokeWidth = p.strokeWidth?.let { f(it, e) } ?: RULE_WIDTH
            val stroke = (strokeColor ushr 24) != 0 && strokeWidth > 0f
            var n = 0
            var startIdx = 0
            var cx = 0f; var cy = 0f
            fun add(x: Float, y: Float) {
                if ((n + 1) * 2 > buf.size) buf = buf.copyOf(buf.size * 2)
                buf[n * 2] = x; buf[n * 2 + 1] = y; n++
            }
            fun flush() {
                if (n >= 1) emit(buf, n, stroke, strokeColor, strokeWidth, p.fillColor)
                n = 0
            }
            for (c in p.commands) {
                val a = FloatArray(c.args.size) { f(c.args[it], e) }
                when (c.letter) {
                    'M' -> { flush(); cx = cell.x + a[0]; cy = cell.y + a[1]; add(cx, cy) }
                    'L' -> { if (n == 0) add(cx, cy); cx = cell.x + a[0]; cy = cell.y + a[1]; add(cx, cy) }
                    'H' -> { if (n == 0) add(cx, cy); cx = cell.x + a[0]; add(cx, cy) }
                    'V' -> { if (n == 0) add(cx, cy); cy = cell.y + a[0]; add(cx, cy) }
                    'C' -> {
                        if (n == 0) add(cx, cy)
                        val x0 = cx; val y0 = cy
                        val x1 = cell.x + a[0]; val y1 = cell.y + a[1]
                        val x2 = cell.x + a[2]; val y2 = cell.y + a[3]
                        val x3 = cell.x + a[4]; val y3 = cell.y + a[5]
                        for (i in 1..CURVE_STEPS) {
                            val t = i / CURVE_STEPS.toFloat(); val u = 1 - t
                            add(u * u * u * x0 + 3 * u * u * t * x1 + 3 * u * t * t * x2 + t * t * t * x3,
                                u * u * u * y0 + 3 * u * u * t * y1 + 3 * u * t * t * y2 + t * t * t * y3)
                        }
                        cx = x3; cy = y3
                    }
                    'Q' -> {
                        if (n == 0) add(cx, cy)
                        val x0 = cx; val y0 = cy
                        val x1 = cell.x + a[0]; val y1 = cell.y + a[1]
                        val x2 = cell.x + a[2]; val y2 = cell.y + a[3]
                        for (i in 1..CURVE_STEPS) {
                            val t = i / CURVE_STEPS.toFloat(); val u = 1 - t
                            add(u * u * x0 + 2 * u * t * x1 + t * t * x2, u * u * y0 + 2 * u * t * y1 + t * t * y2)
                        }
                        cx = x2; cy = y2
                    }
                    'Z' -> if (n > 0) { val sx = buf[startIdx]; val sy = buf[startIdx + 1]; add(sx, sy); cx = sx; cy = sy; flush() }
                }
                if (n == 1) startIdx = 0
            }
            flush()
        }

        /** Stroke / fill one subpath given in template coordinates. */
        private fun emit(pts: FloatArray, n: Int, stroke: Boolean, strokeColor: Int, width: Float, fill: Int?) {
            // Cull what is entirely off the page.
            var minX = Float.MAX_VALUE; var maxX = -Float.MAX_VALUE; var minY = Float.MAX_VALUE; var maxY = -Float.MAX_VALUE
            for (i in 0 until n) {
                minX = minOf(minX, pts[i * 2]); maxX = maxOf(maxX, pts[i * 2])
                minY = minOf(minY, pts[i * 2 + 1]); maxY = maxOf(maxY, pts[i * 2 + 1])
            }
            val pad = width + 1f
            if (maxX < visL - pad || minX > visR + pad || maxY < visT - pad || minY > visB + pad) return
            if (fill != null && n >= 3) {
                val out = FloatArray(n * 2)
                for (i in 0 until n) { out[i * 2] = pts[i * 2] + ox; out[i * 2 + 1] = pts[i * 2 + 1] + oy }
                canvas.fillPolygon(out, n, fill)
            }
            if (!stroke) return
            if (n == 2) {
                // Trim long rules (the firmware's lines run past the page edge) to the page.
                val seg = clip(pts[0], pts[1], pts[2], pts[3]) ?: return
                canvas.polyline(floatArrayOf(seg[0] + ox, seg[1] + oy, seg[2] + ox, seg[3] + oy), 2, width, strokeColor, PageCanvas.Cap.BUTT)
            } else if (n >= 2) {
                val out = FloatArray(n * 2)
                for (i in 0 until n) { out[i * 2] = pts[i * 2] + ox; out[i * 2 + 1] = pts[i * 2 + 1] + oy }
                canvas.polyline(out, n, width, strokeColor, PageCanvas.Cap.BUTT)
            } else if (n == 1) {
                // A lone point: a dot as wide as the stroke.
                val x = pts[0] + ox; val y = pts[1] + oy
                canvas.polyline(floatArrayOf(x, y, x + 0.01f, y), 2, width, strokeColor, PageCanvas.Cap.ROUND)
            }
        }

        /** Liang-Barsky clip of a segment to the visible area (a little oversize so butt ends stay hidden). */
        private fun clip(x0: Float, y0: Float, x1: Float, y1: Float): FloatArray? {
            val l = visL - 2f; val r = visR + 2f; val t = visT - 2f; val b = visB + 2f
            val dx = x1 - x0; val dy = y1 - y0
            var t0 = 0f; var t1 = 1f
            fun edge(p: Float, q: Float): Boolean {
                if (p == 0f) return q >= 0f
                val u = q / p
                if (p < 0f) { if (u > t1) return false; if (u > t0) t0 = u } else { if (u < t0) return false; if (u < t1) t1 = u }
                return true
            }
            if (!edge(-dx, x0 - l) || !edge(dx, r - x0) || !edge(-dy, y0 - t) || !edge(dy, b - y0)) return null
            return floatArrayOf(x0 + t0 * dx, y0 + t0 * dy, x0 + t1 * dx, y0 + t1 * dy)
        }

        private fun drawText(t: TemplateItem.Text, cell: Cell) {
            val size = f(t.fontSize, env(cell))
            val tw = canvas.measureText(t.text, size)
            val e = env(cell, tw)
            val x = cell.x + f(t.x, e)
            val y = cell.y + f(t.y, e)
            if (y < visT - size || y > visB + size || x > visR || x + tw < visL) return
            canvas.text(t.text, x + ox, y + oy, size, false, false, TEXT_COLOR)
        }
    }

    private const val CURVE_STEPS = 12
}
