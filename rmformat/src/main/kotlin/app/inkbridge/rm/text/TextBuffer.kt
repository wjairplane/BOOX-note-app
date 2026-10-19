package app.inkbridge.rm.text

import app.inkbridge.rm.scene.*

/** One paragraph of a [TextContent]: the characters [start] until [end] (the newline that precedes it is not included). */
class ParaInfo(val start: Int, val end: Int, val style: ParagraphStyle, val key: CrdtId) {
    val length: Int get() = end - start
}

/**
 * The visible text of a page as a flat string: every visible character (paragraph breaks are `'\n'`) with its CRDT id and
 * bold / italic state, plus the paragraphs with their styles. Offsets everywhere in the text tool are indices into [text].
 */
class TextContent(
    val text: String,
    val ids: List<CrdtId>,
    val bold: BooleanArray,
    val italic: BooleanArray,
    val paragraphs: List<ParaInfo>,
) {
    val length: Int get() = text.length

    /** Index of the paragraph that contains the caret at [offset] (a caret at a paragraph's end belongs to that paragraph). */
    fun paragraphAt(offset: Int): Int {
        val o = offset.coerceIn(0, text.length)
        var best = 0
        for ((i, p) in paragraphs.withIndex()) if (p.start <= o) best = i
        return best
    }

    /** Word around [offset]: a run of letters / digits, or if the offset is on blank space the blank run. */
    fun wordAt(offset: Int): IntRange {
        if (text.isEmpty()) return 0 until 0
        var o = offset.coerceIn(0, text.length - 1)
        if (text[o] == '\n' && o > 0) o--
        if (text[o] == '\n') return o until o
        val isWord = text[o].isLetterOrDigit()
        fun same(c: Char) = c != '\n' && (c.isLetterOrDigit() == isWord) && (isWord || c.isWhitespace() == text[o].isWhitespace())
        var s = o; var e = o + 1
        while (s > 0 && same(text[s - 1])) s--
        while (e < text.length && same(text[e])) e++
        return s until e
    }

    companion object {
        val EMPTY = TextContent("", emptyList(), BooleanArray(0), BooleanArray(0), listOf(ParaInfo(0, 0, ParagraphStyle.PLAIN, CrdtId.END_MARKER)))

        fun from(t: Text?): TextContent {
            if (t == null) return EMPTY
            val doc = TextDocument.from(t)
            val sb = StringBuilder()
            val ids = ArrayList<CrdtId>()
            val bold = ArrayList<Boolean>()
            val italic = ArrayList<Boolean>()
            val paras = ArrayList<ParaInfo>()
            for ((k, p) in doc.paragraphs.withIndex()) {
                if (k > 0) { sb.append('\n'); ids += p.startId; bold += false; italic += false }
                val start = sb.length
                for (s in p.spans) for ((j, c) in s.s.withIndex()) {
                    // U+2028 is a soft line break inside a paragraph; it is laid out as a space.
                    sb.append(if (c == '\u2028') ' ' else c); ids += s.ids[j]; bold += s.bold; italic += s.italic
                }
                paras += ParaInfo(start, sb.length, p.style, p.startId)
            }
            if (paras.isEmpty()) paras += ParaInfo(0, 0, t.styles[CrdtId.END_MARKER]?.value ?: ParagraphStyle.PLAIN, CrdtId.END_MARKER)
            return TextContent(sb.toString(), ids, bold.toBooleanArray(), italic.toBooleanArray(), paras)
        }
    }
}

/**
 * A typed-text block opened for editing. It holds the character sequence one element per character (live, deleted, or an
 * inline format code), applies edits the way the tablet's CRDT does (new characters get new ids, deleted ones stay as
 * tombstones) and turns itself back into a [Text]. Ids for new elements are taken from [nextCounter] upwards.
 */
class TextBuffer private constructor(
    private val elems: MutableList<Elem>,
    private val styles: MutableMap<CrdtId, Lww<ParagraphStyle>>,
    private val rawStyleCodes: MutableMap<CrdtId, Int>,
    var posX: Double,
    var posY: Double,
    var width: Float,
    private val author: Int,
    var nextCounter: Long,
) {
    private enum class Kind { CHAR, FORMAT, DEAD }
    private class Elem(val id: CrdtId, val kind: Kind, val ch: Char = ' ', val fmt: Int = 0)

    /** True once an edit changed something. */
    var modified = false
        private set

    private var cache: TextContent? = null
    val content: TextContent get() = cache ?: TextContent.from(toText()).also { cache = it }

    private fun newId() = CrdtId(author, nextCounter++)
    private fun changed() { cache = null; modified = true }

    // ---- editing ----

    /**
     * Insert [s] at [offset] with the given typing style. A newline starts a new paragraph that continues a list and
     * otherwise returns to body text. Returns the offset after the inserted text.
     */
    fun insert(offset: Int, s: String, bold: Boolean = false, italic: Boolean = false): Int {
        if (s.isEmpty()) return offset
        val c = content
        val (b0, i0) = states()
        val at = offset.coerceIn(0, c.length)
        var pos = elemIndexAfterVisible(at)
        val nb = ArrayList<Boolean>(b0.toList()); val ni = ArrayList<Boolean>(i0.toList())
        var visible = at
        val startPara = c.paragraphAt(at)
        var curStyle = styleOf(startPara, c)
        // Splitting at the very start of a paragraph pushes its text down and keeps its style.
        var atStart = c.paragraphs[startPara].let { at == it.start && it.length > 0 }
        for (ch in s.replace("\r\n", "\n").replace('\r', '\n')) {
            val e = Elem(newId(), Kind.CHAR, ch)
            elems.add(pos++, e)
            nb.add(visible, bold && ch != '\n'); ni.add(visible, italic && ch != '\n')
            if (ch == '\n') {
                val next = if (atStart) curStyle else styleAfterEnter(curStyle, emptyParagraph = false)
                atStart = false
                styles[e.id] = Lww(newId(), next)
                curStyle = next
            }
            visible++
        }
        ensureLeadingTombstone()
        applyFormats(nb.toBooleanArray(), ni.toBooleanArray())
        changed()
        return visible
    }

    private fun styleOf(para: Int, c: TextContent): ParagraphStyle = c.paragraphs.getOrNull(para)?.style ?: ParagraphStyle.PLAIN

    /** Delete the characters [from] until [to]. */
    fun delete(from: Int, to: Int) {
        val c = content
        val a = from.coerceIn(0, c.length); val b = to.coerceIn(a, c.length)
        if (a == b) return
        val (b0, i0) = states()
        var visible = 0
        for ((idx, e) in elems.withIndex()) {
            if (e.kind != Kind.CHAR) continue
            if (visible in a until b) elems[idx] = Elem(e.id, Kind.DEAD)
            visible++
        }
        val nb = b0.toMutableList().also { it.subList(a, b).clear() }
        val ni = i0.toMutableList().also { it.subList(a, b).clear() }
        ensureLeadingTombstone()
        applyFormats(nb.toBooleanArray(), ni.toBooleanArray())
        changed()
    }

    /** Set the text column: the box is [column] wide and centred on the page. */
    fun setColumn(column: TextColumn) {
        if (column.posX == posX && column.width == width && posY == TextStyles.POS_Y) return
        posX = column.posX; posY = TextStyles.POS_Y; width = column.width
        changed()
    }

    /** Make the paragraph [para] (index into [content].paragraphs) use [style]. */
    fun setParagraphStyle(para: Int, style: ParagraphStyle) {
        val key = content.paragraphs.getOrNull(para)?.key ?: return
        if (styles[key]?.value == style) return
        styles[key] = Lww(newId(), style)
        rawStyleCodes.remove(key)
        changed()
    }

    /** Set bold and / or italic ([null] leaves that one alone) on the characters [from] until [to]. */
    fun setFormat(from: Int, to: Int, bold: Boolean?, italic: Boolean?) {
        val c = content
        val a = from.coerceIn(0, c.length); val b = to.coerceIn(a, c.length)
        val (nb, ni) = states().let { it.first.copyOf() to it.second.copyOf() }
        for (i in a until b) if (c.text[i] != '\n') {
            if (bold != null) nb[i] = bold
            if (italic != null) ni[i] = italic
        }
        applyFormats(nb, ni)
        changed()
    }

    /** Bold / italic state of every visible character as the format codes currently give it. */
    private fun states(): Pair<BooleanArray, BooleanArray> {
        val n = elems.count { it.kind == Kind.CHAR }
        val b = BooleanArray(n); val i = BooleanArray(n)
        var bold = false; var italic = false; var k = 0
        for (e in elems) when (e.kind) {
            Kind.FORMAT -> when (e.fmt) { 1 -> bold = true; 2 -> bold = false; 3 -> italic = true; 4 -> italic = false }
            Kind.CHAR -> { b[k] = bold; i[k] = italic; k++ }
            Kind.DEAD -> Unit
        }
        return b to i
    }

    /** Make the format codes give exactly the wanted states (newlines don't care); untouched when they already do. */
    private fun applyFormats(wantBold: BooleanArray, wantItalic: BooleanArray) {
        val (hb, hi) = states()
        var same = true
        var k = 0
        for (e in elems) if (e.kind == Kind.CHAR) {
            if (e.ch != '\n' && (hb[k] != wantBold[k] || hi[k] != wantItalic[k])) { same = false; break }
            k++
        }
        if (same) return
        for (idx in elems.indices) if (elems[idx].kind == Kind.FORMAT) elems[idx] = Elem(elems[idx].id, Kind.DEAD)
        var bold = false; var italic = false; k = 0
        var idx = 0
        while (idx < elems.size) {
            val e = elems[idx]
            if (e.kind == Kind.CHAR) {
                if (e.ch != '\n') {
                    val codes = ArrayList<Int>(2)
                    if (wantBold[k] != bold) { codes += if (wantBold[k]) 1 else 2; bold = wantBold[k] }
                    if (wantItalic[k] != italic) { codes += if (wantItalic[k]) 3 else 4; italic = wantItalic[k] }
                    for (code in codes) { elems.add(idx, Elem(newId(), Kind.FORMAT, fmt = code)); idx++ }
                }
                k++
            }
            idx++
        }
        changed()
    }

    /** Index in [elems] right after the [n]-th visible character (0 = the very start). */
    private fun elemIndexAfterVisible(n: Int): Int {
        if (n <= 0) return 0
        var seen = 0
        for ((idx, e) in elems.withIndex()) if (e.kind == Kind.CHAR) { seen++; if (seen == n) return idx + 1 }
        return elems.size
    }

    /** A text that starts with a newline would read as "the first paragraph starts here"; a tombstone in front keeps an empty first paragraph. */
    private fun ensureLeadingTombstone() {
        val firstLive = elems.firstOrNull { it.kind == Kind.CHAR } ?: return
        if (firstLive.ch != '\n') return
        val before = elems.subList(0, elems.indexOf(firstLive))
        if (before.none { it.kind == Kind.DEAD }) elems.add(0, Elem(newId(), Kind.DEAD))
    }

    // ---- output ----

    /** The edited text as a block value, chained so that the file order is exactly the order of the elements. */
    fun toText(): Text {
        val items = ArrayList<CrdtSequenceItem<TextValue>>()
        var i = 0
        while (i < elems.size) {
            val first = elems[i]
            var j = i + 1
            if (first.kind != Kind.FORMAT) {
                while (j < elems.size && elems[j].kind == first.kind && elems[j].id.author == first.id.author &&
                    elems[j].id.counter == elems[j - 1].id.counter + 1) j++
            }
            val left = if (i == 0) CrdtId.END_MARKER else elems[i - 1].id
            val right = if (j >= elems.size) CrdtId.END_MARKER else elems[j].id
            val value: TextValue = when (first.kind) {
                Kind.CHAR -> TextValue.Chars(buildString { for (k in i until j) append(elems[k].ch) })
                Kind.FORMAT -> TextValue.Format(first.fmt)
                Kind.DEAD -> TextValue.Chars("")
            }
            items += CrdtSequenceItem(first.id, left, right, if (first.kind == Kind.DEAD) j - i else 0, value)
            i = j
        }
        val live = elems.filter { it.kind == Kind.CHAR && it.ch == '\n' }.mapTo(HashSet()) { it.id }
        val keep = LinkedHashMap<CrdtId, Lww<ParagraphStyle>>()
        for ((k, v) in styles) if (k == CrdtId.END_MARKER || k in live) keep[k] = v
        val raw = rawStyleCodes.filterKeys { it in keep }
        return Text(CrdtSequence(items), keep, posX, posY, width, raw)
    }

    companion object {
        /** Open [t] for editing; a null [t] opens an empty text block at the default place with the given side margin. */
        fun open(t: Text?, author: Int, nextCounter: Long): TextBuffer {
            if (t == null) {
                val c = TextColumn.DEFAULT
                return TextBuffer(ArrayList(), LinkedHashMap(), HashMap(), c.posX, TextStyles.POS_Y, c.width, author, nextCounter)
            }
            val elems = ArrayList<Elem>()
            for (item in TextDocument.expandAll(t)) {
                val v = item.value
                when {
                    item.deletedLength > 0 -> elems += Elem(item.itemId, Kind.DEAD)
                    v is TextValue.Format -> elems += Elem(item.itemId, Kind.FORMAT, fmt = v.code)
                    v is TextValue.Chars && v.s.isNotEmpty() -> elems += Elem(item.itemId, Kind.CHAR, v.s[0])
                    else -> elems += Elem(item.itemId, Kind.DEAD)
                }
            }
            return TextBuffer(elems, LinkedHashMap(t.styles), HashMap(t.unknownStyleCodes), t.posX, t.posY, t.width, author, nextCounter)
        }

        /** Where the first line sits on a new page (the value tablets write). */
        const val DEFAULT_POS_Y = TextStyles.POS_Y

        fun styleAfterEnter(style: ParagraphStyle, emptyParagraph: Boolean): ParagraphStyle = when (style) {
            ParagraphStyle.HEADING, ParagraphStyle.BOLD, ParagraphStyle.BASIC -> ParagraphStyle.PLAIN
            ParagraphStyle.CHECKBOX_CHECKED -> ParagraphStyle.CHECKBOX
            else -> style
        }
    }
}
