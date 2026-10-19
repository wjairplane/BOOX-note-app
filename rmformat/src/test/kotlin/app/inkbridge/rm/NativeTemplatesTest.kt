package app.inkbridge.rm

import app.inkbridge.rm.render.*
import org.junit.Assert.*
import org.junit.Test
import java.io.File
import javax.imageio.ImageIO

class NativeTemplatesTest {
    private val names = listOf(
        "P Hexagon small", "P Hexagon medium", "P Hexagon large",
        "P Calligraphy medium", "P Calligraphy large", "LS Calligraphy medium", "LS Calligraphy large",
    )

    @Test fun theSevenFilelessTemplatesAreSelectable() {
        assertEquals(names.toSet(), NativeTemplates.names)
        for (n in names) {
            val t = TemplateCatalog.all.single { it.filename == n }
            assertTrue("$n is offered by the picker", t.available && t in TemplateCatalog.selectable)
            assertEquals(n.startsWith("LS "), t.landscape)
        }
        assertEquals(0, TemplateCatalog.all.count { !it.available })
        // Hexagon is a grid, Calligraphy a line sheet, as in the firmware's categories.
        assertTrue("Grids" in TemplateCatalog.all.single { it.filename == "P Hexagon small" }.categories)
        assertTrue("Lines" in TemplateCatalog.all.single { it.filename == "P Calligraphy medium" }.categories)
    }

    private class Recorder : PageCanvas {
        val segs = ArrayList<FloatArray>()
        override fun polyline(xy: FloatArray, pointCount: Int, width: Float, argb: Int, cap: PageCanvas.Cap) { segs += xy.copyOf(pointCount * 2) }
        override fun fillRect(x: Float, y: Float, w: Float, h: Float, argb: Int) {}
        override fun text(s: String, x: Float, y: Float, size: Float, bold: Boolean, italic: Boolean, argb: Int) {}
    }

    @Test fun hexagonCellsHaveTheRegularHoneycombProportions() {
        // Pointy-top regular hexagon: width w, side s = w / sqrt(3); a cell is two rows = 3 s tall.
        for ((n, w, h) in listOf(Triple("P Hexagon large", 112.1, 194.4), Triple("P Hexagon medium", 87.8, 151.8), Triple("P Hexagon small", 43.9, 75.9))) {
            assertEquals("$n height", 3 * w / Math.sqrt(3.0), h, 0.9)
            val r = Recorder()
            PageTemplate.fromId(n).draw(r, PageLayout(-702f, 702f, 0f, 1872f))
            assertTrue("$n draws many edges", r.segs.size > 300)
            // Every edge is either vertical or leans 30 degrees from the horizontal... i.e. dy/dx = (h/6)/(w/2).
            for (s in r.segs) {
                val dx = Math.abs(s[2] - s[0]); val dy = Math.abs(s[3] - s[1])
                if (dx < 1e-3) continue
                assertEquals("$n slanted edge", (h / 6) / (w / 2), dy / dx.toDouble(), 1e-3)
            }
        }
    }

    @Test fun calligraphyRowsHaveFourGuidesAndSlantedStrokes() {
        val r = Recorder()
        PageTemplate.fromId("P Calligraphy large").draw(r, PageLayout(-702f, 702f, 0f, 1872f))
        // Rows start at y = 65 and repeat every 195; the baseline (third guide) is solid and spans the page.
        val full = r.segs.filter { it[1] == it[3] && it[2] - it[0] > 1000f }
        assertEquals(65f + 96f, full.first()[1], 0.01f)
        assertEquals(195f, full[1][1] - full[0][1], 0.01f)
        val slanted = r.segs.filter { it[1] != it[3] }
        assertTrue(slanted.isNotEmpty())
        for (s in slanted) { assertEquals(72f, s[2] - s[0], 1e-3f); assertEquals(144f, s[1] - s[3], 1e-3f) }
    }

    @Test fun rendersToPng() {
        System.setProperty("java.awt.headless", "true")
        val out = System.getProperty("rm.renderOut")?.let { File(it).apply { mkdirs() } }
        for (n in names) {
            val t = TemplateCatalog.all.single { it.filename == n }
            val c = Java2DCanvas(t.pageLayout, 0.5f)
            t.draw(c, t.pageLayout)
            val img = c.finish()
            var dark = 0
            for (y in 0 until img.height) for (x in 0 until img.width) if ((img.getRGB(x, y) and 0xFFFFFF) != 0xFFFFFF) dark++
            assertTrue("$n is empty", dark > 2000)
            out?.let { ImageIO.write(img, "png", File(it, "native_" + n.replace(' ', '_') + ".png")) }
        }
    }
}
