package app.inkbridge.rm.edit

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.acos
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

    fun detect(points: List<Pair<Float, Float>>): Shape? {
        if (points.size < 10) return null // the firmware needs at least 10 points
        var length = 0f
        for (i in 1 until points.size) length += dist(points[i - 1], points[i])
        val minX = points.minOf { it.first }; val maxX = points.maxOf { it.first }
        val minY = points.minOf { it.second }; val maxY = points.maxOf { it.second }
        val diag = hypot(maxX - minX, maxY - minY)
        if (diag < 40f) return null

        val first = points.first(); val last = points.last()
        val closed = dist(first, last) < 0.2f * length && length > 2.2f * diag * 0.5f
        if (!closed) {
            // A line: every point close to the chord.
            val chord = dist(first, last)
            if (chord < 0.5f * length) return null
            var worst = 0f
            for (p in points) worst = max(worst, distToLine(p, first, last))
            if (worst > 0.07f * chord) return null
            return Shape.Line(sample(listOf(first, last), false, 24))
        }

        val ring = points + points.first()
        val poly = simplify(ring, 0.1f * diag).let { if (it.size > 1 && dist(it.first(), it.last()) < 1e-3f) it.dropLast(1) else it }
        val ellipse = ellipseFit(points, minX, maxX, minY, maxY)
        return when {
            poly.size == 3 -> Shape.Closed("triangle", sample(poly, true, 24))
            poly.size == 4 && !ellipse -> {
                val rect = nearRectangle(poly)
                Shape.Closed(if (rect != null) "rectangle" else "quadrilateral", sample(rect ?: poly, true, 32))
            }
            ellipse -> Shape.Closed("ellipse", ellipsePoints(minX, maxX, minY, maxY, 64))
            poly.size in 5..6 -> Shape.Closed("polygon", sample(poly, true, 40))
            else -> null
        }
    }

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

    private fun ellipseFit(pts: List<Pair<Float, Float>>, x0: Float, x1: Float, y0: Float, y1: Float): Boolean {
        val cx = (x0 + x1) / 2; val cy = (y0 + y1) / 2; val a = (x1 - x0) / 2; val b = (y1 - y0) / 2
        if (a < 10f || b < 10f) return false
        val r = pts.map { hypot((it.first - cx) / a, (it.second - cy) / b) }
        val mean = r.average().toFloat()
        val sd = sqrt(r.map { (it - mean) * (it - mean) }.average()).toFloat()
        return mean in 0.85f..1.12f && sd < 0.11f
    }

    private fun ellipsePoints(x0: Float, x1: Float, y0: Float, y1: Float, n: Int): List<Pair<Float, Float>> {
        val cx = (x0 + x1) / 2; val cy = (y0 + y1) / 2; val a = (x1 - x0) / 2; val b = (y1 - y0) / 2
        return (0..n).map { val t = 2 * PI * it / n; (cx + a * cos(t)).toFloat() to (cy + b * sin(t)).toFloat() }
    }

    /** A rectangle (possibly rotated) when the four corners are all within 25 degrees of a right angle. */
    private fun nearRectangle(q: List<Pair<Float, Float>>): List<Pair<Float, Float>>? {
        for (i in 0 until 4) {
            val p = q[(i + 3) % 4]; val c = q[i]; val n = q[(i + 1) % 4]
            val v1x = p.first - c.first; val v1y = p.second - c.second; val v2x = n.first - c.first; val v2y = n.second - c.second
            val cosA = (v1x * v2x + v1y * v2y) / (hypot(v1x, v1y) * hypot(v2x, v2y)).coerceAtLeast(1e-6f)
            if (abs(acos(cosA.coerceIn(-1f, 1f)) - PI / 2) > 25 * PI / 180) return null
        }
        // Rebuild it from the centre, the averaged side directions and half sizes.
        val cx = q.sumOf { it.first.toDouble() }.toFloat() / 4; val cy = q.sumOf { it.second.toDouble() }.toFloat() / 4
        val ux = (q[1].first - q[0].first) + (q[2].first - q[3].first); val uy = (q[1].second - q[0].second) + (q[2].second - q[3].second)
        val ul = hypot(ux, uy).coerceAtLeast(1e-6f); val dx = ux / ul; val dy = uy / ul
        val nx = -dy; val ny = dx
        val w = (dist(q[0], q[1]) + dist(q[2], q[3])) / 4; val h = (dist(q[1], q[2]) + dist(q[3], q[0])) / 4
        fun c(sw: Float, sh: Float) = (cx + sw * w * dx + sh * h * nx) to (cy + sw * w * dy + sh * h * ny)
        // keep the original winding
        return listOf(c(-1f, -1f), c(1f, -1f), c(1f, 1f), c(-1f, 1f)).let { r -> if (cross(q) * cross(r) < 0) r.reversed() else r }
    }

    private fun cross(p: List<Pair<Float, Float>>): Float {
        var s = 0f
        for (i in p.indices) { val a = p[i]; val b = p[(i + 1) % p.size]; s += a.first * b.second - b.first * a.second }
        return s
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
