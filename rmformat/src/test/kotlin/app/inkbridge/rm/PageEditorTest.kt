package app.inkbridge.rm

import app.inkbridge.rm.edit.*
import app.inkbridge.rm.io.*
import app.inkbridge.rm.scene.*
import org.junit.Assert.*
import org.junit.Test
import java.io.File
import javax.imageio.ImageIO
import java.util.UUID

class PageEditorTest {
    private fun res(name: String) = javaClass.getResourceAsStream("/rmscene/$name")!!.readBytes()
    private fun pts(vararg xy: Float) = xy.toList().chunked(2).mapIndexed { i, (x, y) -> InputPoint(x, y, 0.6f, 0f, 0f, i * 5L) }
    private fun lines(tree: SceneTree) = tree.walk().filterIsInstance<Line>()

    @Test fun newStrokeIsAppendedAndEverythingElseIsUntouched() {
        val original = res("Lines_v2.rm")
        val ed = PageEditor.fromBytes(original)
        val before = lines(ed.tree).size
        val line = ed.addStroke(PenSpec(PenTool.FINELINER, thickness = 2), pts(100f, 100f, 110f, 105f, 125f, 120f))!!
        assertEquals(PenId.FINELINER_2, line.tool)

        val bytes = ed.toBytes()
        // Existing blocks are unchanged: the old file is a strict prefix of the new one.
        assertTrue(bytes.size > original.size)
        assertArrayEquals(original, bytes.copyOf(original.size))

        val after = PageEditor.fromBytes(bytes)
        assertEquals(before + 1, lines(after.tree).size)
        val last = after.tree.walk().filterIsInstance<Line>().last()
        assertEquals(3, last.points.size)
        assertEquals(16, last.points[0].width) // fineliner: 8 x thickness 2
        // Ids: author 1, counter above everything in the file (Lines_v2 ends at 24), chained after the last line.
        val blk = SceneStream.readBlocks(bytes).filterIsInstance<SceneItemBlock>().last()
        assertEquals(CrdtId(1, 25), blk.itemId)
        assertEquals(CrdtId(1, 24), blk.leftId)
        assertEquals(CrdtId.END_MARKER, blk.rightId)
        assertEquals(2, blk.minVersion); assertEquals(2, blk.currentVersion)
    }

    @Test fun eraseWritesTombstonesAndUndoRestoresBytes() {
        val original = res("Lines_v2.rm")
        val ed = PageEditor.fromBytes(original)
        val target = ed.renderer.placedLines()[2]
        val p = target.line.points[5]
        val erased = ed.eraseAlong(listOf((p.x + target.ox) to (p.y + target.oy)), radius = 3f)
        assertTrue(erased >= 1)

        val blocks = SceneStream.readBlocks(ed.toBytes())
        val tomb = blocks.filterIsInstance<SceneItemBlock>().first { it.itemId == target.itemId }
        assertEquals(1, tomb.deletedLength)
        assertNull(tomb.value); assertNull(tomb.itemType)
        assertTrue(lines(PageEditor.fromBytes(ed.toBytes()).tree).none { it === target.line })
        assertEquals(10 - erased, lines(PageEditor.fromBytes(ed.toBytes()).tree).size)

        assertTrue(ed.undo())
        assertArrayEquals(original, ed.toBytes())
        assertTrue(ed.redo())
        assertEquals(10 - erased, lines(ed.tree).size)
    }

    @Test fun nextStrokeAfterAnEraseDoesNotReuseIds() {
        val ed = PageEditor.fromBytes(res("More_color_highlight_shader_v3.15.4.2.rm")) // has a 223-long tombstone run at (1,14)
        val max = PageEditor.maxCounter(SceneStream.readBlocks(ed.toBytes()))
        ed.addStroke(PenSpec(PenTool.BALLPOINT, thickness = 1), pts(10f, 10f, 20f, 20f))
        val last = SceneStream.readBlocks(ed.toBytes()).filterIsInstance<SceneItemBlock>().last()
        assertEquals(max + 1, last.itemId.counter)
    }

    @Test fun editsSurviveSaveAndReload() {
        val ed = PageEditor.fromBytes(res("Normal_A_stroke_2_layers_v3.3.2.rm"))
        ed.addStroke(PenSpec(PenTool.HIGHLIGHTER, colorId = PenColorId.YELLOW), pts(0f, 300f, 200f, 300f))
        val again = PageEditor.fromBytes(ed.toBytes())
        val hl = lines(again.tree).last()
        assertEquals(PenId.HIGHLIGHTER_2, hl.tool)
        assertEquals(PenColorId.YELLOW, hl.color)
        assertNull(hl.colorRgba)
    }

    @Test fun blankPageMatchesRealDeviceStructure() {
        // Build a blank page with the same author uuid as Lines_v2.rm and compare its blocks to the file's first 7.
        val real = SceneStream.readBlocks(res("Lines_v2.rm"))
        val uuid = (real[0] as AuthorIdsBlock).authors.getValue(1)
        val mine = BlankPage.blocks(uuid)
        val expected = SceneWriter.write(real.take(7))
        assertArrayEquals(expected, SceneWriter.write(mine))
    }

    @Test fun blankPageAcceptsStrokesAndRoundTrips() {
        val ed = PageEditor.blank()
        ed.addStroke(PenSpec(PenTool.BALLPOINT), pts(50f, 50f, 100f, 80f, 150f, 50f))
        ed.addStroke(PenSpec(PenTool.FINELINER, PenColorId.BLUE, 1), pts(60f, 200f, 300f, 220f))
        val again = PageEditor.fromBytes(ed.toBytes())
        assertEquals(2, lines(again.tree).size)
        val ids = SceneStream.readBlocks(ed.toBytes()).filterIsInstance<SceneItemBlock>().filter { it.blockType == SceneItemBlock.LINE }
        assertEquals(listOf(CrdtId(1, 14), CrdtId(1, 15)), ids.map { it.itemId })
        assertEquals(CrdtId(1, 14), ids[1].leftId)
    }

    @Test fun strokeBuilderMatchesFittedPenShapes() {
        val p = pts(0f, 0f, 3f, 0f, 6f, 0f)
        // Ballpoint width spans 12..18 at medium thickness as in the samples; fineliner is constant.
        val light = StrokeBuilder.build(PenSpec(PenTool.BALLPOINT, thickness = 2), p.map { it.copy(pressure = 0f) })!!
        val heavy = StrokeBuilder.build(PenSpec(PenTool.BALLPOINT, thickness = 2), p.map { it.copy(pressure = 1f) })!!
        assertEquals(12, light.points[0].width); assertEquals(18, heavy.points[0].width)
        assertEquals(255, heavy.points[0].pressure)
        assertEquals(24, StrokeBuilder.build(PenSpec(PenTool.FINELINER, thickness = 3), p)!!.points[0].width)
        assertEquals(120, StrokeBuilder.build(PenSpec(PenTool.HIGHLIGHTER), p)!!.points[0].width)
        assertNull(StrokeBuilder.build(PenSpec(PenTool.ERASER), p))
        // Speed: 3 units per 5 ms sample ≈ 2.1 x 3.
        assertEquals(6, StrokeBuilder.build(PenSpec(PenTool.FINELINER), p)!!.points[1].speed)
    }

    @Test fun strokeBuilderHandlesTapsAndDenseSamples() {
        val tap = StrokeBuilder.build(PenSpec(PenTool.FINELINER), listOf(InputPoint(5f, 5f, 0.5f)))!!
        assertEquals(2, tap.points.size)
        val dense = (0..100).map { InputPoint(it * 0.05f, 0f, 0.5f, 0f, 0f, it * 2L) }
        val line = StrokeBuilder.build(PenSpec(PenTool.FINELINER), dense)!!
        assertTrue("dense samples thinned (${line.points.size})", line.points.size < 25)
        assertEquals(5.0f, line.points.last().x, 0.01f) // stroke end preserved
    }

    @Test fun strokesAreStoredRelativeToTheirLayerOffset() {
        // Page-space input must be converted to the layer's local coordinates (zero offset for plain layers).
        val ed = PageEditor.blank()
        ed.addStroke(PenSpec(PenTool.FINELINER), pts(10f, 20f, 30f, 40f))
        val l = lines(ed.tree).single()
        assertEquals(10f, l.points[0].x, 1e-4f); assertEquals(20f, l.points[0].y, 1e-4f)
    }

    @Test fun pageTransformRoundTrips() {
        val layout = app.inkbridge.rm.render.PageLayout(-702f, 702f, 0f, 1872f)
        val t = PageTransform(layout, 1000f, 1200f)
        val (px, py) = 123f to 456f
        assertEquals(px, t.toPageX(t.toViewX(px)), 1e-3f)
        assertEquals(py, t.toPageY(t.toViewY(py)), 1e-3f)
        // Fit to height here (1200/1872 < 1000/1404), centred horizontally.
        assertEquals(1200f / 1872f, t.scale, 1e-6f)
        assertTrue(t.offsetX > 0)
    }

    @Test fun rendersEditedPageToPng() {
        val ed = PageEditor.fromBytes(res("Lines_v2.rm"))
        ed.addStroke(PenSpec(PenTool.BALLPOINT, PenColorId.RED, 3), (0..40).map { InputPoint(100f + it * 8, 700f + Math.sin(it / 4.0).toFloat() * 40, 0.3f + it / 60f, 0f, 0f, it * 5L) })
        ed.addStroke(PenSpec(PenTool.HIGHLIGHTER, PenColorId.YELLOW), pts(80f, 640f, 440f, 640f))
        val first = ed.renderer.placedLines().first()
        ed.eraseAlong(listOf((first.line.points[1].x + first.ox) to (first.line.points[1].y + first.oy)), 3f)
        val c = Java2DCanvas(ed.renderer.layout); ed.renderer.render(c)
        System.getProperty("rm.renderOut")?.let { File(it).mkdirs(); ImageIO.write(c.finish(), "png", File(it, "edited_Lines_v2.png")) }
    }
}
