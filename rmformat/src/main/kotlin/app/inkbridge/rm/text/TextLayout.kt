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
    /** Top of the slot the line (and, for the first line, its paragraph's top margin) takes; strokes anchored to the text follow it. */
    val boxTop: Float,
    /** Top of the line itself and its height (the font's height, without the gap below). */
    val top: Float,
    val height: Float,
    val size: Float,
    val bold: Boolean,
    val font: TextFont,
    val left: Float,
    val runs: List<LayoutRun>,
    val firstOfParagraph: Boolean,
    val lastOfParagraph: Boolean,
    val style: ParagraphStyle,
    /** Bullet / number text drawn in the left margin of the first line, if any. */
    val marker: String?,
    /** Where the marker goes: its left edge, or its right edge for a number. */
    val markerX: Float,
    /** 0 = no check box, 1 = empty, 2 = checked. */
    val checkbox: Int,
) {
    val bottom: Float get() = top + height
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
                val w = TextMetrics.width(r.text.substring(0, o - r.start), line.size, r.bold, r.italic, line.font)
                // Stretched (justified) spaces make a run wider than its text; spread the difference over the run.
                val natural = TextMetrics.width(r.text, line.size, r.bold, r.italic, line.font)
                return r.x + if (natural > 0f) w * (r.width / natural) else w
            }
        }
        return line.runs.lastOrNull()?.let { it.x + it.width } ?: line.left
    }

    fun caret(offset: Int): Caret {
        val i = lineIndexOf(offset)
        if (i < 0) return Caret(left, firstBaseline - TextStyles.BODY_SIZE * TextStyles.ASCENT_FACTOR, firstBaseline + TextStyles.BODY_SIZE * (TextStyles.HEIGHT_FACTOR - TextStyles.ASCENT_FACTOR))
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
        val top = (lines.firstOrNull()?.top ?: (firstBaseline - TextStyles.BODY_SIZE)) - margin
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

    /** The y position of each text character and paragraph (the slot of its line), plus the page-wide top and bottom anchors. */
    fun anchors(): Map<CrdtId, Float> {
        val pos = HashMap<CrdtId, Float>()
        pos[CrdtId(0, 281474976710654)] = firstBaseline
        var last = firstBaseline
        for (l in lines) {
            val p = content.paragraphs[l.para]
            if (l.firstOfParagraph) pos[p.key] = l.boxTop
            for (i in l.start until l.end) content.ids.getOrNull(i)?.let { pos[it] = l.boxTop }
            last = l.baseline
        }
        pos[CrdtId(0, 281474976710655)] = last
        return pos
    }

    // ---- drawing ----

    fun draw(canvas: PageCanvas) {
        val black = 0xFF000000.toInt()
        for (l in lines) {
            for (r in l.runs) if (r.text.isNotBlank()) canvas.styledText(r.text, r.x, l.baseline, l.size, r.bold, r.italic, l.font, black)
            // A ticked check box strikes its text through.
            if (l.checkbox == 2 && l.runs.isNotEmpty() && l.end > l.start) {
                val y = l.baseline - l.size * 0.3f
                val line = floatArrayOf(l.runs.first().x, y, l.runs.last().let { it.x + it.width }, y)
                canvas.polyline(line, 2, max(1.5f, l.size * 0.06f), black, PageCanvas.Cap.BUTT)
            }
            if (l.firstOfParagraph) {
                if (l.checkbox != 0) drawCheckbox(canvas, l, black)
                else l.marker?.let { m ->
                    if (l.style == ParagraphStyle.NUMBERED) {
                        val w = TextMetrics.width(m, l.size, false, false, l.font)
                        canvas.styledText(m, l.markerX - w, l.baseline, l.size, false, false, l.font, black)
                    } else canvas.styledText(m, l.markerX, l.baseline, l.size, false, false, l.font, black)
                }
            }
        }
    }

    /** The firmware's 40 x 40 check box, 2 px above the line's top. */
    private fun drawCheckbox(canvas: PageCanvas, l: LayoutLine, color: Int) {
        val s = CHECKBOX_SIZE
        val x = l.markerX + 3f; val y = l.top - 2f + 3f
        val w = 3f
        val e = s - 6f
        val box = floatArrayOf(x, y, x + e, y, x + e, y + e, x, y + e, x, y)
        canvas.polyline(box, 5, w, color, PageCanvas.Cap.SQUARE)
        if (l.checkbox == 2) {
            val tick = floatArrayOf(x + e * 0.2f, y + e * 0.52f, x + e * 0.43f, y + e * 0.76f, x + e * 0.85f, y + e * 0.22f)
            canvas.polyline(tick, 3, w * 1.2f, color, PageCanvas.Cap.ROUND)
        }
    }

    companion object {
        const val CHECKBOX_SIZE = 40f

        /** Font of a paragraph style: Title in reMarkable Serif Small, Subheading in Sans Medium, the rest in Sans. */
        fun fontOf(style: ParagraphStyle): TextFont = when (style) {
            ParagraphStyle.HEADING -> TextFont.RM_SERIF
            ParagraphStyle.BOLD -> TextFont.RM_SANS_MEDIUM
            else -> TextFont.RM_SANS
        }

        /** Pixel size of a paragraph style: Title 64, Subheading (2) 36, everything else 32. */
        fun sizeOf(style: ParagraphStyle): Float = when (style) {
            ParagraphStyle.HEADING -> 64f
            ParagraphStyle.BOLD -> 36f
            else -> TextStyles.BODY_SIZE
        }

        /** The block's top margin: Title 88, Subheading 2 40, body and lists 24. */
        fun topMargin(style: ParagraphStyle): Float = when (style) {
            ParagraphStyle.HEADING -> 88f
            ParagraphStyle.BOLD -> 40f
            else -> 24f
        }

        private fun isBody(style: ParagraphStyle) = style != ParagraphStyle.HEADING && style != ParagraphStyle.BOLD

        private fun levelOf(style: ParagraphStyle) = if (style == ParagraphStyle.BULLET2) 1 else 0

        private fun isList(style: ParagraphStyle) = when (style) {
            ParagraphStyle.BULLET, ParagraphStyle.BULLET2, ParagraphStyle.NUMBERED, ParagraphStyle.CHECKBOX, ParagraphStyle.CHECKBOX_CHECKED -> true
            else -> false
        }

        fun of(text: Text?): TextLayout {
            val col = TextColumn.DEFAULT
            return of(TextContent.from(text), text?.posX?.toFloat() ?: col.posX.toFloat(), text?.posY?.toFloat() ?: TextStyles.POS_Y.toFloat(),
                text?.width ?: col.width)
        }

        fun of(content: TextContent, posX: Float, posY: Float, width: Float): TextLayout {
            val lines = ArrayList<LayoutLine>()
            val boxLeft = posX + TextStyles.DOCUMENT_MARGIN
            val boxWidth = width - 2 * TextStyles.DOCUMENT_MARGIN
            var y = posY + TextStyles.DOCUMENT_MARGIN
            var number = 0
            for ((k, p) in content.paragraphs.withIndex()) {
                val style = p.style
                val size = sizeOf(style)
                val font = fontOf(style)
                val bold = false
                val h = size * TextStyles.HEIGHT_FACTOR
                val gap = if (isBody(style)) TextStyles.BODY_LINE_GAP else 0f
                number = if (style == ParagraphStyle.NUMBERED) number + 1 else 0
                val level = levelOf(style)
                val indent = if (isList(style)) (level + 1) * TextStyles.LIST_INDENT else 0f
                val textLeft = boxLeft + indent
                val avail = (boxWidth - indent).coerceAtLeast(size)
                val breaks = breakLines(content, p, size, false, avail, font)
                var first = true
                for ((li, br) in breaks.withIndex()) {
                    val boxTop = y
                    if (first) y += topMargin(style)
                    val top = y
                    val baseline = top + size * TextStyles.ASCENT_FACTOR
                    y = top + h + gap
                    val last = li == breaks.lastIndex
                    val runs = buildRuns(content, br.first, br.second, size, false, textLeft, avail, false, font)
                    val blockLeft = boxLeft + level * TextStyles.LIST_INDENT
                    val marker = when (style) {
                        ParagraphStyle.BULLET -> "\u2022"
                        ParagraphStyle.BULLET2 -> "\u25E6"
                        ParagraphStyle.NUMBERED -> "$number."
                        else -> null
                    }
                    val markerX = when (style) {
                        ParagraphStyle.NUMBERED -> blockLeft + 29f
                        ParagraphStyle.BULLET, ParagraphStyle.BULLET2 -> blockLeft + 20f
                        else -> blockLeft
                    }
                    lines += LayoutLine(
                        k, br.first, br.second, baseline, boxTop, top, h, size, bold, font, textLeft, runs, first, last, style, marker, markerX,
                        when (style) { ParagraphStyle.CHECKBOX -> 1; ParagraphStyle.CHECKBOX_CHECKED -> 2; else -> 0 },
                    )
                    first = false
                }
            }
            return TextLayout(content, posX, width, posY + TextStyles.DOCUMENT_MARGIN, lines)
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
        fun anchors(text: Text?): Map<CrdtId, Float> = of(text).anchors()
    }
}
