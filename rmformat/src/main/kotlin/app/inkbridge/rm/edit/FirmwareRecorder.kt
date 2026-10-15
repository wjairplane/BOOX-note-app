package app.inkbridge.rm.edit

import app.inkbridge.rm.scene.Point
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan
import kotlin.math.atan2
import kotlin.math.floor
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.math.tan

/**
 * How the tablet turns digitizer samples into the points it stores (xochitl's `LineBuilder::addSample`, 0xb63490 / 0xb62de4),
 * ported from the firmware (tools/firmware/pens_record_port.py, which matches the real code under emulation except for two
 * direction bytes in about 23,000). Widths, speeds, directions and pressures come out in the file's units
 * (width and speed are 4 x the page-unit value, direction a full turn in 0..255, pressure 0..255).
 */
object FirmwareRecorder {
    /** One digitizer sample: page position, pressure 0..1 and the pen's tilt along x and y in radians. */
    class Sample(val x: Float, val y: Float, val pressure: Float, val tiltX: Float = 0f, val tiltY: Float = 0f)

    private const val TWO_PI = 2 * PI

    private fun round(v: Double): Int = if (v >= 0) floor(v + 0.5).toInt() else -floor(-v + 0.5).toInt()
    private fun norm2pi(a: Double): Double = if (a < 0) a % TWO_PI + TWO_PI else if (a >= TWO_PI) a % TWO_PI else a
    private fun smooth(t: Double) = (3 - 2 * t) * t * t

    /** Old-style tools whose pressure is damped by speed (mask 0x81900b at 0xb5f1a8). */
    private val SPEED_DAMPED = setOf(0, 1, 3, 12, 15, 23)
    private val NEW_STYLE = setOf(13, 14, 15, 16, 19, 20, 21, 23)

    /**
     * Points for one stroke made with pen [tool] (a pen id) at thickness [thickness] (1 thin, 2 medium, 3 thick).
     * [zoom] is the page's zoom (1 when the page fills the screen width, which is what a file from the tablet assumes);
     * [leftHanded] and [nibRotationDeg] only matter for the calligraphy pen.
     */
    fun record(tool: Int, thickness: Double, samples: List<Sample>, zoom: Double = 1.0, leftHanded: Boolean = false, nibRotationDeg: Double = 0.0): List<Point> {
        val out = ArrayList<Point>(samples.size)
        var prev: Sample? = null; var prev2: Sample? = null
        var last: Point? = null
        for (s in samples) {
            if (prev == null) { prev = s; prev2 = s }
            val p0 = prev; val p2 = prev2!!
            val dx = (s.x - p0.x).toDouble(); val dy = (s.y - p0.y).toDouble()
            val dirc = norm2pi(atan2(dy, dx))
            val p = s.pressure.toDouble()
            val tx = s.tiltX.toDouble(); val ty = s.tiltY.toDouble()
            val pt: Point
            if (tool in NEW_STYLE) {
                val tilt = min(atan(sqrt(tan(ty).pow(2) + tan(tx).pow(2))), 1.0)
                var speed = zoom * hypot(dx, dy)
                val tp = if (thickness > 1.0) thickness / 1.35 else thickness
                val width: Double
                var pressureByte: Int
                when (tool) {
                    13 -> { width = 4.0 * tp; pressureByte = if (p < 0) 179 else if (p > 1) 255 else round((0.7 + smooth(p) * 0.3) * 255) }
                    14 -> {
                        var tf = if (tilt < 0.5235988) 0.0 else if (tilt <= 0.9599311) (tilt - 0.5235988) / 0.4363323 else 1.0
                        tf *= tf
                        val pp = if (last != null) p * 0.2 + (last.pressure / 255.0) * 0.8 else p
                        pressureByte = round(pp * 255); width = (pp + 2.0 + tf * 15.0) * thickness
                    }
                    15 -> { width = max(p * 3, 2.0) * tp; pressureByte = round(p * 255) }
                    16 -> { width = ((p * 0.5 + 0.5) * tilt * tilt * 10 + 2.5) * thickness; pressureByte = round(p * 255) }
                    19, 20 -> { width = 2 * thickness; pressureByte = round(p * 255) }
                    21 -> {
                        val nib = ((if (leftHanded) 40.0 else 170.0) + nibRotationDeg) * PI / 180.0
                        var az = atan2(sin(ty), sin(tx)); if (az < 0) az += TWO_PI
                        var a = dirc - az; if (a < 0) a += TWO_PI
                        a -= (PI / 2 - nib); if (a < 0) a += TWO_PI
                        if (a > PI) a -= TWO_PI
                        val f = max(0.0, (1.0471976 - abs(a)) / 1.0471976)
                        var w = max((f * p * 4.5 + 1.0) * thickness, 1.5)
                        if (last != null) w = w * 0.25 + (last.width / 4.0 * 0.25) * 0.75
                        width = w; pressureByte = round(p * 255)
                    }
                    else -> { // 23, the shading marker
                        val pf = if (p < 0.1) 1.0 / 3 else if (p <= 0.3) { val x = (p - 0.1) / 0.2; x + (1 - x) / 3 } else 1.0
                        width = (2.0 + 10.0 * thickness) * pf; pressureByte = round(p * 255)
                        if (last != null) speed = speed * 0.1 + (last.speed / 4.0 * 0.25) * 0.9
                    }
                }
                pt = Point(s.x, s.y, round(speed * 4).coerceIn(0, 0xFFFF), round(dirc * 255 / TWO_PI).coerceIn(0, 255), round(width * 4).coerceIn(0, 0xFFFF), pressureByte.coerceIn(0, 255))
            } else {
                // Old-style tools (the first half of 0xb63490): fineliner, highlighter, paintbrush...
                val dx2 = (p0.x - p2.x).toDouble(); val dy2 = (p0.y - p2.y).toDouble()
                val angp = norm2pi(atan2(dy2, dx2))
                var ps = min((p + p0.pressure) * 0.5, 1.0)
                val tmag = hypot(tx, ty)
                val d = hypot(dx, dy); val d2 = hypot(dx2, dy2)
                val speed = (d + d2) * zoom * 0.5
                if (tool in SPEED_DAMPED) {
                    val f = 1.0 - (d + d2) * 0.5 / 100.0
                    if (f < 0.5) ps *= 0.5 else if (f < 1.0) ps *= f
                }
                val direction = (angp + dirc) * 0.5
                var pressureByte = round(ps * 255)
                var tp = thickness
                val width: Double
                when (tool) {
                    0, 12 -> { ps = max(ps, 0.25); pressureByte = round(ps * 255); width = max(10.0 * ps.pow(4.5) + 5.0 * tmag.pow(4), 2.0) }
                    4, 17 -> width = 2.0
                    5, 18 -> { width = 30.0; tp = 1.0 }
                    else -> width = 2.0
                }
                val w = width * tp
                val wraw = if (w <= 2.0) 8 else round(w * 4)
                pt = Point(s.x, s.y, round(speed * 4).coerceIn(0, 0xFFFF), round(direction * 255 / TWO_PI).coerceIn(0, 255), wraw.coerceIn(0, 0xFFFF), pressureByte.coerceIn(0, 255))
            }
            out += pt
            last = pt
            prev2 = prev; prev = s
        }
        return out
    }

    /** True for the pen ids this recorder reproduces exactly. */
    fun supports(tool: Int): Boolean = tool in NEW_STYLE || tool in setOf(0, 4, 5, 12, 17, 18)
}
