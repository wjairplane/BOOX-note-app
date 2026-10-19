package app.inkbridge

import android.os.SystemClock
import android.view.MotionEvent
import app.inkbridge.rm.edit.PageEditor
import app.inkbridge.rm.scene.ParagraphStyle
import app.inkbridge.rm.text.TextContent
import app.inkbridge.text.TextController
import app.inkbridge.text.TextTapDetector
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.io.File

/** The text tool's editing behaviour on a page session: typing, deleting, styles, formats, selection, undo, saving. */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34])
class TextControllerTest {
    @get:Rule val tmp = TemporaryFolder()

    private fun open(): Triple<PageSession, TextController, File> {
        val f = tmp.newFile("page.rm").also { it.writeBytes(PageEditor.blank().toBytes()) }
        val s = PageSession(f).also { it.resize(1404, 1872) }
        return Triple(s, TextController(s), f)
    }

    private fun reloaded(f: File) = TextContent.from(PageEditor.fromBytes(f.readBytes()).rootText)

    @Test fun typingDeletingAndSavingKeepTheText() {
        val (s, c, f) = open()
        c.commit("Hello")
        c.commit(" world")
        assertEquals("Hello world", c.content.text)
        assertEquals(11, c.caret)
        c.backspace(); c.backspace()
        assertEquals("Hello wor", c.content.text)
        c.moveHorizontal(-4, false)
        c.commit("X")
        assertEquals("HelloX wor", c.content.text)
        s.save()
        assertEquals("HelloX wor", reloaded(f).text)
    }

    @Test fun typingIsOneUndoStepAndUndoRestoresThePage() {
        val (s, c, _) = open()
        for (ch in "abc") c.commit(ch.toString())
        assertEquals("abc", c.content.text)
        assertTrue(c.undo())
        assertEquals("", c.content.text)
        assertTrue(c.redo())
        assertEquals("abc", c.content.text)
        assertTrue(s.canUndo)
    }

    @Test fun enterContinuesListsAndAnEmptyItemEndsThem() {
        val (_, c, f) = open()
        c.commit("Title"); c.setStyle(ParagraphStyle.HEADING)
        c.enter()
        assertEquals(ParagraphStyle.PLAIN, c.paragraphStyle)
        c.cycleStyle(ParagraphStyle.BULLET)
        c.commit("one"); c.enter(); c.commit("two"); c.enter()
        assertEquals(listOf(ParagraphStyle.HEADING, ParagraphStyle.BULLET, ParagraphStyle.BULLET, ParagraphStyle.BULLET), c.content.paragraphs.map { it.style })
        c.enter() // empty item: the list ends
        assertEquals(ParagraphStyle.PLAIN, c.paragraphStyle)
        assertEquals("Title\none\ntwo\n", c.content.text)
        // Tab on a bullet makes it a sub-item; again, back.
        c.moveTo(7, false)
        c.indent(true)
        assertEquals(ParagraphStyle.BULLET2, c.paragraphStyle)
        c.indent(false)
        assertEquals(ParagraphStyle.BULLET, c.paragraphStyle)
        // Backspace at the start of a list item removes the bullet before it joins lines.
        c.moveTo(c.content.paragraphs[2].start, false)
        c.backspace()
        assertEquals(ParagraphStyle.PLAIN, c.paragraphStyle)
        assertEquals("Title\none\ntwo\n", c.content.text)
    }

    @Test fun boldAndItalicApplyToTheSelectionOrToWhatIsTypedNext() {
        val (s, c, f) = open()
        c.commit("plain ")
        c.toggleBold()
        c.commit("heavy")
        c.toggleBold(); c.toggleItalic()
        c.commit(" slanted")
        var t = c.content
        assertEquals((6 until 11).toList(), t.bold.indices.filter { t.bold[it] })
        assertEquals((11 until 19).toList(), t.italic.indices.filter { t.italic[it] })
        // Select a word and make it bold.
        c.selectWord(1)
        assertEquals("plain", c.selectedText())
        c.toggleBold()
        t = c.content
        assertEquals((0 until 5) + (6 until 11), t.bold.indices.filter { t.bold[it] })
        s.save()
        val saved = reloaded(f)
        assertEquals(t.bold.toList(), saved.bold.toList())
        assertEquals(t.italic.toList(), saved.italic.toList())
    }

    @Test fun selectionByWordParagraphAndAllAndReplacingIt() {
        val (_, c, _) = open()
        c.commit("one two\nthree four")
        c.selectWord(5)
        assertEquals("two", c.selectedText())
        c.selectParagraph(10)
        assertEquals("three four", c.selectedText())
        c.selectAll()
        assertEquals("one two\nthree four", c.selectedText())
        c.commit("x")
        assertEquals("x", c.content.text)
        assertEquals(1, c.caret)
    }

    @Test fun composingTextIsReplacedUntilCommitted() {
        val (_, c, _) = open()
        c.compose("he"); c.compose("hel"); c.compose("hello")
        assertEquals("hello", c.content.text)
        c.commit("hello ")
        assertEquals("hello ", c.content.text)
        c.compose("wo")
        assertEquals("hello wo", c.content.text)
    }

    @Test fun checkboxesToggleWhenTapped() {
        val (s, c, _) = open()
        c.commit("buy milk"); c.cycleStyle(ParagraphStyle.CHECKBOX)
        val l = s.textLayout!!
        val line = l.lines.first()
        val t = s.transform!!
        c.tap(t.toViewX(line.markerX + 5f), t.toViewY(line.baseline - 10f), 1)
        assertEquals(ParagraphStyle.CHECKBOX_CHECKED, c.paragraphStyle)
        c.tap(t.toViewX(line.markerX + 5f), t.toViewY(line.baseline - 10f), 1)
        assertEquals(ParagraphStyle.CHECKBOX, c.paragraphStyle)
    }

    @Test fun tapsPlaceTheCaretAndCountMultiTaps() {
        val (s, c, _) = open()
        c.commit("alpha beta gamma")
        val t = s.transform!!
        val l = s.textLayout!!
        val line = l.lines.first()
        val x = t.toViewX(l.xOf(line, 8)); val y = t.toViewY(line.baseline - 10f)
        c.tap(x, y, 1)
        assertEquals(8, c.caret)
        c.tap(x, y, 2)
        assertEquals("beta", c.selectedText())
        c.tap(x, y, 4)
        assertEquals("alpha beta gamma", c.selectedText())

        // The detector counts taps within 300 ms and 0.6 cm.
        val got = ArrayList<Int>()
        val d = TextTapDetector(100f) { _, _, n -> got += n }
        fun tap(at: Long, x: Float) {
            fun ev(action: Int, t: Long): MotionEvent {
                val p = arrayOf(MotionEvent.PointerProperties().apply { id = 0; toolType = MotionEvent.TOOL_TYPE_FINGER })
                val co = arrayOf(MotionEvent.PointerCoords().apply { this.x = x; this.y = 50f })
                return MotionEvent.obtain(at, t, action, 1, p, co, 0, 0, 1f, 1f, 0, 0, 0, 0)
            }
            d.onTouch(ev(MotionEvent.ACTION_DOWN, at)); d.onTouch(ev(MotionEvent.ACTION_UP, at + 50))
        }
        val t0 = SystemClock.uptimeMillis()
        tap(t0, 10f); tap(t0 + 200, 20f); tap(t0 + 400, 30f); tap(t0 + 600, 30f); tap(t0 + 800, 30f)  // 1,2,3,4 then 1
        tap(t0 + 2000, 10f); tap(t0 + 2500, 12f)                                            // too slow: 1, 1
        tap(t0 + 3000, 10f); tap(t0 + 3200, 200f)                                           // too far: 1, 1
        assertEquals(listOf(1, 2, 3, 4, 1, 1, 1, 1, 1), got)
    }
}
