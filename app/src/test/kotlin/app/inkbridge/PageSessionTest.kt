package app.inkbridge

import app.inkbridge.pen.PenSample
import app.inkbridge.rm.edit.InputPoint
import app.inkbridge.rm.edit.PageEditor
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/** The page session's selection, view and layer behaviour (the parts a pen on a real device drives). */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34])
class PageSessionTest {
    @get:Rule val tmp = TemporaryFolder()

    private fun pts(vararg xy: Float) = xy.toList().chunked(2).mapIndexed { i, (x, y) -> InputPoint(x, y, 0.6f, 0f, 0f, i * 5L) }

    /** A page with two strokes near the top-left and one near the bottom-right, shown in a 1000 x 1200 view. */
    private fun session(): PageSession {
        val ed = PageEditor.blank()
        ed.addStroke(PenSpec(PenTool.FINELINER), pts(-500f, 100f, -460f, 110f, -420f, 100f))
        ed.addStroke(PenSpec(PenTool.FINELINER), pts(-480f, 150f, -440f, 150f))
        ed.addStroke(PenSpec(PenTool.FINELINER), pts(400f, 1500f, 440f, 1540f))
        val f = tmp.newFile("page.rm").also { it.writeBytes(ed.toBytes()) }
        return PageSession(f).also { it.resize(1000, 1200) }
    }

    /** View-pixel samples through the given page points. */
    private fun path(s: PageSession, vararg xy: Float): List<PenSample> {
        val t = s.transform!!
        return xy.toList().chunked(2).mapIndexed { i, (x, y) -> PenSample(t.toViewX(x), t.toViewY(y), 0.5f, 0f, 0f, i * 5L) }
    }

    @Test fun lassoSelectsStrokesDragsThemDuplicatesAndDeletes() {
        val s = session()
        assertFalse(s.hasSelection)
        // A lasso around the two strokes at the top-left selects them (and not the far one).
        assertTrue(s.selectionStroke(path(s, -560f, 50f, -380f, 50f, -380f, 220f, -560f, 220f, -560f, 50f)))
        assertTrue(s.hasSelection)
        val r = s.selectionRect()!!
        val t = s.transform!!
        assertEquals(t.toViewX(-500f), r.left, 1f); assertEquals(t.toViewX(-420f), r.right, 1f)

        // A stroke that starts inside the selection drags it.
        val f = s.selectionFrame()!!
        assertTrue(s.selectionStroke(listOf(PenSample(f.centerX, f.centerY, .5f, 0f, 0f, 0), PenSample(f.centerX + 100f * t.scale, f.centerY + 100f * t.scale, .5f, 0f, 0f, 5))))
        val moved = s.selectionRect()!!
        assertEquals(r.left + 100f * t.scale, moved.left, 1f); assertEquals(r.top + 100f * t.scale, moved.top, 1f)
        assertTrue(s.isDirty)

        // Duplicate selects the copies, offset from the originals; delete removes them again.
        assertTrue(s.duplicateSelection())
        assertTrue(s.selectionRect()!!.left > moved.left)
        assertTrue(s.deleteSelection())
        assertFalse(s.hasSelection); assertNull(s.selectionRect())

        // The originals now sit 100 units lower and to the right. A lasso around nothing clears the selection; a tap clears it too.
        assertTrue(s.selectionStroke(path(s, -440f, 180f, -300f, 180f, -300f, 270f, -440f, 270f)))
        assertTrue(s.hasSelection)
        assertTrue(s.selectionStroke(path(s, 0f, 700f)))
        assertFalse(s.hasSelection)

        // Undo drops the selection (its strokes may no longer exist).
        assertTrue(s.selectionStroke(path(s, -440f, 180f, -300f, 180f, -300f, 270f, -440f, 270f)))
        assertTrue(s.undo()); assertFalse(s.hasSelection)
    }

    @Test fun pinchZoomPanAndFitModes() {
        val s = session()
        val fit = s.transform!!
        assertEquals(1f, s.zoom, 1e-6f)
        assertNull(s.customView)

        // Pinch out around the middle of the view: the page point under the fingers stays put.
        val fx = 500f; val fy = 600f
        val px = fit.toPageX(fx); val py = fit.toPageY(fy)
        s.viewGesture(2f, fx, fy, 0f, 0f)
        assertEquals(2f, s.zoom, 1e-4f)
        assertEquals(px, s.transform!!.toPageX(fx), 0.5f); assertEquals(py, s.transform!!.toPageY(fy), 0.5f)
        assertNotNull(s.customView)
        // The bitmap stays the size of the view, whatever the zoom.
        assertEquals(1000, s.bitmap!!.width); assertEquals(1200, s.bitmap!!.height)

        // Two-finger drag pans, clamped so the page always covers the view.
        s.viewGesture(1f, fx, fy, 99999f, 99999f)
        assertEquals(0f, s.transform!!.offsetX, 1e-3f); assertEquals(0f, s.transform!!.offsetY, 1e-3f)

        // Fit modes.
        s.fitPage(); assertEquals(1f, s.zoom, 1e-6f)
        s.fitHeight(); assertEquals(1f, s.zoom, 1e-3f) // this view is height-bound already
        val wide = PageSession(java.io.File(tmp.root, "w.rm")).also { it.resize(2000, 1200) }
        wide.fitWidth()
        assertTrue("fit to width zooms in on a wide view (${wide.zoom})", wide.zoom > 1.5f)
        assertEquals(0f, wide.transform!!.offsetY, 1e-3f)
        // "Fit to custom view" comes back to the last pinch.
        s.viewGesture(2.5f, fx, fy, 0f, 0f); val custom = s.zoom
        s.fitPage(); s.fitCustom()
        assertEquals(custom, s.zoom, 1e-4f)
    }

    @Test fun strokesDrawnWhileZoomedLandInTheRightPlace() {
        val s = session()
        s.viewGesture(2f, 500f, 600f, 0f, 0f)
        val t = s.transform!!
        // The pen is at view (500, 600); that must be stored at the page point under it.
        val expectedX = t.toPageX(500f); val expectedY = t.toPageY(600f)
        assertTrue(s.addStroke(PenSpec(PenTool.FINELINER), listOf(PenSample(500f, 600f, .5f, 0f, 0f, 0), PenSample(520f, 620f, .5f, 0f, 0f, 5))))
        assertTrue(s.selectionStroke(path(s, expectedX - 60f, expectedY - 60f, expectedX + 60f, expectedY - 60f, expectedX + 60f, expectedY + 60f, expectedX - 60f, expectedY + 60f)))
        val r = s.selectionRect()!!
        assertEquals(500f, r.left, 1f); assertEquals(600f, r.top, 1f)
    }

    @Test fun layersHideStrokesAndNewStrokesGoToTheCurrentLayer() {
        val s = session()
        val first = s.layers().single()
        assertTrue(first.current)
        s.addLayer("Notes")
        val notes = s.layers().last()
        assertEquals("Notes", notes.label); assertTrue(notes.current)
        assertTrue(s.addStroke(PenSpec(PenTool.BALLPOINT), listOf(PenSample(100f, 100f, .5f, 0f, 0f, 0), PenSample(140f, 120f, .5f, 0f, 0f, 5))))
        // Hiding the layer hides its strokes from lassoing, and drawing then falls back to the visible layer.
        s.setLayerVisible(notes.id, false)
        assertEquals(first.id, s.layers().single { it.current }.id)
        assertTrue(s.deleteLayer(notes.id))
        assertEquals(1, s.layers().size)
        assertFalse(s.deleteLayer(first.id))
    }

    private fun select(s: PageSession) =
        assertTrue(s.selectionStroke(path(s, -560f, 50f, -380f, 50f, -380f, 220f, -560f, 220f, -560f, 50f)))

    @Test fun cornerHandleResizesAndRotateHandleRotates() {
        val s = session()
        select(s)
        val before = s.selectionRect()!!
        val frame = s.selectionFrame()!!
        // Drag the bottom-right corner handle away from the top-left one: the selection grows about the top-left corner.
        val (cx, cy) = frame.corners()[2]
        assertTrue(s.selectionStroke(listOf(PenSample(cx, cy, .5f, 0f, 0f, 0), PenSample(cx + 100f, cy + 100f, .5f, 0f, 0f, 5))))
        val after = s.selectionRect()!!
        // The opposite (top-left) corner of the frame stays where it was.
        // (The frame's padding doesn't scale, so it shifts by a few pixels.)
        assertEquals(frame.left, s.selectionFrame()!!.left, 80f); assertEquals(frame.top, s.selectionFrame()!!.top, 80f)
        assertTrue(after.width() > before.width() * 1.2f)

        // Drag the rotate handle a quarter turn about the centre: a wide selection turns tall.
        val f2 = s.selectionFrame()!!
        val (rx, ry) = f2.rotateHandle(app.inkbridge.rm.edit.SelectionGesture.ROTATE_OFFSET)
        val w = s.selectionRect()!!.width(); val h = s.selectionRect()!!.height()
        assertTrue(s.selectionStroke(listOf(PenSample(rx, ry, .5f, 0f, 0f, 0), PenSample(f2.centerX + (f2.centerY - ry), f2.centerY, .5f, 0f, 0f, 5))))
        val turned = s.selectionRect()!!
        assertTrue("was ${w}x$h, now ${turned.width()}x${turned.height()}", kotlin.math.abs(turned.width() - h) < kotlin.math.abs(turned.width() - w))
    }

    @Test fun copyCutAndPasteWorkAcrossPages() {
        StrokeClipboard.lines = emptyList()
        val s = session()
        assertFalse(s.pasteClipboard())
        select(s)
        // Copying ends the selection; a tap with the selection tool then pastes the strokes with their centre there.
        assertTrue(s.copySelection()); assertTrue(StrokeClipboard.hasContent); assertFalse(s.hasSelection)
        assertTrue(s.selectionStroke(listOf(PenSample(500f, 900f, .5f, 0f, 0f, 0))))
        val pasted = s.selectionRect()!!
        assertEquals(500f, (pasted.left + pasted.right) / 2, 30f); assertEquals(900f, (pasted.top + pasted.bottom) / 2, 30f)
        // Cut removes the selection; pasting into another page puts it there.
        assertTrue(s.cutSelection()); assertFalse(s.hasSelection)
        val other = PageSession(java.io.File(tmp.root, "other.rm")).also { it.resize(1000, 1200) }
        assertTrue(other.pasteClipboard()); assertTrue(other.hasSelection)
        // The eraser's selection mode and "erase all" on the current layer.
        assertTrue(other.eraseCurrentLayer()); assertFalse(other.eraseCurrentLayer())
    }

    @Test fun layerOptionsAndBackgroundChangeThePage() {
        val s = session()
        val first = s.layers().single().id
        s.addLayer("Notes")
        val notes = s.layers().last().id
        assertTrue(s.moveLayer(notes, up = false))
        assertEquals("Notes", s.layers().first().label)
        s.renameLayer(first, "Ink")
        assertEquals(listOf("Notes", "Ink"), s.layers().map { it.label })
        assertTrue(s.mergeLayerDown(first)); assertEquals(listOf("Notes"), s.layers().map { it.label })
        assertTrue(s.backgroundVisible()); s.setBackgroundVisible(false); assertFalse(s.backgroundVisible())
    }

    @Test fun liveStrokeLooksLikeTheFinishedStrokeAndLeavesNoTrace() {
        val s = session()
        val bmp = s.bitmap!!
        val before = IntArray(bmp.width * bmp.height).also { bmp.getPixels(it, 0, bmp.width, 0, 0, bmp.width, bmp.height) }
        val stroke = path(s, -200f, 600f, -150f, 620f, -90f, 640f, -30f, 650f, 40f, 640f, 120f, 610f)
        val spec = PenSpec(PenTool.BALLPOINT)
        // Written in two frames, as the pen moves.
        val first = s.previewStroke(spec, stroke.take(3), 0)
        val rect = s.previewStroke(spec, stroke, 3)
        assertNotNull(first); assertNotNull(rect)
        val live = IntArray(bmp.width * bmp.height).also { bmp.getPixels(it, 0, bmp.width, 0, 0, bmp.width, bmp.height) }
        assertTrue(live.indices.any { live[it] != before[it] })

        // The pen lifts: the live stroke comes off, the stroke is added, and the picture matches what was shown (apart from the end cap).
        s.endPreview()
        val cleared = IntArray(bmp.width * bmp.height).also { bmp.getPixels(it, 0, bmp.width, 0, 0, bmp.width, bmp.height) }
        assertArrayEquals(before, cleared)
        assertTrue(s.addStroke(spec, stroke))
        assertNotNull(s.takeStrokeRect()); assertNull(s.takeStrokeRect())
        val done = IntArray(bmp.width * bmp.height).also { bmp.getPixels(it, 0, bmp.width, 0, 0, bmp.width, bmp.height) }
        val different = live.indices.count { live[it] != done[it] }
        assertTrue("live and final differ in $different px", different < 40)
    }

    @Test fun eraserFadesWhatItPassesOverAsACheckerboardAndOnlyCutsAtPenUp() {
        val s = session()
        val bmp = s.bitmap!!
        val spec = PenSpec(PenTool.FINELINER, thickness = 3)
        val stroke = path(s, -200f, 600f, -150f, 620f, -90f, 640f, -30f, 650f, 40f, 640f, 120f, 610f)
        assertTrue(s.addStroke(spec, stroke)); s.takeStrokeRect()
        val before = IntArray(bmp.width * bmp.height).also { bmp.getPixels(it, 0, bmp.width, 0, 0, bmp.width, bmp.height) }
        val eraser = path(s, -100f, 600f, -60f, 640f, 0f, 660f)
        val rect = s.previewErase(eraser, 20f, 0)
        assertNotNull(rect)
        val live = IntArray(bmp.width * bmp.height).also { bmp.getPixels(it, 0, bmp.width, 0, 0, bmp.width, bmp.height) }
        val changed = live.indices.filter { live[it] != before[it] }
        assertTrue(changed.isNotEmpty())
        // Only pixels with x + y even turn white, nothing is blended.
        assertTrue(changed.all { (it % bmp.width + it / bmp.width) % 2 == 0 && live[it] == -1 })
        // Nothing is cut until the pen lifts.
        s.endErasePreview()
        val restored = IntArray(bmp.width * bmp.height).also { bmp.getPixels(it, 0, bmp.width, 0, 0, bmp.width, bmp.height) }
        assertArrayEquals(before, restored)
        assertTrue(s.erase(eraser, 20f))
    }
}
