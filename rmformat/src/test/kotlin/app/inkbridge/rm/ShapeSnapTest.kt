package app.inkbridge.rm

import app.inkbridge.rm.edit.ShapeSnap
import org.junit.Assert.*
import org.junit.Test
import kotlin.math.cos
import kotlin.math.sin

class ShapeSnapTest {
    private fun jitter(i: Int) = ((i * 7919) % 11 - 5) * 0.4f
    private fun circle(n: Int = 80) = (0..n).map { val t = 2 * Math.PI * it / n; (500 + 200 * cos(t).toFloat() + jitter(it)) to (500 + 150 * sin(t).toFloat() + jitter(it + 3)) }
    private fun poly(vararg c: Pair<Float, Float>): List<Pair<Float, Float>> {
        val out = ArrayList<Pair<Float, Float>>()
        for (i in c.indices) { val a = c[i]; val b = c[(i + 1) % c.size]; for (s in 0 until 20) out += (a.first + (b.first - a.first) * s / 20 + jitter(out.size)) to (a.second + (b.second - a.second) * s / 20 + jitter(out.size + 1)) }
        out += c[0]; return out
    }

    @Test fun lineBecomesStraight() {
        val s = ShapeSnap.detect((0..40).map { (100f + it * 10) to (300f + (if (it % 2 == 0) 2f else -2f)) })
        assertTrue(s is ShapeSnap.Shape.Line)
        assertTrue(ShapeSnap.isHorizontalLine(s))
    }
    @Test fun circleBecomesEllipse() = assertEquals("ellipse", (ShapeSnap.detect(circle()) as ShapeSnap.Shape.Closed).kind)
    @Test fun squareBecomesRectangle() = assertEquals("rectangle", (ShapeSnap.detect(poly(100f to 100f, 400f to 100f, 400f to 350f, 100f to 350f)) as ShapeSnap.Shape.Closed).kind)
    @Test fun triangleBecomesTriangle() = assertEquals("triangle", (ShapeSnap.detect(poly(100f to 400f, 300f to 100f, 500f to 400f)) as ShapeSnap.Shape.Closed).kind)
    @Test fun scribbleIsLeftAlone() {
        val s = (0..120).map { (100f + it * 3 + 40 * sin(it / 3.0).toFloat()) to (200f + 90 * cos(it / 5.0).toFloat()) }
        assertNull(ShapeSnap.detect(s))
    }
}
