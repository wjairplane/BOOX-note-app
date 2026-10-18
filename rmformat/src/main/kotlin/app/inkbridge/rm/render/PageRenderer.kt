package app.inkbridge.rm.render

import app.inkbridge.rm.scene.*
import app.inkbridge.rm.text.TextLayout
import app.inkbridge.rm.text.TextSettings
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/** Content extent in page units. x is relative to the page centre, as stored in the file. */
data class PageLayout(val xMin: Float, val xMax: Float, val yMin: Float, val yMax: Float) {
    val width: Float get() = xMax - xMin
    val height: Float get() = yMax - yMin

    companion object {
        const val PAGE_WIDTH = 1404f
        const val PAGE_HEIGHT = 1872f
    }
}

/**
 * Draws a [SceneTree] page onto a [PageCanvas]. Layers draw in file order; hidden layers are skipped.
 * Output is in page units with x relative to the page centre (see [layout] for the shift).
 */
class PageRenderer(private val tree: SceneTree) {
    private val anchorPos = buildAnchorPos(tree.rootText)

    /** The typed text set for this page with the settings in force when the renderer was made; null on a page without text. */
    val textLayout: TextLayout? by lazy { tree.rootText?.let { TextLayout.of(it, TextSettings.current) } }

    /** Standard page area, grown if strokes extend past it (notebook pages can scroll vertically). */
    val layout: PageLayout by lazy {
        val b = floatArrayOf(-PageLayout.PAGE_WIDTH / 2, PageLayout.PAGE_WIDTH / 2, 0f, PageLayout.PAGE_HEIGHT)
        grow(tree.root, 0f, 0f, b)
        // Typed text that runs past the bottom of the page makes the page longer.
        textLayout?.lines?.lastOrNull()?.let { b[3] = max(b[3], it.bottom + TextSettings.TOP_MARGIN) }
        PageLayout(b[0], b[1], b[2], b[3])
    }

    /** A stroke with the page-space offset of its (possibly text-anchored) parent group. */
    class PlacedLine(val itemId: CrdtId, val parent: Group, val line: Line, val ox: Float, val oy: Float)

    /** Visible strokes in drawing order, with parent and offset (for hit-testing and editing). */
    fun placedLines(): List<PlacedLine> = buildList { collectLines(tree.root, 0f, 0f, this) }

    private fun collectLines(g: Group, ox: Float, oy: Float, out: MutableList<PlacedLine>) {
        for (e in g.children.orderedItems()) when (val c = e.value) {
            is Group -> if (c.visible.value) {
                val (ax, ay) = anchorOffset(c)
                collectLines(c, ox + ax, oy + ay, out)
            }
            is Line -> out += PlacedLine(e.itemId, g, c, ox, oy)
            else -> Unit
        }
    }

    /** Page-space offset of a group relative to the page origin (sum of anchor offsets from the root). */
    fun offsetOf(target: Group): Pair<Float, Float> {
        fun find(g: Group, ox: Float, oy: Float): Pair<Float, Float>? {
            if (g === target) return ox to oy
            for (c in g.childItems()) if (c is Group) {
                val (ax, ay) = anchorOffset(c)
                find(c, ox + ax, oy + ay)?.let { return it }
            }
            return null
        }
        return find(tree.root, 0f, 0f) ?: (0f to 0f)
    }

    /** Draw one stroke (e.g. the newest one onto an existing bitmap). */
    fun renderLine(line: Line, ox: Float, oy: Float, canvas: PageCanvas) = drawLine(line, ox, oy, canvas)

    /** Draw the page's text and strokes with the vector pens (for SVG / PDF export and thumbnails). */
    fun render(canvas: PageCanvas) = render(canvas, strokes = true)

    /** Draw the page's text and highlights; the strokes only when [strokes] (on screen they are drawn pixel by pixel by [renderInk]). */
    fun render(canvas: PageCanvas, strokes: Boolean) {
        drawText(canvas)
        drawGroup(tree.root, 0f, 0f, canvas, strokes)
    }

    /** Draw the page's strokes with the firmware's pen renderer, bottom layer first. */
    fun renderInk(ink: PixelInk, tf: PixelInk.Transform, paletteMode: Int = 0) {
        val items = ArrayList<PixelInk.Placed>()
        inkGroup(tree.root, 0f, 0f, items)
        ink.drawLines(items, tf, paletteMode)
    }

    private fun inkGroup(g: Group, ox: Float, oy: Float, out: MutableList<PixelInk.Placed>) {
        for (c in g.childItems()) when (c) {
            is Group -> if (c.visible.value) {
                val (ax, ay) = anchorOffset(c)
                inkGroup(c, ox + ax, oy + ay, out)
            }
            is Line -> out += PixelInk.Placed(c, ox, oy)
            is GlyphRange -> Unit
        }
    }

    private fun anchorOffset(g: Group): Pair<Float, Float> {
        val id = g.anchorId ?: return 0f to 0f
        val x = g.anchorOriginX?.value ?: 0f
        val y = anchorPos[id.value] ?: 0f
        return x to y
    }

    private fun grow(g: Group, ox: Float, oy: Float, b: FloatArray) {
        for (c in g.childItems()) when (c) {
            is Group -> {
                if (!c.visible.value) continue
                val (ax, ay) = anchorOffset(c)
                grow(c, ox + ax, oy + ay, b)
            }
            is Line -> for (p in c.points) {
                b[0] = min(b[0], p.x + ox); b[1] = max(b[1], p.x + ox)
                b[2] = min(b[2], p.y + oy); b[3] = max(b[3], p.y + oy)
            }
            is GlyphRange -> Unit
        }
    }

    private fun drawGroup(g: Group, ox: Float, oy: Float, canvas: PageCanvas, strokes: Boolean = true) {
        for (c in g.childItems()) when (c) {
            is Group -> if (c.visible.value) {
                val (ax, ay) = anchorOffset(c)
                drawGroup(c, ox + ax, oy + ay, canvas, strokes)
            }
            is Line -> if (strokes) drawLine(c, ox, oy, canvas)
            is GlyphRange -> drawGlyph(c, ox, oy, canvas)
        }
    }

    private fun argb(rgba: IntArray, opacity: Double): Int {
        val a = (rgba[3] * opacity.coerceIn(0.0, 1.0)).roundToInt().coerceIn(0, 255)
        return (a shl 24) or (rgba[0] shl 16) or (rgba[1] shl 8) or rgba[2]
    }

    private fun drawLine(line: Line, ox: Float, oy: Float, canvas: PageCanvas) {
        val rgba = PenPalette.lookup(line.color, line.colorRgba)
        val pen = Pen.create(line.tool, rgba, line.thicknessScale, explicitAlpha = line.colorRgba != null) ?: return
        val pts = line.points
        if (pts.isEmpty()) return

        val buf = FloatArray((pen.segmentLength + 1) * 2)
        var n = 0
        var lastWidth = 0.0
        var width = 0f
        var color = 0

        fun flush() {
            if (n > 0) canvas.polyline(buf, n, width, color, pen.cap)
        }

        for ((i, p) in pts.withIndex()) {
            if (i % pen.segmentLength == 0) {
                val joinX = if (n > 0) buf[(n - 1) * 2] else 0f
                val joinY = if (n > 0) buf[(n - 1) * 2 + 1] else 0f
                val hadPrev = n > 0
                flush()
                n = 0
                val w = pen.segmentWidth(p.speed, p.direction, p.width, p.pressure, lastWidth)
                val c = pen.segmentColor(p.speed, p.direction, p.width, p.pressure, lastWidth)
                val o = pen.segmentOpacity(p.speed, p.direction, p.width, p.pressure, lastWidth)
                width = max(w, MIN_WIDTH).toFloat()
                color = argb(c, o)
                lastWidth = w
                if (hadPrev) { buf[0] = joinX; buf[1] = joinY; n = 1 } // continue from the previous segment
            }
            buf[n * 2] = p.x + ox
            buf[n * 2 + 1] = p.y + oy
            n++
        }
        flush()
        // A single-point stroke (a dot) still needs a visible mark.
        if (pts.size == 1) {
            val p = pts[0]
            buf[0] = p.x + ox; buf[1] = p.y + oy; buf[2] = p.x + ox + 0.01f; buf[3] = p.y + oy
            canvas.polyline(buf, 2, width, color, PageCanvas.Cap.ROUND)
        }
    }

    private fun drawGlyph(g: GlyphRange, ox: Float, oy: Float, canvas: PageCanvas) {
        val rgba = PenPalette.lookup(g.color, g.colorRgba)
        val c = argb(rgba, 0.35)
        for (r in g.rectangles) canvas.fillRect((r.x + ox).toFloat(), (r.y + oy).toFloat(), r.w.toFloat(), r.h.toFloat(), c)
    }

    private fun drawText(canvas: PageCanvas) { textLayout?.draw(canvas) }

    companion object {
        /** Smallest stroke width drawn; pen formulas can dip to zero or below at very light pressure. */
        const val MIN_WIDTH = 0.5

        private val TOP_ANCHOR = CrdtId(0, 281474976710654)
        private val BOTTOM_ANCHOR = CrdtId(0, 281474976710655)

        /** Y position of each text character / paragraph, used to place groups anchored to text. */
        fun buildAnchorPos(text: Text?): Map<CrdtId, Float> {
            if (text == null) return mapOf(TOP_ANCHOR to 0f, BOTTOM_ANCHOR to PageLayout.PAGE_HEIGHT)
            return TextLayout.anchors(text)
        }
    }
}
