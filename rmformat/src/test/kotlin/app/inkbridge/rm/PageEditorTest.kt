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
        val added = ed.addStroke(PenSpec(PenTool.FINELINER, thickness = 2), pts(100f, 100f, 110f, 105f, 125f, 120f))!!
        assertEquals(PenId.FINELINER_2, added.line.tool)

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
        // Only the part under the eraser goes: the stroke is cut in two, and both halves stay (shorter than the original).
        val after = lines(PageEditor.fromBytes(ed.toBytes()).tree).toList()
        assertTrue(after.size > 10 - erased) // something of the touched stroke is left
        assertTrue(after.any { it.tool == target.line.tool && it.points.size < target.line.points.size && it.points.size >= 2 })

        assertTrue(ed.undo())
        assertArrayEquals(original, ed.toBytes())
        assertTrue(ed.redo())
        assertTrue(lines(ed.tree).count() > 10 - erased)
    }

    @Test fun eraserLeavesTheRestOfALongStroke() {
        val ed = PageEditor.blank()
        ed.addStroke(PenSpec(PenTool.FINELINER, thickness = 2), (0..60).map { InputPoint(100f + it * 10f, 300f, 0.6f, 0f, 0f, it * 5L) })
        val before = lines(ed.tree).single().points.size
        assertEquals(1, ed.eraseAlong(listOf(400f to 300f, 420f to 300f), radius = 15f))
        val parts = lines(ed.tree).toList()
        assertEquals(2, parts.size)
        assertTrue(parts.all { it.points.size in 2 until before })
        assertTrue(parts.maxOf { p -> p.points.maxOf { it.x } } > 650f && parts.minOf { p -> p.points.minOf { it.x } } < 150f)
        // Nowhere near the stroke: nothing changes.
        assertEquals(0, ed.eraseAlong(listOf(400f to 900f), radius = 15f))
    }

    @Test fun eraseAllRemovesEveryStrokeInOneUndoStep() {
        val original = res("Lines_v2.rm")
        val ed = PageEditor.fromBytes(original)
        assertEquals(10, lines(ed.tree).size)
        assertEquals(10, ed.eraseAll())
        assertEquals(0, lines(PageEditor.fromBytes(ed.toBytes()).tree).size)
        assertEquals(0, ed.eraseAll()) // nothing left
        assertTrue(ed.undo())
        assertArrayEquals(original, ed.toBytes())
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
        // A highlighter is stored as the tablet stores one: the "highlight" colour id with an explicit RGBA.
        assertEquals(PenColorId.HIGHLIGHT, hl.color)
        assertEquals(listOf(254, 253, 96, 255), hl.colorRgba!!.toList())
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
        // The tablet records every sample the digitizer gives.
        assertEquals(101, line.points.size)
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

    @Test fun zoomingKeepsTheFocusPointAndNeverLeavesAGap() {
        val layout = app.inkbridge.rm.render.PageLayout(-702f, 702f, 0f, 1872f)
        val fit = PageTransform(layout, 1404f, 1872f)
        assertEquals(1f, fit.scale, 1e-6f); assertEquals(0f, fit.offsetX, 1e-3f)
        // Zoom 2x around a point: the page point under the finger stays under the finger.
        val z = fit.zoomedAround(2f, 700f, 900f)
        assertEquals(fit.toPageX(700f), z.toPageX(700f), 1e-2f); assertEquals(fit.toPageY(900f), z.toPageY(900f), 1e-2f)
        assertEquals(2f, z.scale, 1e-6f)
        // Panning is clamped to the page: the left/top edges can't move past the view's edges.
        val far = z.pannedBy(5000f, 5000f)
        assertEquals(0f, far.offsetX, 1e-3f); assertEquals(0f, far.offsetY, 1e-3f)
        val farther = z.pannedBy(-99999f, -99999f)
        assertEquals(1404f - 2808f, farther.offsetX, 1e-3f); assertEquals(1872f - 3744f, farther.offsetY, 1e-3f)
        // The zoom is limited, and the visible page area never exceeds the view.
        assertEquals(PageTransform.MAX_ZOOM, fit.zoomedAround(99f, 0f, 0f).zoom, 1e-6f)
        assertEquals(1f, fit.zoomedAround(0.1f, 0f, 0f).zoom, 1e-6f)
        val r = z.visiblePageRect(); assertEquals(0f, r[0], 1e-3f); assertEquals(1404f, r[2], 1e-3f)
        // Fit to width in a view that is wider than the page's shape (a toolbar at the side): the page overflows vertically.
        val wide = PageTransform(layout, 1600f, 1872f)
        val w = wide.fitWidth()
        assertEquals(1600f / 1404f, w.scale, 1e-4f); assertEquals(0f, w.offsetX, 1e-3f)
        val h = wide.fitHeight()
        assertEquals(1872f / 1872f, h.scale, 1e-4f)
    }

    @Test fun layersCanBeAddedHiddenRenamedSwitchedAndDeleted() {
        val ed = PageEditor.blank()
        assertEquals(listOf("Layer 1"), ed.layers().map { it.label })
        ed.addStroke(PenSpec(PenTool.FINELINER), pts(10f, 20f, 30f, 40f))
        val first = ed.layers().single().id

        val second = ed.addLayer("Notes")
        assertEquals(listOf("Layer 1", "Notes"), ed.layers().map { it.label })
        assertEquals(second, ed.layers().single { it.current }.id) // a new layer becomes current
        ed.addStroke(PenSpec(PenTool.BALLPOINT), pts(50f, 60f, 70f, 80f))
        assertEquals(2, lines(ed.tree).size)
        assertEquals(1, (ed.tree[second]).childItems().size)

        // Hiding a layer removes its strokes from the rendering; a hidden layer can't be drawn on.
        ed.setLayerVisible(second, false)
        assertEquals(1, ed.renderer.placedLines().size)
        assertEquals(first, ed.layers().single { it.current }.id)
        ed.setLayerVisible(second, true)
        ed.setCurrentLayer(first)
        assertEquals(first, ed.layers().single { it.current }.id)
        ed.renameLayer(second, "  Margin notes ")
        assertEquals("Margin notes", ed.layers().last().label)

        // Everything survives a save and reload.
        val again = PageEditor.fromBytes(ed.toBytes())
        assertEquals(listOf("Layer 1", "Margin notes"), again.layers().map { it.label })
        assertEquals(first, again.layers().single { it.current }.id)
        assertEquals(2, again.renderer.placedLines().size)

        // Deleting a layer removes its strokes; the last layer can't be deleted; undo brings it back.
        assertTrue(ed.deleteLayer(second))
        assertEquals(listOf("Layer 1"), ed.layers().map { it.label })
        assertEquals(1, ed.renderer.placedLines().size)
        assertFalse(ed.deleteLayer(first))
        assertTrue(ed.undo())
        assertEquals(2, ed.layers().size)
        assertEquals(2, PageEditor.fromBytes(ed.toBytes()).renderer.placedLines().size)
    }

    @Test fun lassoSelectsMovesDuplicatesAndDeletesStrokes() {
        val ed = PageEditor.blank()
        ed.addStroke(PenSpec(PenTool.FINELINER), pts(100f, 100f, 140f, 110f, 180f, 100f))   // inside the lasso
        ed.addStroke(PenSpec(PenTool.FINELINER), pts(120f, 150f, 160f, 150f))                // inside
        ed.addStroke(PenSpec(PenTool.FINELINER), pts(600f, 600f, 640f, 640f))                // far away
        val lasso = listOf(50f to 50f, 250f to 50f, 250f to 250f, 50f to 250f)
        val picked = ed.selectInside(lasso)
        assertEquals(2, picked.size)
        assertEquals(0, ed.selectInside(listOf(0f to 0f, 10f to 0f)).size) // not a region
        val b = ed.boundsOf(picked)!!
        assertEquals(100f, b.left, 1e-3f); assertEquals(180f, b.right, 1e-3f); assertEquals(100f, b.top, 1e-3f); assertEquals(150f, b.bottom, 1e-3f)

        // Move: only the selected strokes shift, in one undo step.
        val before = ed.toBytes()
        assertEquals(2, ed.moveStrokes(picked, 300f, -40f))
        val moved = ed.boundsOf(picked)!!
        assertEquals(400f, moved.left, 1e-3f); assertEquals(60f, moved.top, 1e-3f)
        assertEquals(3, lines(ed.tree).size)
        assertTrue(ed.undo()); assertArrayEquals(before, ed.toBytes())

        // Duplicate: copies appear next to the originals and are valid on reload.
        val copies = ed.duplicateStrokes(picked, 20f, 20f)
        assertEquals(2, copies.size); assertTrue(copies.none { it in picked })
        assertEquals(5, lines(ed.tree).size)
        assertEquals(5, lines(PageEditor.fromBytes(ed.toBytes()).tree).size)
        val cb = ed.boundsOf(copies)!!
        assertEquals(120f, cb.left, 1e-3f); assertEquals(120f, cb.top, 1e-3f)

        // Delete.
        assertEquals(2, ed.deleteStrokes(picked))
        assertEquals(3, lines(PageEditor.fromBytes(ed.toBytes()).tree).size)
        assertEquals(0, ed.deleteStrokes(picked)) // already gone
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
