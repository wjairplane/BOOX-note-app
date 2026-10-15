package app.inkbridge.rm

import app.inkbridge.rm.edit.*
import app.inkbridge.rm.render.PixelInk
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.math.cos
import kotlin.math.sin

/** A timing check: a page of handwriting-like strokes drawn at fit zoom and zoomed in, on a Note Air 5C sized view. */
class PixelInkBenchTest {
    private fun page(): PageEditor {
        val ed = PageEditor.blank()
        val tools = PenTool.values().filter { it != PenTool.ERASER && it != PenTool.SELECTION && it != PenTool.ERASE_AREA }
        var n = 0
        for (row in 0 until 30) for (word in 0 until 8) {
            val spec = PenSpec(tools[n++ % tools.size], thickness = 1 + n % 3)
            val x0 = 80f + word * 160f; val y0 = 150f + row * 55f
            val pts = (0 until 40).map { i ->
                val t = i / 39f
                InputPoint(x0 + 140f * t, y0 + 18f * sin(t * 14f) + 6f * cos(t * 31f), 0.3f + 0.5f * t, 0f, 0f, i * 8L)
            }
            ed.addStroke(spec, pts)
        }
        return ed
    }

    @Test fun benchmark() {
        val ed = page()
        val w = 1860; val h = 2480
        val fit = h / 1872f
        for ((name, tf) in listOf(
            "fit" to PixelInk.Transform(fit, (w - 1404 * fit) / 2, 0f),
            "x2" to PixelInk.Transform(fit * 2, -400f, -300f),
            "x4" to PixelInk.Transform(fit * 4, -1500f, -1200f),
        )) {
            val ink = PixelInk(w, h)
            repeat(2) { ink.clear(); ed.renderer.renderInk(ink, tf) } // warm up
            val t0 = System.nanoTime()
            repeat(3) { ink.clear(); ed.renderer.renderInk(ink, tf) }
            println("BENCH renderInk $name: ${(System.nanoTime() - t0) / 3_000_000} ms")
            val base = IntArray(w * h) { -1 }; val out = IntArray(w * h)
            val t1 = System.nanoTime()
            repeat(3) { ink.compositeInto(base, out, 0, 0, w, h) }
            println("BENCH composite $name: ${(System.nanoTime() - t1) / 3_000_000} ms")
            assertTrue(ink.isDirty)
        }
    }
}
