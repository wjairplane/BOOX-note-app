package app.inkbridge.pen

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Point
import android.os.SystemClock
import com.onyx.android.sdk.device.Device

/**
 * A look at what the tablet's firmware offers for drawing ink faster than a normal surface (found by reading the Onyx SDK, never tried on a
 * device): the board and device class, the stroke-style parameter tables, and whether the hand-writing bitmap call accepts our pixels.
 * Everything is called by reflection and guarded, so a missing or refused call is reported, never fatal.
 */
object PenProbe {
    fun run(): String {
        val out = StringBuilder()
        fun line(s: String) { out.append(s).append('\n') }
        line("Board: " + runCatching { Device.getBoardPlatform() }.getOrElse { "unknown (${it.javaClass.simpleName})" })
        val device = runCatching { Device.currentDevice() }.getOrNull()
        line("Device class: ${device?.javaClass?.simpleName ?: "unknown"}")
        if (device != null) for (style in 0..7) {
            val params = runCatching { device.javaClass.getMethod("getStrokeParameters", Int::class.javaPrimitiveType).invoke(device, style) as? FloatArray }.getOrNull()
            line("Stroke style $style parameters: " + (params?.joinToString(", ", "[", "]") { "%.3f".format(it) } ?: "not available"))
        }
        // A small grey square at (480, 480): does the firmware take it, how long does it take, does it show?
        val bmp = Bitmap.createBitmap(96, 96, Bitmap.Config.ARGB_8888).also { Canvas(it).drawColor(Color.argb(255, 90, 90, 90)) }
        val t0 = SystemClock.elapsedRealtimeNanos()
        val result = runCatching {
            val cls = Class.forName("com.onyx.android.sdk.api.device.epd.EpdController")
            cls.getMethod("drawScreenHandWritingBitmap", Bitmap::class.java, Point::class.java).invoke(null, bmp, Point(480, 480))
        }
        val ms = (SystemClock.elapsedRealtimeNanos() - t0) / 1e6
        line("drawScreenHandWritingBitmap: " + result.fold({ "returned $it in ${"%.1f".format(ms)} ms" }, { "failed (${it.cause?.javaClass?.simpleName ?: it.javaClass.simpleName}: ${it.cause?.message ?: it.message})" }))
        line("Look for a grey square near the middle of the screen.")
        return out.toString().trim()
    }
}
