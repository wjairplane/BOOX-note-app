package app.inkbridge.rm

import app.inkbridge.rm.edit.InputPoint
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.edit.StrokeBuilder
import app.inkbridge.rm.render.PixelInk
import app.inkbridge.rm.scene.PenColorId
import app.inkbridge.rm.scene.Line
import app.inkbridge.rm.scene.Point
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File
import javax.imageio.ImageIO

/** The Kotlin pen renderer against renders of the firmware's own pen code (reference/remarkable-3.27.1.0/pens/golden). */
class PixelInkGoldenTest {
    private fun root(): File {
        var d = File("").absoluteFile
        while (!File(d, "reference/remarkable-3.27.1.0/pens/golden").isDirectory) d = d.parentFile ?: error("golden dir not found")
        return File(d, "reference/remarkable-3.27.1.0/pens/golden")
    }

    private fun num(json: String, key: String) = Regex("\"$key\":\\s*(-?[0-9.eE+-]+)").find(json)!!.groupValues[1].toDouble()

    @Test fun everyPenMatchesTheFirmware() {
        val dir = root()
        val names = dir.listFiles { f -> f.name.endsWith(".json") }!!.map { it.name.removeSuffix(".json") }.sorted()
        assertTrue(names.size >= 60)
        val perPen = sortedMapOf<String, IntArray>() // pen -> [ink px, mismatching px]
        val failures = ArrayList<String>()
        for (name in names) {
            val json = File(dir, "$name.json").readText()
            val tool = num(json, "tool").toInt()
            val zoom = num(json, "zoom")
            val points = Regex("\\{\\s*\"x\":\\s*([^,]+),\\s*\"y\":\\s*([^,]+),\\s*\"speed\":\\s*(\\d+),\\s*\"width_raw\":\\s*(\\d+),\\s*\"direction\":\\s*(\\d+),\\s*\"pressure\":\\s*(\\d+)\\s*\\}")
                .findAll(json).map { m ->
                    Point(m.groupValues[1].toFloat(), m.groupValues[2].toFloat(), m.groupValues[3].toInt(), m.groupValues[5].toInt(), m.groupValues[4].toInt(), m.groupValues[6].toInt())
                }.toList()
            val line = Line(tool, num(json, "color").toInt(), points, num(json, "thicknessScale"), num(json, "startingLength").toFloat())
            val ink = PixelInk(128, 64)
            ink.drawLine(line, 0f, 0f, PixelInk.Transform(zoom.toFloat(), 0f, 0f), paletteMode = num(json, "palette_mode").toInt())
            val white = IntArray(128 * 64) { 0xFFFFFFFF.toInt() }
            val out = IntArray(128 * 64)
            ink.compositeInto(white, out, 0, 0, 128, 64)
            val png = ImageIO.read(File(dir, "$name.png"))
            var inkPx = 0; var bad = 0
            for (y in 0 until 64) for (x in 0 until 128) {
                val want = png.getRGB(x, y) and 0xFFFFFF; val got = out[y * 128 + x] and 0xFFFFFF
                if (want != 0xFFFFFF) inkPx++
                // Allow a rounding step in the blend.
                if (kotlin.math.abs((want shr 16) - (got shr 16)) > 2 || kotlin.math.abs(((want shr 8) and 255) - ((got shr 8) and 255)) > 2 || kotlin.math.abs((want and 255) - (got and 255)) > 2) bad++
            }
            val key = name.substringBefore("_t")
            perPen.getOrPut(key) { IntArray(2) }.also { it[0] += inkPx; it[1] += bad }
            if (inkPx > 0 && bad * 100.0 / inkPx > 2.0) failures += "$name: $bad of $inkPx ink px differ"
        }
        println(perPen.entries.joinToString("\n") { (k, v) -> "$k: ${v[1]} of ${v[0]} differ (${"%.3f".format(v[1] * 100.0 / v[0].coerceAtLeast(1))} %)" })
        assertTrue(failures.joinToString("\n"), failures.isEmpty())
    }

    /** A sheet of the nine pens at three thicknesses, drawn by the Kotlin renderer at a BOOX-like scale (build/pen-sheet.png). */
    @Test fun writesAPenSheet() {
        val scale = 1.325f
        val w = 1000; val h = 1500
        val ink = PixelInk(w, h)
        var y = 60f
        val tools = listOf(15, 17, 16, 14, 13, 12, 21, 18)
        for (tool in tools) for (th in 1..3) {
            val spec = PenSpec(PenTool.entries.first { it.toolId == tool }, if (tool == 18) PenColorId.YELLOW else PenColorId.BLACK, th)
            val samples = (0..70).map { i -> InputPoint(30f + i * 10f, y / scale + kotlin.math.sin(i / 6.0).toFloat() * 8f, 0.15f + 0.85f * i / 70f, 10f, 5f, i * 5L) }
            val line = StrokeBuilder.build(spec, samples)!!
            ink.drawLine(line, 0f, 0f, PixelInk.Transform(scale, 0f, 0f))
            y += 48f
        }
        val white = IntArray(w * h) { 0xFFFFFFFF.toInt() }
        val out = IntArray(w * h); ink.compositeInto(white, out, 0, 0, w, h)
        val img = java.awt.image.BufferedImage(w, h, java.awt.image.BufferedImage.TYPE_INT_ARGB)
        img.setRGB(0, 0, w, h, out, 0, w)
        File("build").mkdirs(); ImageIO.write(img, "png", File("build/pen-sheet.png"))
    }
}
