package app.inkbridge.rm.edit

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * "Draw shapes": a stroke that ends with the pen held still turns into the clean shape it was meant to be (a line, ellipse, triangle,
 * rectangle or other polygon). Works on a list of (x, y) points in any unit and returns the shape's points, evenly spaced, or null when
 * the stroke is not close enough to any shape.
 */
object ShapeSnap {
    sealed class Shape {
        abstract val points: List<Pair<Float, Float>>
        class Line(override val points: List<Pair<Float, Float>>) : Shape()
        class Closed(val kind: String, override val points: List<Pair<Float, Float>>) : Shape()
    }

    /** True for a stroke that is a straight, near-horizontal line (used by "select below"). */
    fun isHorizontalLine(shape: Shape?): Boolean {
        val l = shape as? Shape.Line ?: return false
        val a = l.points.first(); val b = l.points.last()
        return abs(b.first - a.first) > 3 * abs(b.second - a.second)
    }

    /**
     * Recognise the stroke [points] (view pixels; [scale] = view pixels per page unit) as the firmware's `DrawAndHoldGesture` does
     * (reference/remarkable-3.27.1.0/behaviour/shape_snap.md): simplify with Douglas-Peucker at 1 page unit, then in this order a straight line
     * (deviation < 0.1 x chord, path < 1.2 x chord), an ellipse (fit score > 0.9), a rectangle (score > 0.95) and a 3 or 4 corner polygon
     * (corners merged within 15 px, simplified length > 0.93 x length). At least 10 points and a chord of 3 px are needed.
     */
    fun detect(points: List<Pair<Float, Float>>, scale: Float = 1f): Shape? {
        if (points.size < MIN_POINTS) return null
        val first = points.first(); val last = points.last()
        val chord = dist(first, last)
        // The firmware wants a first-to-last chord of 3 px; a loop closed to within 3 px would never pass that, so the app tests the stroke's size instead.
        if (hypot(points.maxOf { it.first } - points.minOf { it.first }, points.maxOf { it.second } - points.minOf { it.second }) < MIN_CHORD_PX) return null
        val closed = chord < 1e-3f // the firmware's "first equals last" test: only an exactly closed loop is measured from its end point

        val p = simplify(points, EPS * scale)
        // Straight line: every simplified point near the chord, and not much longer than it.
        val maxDev = p.drop(1).maxOfOrNull { if (closed) dist(it, last) else distToLine(it, first, last) } ?: 0f
        val pathLen = length(p)
        if (maxDev < 0.1f * chord && pathLen < 1.2f * chord) return Shape.Line(lineSnap(first, last))

        // The minimum-area rectangle of the convex hull, centred on the bounding box of the points.
        val box = minAreaBox(p)
        val cx = (p.minOf { it.first } + p.maxOf { it.first }) / 2f; val cy = (p.minOf { it.second } + p.maxOf { it.second }) / 2f
        val w0 = box.w; val h0 = box.h; val theta = box.theta
        val cosT = cos(theta); val sinT = sin(theta)
        fun local(q: Pair<Float, Float>): Pair<Float, Float> { val dx = q.first - cx; val dy = q.second - cy; return (cosT * dx + sinT * dy) to (cosT * dy - sinT * dx) }
        val pLen = pathLen
        fun score(outline: Float, tol: Float, d: (Float, Float) -> Float): Float {
            if (pLen < 0.9f * outline) return 0f
            return p.count { val (x, y) = local(it); abs(d(x, y)) < tol }.toFloat() / p.size
        }
        val hw = w0 / 2f; val hh = h0 / 2f
        val ellipseOutline = ellipsePolygon(hw, hh, 100).let { poly -> (poly.indices).sumOf { dist(poly[it], poly[(it + 1) % poly.size]).toDouble() }.toFloat() }
        val sE = if (hw > 0f && hh > 0f) score(ellipseOutline, 0.2f) { x, y -> sqrt((x / hw) * (x / hw) + (y / hh) * (y / hh)) - 1f } else 0f
        val sR = if (hw > 0f && hh > 0f) score(2f * (w0 + h0), 0.35f) { x, y -> max(abs(x) - hw, abs(y) - hh) / min(hw, hh) } else 0f

        // The circle / square rule: nearly equal sides become equal. The firmware keeps the corner computed from the raw sides (so the
        // averaged shape is not re-centred); its bounds are (cx - w0/2, cy - h0/2, w, h) turned about their own centre.
        var w = w0; var h = h0
        if (max(w0, h0) > 0f && min(w0, h0) / max(w0, h0) > 0.8f) { w = (w0 + h0) / 2f; h = w }
        val ox = cx - w0 / 2f; val oy = cy - h0 / 2f
        val bx = ox + w / 2f; val by = oy + h / 2f
        fun world(lx: Float, ly: Float) = (bx + cosT * lx - sinT * ly) to (by + sinT * lx + cosT * ly)
        if (sE > 0.9f) return Shape.Closed("ellipse", ellipsePolygon(w / 2f, h / 2f, 100).map { world(it.first, it.second) }.let { it + it.first() })
        if (sR > 0.95f) return Shape.Closed("rectangle", sample(listOf(world(-w / 2f, -h / 2f), world(w / 2f, -h / 2f), world(w / 2f, h / 2f), world(-w / 2f, h / 2f)), true, 32))

        // A polygon of three or four corners.
        val diag = hypot(w0, h0)
        if (dist(p.first(), p.last()) >= max(diag / 3f, 1f)) return null
        val sp = simplify(p, diag / 10f)
        if (sp.size != 4 && sp.size != 5) return null
        val v = ArrayList<Pair<Float, Float>>()
        v += ((sp.first().first + sp.last().first) / 2f) to ((sp.first().second + sp.last().second) / 2f)
        v += sp.subList(1, sp.size - 1)
        for (i in 1 until v.size) for (j in 0 until i) {
            if (abs(v[i].first - v[j].first) < AXIS_SNAP_PX) v[i] = v[j].first to v[i].second
            if (abs(v[i].second - v[j].second) < AXIS_SNAP_PX) v[i] = v[i].first to v[j].second
        }
        if (length(sp) / pLen.coerceAtLeast(1e-6f) <= 0.93f) return null
        return Shape.Closed(if (v.size == 3) "triangle" else "quadrilateral", sample(v, true, 24))
    }

    private const val MIN_POINTS = 10
    private const val MIN_CHORD_PX = 3f
    private const val EPS = 1f
    private const val AXIS_SNAP_PX = 15f

    private fun length(p: List<Pair<Float, Float>>): Float { var s = 0f; for (i in 1 until p.size) s += dist(p[i - 1], p[i]); return s }

    /** A line from [a] to [b]: close to horizontal or vertical (within max(L/3, 10) px) it is made exactly so. */
    private fun lineSnap(a: Pair<Float, Float>, b: Pair<Float, Float>): List<Pair<Float, Float>> {
        val len = dist(a, b); val tol = max(len / 3f, 10f)
        var end = b
        if (abs(b.second - a.second) < tol) end = end.first to a.second
        else if (abs(b.first - a.first) < tol) end = a.first to end.second
        return sample(listOf(a, end), false, 24)
    }

    private class Box(val w: Float, val h: Float, val theta: Float)

    /** The minimum-area rectangle of the convex hull of [pts]: the hull edge direction that gives the smallest bounding box. */
    private fun minAreaBox(pts: List<Pair<Float, Float>>): Box {
        val hull = convexHull(pts)
        if (hull.size < 3) return Box(abs(pts.last().first - pts.first().first), abs(pts.last().second - pts.first().second), 0f)
        var best: Box? = null; var bestArea = Float.MAX_VALUE
        for (i in hull.indices) {
            val a = hull[i]; val b = hull[(i + 1) % hull.size]
            val ang = atan2(b.second - a.second, b.first - a.first)
            val c = cos(ang); val s = sin(ang)
            var u0 = Float.MAX_VALUE; var u1 = -Float.MAX_VALUE; var v0 = Float.MAX_VALUE; var v1 = -Float.MAX_VALUE
            for (q in hull) { val u = c * q.first + s * q.second; val v = c * q.second - s * q.first; u0 = min(u0, u); u1 = max(u1, u); v0 = min(v0, v); v1 = max(v1, v) }
            val area = (u1 - u0) * (v1 - v0)
            if (area < bestArea) { bestArea = area; best = Box(u1 - u0, v1 - v0, ang) }
        }
        return best!!
    }

    /** Andrew's monotone chain. */
    private fun convexHull(pts: List<Pair<Float, Float>>): List<Pair<Float, Float>> {
        val s = pts.distinct().sortedWith(compareBy({ it.first }, { it.second }))
        if (s.size < 3) return s
        fun cr(o: Pair<Float, Float>, a: Pair<Float, Float>, b: Pair<Float, Float>) = (a.first - o.first) * (b.second - o.second) - (a.second - o.second) * (b.first - o.first)
        val lower = ArrayList<Pair<Float, Float>>()
        for (q in s) { while (lower.size >= 2 && cr(lower[lower.size - 2], lower.last(), q) <= 0) lower.removeAt(lower.size - 1); lower += q }
        val upper = ArrayList<Pair<Float, Float>>()
        for (q in s.asReversed()) { while (upper.size >= 2 && cr(upper[upper.size - 2], upper.last(), q) <= 0) upper.removeAt(upper.size - 1); upper += q }
        return lower.dropLast(1) + upper.dropLast(1)
    }

    /** [n] points around an ellipse with half-axes [a], [b] about the origin. */
    private fun ellipsePolygon(a: Float, b: Float, n: Int): List<Pair<Float, Float>> =
        (0 until n).map { val t = 2 * PI * it / n; (a * cos(t)).toFloat() to (b * sin(t)).toFloat() }

    private fun dist(a: Pair<Float, Float>, b: Pair<Float, Float>) = hypot(a.first - b.first, a.second - b.second)

    private fun distToLine(p: Pair<Float, Float>, a: Pair<Float, Float>, b: Pair<Float, Float>): Float {
        val dx = b.first - a.first; val dy = b.second - a.second
        val len = hypot(dx, dy).coerceAtLeast(1e-6f)
        return abs(dy * (p.first - a.first) - dx * (p.second - a.second)) / len
    }

    /** Douglas-Peucker. */
    private fun simplify(pts: List<Pair<Float, Float>>, eps: Float): List<Pair<Float, Float>> {
        if (pts.size < 3) return pts
        var idx = 0; var worst = 0f
        for (i in 1 until pts.size - 1) { val d = distToLine(pts[i], pts.first(), pts.last()); if (d > worst) { worst = d; idx = i } }
        // A closed ring has the same first and last point: split it at the farthest point first.
        if (dist(pts.first(), pts.last()) < 1e-3f) {
            var far = 0; var fd = 0f
            for (i in 1 until pts.size - 1) { val d = dist(pts[i], pts.first()); if (d > fd) { fd = d; far = i } }
            val a = simplify(pts.subList(0, far + 1), eps); val b = simplify(pts.subList(far, pts.size), eps)
            return a.dropLast(1) + b
        }
        return if (worst > eps) simplify(pts.subList(0, idx + 1), eps).dropLast(1) + simplify(pts.subList(idx, pts.size), eps) else listOf(pts.first(), pts.last())
    }

    /** Points along the polyline through [corners] (closed back to the start when [close]), [perSide] per side at most. */
    private fun sample(corners: List<Pair<Float, Float>>, close: Boolean, perSide: Int): List<Pair<Float, Float>> {
        val out = ArrayList<Pair<Float, Float>>()
        val n = if (close) corners.size else corners.size - 1
        for (i in 0 until n) {
            val a = corners[i]; val b = corners[(i + 1) % corners.size]
            val steps = max(2, min(perSide, (dist(a, b) / 12f).toInt()))
            for (s in 0 until steps) { val t = s / steps.toFloat(); out += (a.first + (b.first - a.first) * t) to (a.second + (b.second - a.second) * t) }
        }
        out += if (close) corners.first() else corners.last()
        return out
    }
}
