package app.inkbridge.rm

import app.inkbridge.rm.edit.*
import app.inkbridge.rm.export.PageExport
import app.inkbridge.rm.io.SceneStream
import app.inkbridge.rm.render.PageRenderer
import org.junit.Assert.*
import org.junit.Test
import javax.xml.parsers.DocumentBuilderFactory

class SvgExportTest {
    private fun parse(svg: String) = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(svg.byteInputStream())
    private fun res(n: String) = javaClass.getResourceAsStream("/rmscene/$n")!!.readBytes()

    @Test fun exportsWellFormedSvgWithStrokesAndText() {
        val svg = PageExport.svg(PageRenderer(SceneStream.readTree(res("With_SceneInfo_Block.rm"))))
        val doc = parse(svg)
        assertEquals("svg", doc.documentElement.tagName)
        assertTrue(doc.getElementsByTagName("polyline").length >= 13)
        val texts = (0 until doc.getElementsByTagName("text").length).map { doc.getElementsByTagName("text").item(it).textContent }
        assertTrue(texts.contains("TEST TEXT"))
    }

    @Test fun escapesTextAndKeepsOpacity() {
        val ed = PageEditor.blank()
        ed.addStroke(PenSpec(PenTool.HIGHLIGHTER), listOf(InputPoint(0f, 10f, 1f), InputPoint(50f, 10f, 1f)))
        val svg = PageExport.svg(ed.renderer)
        parse(svg) // well-formed
        assertTrue(svg.contains("stroke-opacity=\"0.30"))
    }
}
