package app.inkbridge.text

import android.content.Context
import android.text.InputType
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.BaseInputConnection
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import app.inkbridge.rm.scene.ParagraphStyle

/**
 * An invisible view that is the text tool's input target: the system keyboard (soft or hardware) talks to it, and it hands
 * what it receives to the [controller]. The page itself is drawn by the app, so the view only has to exist and hold focus.
 */
class TextInputView(context: Context) : View(context) {
    var controller: TextController? = null

    /** The clipboard, for Ctrl+C / X / V on a hardware keyboard. */
    var onClipboardCopy: ((String) -> Unit)? = null
    var onClipboardPaste: (() -> String?)? = null

    init {
        isFocusable = true
        isFocusableInTouchMode = true
    }

    override fun onCheckIsTextEditor(): Boolean = true

    override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection {
        outAttrs.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_MULTI_LINE or InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
        outAttrs.imeOptions = EditorInfo.IME_FLAG_NO_FULLSCREEN or EditorInfo.IME_FLAG_NO_EXTRACT_UI or EditorInfo.IME_ACTION_NONE
        return Connection(this)
    }

    fun showKeyboard() {
        requestFocus()
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
        imm?.showSoftInput(this, 0)
    }

    fun hideKeyboard() {
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
        imm?.hideSoftInputFromWindow(windowToken, 0)
    }

    private inner class Connection(view: View) : BaseInputConnection(view, false) {
        override fun commitText(text: CharSequence?, newCursorPosition: Int): Boolean {
            val c = controller ?: return false
            c.finishComposing()
            if (!text.isNullOrEmpty()) c.commit(text.toString())
            return true
        }

        override fun setComposingText(text: CharSequence?, newCursorPosition: Int): Boolean {
            controller?.compose(text?.toString().orEmpty())
            return true
        }

        override fun finishComposingText(): Boolean { controller?.finishComposing(); return true }
        override fun setComposingRegion(start: Int, end: Int): Boolean = true
        override fun setSelection(start: Int, end: Int): Boolean = true

        override fun deleteSurroundingText(beforeLength: Int, afterLength: Int): Boolean {
            controller?.deleteAround(beforeLength, afterLength)
            return true
        }

        override fun getTextBeforeCursor(n: Int, flags: Int): CharSequence = controller?.before(n).orEmpty()
        override fun getTextAfterCursor(n: Int, flags: Int): CharSequence = controller?.after(n).orEmpty()
        override fun getSelectedText(flags: Int): CharSequence? = controller?.selectedText()?.takeIf { it.isNotEmpty() }

        override fun performEditorAction(editorAction: Int): Boolean { controller?.enter(); return true }

        override fun sendKeyEvent(event: KeyEvent): Boolean {
            if (event.action == KeyEvent.ACTION_DOWN) return handleKey(event.keyCode, event)
            return true
        }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean = handleKey(keyCode, event) || super.onKeyDown(keyCode, event)

    /** Hardware keyboard and the keys an input method sends as events. */
    private fun handleKey(keyCode: Int, event: KeyEvent): Boolean {
        val c = controller ?: return false
        val ctrl = event.isCtrlPressed || event.isMetaPressed
        val shift = event.isShiftPressed
        if (ctrl) {
            when (keyCode) {
                KeyEvent.KEYCODE_A -> c.selectAll()
                KeyEvent.KEYCODE_B -> c.toggleBold()
                KeyEvent.KEYCODE_I -> c.toggleItalic()
                KeyEvent.KEYCODE_Z -> if (shift) c.redo() else c.undo()
                KeyEvent.KEYCODE_Y -> c.redo()
                KeyEvent.KEYCODE_C -> onClipboardCopy?.invoke(c.selectedText())
                KeyEvent.KEYCODE_X -> onClipboardCopy?.invoke(c.cut())
                KeyEvent.KEYCODE_V -> onClipboardPaste?.invoke()?.let { c.paste(it) }
                KeyEvent.KEYCODE_DPAD_LEFT -> c.moveWord(false, shift)
                KeyEvent.KEYCODE_DPAD_RIGHT -> c.moveWord(true, shift)
                // The firmware's style shortcuts: 1 title, 2 subheading, 3 body text, 4 bullet points, 5 checkbox.
                KeyEvent.KEYCODE_1 -> c.cycleStyle(ParagraphStyle.HEADING)
                KeyEvent.KEYCODE_2 -> c.cycleStyle(ParagraphStyle.BOLD)
                KeyEvent.KEYCODE_3 -> c.setStyle(ParagraphStyle.PLAIN)
                KeyEvent.KEYCODE_4 -> c.cycleStyle(ParagraphStyle.BULLET)
                KeyEvent.KEYCODE_5 -> c.cycleStyle(ParagraphStyle.CHECKBOX)
                else -> return false
            }
            return true
        }
        when (keyCode) {
            KeyEvent.KEYCODE_DEL -> c.backspace()
            KeyEvent.KEYCODE_FORWARD_DEL -> c.deleteForward()
            KeyEvent.KEYCODE_ENTER, KeyEvent.KEYCODE_NUMPAD_ENTER -> c.enter()
            KeyEvent.KEYCODE_TAB -> c.indent(deeper = !shift)
            KeyEvent.KEYCODE_DPAD_LEFT -> c.moveHorizontal(-1, shift)
            KeyEvent.KEYCODE_DPAD_RIGHT -> c.moveHorizontal(1, shift)
            KeyEvent.KEYCODE_DPAD_UP -> c.moveVertical(true, shift)
            KeyEvent.KEYCODE_DPAD_DOWN -> c.moveVertical(false, shift)
            KeyEvent.KEYCODE_MOVE_HOME -> c.moveToLineEdge(false, shift)
            KeyEvent.KEYCODE_MOVE_END -> c.moveToLineEdge(true, shift)
            KeyEvent.KEYCODE_SPACE -> c.commit(" ")
            else -> {
                val ch = event.unicodeChar
                if (ch <= 0 || event.isAltPressed || ch and KeyCharacterMapCombining != 0) return false
                c.commit(String(Character.toChars(ch)))
            }
        }
        return true
    }

    private companion object {
        const val KeyCharacterMapCombining = android.view.KeyCharacterMap.COMBINING_ACCENT
    }
}
