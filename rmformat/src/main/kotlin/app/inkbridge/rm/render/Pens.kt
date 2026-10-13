package app.inkbridge.rm.render

import app.inkbridge.rm.scene.PenColorId
import app.inkbridge.rm.scene.PenId
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow

/**
 * Pen behaviour: how width, colour and opacity vary along a stroke.
 *
 * The width/opacity formulas are empirical approximations of the tablet's brushes, derived from
 * the open-source `rmc` / `maxio` renderers (MIT). They are tuned numbers, not xochitl code.
 * Inputs use the file's v2 units: speed/width are uint16 (÷4 for page units), direction/pressure uint8.
 */
abstract class Pen(val baseWidth: Double, val baseColor: IntArray /* r,g,b,a */) {
    /** Points per drawn polyline segment; per-segment styling can't vary within one. */
    open val segmentLength: Int = 1000
    open val roundCap: Boolean = true
    open val baseOpacity: Double = 1.0

    open fun segmentWidth(speed: Int, direction: Int, width: Int, pressure: Int, last: Double): Double = baseWidth

    /** RGBA of the segment. */
    open fun segmentColor(speed: Int, direction: Int, width: Int, pressure: Int, last: Double): IntArray = baseColor

    open fun segmentOpacity(speed: Int, direction: Int, width: Int, pressure: Int, last: Double): Double = baseOpacity

    protected fun tilt(direction: Int) = direction * (PI * 2) / 255
    protected fun clamp(v: Double) = min(max(v, 0.0), 1.0)

    /** Blend [base] toward white by [amount] 0..1 (0 = base colour). */
    protected fun towardWhite(base: IntArray, amount: Double): IntArray = intArrayOf(
        (base[0] + (255 - base[0]) * amount).toInt().coerceIn(0, 255),
        (base[1] + (255 - base[1]) * amount).toInt().coerceIn(0, 255),
        (base[2] + (255 - base[2]) * amount).toInt().coerceIn(0, 255),
        base[3],
    )

    companion object {
        /** Returns null for tools that are not drawn (erasers). */
        fun create(tool: Int, color: IntArray, thicknessScale: Double): Pen? = when (tool) {
            PenId.PAINTBRUSH_1, PenId.PAINTBRUSH_2 -> Brush(thicknessScale, color)
            PenId.CALLIGRAPHY -> Calligraphy(thicknessScale, color)
            PenId.MARKER_1, PenId.MARKER_2 -> Marker(thicknessScale, color)
            PenId.BALLPOINT_1, PenId.BALLPOINT_2 -> Ballpoint(thicknessScale, color)
            PenId.FINELINER_1, PenId.FINELINER_2 -> Fineliner(thicknessScale, color)
            PenId.PENCIL_1, PenId.PENCIL_2 -> Pencil(thicknessScale, color)
            PenId.MECHANICAL_PENCIL_1, PenId.MECHANICAL_PENCIL_2 -> MechanicalPencil(thicknessScale, color)
            PenId.HIGHLIGHTER_1, PenId.HIGHLIGHTER_2 -> Highlighter(color)
            PenId.SHADER -> Shader(color)
            PenId.ERASER, PenId.ERASER_AREA -> null
            else -> Fineliner(thicknessScale, color) // unknown future pen: draw something sensible
        }
    }

    class Fineliner(w: Double, c: IntArray) : Pen(w * 1.8, c)

    class Ballpoint(w: Double, c: IntArray) : Pen(w, c) {
        override val segmentLength = 5
        override fun segmentWidth(speed: Int, direction: Int, width: Int, pressure: Int, last: Double) =
            (0.5 + pressure / 255.0) + (width / 4.0) - 0.5 * ((speed / 4.0) / 50)

        override fun segmentColor(speed: Int, direction: Int, width: Int, pressure: Int, last: Double): IntArray {
            val intensity = clamp((0.1 * -((speed / 4.0) / 35)) + (1.2 * pressure / 255) + 0.5)
            // Black ink: up to dark grey (60/255) when light/fast; coloured ink fades toward white by the same amount.
            return towardWhite(baseColor, min(abs(intensity - 1) * 255, 60.0) / 255)
        }
    }

    class Marker(w: Double, c: IntArray) : Pen(w, c) {
        override val segmentLength = 3
        override fun segmentWidth(speed: Int, direction: Int, width: Int, pressure: Int, last: Double) =
            0.9 * ((width / 4.0) - 0.4 * tilt(direction)) + 0.1 * last
    }

    class Pencil(w: Double, c: IntArray) : Pen(w, c) {
        override val segmentLength = 2
        override fun segmentWidth(speed: Int, direction: Int, width: Int, pressure: Int, last: Double): Double {
            val w = 0.7 * ((((0.8 * baseWidth) + (0.5 * pressure / 255)) * (width / 4.0)) -
                (0.25 * tilt(direction).pow(1.8)) - (0.6 * (speed / 4.0) / 50))
            return min(w, baseWidth * 10)
        }

        override fun segmentOpacity(speed: Int, direction: Int, width: Int, pressure: Int, last: Double) =
            max(clamp((0.1 * -((speed / 4.0) / 35)) + (1.0 * pressure / 255)) - 0.1, 0.0)
    }

    class MechanicalPencil(w: Double, c: IntArray) : Pen(w * w, c) {
        override val baseOpacity = 0.7
    }

    class Brush(w: Double, c: IntArray) : Pen(w, c) {
        override val segmentLength = 2
        override fun segmentWidth(speed: Int, direction: Int, width: Int, pressure: Int, last: Double) =
            0.7 * (((1 + (1.4 * pressure / 255)) * (width / 4.0)) - (0.5 * tilt(direction)) - ((speed / 4.0) / 50))

        override fun segmentColor(speed: Int, direction: Int, width: Int, pressure: Int, last: Double): IntArray {
            val intensity = clamp(((pressure / 255.0).pow(1.5) - 0.2 * ((speed / 4.0) / 50)) * 1.5)
            return towardWhite(baseColor, abs(intensity - 1))
        }
    }

    class Calligraphy(w: Double, c: IntArray) : Pen(w, c) {
        override val segmentLength = 2
        override fun segmentWidth(speed: Int, direction: Int, width: Int, pressure: Int, last: Double) =
            0.9 * (((1 + pressure / 255.0) * (width / 4.0)) - 0.3 * tilt(direction)) + 0.1 * last
    }

    class Highlighter(c: IntArray) : Pen(15.0, c) {
        override val roundCap = false
        override val baseOpacity = 0.3
    }

    class Shader(c: IntArray) : Pen(12.0, c) {
        override val baseOpacity = 0.1
    }
}

/** Colour palette (RGB) used by the tablet's pen colour ids. */
object PenPalette {
    private val rgb = mapOf(
        PenColorId.BLACK to intArrayOf(0, 0, 0),
        PenColorId.GRAY to intArrayOf(144, 144, 144),
        PenColorId.WHITE to intArrayOf(255, 255, 255),
        PenColorId.YELLOW to intArrayOf(251, 247, 25),
        PenColorId.GREEN to intArrayOf(0, 255, 0),
        PenColorId.PINK to intArrayOf(255, 192, 203),
        PenColorId.BLUE to intArrayOf(78, 105, 201),
        PenColorId.RED to intArrayOf(179, 62, 57),
        PenColorId.GRAY_OVERLAP to intArrayOf(125, 125, 125),
        PenColorId.GREEN_2 to intArrayOf(161, 216, 125),
        PenColorId.CYAN to intArrayOf(139, 208, 229),
        PenColorId.MAGENTA to intArrayOf(183, 130, 205),
        PenColorId.YELLOW_2 to intArrayOf(247, 232, 81),
        // "HIGHLIGHT" shares one id; the real shade normally comes in the explicit RGBA field.
        PenColorId.HIGHLIGHT to intArrayOf(251, 247, 25),
    )

    /** RGBA for a pen colour id, preferring the explicit RGBA stored with the stroke. */
    fun lookup(colorId: Int, explicitRgba: IntArray?): IntArray {
        if (explicitRgba != null) return explicitRgba
        val c = rgb[colorId] ?: rgb.getValue(PenColorId.BLACK)
        return intArrayOf(c[0], c[1], c[2], 255)
    }
}
