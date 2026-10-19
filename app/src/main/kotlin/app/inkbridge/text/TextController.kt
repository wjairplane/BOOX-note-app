package app.inkbridge.text

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import app.inkbridge.PageSession
import app.inkbridge.rm.scene.ParagraphStyle
import app.inkbridge.rm.text.TextBuffer
import app.inkbridge.rm.text.TextContent
import app.inkbridge.rm.text.TextLayout
import app.inkbridge.rm.text.TextColumn
import kotlin.math.max
import kotlin.math.min

/**
 * The state of the typed-text tool on one page: the caret and selection, the style the next typed character gets, and the
 * edits (typing, deleting, paragraph styles, bold / italic, indent) that go to the page through [PageSession.editText].
 * Offsets are indices into [TextContent.text]. The input method and hardware keys both come in through here.
 */
class TextController(private val session: PageSession) {
    /** Bumped on every change, so that views reading the controller recompose. */
    var version by mutableIntStateOf(0)
        private set

    var caret by mutableIntStateOf(0)
        private set

    /** The other end of the selection; equal to [caret] when nothing is selected. */
    var anchor by mutableIntStateOf(0)
        private set

    /** Style of the next typed characters. */
    var typingBold by mutableStateOf(false)
        private set
    var typingItalic by mutableStateOf(false)
        private set

    /** The little menu that opens when the caret itself is tapped (select all, paste). */
    var caretMenu by mutableStateOf(false)
        private set

    /** The format menu next to the paragraph is folded out. */
    var menuOpen by mutableStateOf(false)

    fun closeCaretMenu() { caretMenu = false }

    /** The input method's composing region (autocorrect candidates), or empty. */
    private var composeFrom = 0
    private var composeTo = 0

    val layout: TextLayout? get() = session.textLayout
    val content: TextContent get() = layout?.content ?: TextContent.EMPTY
    val hasSelection: Boolean get() = anchor != caret
    val selStart: Int get() = min(anchor, caret)
    val selEnd: Int get() = max(anchor, caret)
    val hasText: Boolean get() = content.length > 0

    /** The paragraph that holds the caret. */
    val paragraph: Int get() = content.paragraphAt(caret)
    val paragraphStyle: ParagraphStyle get() = content.paragraphs.getOrNull(paragraph)?.style ?: ParagraphStyle.PLAIN

    /** Counts the edits that changed the page, so the screen knows when its picture of the page is out of date. */
    var editCount by mutableIntStateOf(0)
        private set

    private fun touch() { version++ }

    private fun edit(merge: Boolean = false, f: (TextBuffer) -> Unit): Boolean {
        return session.editText(merge, f).also { if (it) editCount++ }
    }

    private companion object { const val TYPING_PAUSE_MS = 1500L }

    /** Start from the end of the text (the toolbar's "Add text" / "Edit text"). */
    fun placeAtEnd() { moveTo(content.length, false) }

    private fun clamp(o: Int) = o.coerceIn(0, content.length)

    // ---- caret and selection ----

    fun moveTo(offset: Int, extend: Boolean) {
        mergeTyping = false
        session.endTextRun()
        caret = clamp(offset)
        if (!extend) anchor = caret
        endComposing()
        syncTypingStyle()
        touch()
    }

    /** The page has changed under the controller (undo, redo, another edit): keep the caret inside the text. */
    fun refresh() {
        clamp()
        endComposing()
        touch()
    }

    /** Keep the caret inside the text without announcing a change. */
    fun clamp() { caret = clamp(caret); anchor = clamp(anchor) }

    fun selectWord(offset: Int) { val r = content.wordAt(offset); anchor = r.first; caret = r.last + 1; syncTypingStyle(); touch() }

    fun selectParagraph(offset: Int) {
        val p = content.paragraphs.getOrNull(content.paragraphAt(offset)) ?: return
        anchor = p.start; caret = p.end; touch()
    }

    fun selectAll() { anchor = 0; caret = content.length; touch() }

    fun moveHorizontal(delta: Int, extend: Boolean) {
        val target = if (hasSelection && !extend) (if (delta < 0) selStart else selEnd) else clamp(caret + delta)
        moveTo(target, extend)
    }

    fun moveVertical(up: Boolean, extend: Boolean) {
        val l = layout ?: return
        val x = l.caret(caret).x
        moveTo(l.offsetVertical(caret, up, x), extend)
    }

    fun moveToLineEdge(end: Boolean, extend: Boolean) {
        val l = layout ?: return
        moveTo(if (end) l.lineEnd(caret) else l.lineStart(caret), extend)
    }

    fun moveWord(forward: Boolean, extend: Boolean) {
        val t = content.text
        var o = caret
        if (forward) { while (o < t.length && !t[o].isLetterOrDigit()) o++; while (o < t.length && t[o].isLetterOrDigit()) o++ }
        else { while (o > 0 && !t[o - 1].isLetterOrDigit()) o--; while (o > 0 && t[o - 1].isLetterOrDigit()) o-- }
        moveTo(o, extend)
    }

    private fun syncTypingStyle() {
        val c = content
        // Typing continues the style of the character before the caret; at the start of a paragraph, that of its first character.
        val atParagraphStart = caret == 0 || c.text.getOrNull(caret - 1) == '\n'
        val j = if (atParagraphStart) caret else caret - 1
        typingBold = c.bold.getOrElse(j) { false }
        typingItalic = c.italic.getOrElse(j) { false }
    }

    // ---- typing ----

    private fun endComposing() { composeFrom = 0; composeTo = 0 }

    // Typing a run of characters is one undo step; moving the caret or pausing starts a new one.
    private var mergeTyping = false
    private var lastTypedAt = 0L

    /** Replace [from] until [to] by [s] and put the caret after it. */
    private fun replace(from: Int, to: Int, s: String, merge: Boolean = true) {
        var after = from
        val now = android.os.SystemClock.uptimeMillis()
        // A pause or a caret move ends the run of typing that shares an undo step.
        if (!(merge && mergeTyping && now - lastTypedAt < TYPING_PAUSE_MS)) session.endTextRun()
        val changed = edit(merge) { b ->
            if (to > from) b.delete(from, to)
            after = if (s.isNotEmpty()) b.insert(from, s, typingBold, typingItalic) else from
        }
        if (changed) { caret = after; anchor = after }
        mergeTyping = merge && changed; lastTypedAt = now
        touch()
    }

    /** Text the input method committed (or the hardware keyboard typed). */
    fun commit(s: String) {
        if (s.isEmpty()) return
        if (s == "\n") { enter(); return }
        val from = if (composeTo > composeFrom) composeFrom else selStart
        val to = if (composeTo > composeFrom) composeTo else selEnd
        endComposing()
        replace(from, to, s)
    }

    /** The input method's composing text, which it keeps replacing until it commits. */
    fun compose(s: String) {
        val from = if (composeTo > composeFrom) composeFrom else selStart
        val to = if (composeTo > composeFrom) composeTo else selEnd
        replace(from, to, s)
        composeFrom = from; composeTo = from + s.length
    }

    fun finishComposing() = endComposing()

    fun enter() {
        endComposing()
        val p = content.paragraphs.getOrNull(paragraph)
        // Enter on an empty list item ends the list.
        if (!hasSelection && p != null && p.length == 0 && p.style.isList()) { setStyle(ParagraphStyle.PLAIN); return }
        replace(selStart, selEnd, "\n")
    }

    fun backspace() {
        endComposing()
        if (hasSelection) { replace(selStart, selEnd, ""); return }
        if (caret == 0) return
        val p = content.paragraphs.getOrNull(paragraph)
        // Backspace at the start of a styled paragraph first removes its style.
        if (p != null && p.start == caret && p.style != ParagraphStyle.PLAIN && p.style != ParagraphStyle.BASIC) { setStyle(ParagraphStyle.PLAIN); return }
        replace(caret - 1, caret, "")
    }

    fun deleteForward() {
        endComposing()
        if (hasSelection) { replace(selStart, selEnd, ""); return }
        if (caret >= content.length) return
        replace(caret, caret + 1, "")
    }

    /** Delete [before] characters before and [after] after the caret (what the input method asks for). */
    fun deleteAround(before: Int, after: Int) {
        endComposing()
        if (hasSelection) { replace(selStart, selEnd, ""); return }
        val a = clamp(caret - before); val b = clamp(caret + after)
        if (b > a) replace(a, b, "")
    }

    // ---- paragraph styles and character formats ----

    private fun ParagraphStyle.isList() = this == ParagraphStyle.BULLET || this == ParagraphStyle.BULLET2 || this == ParagraphStyle.NUMBERED ||
        this == ParagraphStyle.CHECKBOX || this == ParagraphStyle.CHECKBOX_CHECKED

    private fun selectedParagraphs(): IntRange = content.paragraphAt(selStart)..content.paragraphAt(selEnd)

    /** Give the paragraphs under the caret / selection [style]. */
    fun setStyle(style: ParagraphStyle) {
        val range = selectedParagraphs()
        val changed = edit { b -> for (p in range) b.setParagraphStyle(p, style) }
        if (!changed && !hasText) {
            // No text yet: a style chosen on an empty page makes the first paragraph carry it.
            edit { b -> b.setParagraphStyle(0, style) }
        }
        touch()
    }

    /** The firmware's menu buttons toggle: choosing the style the paragraph already has goes back to body text. */
    fun cycleStyle(style: ParagraphStyle) {
        val all = selectedParagraphs().all { content.paragraphs.getOrNull(it)?.style == style }
        setStyle(if (all) ParagraphStyle.PLAIN else style)
    }

    fun isStyle(style: ParagraphStyle): Boolean = content.paragraphs.getOrNull(paragraph)?.style == style

    /** Is every selected character (or the character before the caret) bold? */
    val isBold: Boolean get() = if (hasSelection) (selStart until selEnd).all { content.text[it] == '\n' || content.bold[it] } else typingBold
    val isItalic: Boolean get() = if (hasSelection) (selStart until selEnd).all { content.text[it] == '\n' || content.italic[it] } else typingItalic

    fun toggleBold() {
        if (!hasSelection) { typingBold = !typingBold; touch(); return }
        val on = !isBold
        edit { it.setFormat(selStart, selEnd, bold = on, italic = null) }
        touch()
    }

    fun toggleItalic() {
        if (!hasSelection) { typingItalic = !typingItalic; touch(); return }
        val on = !isItalic
        edit { it.setFormat(selStart, selEnd, bold = null, italic = on) }
        touch()
    }

    /** Tab / Shift+Tab: move a list item one level in or out. */
    fun indent(deeper: Boolean) {
        val range = selectedParagraphs()
        edit { b ->
            for (p in range) {
                val s = content.paragraphs.getOrNull(p)?.style ?: continue
                val next = when {
                    deeper && s == ParagraphStyle.BULLET -> ParagraphStyle.BULLET2
                    !deeper && s == ParagraphStyle.BULLET2 -> ParagraphStyle.BULLET
                    else -> null
                }
                if (next != null) b.setParagraphStyle(p, next)
            }
        }
        touch()
    }

    /** The column the page's text is in (the medium one on a page without text); null for a custom width. */
    val column: TextColumn? get() = TextColumn.ofWidth(session.textLayout?.width ?: TextColumn.DEFAULT.width)

    /** Choose a text column. Like the firmware, this does nothing before the page has text. One undo step. */
    fun setColumn(c: TextColumn) {
        if (!hasText && session.textLayout == null) return
        edit { it.setColumn(c) }
        touch()
    }

    /** Tap on a check box: tick or untick it. */
    fun toggleCheckbox(para: Int) {
        val s = content.paragraphs.getOrNull(para)?.style ?: return
        val next = if (s == ParagraphStyle.CHECKBOX) ParagraphStyle.CHECKBOX_CHECKED else ParagraphStyle.CHECKBOX
        edit { it.setParagraphStyle(para, next) }
        touch()
    }

    // ---- clipboard ----

    fun selectedText(): String = if (hasSelection) content.text.substring(selStart, selEnd) else ""

    fun cut(): String = selectedText().also { if (it.isNotEmpty()) replace(selStart, selEnd, "") }

    fun paste(s: String) = commit(s)

    // ---- undo ----

    fun undo(): Boolean = session.undo().also { if (it) { editCount++; refresh() } }
    fun redo(): Boolean = session.redo().also { if (it) { editCount++; refresh() } }

    /** Text before / after the caret, for the input method's context. */
    fun before(n: Int): String = content.text.substring(max(0, caret - n), caret)
    fun after(n: Int): String = content.text.substring(caret, min(content.length, caret + n))

    // ---- touch ----

    /** The text offset at a view-pixel point, or null when the page has no transform yet. */
    fun offsetAtView(vx: Float, vy: Float): Int? {
        val t = session.transform ?: return null
        val l = layout ?: return 0
        return l.offsetAt(t.toPageX(vx), t.toPageY(vy))
    }

    /** Is the view-pixel point in the text block (with [margin] page units around it)? An empty page counts as all text block. */
    fun isInTextArea(vx: Float, vy: Float, margin: Float): Boolean {
        val t = session.transform ?: return false
        val l = layout ?: return true
        val x = t.toPageX(vx); val y = t.toPageY(vy)
        return l.contains(x, y, margin)
    }

    /** [taps] taps in a row at the view-pixel point: caret, word, paragraph, everything. */
    fun tap(vx: Float, vy: Float, taps: Int, caretSlop: Float = 40f) {
        val t = session.transform ?: return
        val l = layout
        val wasMenu = caretMenu
        caretMenu = false
        menuOpen = false
        if (taps == 1 && l != null && !hasSelection) {
            // A tap on the caret itself opens its menu.
            val c = l.caret(caret)
            if (kotlin.math.abs(vx - t.toViewX(c.x)) <= caretSlop && vy in (t.toViewY(c.top) - caretSlop)..(t.toViewY(c.bottom) + caretSlop * 1.5f)) {
                caretMenu = !wasMenu; touch(); return
            }
        }
        if (l != null && taps == 1) {
            l.checkboxAt(t.toPageX(vx), t.toPageY(vy))?.let { toggleCheckbox(it); return }
        }
        val o = offsetAtView(vx, vy) ?: return
        when (taps) {
            1 -> moveTo(o, false)
            2 -> selectWord(o)
            3 -> selectParagraph(o)
            else -> selectAll()
        }
    }

    /** Drag from the caret: extend the selection to the point (the handle in the firmware moves the caret). */
    fun dragTo(vx: Float, vy: Float, extend: Boolean) {
        val o = offsetAtView(vx, vy) ?: return
        moveTo(o, extend)
    }
}
