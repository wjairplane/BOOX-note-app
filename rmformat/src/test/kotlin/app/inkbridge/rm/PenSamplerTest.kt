package app.inkbridge.rm

import app.inkbridge.rm.edit.*
import app.inkbridge.rm.io.SceneStream
import app.inkbridge.rm.scene.PenColorId
import org.junit.Assert.*
import org.junit.Test
import java.io.File
import javax.imageio.ImageIO

class PenSamplerTest {
    private fun wave(y: Float, pressureRamp: Boolean) = (0..60).map {
        InputPoint(120f + it * 18, y + Math.sin(it / 5.0).toFloat() * 26, if (pressureRamp) 0.15f + 0.85f * it / 60f else 0.6f, 20f, 10f, it * 5L)
    }

    @Test fun everyPenRoundTripsAndDraws() {
        val ed = PageEditor.blank()
        var y = 140f
        for (tool in PenTool.PENS) {
            for (th in 1..3) {
                val color = if (tool.isHighlighter) PenColorId.YELLOW else PenColorId.BLACK
                assertNotNull("$tool", ed.addStroke(PenSpec(tool, color, th), wave(y, pressureRamp = true)))
                y += 36f
            }
            y += 20f
        }
        // Colours too.
        for (c in PenSpec.INK_COLORS) { ed.addStroke(PenSpec(PenTool.FINELINER, c, 2), wave(y, false)); y += 34f }
        val again = PageEditor.fromBytes(ed.toBytes())
        assertEquals(PenTool.PENS.size * 3 + PenSpec.INK_COLORS.size, again.tree.walk().size)
        // Distinct pen ids were written.
        val tools = again.tree.walk().filterIsInstance<app.inkbridge.rm.scene.Line>().map { it.tool }.toSet()
        assertEquals(PenTool.PENS.map { it.toolId }.toSet(), tools)

        val c = Java2DCanvas(again.renderer.layout); again.renderer.render(c)
        System.getProperty("rm.renderOut")?.let { File(it).mkdirs(); ImageIO.write(c.finish(), "png", File(it, "pen_sampler.png")) }
    }

    @Test fun theNinePensAndNineColoursMatchThePenMenu() {
        assertEquals(9, PenTool.PENS.size)
        assertEquals(listOf("Ballpoint pen", "Fineliner", "Marker", "Pencil", "Mechanical pencil", "Paintbrush", "Calligraphy pen", "Highlighter", "Shader"), PenTool.PENS.map { it.label })
        assertEquals(listOf("Black", "Gray", "White", "Blue", "Red", "Green", "Yellow", "Cyan", "Magenta"), PenSpec.INK_COLORS.map { PenSpec.colorName(it) })
    }

    @Test fun shaderIsStoredWithExplicitTranslucentRgba() {
        val ed = PageEditor.blank()
        ed.addStroke(PenSpec(PenTool.SHADER, PenColorId.BLUE, 2), wave(300f, true))
        val l = PageEditor.fromBytes(ed.toBytes()).tree.walk().filterIsInstance<app.inkbridge.rm.scene.Line>().single()
        assertEquals(PenColorId.HIGHLIGHT, l.color)
        assertEquals(100, l.colorRgba!![3])
        assertEquals(78, l.colorRgba!![0]) // blue's red channel
    }

    @Test fun highlighterHasTheSixRealColoursIncludingOrange() {
        assertEquals(listOf("Yellow", "Blue", "Pink", "Orange", "Green", "Gray"), PenSpec.HIGHLIGHTER_COLORS.map { PenSpec.colorName(it) })
        val ed = PageEditor.blank()
        ed.addStroke(PenSpec(PenTool.HIGHLIGHTER, PenColorId.ORANGE), wave(200f, false))
        val l = PageEditor.fromBytes(ed.toBytes()).tree.walk().filterIsInstance<app.inkbridge.rm.scene.Line>().single()
        assertEquals(PenColorId.HIGHLIGHT, l.color)
        assertEquals(listOf(255, 195, 140, 255), l.colorRgba!!.toList())
    }

    @Test fun pensHaveSensibleWidthsAcrossPressure() {
        for (tool in PenTool.PENS) for (th in 1..3) for (p in listOf(0f, 0.5f, 1f)) {
            val w = StrokeBuilder.widthRaw(PenSpec(tool, thickness = th), p)
            assertTrue("$tool th$th p$p width $w", w in 4..400)
        }
    }
}
