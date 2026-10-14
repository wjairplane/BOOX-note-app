package app.inkbridge.rm

import app.inkbridge.rm.io.SceneStream
import app.inkbridge.rm.render.PageRenderer
import org.junit.Assert.*
import org.junit.Test
import java.io.File
import javax.imageio.ImageIO

class RenderSnapshotTest {
    private val samples = listOf(
        "Color_and_tool_v3.14.4", "Lines_v2", "More_color_highlight_shader_v3.15.4.2",
        "Normal_A_stroke_2_layers_v3.3.2", "With_SceneInfo_Block", "Wikipedia_highlighted_p1",
        "Bold_Heading_Bullet_Normal", "Normal_AB", "test-crdt-ordering",
    )

    private fun render(name: String): java.awt.image.BufferedImage {
        System.setProperty("java.awt.headless", "true")
        val bytes = javaClass.getResourceAsStream("/rmscene/$name.rm")!!.readBytes()
        val r = PageRenderer(SceneStream.readTree(bytes))
        val c = Java2DCanvas(r.layout)
        r.render(c)
        return c.finish()
    }

    private fun inkPixels(img: java.awt.image.BufferedImage): Int {
        var n = 0
        for (y in 0 until img.height) for (x in 0 until img.width) if (img.getRGB(x, y) and 0xFFFFFF != 0xFFFFFF) n++
        return n
    }

    @Test fun rendersAllSamplesAndWritesPngs() {
        val out = System.getProperty("rm.renderOut")?.let { File(it).apply { mkdirs() } }
        for (name in samples) {
            val img = render(name)
            assertTrue("$name: empty size", img.width > 100 && img.height > 100)
            assertTrue("$name: rendered nothing", inkPixels(img) > 50)
            out?.let { ImageIO.write(img, "png", File(it, "$name.png")) }
        }
    }
}
