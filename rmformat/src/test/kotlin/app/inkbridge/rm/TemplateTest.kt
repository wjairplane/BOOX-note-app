package app.inkbridge.rm

import app.inkbridge.rm.render.*
import org.junit.Assert.*
import org.junit.Test
import java.awt.Color
import java.awt.Font
import java.awt.RenderingHints
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

class TemplateTest {
    private fun eval(src: String, vars: Map<String, Double> = emptyMap()) = Expr.parse(src).eval { vars[it] }

    /** Counts what a template draws. */
    private class Recorder : PageCanvas {
        var lines = 0; var polys = 0; var fills = 0; val texts = ArrayList<String>()
        val segs = ArrayList<FloatArray>()
        override fun polyline(xy: FloatArray, pointCount: Int, width: Float, argb: Int, cap: PageCanvas.Cap) {
            lines++; segs += xy.copyOf(pointCount * 2)
            for (v in xy.take(pointCount * 2)) assertTrue("finite coordinate", v.isFinite())
        }
        override fun fillRect(x: Float, y: Float, w: Float, h: Float, argb: Int) { fills++ }
        override fun fillPolygon(xy: FloatArray, pointCount: Int, argb: Int) { polys++ }
        override fun text(s: String, x: Float, y: Float, size: Float, bold: Boolean, italic: Boolean, argb: Int) { texts += s }
    }

    @Test fun expressions() {
        assertEquals(7.0, eval("1 + 2 * 3"), 0.0)
        assertEquals(9.0, eval("(1 + 2) * 3"), 0.0)
        assertEquals(-3.0, eval("-(1 + 2)"), 0.0)
        assertEquals(2.5, eval("10 / 4"), 0.0)
        assertEquals(0.0, eval("1 / 0"), 0.0)
        assertEquals(1.0, eval("2 > 1"), 0.0)
        assertEquals(0.0, eval("2 < 1"), 0.0)
        assertEquals(1.0, eval("1 || 0 && 0"), 0.0)
        assertEquals(10.0, eval("templateWidth > mobileMaxWidth ? 10 : 20", mapOf("templateWidth" to 1404.0, "mobileMaxWidth" to 1000.0)), 0.0)
        assertEquals(20.0, eval("templateWidth > mobileMaxWidth ? 10 : 20", mapOf("templateWidth" to 900.0, "mobileMaxWidth" to 1000.0)), 0.0)
        // Nested ternaries associate to the right; unknown names are 0.
        assertEquals(3.0, eval("0 ? 1 : 0 ? 2 : 3"), 0.0)
        assertEquals(5.0, eval("unknown + 5"), 0.0)
        assertEquals(0.5, eval("0.5"), 0.0)
        assertEquals(702 - 42.5 / 2, eval("702 - 42.5 / 2"), 1e-9)
        assertEquals(1.0, eval("1 != 2"), 0.0)
        assertEquals(1.0, eval("!0"), 0.0)
        assertThrows(Expr.ParseException::class.java) { Expr.parse("1 +") }
        assertThrows(Expr.ParseException::class.java) { Expr.parse("a ? b") }
    }

    @Test fun parserToleratesTrailingCommasAndComments() {
        val d = TemplateDef.parse("""
            { "name": "x", "orientation": "landscape", "categories": ["Lines",],
              "constants": [ {"a": 5}, {"b": "a * 2"}, ],
              // a comment
              "items": [ {"type": "path", "data": ["M", 0, 0, "L", "b", 0,], "unknownKey": 1}, {"type": "mystery"}, ],
            }""")
        assertTrue(d.landscape); assertEquals(2, d.constants.size); assertEquals(1, d.items.size)
        val rec = Recorder()
        TemplateRenderer.draw(d, false, rec, PageLayout(-702f, 702f, 0f, 1872f))
        assertEquals(1, rec.lines)
        assertEquals(10f, rec.segs[0][2] - rec.segs[0][0], 1e-3f)
    }

    @Test fun catalog() {
        assertEquals(79, TemplateCatalog.all.size)
        assertEquals(listOf("Creative", "Lines", "Grids", "Planners"), TemplateCatalog.categories.sortedBy { listOf("Creative", "Lines", "Grids", "Planners").indexOf(it) })
        assertEquals(TemplateCatalog.all.size, TemplateCatalog.all.map { it.id }.toSet().size)
        for (t in TemplateCatalog.all) assertSame(t, PageTemplate.fromId(t.id).takeIf { it == t } ?: t)
        // Legacy ids map to the nearest firmware templates; unknown ids to Blank.
        assertTrue(PageTemplate.fromId("blank").isBlank)
        assertEquals("P Lines medium", PageTemplate.fromId("lines").filename)
        assertEquals("P Grid medium", PageTemplate.fromId("grid").filename)
        assertEquals("P Dots S", PageTemplate.fromId("dots").filename)
        assertEquals("P Lines medium", PageTemplate.fromId("P Lines medium").filename)
        assertTrue(PageTemplate.fromId("nonsense").isBlank)
        assertTrue(PageTemplate.fromId(null).isBlank)
        val land = PageTemplate.fromId("Blank@landscape")
        assertTrue(land.landscape && land.isBlank)
        assertTrue(PageTemplate.fromId("LS Dayplanner").landscape)
        assertTrue(TemplateCatalog.filter("Planners", true).all { it.landscape && "Planners" in it.categories })
        assertTrue(TemplateCatalog.filter(TemplateCatalog.ALL, false).size > 20)
        assertEquals(TemplateCatalog.all.size - TemplateCatalog.selectable.size, TemplateCatalog.all.count { !it.available })
    }

    @Test fun everyTemplateParsesAndRenders() {
        val portrait = PageLayout(-702f, 702f, 0f, 1872f)
        val landscape = PageLayout(-936f, 936f, 0f, 1404f)
        for (t in TemplateCatalog.selectable) {
            if (!t.isBlank) assertNotNull("${t.filename} parses", TemplateCatalog.definition(t))
            for (layout in listOf(portrait, landscape)) {
                val r = Recorder()
                t.draw(r, layout)
                if (!t.isBlank) assertTrue("${t.filename} draws something on $layout", r.lines + r.polys + r.fills + r.texts.size > 0)
            }
            val j = Java2DCanvas(t.pageLayout, 0.3f)
            t.draw(j, t.pageLayout)
            j.finish()
        }
    }

    @Test fun linesMedium() {
        val layout = PageLayout(-702f, 702f, 0f, 1872f)
        val r = Recorder()
        PageTemplate.fromId("P Lines medium").draw(r, layout)
        // Rules every 78.7 from y = 177.8 down to the page end, trimmed to the page width.
        assertEquals(22, r.lines)
        assertEquals(177.8f, r.segs.first()[1], 0.01f)
        for (s in r.segs) { assertEquals(s[1], s[3], 0f); assertTrue(s[0] >= -704f && s[2] <= 704f) }
        assertEquals(177.8f + 21 * 78.7f, r.segs.last()[1], 0.1f)

        val image = render(PageTemplate.fromId("P Lines medium"), 0.5f)
        val dark = nonWhite(image)
        assertTrue("some pixels drawn ($dark)", dark in 1000..40000)
        assertEquals("blank draws nothing", 0, nonWhite(render(PageTemplate.BLANK, 0.5f)))
    }

    @Test fun gridAndDots() {
        val g = nonWhite(render(PageTemplate.fromId("grid"), 0.5f))
        val l = nonWhite(render(PageTemplate.fromId("lines"), 0.5f))
        val d = nonWhite(render(PageTemplate.fromId("dots"), 0.5f))
        assertTrue("grid has more ink than lines ($g > $l)", g > l)
        assertTrue("dots have some ink but less than lines ($d)", d in 50 until l)
        val dots = Recorder().also { PageTemplate.fromId("dots").draw(it, PageLayout(-702f, 702f, 0f, 1872f)) }
        assertTrue("dots as filled boxes (${dots.polys} polys, ${dots.fills} rects, ${dots.lines} lines)", dots.polys + dots.fills + dots.lines > 500)
    }

    @Test fun landscapeSwapsTemplateSize() {
        val r = Recorder()
        val t = PageTemplate.fromId("LS Lines medium")
        t.draw(r, t.pageLayout)
        assertTrue(r.segs.isNotEmpty())
        // Landscape pages are 1872 wide: rules span it.
        assertTrue(r.segs.maxOf { maxOf(it[0], it[2]) } > 900f)
    }

    private fun render(t: PageTemplate, scale: Float): BufferedImage {
        val layout = PageLayout(-702f, 702f, 0f, 1872f)
        val c = Java2DCanvas(layout, scale)
        t.draw(c, layout)
        return c.finish()
    }

    private fun nonWhite(img: BufferedImage): Int {
        var n = 0
        for (y in 0 until img.height) for (x in 0 until img.width) if ((img.getRGB(x, y) and 0xFFFFFF) != 0xFFFFFF) n++
        return n
    }

    /** All 79 firmware entries on one sheet, for eyeballing. Written to build/render-snapshots/templates_contact_sheet.png. */
    @Test fun contactSheet() {
        val out = System.getProperty("rm.renderOut")?.let { File(it) } ?: return
        out.mkdirs()
        val all = TemplateCatalog.all
        val cols = 10
        val cellW = 220; val cellH = 330
        val sheet = BufferedImage(cols * cellW, ((all.size + cols - 1) / cols) * cellH, BufferedImage.TYPE_INT_RGB)
        val g = sheet.createGraphics()
        g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
        g.color = Color(0xE6E6E6); g.fillRect(0, 0, sheet.width, sheet.height)
        g.font = Font(Font.SANS_SERIF, 0, 12)
        all.forEachIndexed { i, t ->
            val x = (i % cols) * cellW; val y = (i / cols) * cellH
            val layout = t.pageLayout
            val scale = 200f / maxOf(layout.width, layout.height)
            val c = Java2DCanvas(layout, scale)
            t.draw(c, layout)
            val img = c.finish()
            g.drawImage(img, x + 10 + (200 - img.width) / 2, y + 10, null)
            g.color = Color.BLACK; g.drawRect(x + 10 + (200 - img.width) / 2, y + 10, img.width, img.height)
            g.drawString(t.label + if (t.landscape) " (L)" else "", x + 10, y + 10 + 270)
            g.drawString(t.filename + if (!t.available) " (no data)" else "", x + 10, y + 10 + 286)
        }
        g.dispose()
        ImageIO.write(sheet, "png", File(out, "templates_contact_sheet.png"))
    }
}
