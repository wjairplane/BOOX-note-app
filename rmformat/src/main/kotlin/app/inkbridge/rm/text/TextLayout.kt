package app.inkbridge.rm.text

import app.inkbridge.rm.render.PageCanvas
import app.inkbridge.rm.scene.*
import kotlin.math.abs
import kotlin.math.max

/** A stretch of one line drawn in one style, starting [x] from the page origin. */
class LayoutRun(val start: Int, val end: Int, val text: String, val bold: Boolean, val italic: Boolean, val x: Float, val width: Float)

/** One laid-out line of a paragraph. Offsets index [TextContent.text]; [end] is exclusive and excludes the paragraph break. */
class LayoutLine(
    val para: Int,
    val start: Int,
    val end: Int,
    /** Baseline of the text. */
    val baseline: Float,
    /** Where the baseline of the previous line was: the line's slot on the page, which strokes anchored to the text follow. */
    val boxTop: Float,
    val size: Float,
    val bold: Boolean,
    val left: Float,
    val runs: List<LayoutRun>,
    val firstOfParagraph: Boolean,
    val lastOfParagraph: Boolean,
    val style: ParagraphStyle,
    /** Bullet / number text drawn in the left margin of the first line, if any. */
    val marker: String?,
    val markerX: Float,
    /** 0 = no check box, 1 = empty, 2 = checked. */
    val checkbox: Int,
) {
    val top: Float get() = baseline - size * 0.95f
    val bottom: Float get() = baseline + size * 0.32f
    val right: Float get() = runs.lastOrNull()?.let { it.x + it.width } ?: left
}

class Caret(val x: Float, val top: Float, val bottom: Float)

/**
 * Typed text set for the page: wraps paragraphs to the text block's width, picks sizes and spacing from the paragraph
 * styles and the page's [TextSettings], and answers where the caret goes for an offset and which offset a point is at.
 * All coordinates are page units, x relative to the page centre as in the file.
 */
class TextLayout private constructor(
    val content: TextContent,
    val settings: TextSettings,
    val left: Float,
    val width: Float,
    val firstBaseline: Float,
    val lines: List<LayoutLine>,
) {
    val right: Float get() = left + width
    val bottom: Float get() = lines.lastOrNull()?.bottom ?: firstBaseline

    /** The line that holds the caret at [offset]; a caret at a soft line break sits at the start of the next line. */
    fun lineIndexOf(offset: Int): Int {
        if (lines.isEmpty()) return -1
        var best = 0
        for ((i, l) in lines.withIndex()) {
            if (offset > l.end) continue
            if (offset >= l.start) { best = i; if (offset < l.end || l.lastOfParagraph) return i else continue }
            return best
        }
        return lines.lastIndex
    }

    fun xOf(line: LayoutLine, offset: Int): Float {
        val o = offset.coerceIn(line.start, line.end)
        for (r in line.runs) {
            if (o <= r.start) return r.x
            if (o < r.end) {
                val w = TextMetrics.width(r.text.substring(0, o - r.start), line.size, r.bold, r.italic, settings.font)
                // Stretched (justified) spaces make a run wider than its text; spread the difference over the run.
                val natural = TextMetrics.width(r.text, line.size, r.bold, r.italic, settings.font)
                return r.x + if (natural > 0f) w * (r.width / natural) else w
            }
        }
        return line.runs.lastOrNull()?.let { it.x + it.width } ?: line.left
    }

    fun caret(offset: Int): Caret {
        val i = lineIndexOf(offset)
        if (i < 0) return Caret(left, firstBaseline - settings.bodySize * 0.95f, firstBaseline + settings.bodySize * 0.32f)
        val l = lines[i]
        return Caret(xOf(l, offset), l.top, l.bottom)
    }

    /** The offset nearest to the point ([x], [y]). */
    fun offsetAt(x: Float, y: Float): Int {
        if (lines.isEmpty()) return 0
        var best = 0
        var bestD = Float.MAX_VALUE
        for ((i, l) in lines.withIndex()) {
            val mid = (l.baseline - l.size * 0.3f)
            val slot = abs(y - mid)
            if (slot < bestD) { bestD = slot; best = i }
        }
        val l = lines[best]
        var lo = l.start; var hi = l.end
        // Binary search over the caret positions of the line.
        while (lo < hi) {
            val m = (lo + hi) / 2
            if (xOf(l, m + 1) <= x) lo = m + 1 else hi = m
        }
        // lo is the first offset whose right edge passes x: pick the nearer edge.
        val a = xOf(l, lo); val b = xOf(l, (lo + 1).coerceAtMost(l.end))
        var o = if (lo < l.end && abs(x - b) < abs(x - a)) lo + 1 else lo
        // A caret at a soft line break belongs to the start of the next line; keep it on this one when the user pointed here.
        if (o == l.end && !l.lastOfParagraph && o > l.start && content.text.getOrNull(o - 1) == ' ') o = l.end
        return o
    }

    /** Where the caret goes for the arrow keys up / down, keeping the horizontal position [x]. */
    fun offsetVertical(offset: Int, up: Boolean, x: Float): Int {
        val i = lineIndexOf(offset)
        val j = if (up) i - 1 else i + 1
        if (i < 0 || j !in lines.indices) return if (up) 0 else content.length
        val l = lines[j]
        return offsetAt(x, l.baseline - l.size * 0.3f)
    }

    fun lineStart(offset: Int): Int = lines.getOrNull(lineIndexOf(offset))?.start ?: 0
    fun lineEnd(offset: Int): Int = lines.getOrNull(lineIndexOf(offset))?.end ?: 0

    /** The area of the paragraph [para], for placing the format menu next to it. */
    fun paragraphBounds(para: Int): FloatArray? {
        val ls = lines.filter { it.para == para }
        if (ls.isEmpty()) return null
        return floatArrayOf(left, ls.first().top, right, ls.last().bottom)
    }

    /** Boxes (x0, top, x1, bottom) covering the characters [from] until [to], one per line, for drawing a selection. */
    fun selectionRects(from: Int, to: Int): List<FloatArray> {
        if (from >= to) return emptyList()
        val out = ArrayList<FloatArray>()
        for (l in lines) {
            val a = max(from, l.start); val b = minOf(to, l.end)
            val breakIncluded = to > l.end && l.lastOfParagraph && from <= l.end
            if (a >= b && !breakIncluded) continue
            val x0 = xOf(l, a.coerceIn(l.start, l.end))
            var x1 = xOf(l, b.coerceIn(l.start, l.end))
            if (breakIncluded) x1 += l.size * 0.3f
            if (x1 > x0) out += floatArrayOf(x0, l.top, x1, l.bottom)
        }
        return out
    }

    /** True when the point is inside the text block, with [margin] around it. */
    fun contains(x: Float, y: Float, margin: Float): Boolean {
        val top = (lines.firstOrNull()?.top ?: (firstBaseline - settings.bodySize)) - margin
        return x >= left - margin && x <= right + margin && y >= top && y <= bottom + margin
    }

    /** The check box line at the point, if the point is on a check box. */
    fun checkboxAt(x: Float, y: Float): Int? {
        for (l in lines) if (l.checkbox != 0 && l.firstOfParagraph) {
            val s = l.size
            if (x in (l.markerX - s * 0.3f)..(l.markerX + s * 1.2f) && y in (l.top - s * 0.2f)..(l.bottom + s * 0.2f)) return l.para
        }
        return null
    }

    // ---- drawing ----

    fun draw(canvas: PageCanvas) {
        val black = 0xFF000000.toInt()
        for (l in lines) {
            for (r in l.runs) if (r.text.isNotBlank()) canvas.styledText(r.text, r.x, l.baseline, l.size, r.bold, r.italic, settings.font, black)
            if (l.firstOfParagraph) {
                if (l.checkbox != 0) drawCheckbox(canvas, l, black)
                else l.marker?.let { canvas.styledText(it, l.markerX, l.baseline, l.size, l.bold, false, settings.font, black) }
            }
        }
    }

    private fun drawCheckbox(canvas: PageCanvas, l: LayoutLine, color: Int) {
        val s = l.size * 0.72f
        val x = l.markerX; val y = l.baseline - s
        val w = max(2f, l.size * 0.07f)
        val box = floatArrayOf(x, y, x + s, y, x + s, y + s, x, y + s, x, y)
        canvas.polyline(box, 5, w, color, PageCanvas.Cap.SQUARE)
        if (l.checkbox == 2) {
            val tick = floatArrayOf(x + s * 0.2f, y + s * 0.52f, x + s * 0.43f, y + s * 0.76f, x + s * 0.85f, y + s * 0.2f)
            canvas.polyline(tick, 3, w * 1.3f, color, PageCanvas.Cap.ROUND)
        }
    }

    companion object {
        /** Offset of the first baseline above the text block's stored y, as the tablet's files place it. */
        const val TEXT_TOP_Y = -88f

        private const val TITLE_SCALE = 64f / 36f

        fun sizeOf(style: ParagraphStyle, settings: TextSettings): Float =
            if (style == ParagraphStyle.HEADING) settings.bodySize * TITLE_SCALE else settings.bodySize

        fun isBold(style: ParagraphStyle) = style == ParagraphStyle.HEADING || style == ParagraphStyle.BOLD

        /** Distance from one line to the next inside a paragraph. */
        fun pitch(style: ParagraphStyle, settings: TextSettings): Float = sizeOf(style, settings) * settings.lineSpacing.percent / 100f

        /** The extra space a paragraph adds in front of its first line (on top of the line pitch). */
        fun paragraphGap(style: ParagraphStyle, settings: TextSettings): Float = when (style) {
            ParagraphStyle.HEADING -> 54f
            ParagraphStyle.BULLET, ParagraphStyle.BULLET2, ParagraphStyle.NUMBERED,
            ParagraphStyle.CHECKBOX, ParagraphStyle.CHECKBOX_CHECKED -> 0f
            else -> 16f
        } * settings.scale

        private fun indentOf(style: ParagraphStyle, settings: TextSettings): Float = settings.bodySize * when (style) {
            ParagraphStyle.BULLET, ParagraphStyle.NUMBERED, ParagraphStyle.CHECKBOX, ParagraphStyle.CHECKBOX_CHECKED -> 1.3f
            ParagraphStyle.BULLET2 -> 2.6f
            else -> 0f
        }

        fun of(text: Text?, settings: TextSettings = TextSettings.current): TextLayout =
            of(TextContent.from(text), text?.posX?.toFloat() ?: (-TextSettings.PAGE_WIDTH / 2 + TextSettings.DEFAULT_SIDE_MARGIN),
                text?.posY?.toFloat() ?: TextBuffer.DEFAULT_POS_Y.toFloat(),
                text?.width ?: (TextSettings.PAGE_WIDTH - 2 * TextSettings.DEFAULT_SIDE_MARGIN), settings)

        fun of(content: TextContent, posX: Float, posY: Float, width: Float, settings: TextSettings): TextLayout {
            val font = settings.font
            val lines = ArrayList<LayoutLine>()
            var y = posY + TEXT_TOP_Y
            var number = 0
            for ((k, p) in content.paragraphs.withIndex()) {
                val style = p.style
                val size = sizeOf(style, settings)
                val bold = isBold(style)
                val pitch = pitch(style, settings)
                number = if (style == ParagraphStyle.NUMBERED) number + 1 else 0
                val indent = indentOf(style, settings)
                val textLeft = posX + indent
                val avail = (width - indent).coerceAtLeast(size)
                val breaks = breakLines(content, p, size, bold, avail, font)
                var first = true
                for ((li, br) in breaks.withIndex()) {
                    val boxTop = y
                    y += pitch + if (first) paragraphGap(style, settings) else 0f
                    val last = li == breaks.lastIndex
                    val justify = settings.justify && !last
                    val runs = buildRuns(content, br.first, br.second, size, bold, textLeft, avail, justify, font)
                    val marker = when (style) {
                        ParagraphStyle.BULLET -> "•"
                        ParagraphStyle.BULLET2 -> "–"
                        ParagraphStyle.NUMBERED -> "$number."
                        else -> null
                    }
                    val markerX = when (style) {
                        ParagraphStyle.NUMBERED -> textLeft - TextMetrics.width("$number. ", size, false, false, font)
                        ParagraphStyle.BULLET -> posX + size * 0.4f
                        ParagraphStyle.BULLET2 -> posX + size * 1.7f
                        ParagraphStyle.CHECKBOX, ParagraphStyle.CHECKBOX_CHECKED -> posX + size * 0.2f
                        else -> posX
                    }
                    lines += LayoutLine(
                        k, br.first, br.second, y, boxTop, size, bold, textLeft, runs, first, last, style, marker, markerX,
                        when (style) { ParagraphStyle.CHECKBOX -> 1; ParagraphStyle.CHECKBOX_CHECKED -> 2; else -> 0 },
                    )
                    first = false
                }
            }
            return TextLayout(content, settings, posX, width, posY + TEXT_TOP_Y, lines)
        }

        /** Greedy word wrap of paragraph [p]: (start, end) pairs, end exclusive. A line keeps the spaces that follow its last word. */
        private fun breakLines(c: TextContent, p: ParaInfo, size: Float, baseBold: Boolean, avail: Float, font: TextFont): List<Pair<Int, Int>> {
            if (p.length == 0) return listOf(p.start to p.start)
            val out = ArrayList<Pair<Int, Int>>()
            var lineStart = p.start
            var lineW = 0f
            var i = p.start
            while (i < p.end) {
                // An atom is a word with the spaces after it.
                var e = i
                while (e < p.end && c.text[e] != ' ') e++
                val wordEnd = e
                while (e < p.end && c.text[e] == ' ') e++
                val wordW = widthOf(c, i, wordEnd, size, baseBold, font)
                val fullW = widthOf(c, i, e, size, baseBold, font)
                if (lineW > 0f && lineW + wordW > avail) {
                    out += lineStart to i
                    lineStart = i; lineW = 0f
                }
                if (wordW > avail) {
                    // A word wider than the line is split where it overflows.
                    while (widthOf(c, lineStart, wordEnd, size, baseBold, font) > avail && wordEnd - lineStart > 1) {
                        var t = lineStart + 1
                        while (t < wordEnd - 1 && widthOf(c, lineStart, t + 1, size, baseBold, font) <= avail) t++
                        out += lineStart to t
                        lineStart = t
                    }
                    lineW = widthOf(c, lineStart, e, size, baseBold, font)
                } else lineW += fullW
                i = e
            }
            out += lineStart to p.end
            return out
        }

        private fun widthOf(c: TextContent, from: Int, to: Int, size: Float, baseBold: Boolean, font: TextFont): Float {
            var w = 0f
            var s = from
            while (s < to) {
                var e = s + 1
                while (e < to && c.bold[e] == c.bold[s] && c.italic[e] == c.italic[s]) e++
                w += TextMetrics.width(c.text.substring(s, e), size, baseBold || c.bold[s], c.italic[s], font)
                s = e
            }
            return w
        }

        private fun buildRuns(c: TextContent, from: Int, to: Int, size: Float, baseBold: Boolean, left: Float, avail: Float, justify: Boolean, font: TextFont): List<LayoutRun> {
            val runs = ArrayList<LayoutRun>()
            var x = left
            var s = from
            // Trailing spaces hang past the edge and don't count when stretching a line.
            var visibleEnd = to
            while (visibleEnd > from && c.text[visibleEnd - 1] == ' ') visibleEnd--
            var gap = 0f
            if (justify) {
                var spaces = 0
                for (i in from until visibleEnd) if (c.text[i] == ' ') spaces++
                val natural = widthOf(c, from, visibleEnd, size, baseBold, font)
                if (spaces > 0 && natural < avail) gap = (avail - natural) / spaces
            }
            while (s < to) {
                var e = s + 1
                while (e < to && c.bold[e] == c.bold[s] && c.italic[e] == c.italic[s] && (gap == 0f || (c.text[e] == ' ') == (c.text[s] == ' '))) e++
                val str = c.text.substring(s, e)
                var w = TextMetrics.width(str, size, baseBold || c.bold[s], c.italic[s], font)
                if (gap > 0f && s < visibleEnd && str[0] == ' ') w += gap * str.length
                runs += LayoutRun(s, e, str, baseBold || c.bold[s], c.italic[s], x, w)
                x += w
                s = e
            }
            if (runs.isEmpty()) runs += LayoutRun(from, from, "", baseBold, false, left, 0f)
            return runs
        }

        /** Y position of each text character / paragraph, used to place groups anchored to text lines. */
        fun anchors(text: Text?, settings: TextSettings = TextSettings.current): Map<CrdtId, Float> {
            val pos = HashMap<CrdtId, Float>()
            val layout = of(text, settings)
            pos[CrdtId(0, 281474976710654)] = layout.firstBaseline
            var last = layout.firstBaseline
            for (l in layout.lines) {
                val p = layout.content.paragraphs[l.para]
                if (l.firstOfParagraph) pos[p.key] = l.boxTop
                for (i in l.start until l.end) layout.content.ids.getOrNull(i)?.let { pos[it] = l.boxTop }
                // The paragraph break that starts the next paragraph sits at the end of this line's paragraph.
                last = l.baseline
            }
            pos[CrdtId(0, 281474976710655)] = last
            return pos
        }
    }
}
