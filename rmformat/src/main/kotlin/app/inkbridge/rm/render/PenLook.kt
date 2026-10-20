package app.inkbridge.rm.render

import app.inkbridge.rm.edit.InputPoint
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.StrokeBuilder

/**
 * What a pen's finished stroke looks like on average, so a live preview drawn by another renderer (the Onyx SDK's fixed ink styles) can be
 * set to the same width and the same amount of ink. The firmware pens are textured and soft-edged; a solid SDK line of the measured
 * [width] in a grey of the measured [coverage] puts the same ink on the screen.
 */
object PenLook {
    /** [width] in page units across the stroke's solid core; [coverage] 0..1 = ink per unit of that width (1 = solid). */
    data class Look(val width: Float, val coverage: Float)

    private val cache = HashMap<Pair<Int, Int>, Look>()

    /** The look of [spec] drawn at page scale 1 with a steady medium pressure. */
    @Synchronized fun of(spec: PenSpec): Look = cache.getOrPut(spec.tool.ordinal to spec.thickness) { measure(PenSpec(spec.tool, app.inkbridge.rm.scene.PenColorId.BLACK, spec.thickness)) }

    private fun measure(spec: PenSpec): Look {
        val pts = (0..60).map { InputPoint(100f + it * 5f, 100f, 0.6f, 0f, 0f, it * 8L) }
        val line = StrokeBuilder.build(spec, pts) ?: return Look(2f * spec.thickness, 1f)
        val ink = PixelInk(500, 200)
        ink.drawLine(line, 0f, 0f, PixelInk.Transform(1f, 0f, 0f))
        var extentSum = 0f; var massSum = 0f; var cols = 0
        for (x in 200..300) {
            var lo = Int.MAX_VALUE; var hi = -1; var mass = 0f
            for (y in 0 until 200) {
                val a = ink.px[y * 500 + x] ushr 24
                if (a > 0) mass += a / 255f
                if (a >= 64) { if (y < lo) lo = y; if (y > hi) hi = y }
            }
            if (hi >= lo) { extentSum += (hi - lo + 1); massSum += mass; cols++ }
        }
        if (cols == 0) return Look(2f * spec.thickness, 1f)
        val extent = extentSum / cols
        return Look(extent, (massSum / cols / extent).coerceIn(0.15f, 1f))
    }
}
