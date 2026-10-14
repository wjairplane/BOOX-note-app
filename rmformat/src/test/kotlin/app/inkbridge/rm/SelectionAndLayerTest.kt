package app.inkbridge.rm

import app.inkbridge.rm.edit.*
import app.inkbridge.rm.edit.SelectionGesture.Mode
import org.junit.Assert.*
import org.junit.Test

class SelectionAndLayerTest {
    private fun pts(vararg xy: Float) = xy.toList().chunked(2).mapIndexed { i, (x, y) -> InputPoint(x, y, 0.6f, 0f, 0f, i * 5L) }
    private val pen = PenSpec(PenTool.FINELINER)

    private fun editor(): PageEditor = PageEditor.blank().also {
        it.addStroke(pen, pts(100f, 100f, 200f, 100f, 200f, 200f))
        it.addStroke(pen, pts(300f, 300f, 400f, 300f))
    }

    private fun roundTrip(e: PageEditor) = PageEditor.fromBytes(e.toBytes())

    @Test fun handlesAreHitInPriorityOrderAndGestureMapsAreRight() {
        val f = SelectionGesture.Frame(100f, 200f, 300f, 400f)
        assertEquals(Mode.ROTATE, SelectionGesture.hit(f, 200f, 200f - SelectionGesture.ROTATE_OFFSET).mode)
        val corner = SelectionGesture.hit(f, 302f, 398f)
        assertEquals(Mode.SCALE, corner.mode); assertEquals(100f, corner.anchorX, 0f); assertEquals(200f, corner.anchorY, 0f) // the opposite corner
        assertEquals(Mode.MOVE, SelectionGesture.hit(f, 200f, 300f).mode)
        assertEquals(Mode.NONE, SelectionGesture.hit(f, 600f, 700f).mode)

        // Dragging the bottom-right corner to twice the distance from the top-left corner doubles the size about it.
        val m = SelectionGesture.transform(corner, 300f, 400f, 500f, 600f)
        assertEquals(2f, m.a, 1e-4f); assertEquals(-100f, m.tx, 1e-3f); assertEquals(-200f, m.ty, 1e-3f)
        // Rotating a quarter turn about the centre (200, 300) sends the top-right corner (300, 200) to the bottom-right (300, 400).
        val rot = SelectionGesture.hit(f, 200f, 200f - SelectionGesture.ROTATE_OFFSET)
        val r = SelectionGesture.transform(rot, 200f, 100f, 300f, 300f) // from straight above the centre to straight right of it
        val out = SelectionGesture.mapped(f, r)[1]
        assertEquals(300f, out.first, 1e-2f); assertEquals(400f, out.second, 1e-2f)
        // View-space maps become page-space maps with the same effect.
        val page = SelectionGesture.viewToPage(PageEditor.Affine(1f, 0f, 0f, 1f, 50f, 20f), 2f, 10f, 10f)
        assertEquals(25f, page.tx, 1e-4f); assertEquals(10f, page.ty, 1e-4f)
    }

    @Test fun strokesCanBeScaledRotatedCopiedAndPasted() {
        val e = editor()
        val all = e.renderer.placedLines().map { it.itemId }.toSet()
        val before = e.boundsOf(all)!!
        assertEquals(2, e.transformStrokes(all, PageEditor.Affine(2f, 0f, 0f, 2f, 0f, 0f)))
        val after = e.boundsOf(all)!!
        assertEquals(before.right * 2, after.right, 1e-2f); assertEquals(before.bottom * 2, after.bottom, 1e-2f)
        assertEquals(2, roundTrip(e).renderer.placedLines().size)
        assertTrue(e.undo()); assertEquals(before.right, e.boundsOf(all)!!.right, 1e-2f)

        val lines = e.copyStrokes(all)
        assertEquals(2, lines.size)
        val pasted = e.pasteStrokes(lines, 40f, 40f)
        assertEquals(2, pasted.size)
        assertEquals(4, roundTrip(e).renderer.placedLines().size)
        assertEquals(before.left + 40f, e.boundsOf(pasted)!!.left, 1e-2f)
        assertTrue(e.pasteStrokes(emptyList(), 0f, 0f).isEmpty())
    }

    @Test fun layersReorderMergeAndBackgroundSurviveSaving() {
        val e = editor()
        e.addLayer("Top"); e.addStroke(pen, pts(500f, 500f, 600f, 600f))
        e.addLayer("Third")
        val ids = e.layers().map { it.id }
        assertEquals(listOf("Layer 1", "Top", "Third"), e.layers().map { it.label })

        // Move the middle layer up: it swaps with the top one.
        assertTrue(e.moveLayer(ids[1], up = true))
        assertEquals(listOf("Layer 1", "Third", "Top"), roundTrip(e).layers().map { it.label })
        assertFalse(e.moveLayer(ids[1], up = true)); assertFalse(e.moveLayer(ids[0], up = false))

        e.renameLayer(ids[0], "Base")
        assertEquals("Base", roundTrip(e).layers().first().label)

        // Merging "Top" (now the topmost) down moves its stroke onto "Third" and removes it.
        assertTrue(e.mergeLayerDown(ids[1]))
        assertEquals(listOf("Base", "Third"), e.layers().map { it.label })
        val third = e.layers().last().id
        assertEquals(1, e.renderer.placedLines().count { it.parent.nodeId == third })
        assertEquals(3, e.renderer.placedLines().size)
        assertFalse(e.mergeLayerDown(e.layers().first().id)) // the bottom layer has nothing below it
        assertTrue(e.undo()); assertEquals(3, e.layers().size)

        // The background can be hidden even on a page that has no scene info yet.
        assertTrue(roundTrip(e).backgroundVisible)
        e.setBackgroundVisible(false)
        assertFalse(roundTrip(e).backgroundVisible)
        e.setBackgroundVisible(true)
        assertTrue(roundTrip(e).backgroundVisible)
    }
}
