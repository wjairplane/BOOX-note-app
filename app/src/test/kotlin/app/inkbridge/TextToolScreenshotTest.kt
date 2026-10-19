package app.inkbridge

import android.app.Application
import android.os.SystemClock
import android.view.InputDevice
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import androidx.activity.ComponentActivity
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.foundation.layout.fillMaxSize
import app.inkbridge.pen.PenSurface
import app.inkbridge.rm.edit.InputPoint
import app.inkbridge.rm.edit.PageEditor
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.library.LibraryOps
import app.inkbridge.rm.library.LibraryScanner
import app.inkbridge.rm.library.PageFiles
import app.inkbridge.rm.render.PageTemplate
import app.inkbridge.rm.scene.ParagraphStyle
import app.inkbridge.rm.text.TextContent
import app.inkbridge.rm.text.TextSettings
import app.inkbridge.text.TextInputView
import app.inkbridge.ui.InkBridgeApp
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.io.File

/** The typed-text tool on screen: text on a page, the typing foldout and format menu, typing, and the Text settings. PNGs go to build/ui-snapshots. */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w702dp-h936dp-xhdpi")
class TextToolScreenshotTest {
    @get:Rule val rule = createAndroidComposeRule<ComponentActivity>()

    @After fun resetSettings() { TextSettings.current = TextSettings.DEFAULT }

    private fun snapshot(name: String) {
        val decor = rule.activity.window.decorView
        val bmp = android.graphics.Bitmap.createBitmap(decor.width.coerceAtLeast(1), decor.height.coerceAtLeast(1), android.graphics.Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(bmp)
        decor.draw(canvas)
        // The page lives on a SurfaceView, which a view capture leaves out: lay its bitmap under the Compose layers.
        findSurface(decor)?.let { v ->
            val bitmap = v.shownBitmap ?: return@let
            val at = IntArray(2).also { v.getLocationInWindow(it) }
            canvas.drawBitmap(bitmap, at[0].toFloat(), at[1].toFloat(), android.graphics.Paint().apply { xfermode = android.graphics.PorterDuffXfermode(android.graphics.PorterDuff.Mode.DARKEN) })
        }
        runCatching {
            val wmg = Class.forName("android.view.WindowManagerGlobal")
            val global = wmg.getMethod("getInstance").invoke(null)
            val names = wmg.getMethod("getViewRootNames").invoke(global) as Array<*>
            for (n in names) {
                val root = wmg.getMethod("getRootView", String::class.java).invoke(global, n) as? View ?: continue
                if (root === decor || root.width == 0 || root.height == 0) continue
                val lp = root.layoutParams as? android.view.WindowManager.LayoutParams
                canvas.save()
                canvas.translate((lp?.x ?: 0).toFloat(), (lp?.y ?: 0).toFloat())
                root.draw(canvas)
                canvas.restore()
            }
        }
        val out = File("build/ui-snapshots").apply { mkdirs() }
        File(out, "$name.png").outputStream().use { bmp.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, it) }
    }

    private fun settle() = repeat(14) { Thread.sleep(120); rule.mainClock.advanceTimeBy(100); rule.waitForIdle() }

    private fun findSurface(v: View): PenSurface? =
        if (v is PenSurface) v else (v as? ViewGroup)?.let { g -> (0 until g.childCount).firstNotNullOfOrNull { findSurface(g.getChildAt(it)) } }

    private fun findInput(v: View): TextInputView? =
        if (v is TextInputView) v else (v as? ViewGroup)?.let { g -> (0 until g.childCount).firstNotNullOfOrNull { findInput(g.getChildAt(it)) } }

    /** A notebook whose first page has typed text in every paragraph style, a bold and an italic word, and a pen stroke. */
    private fun launch(withText: Boolean = true): Pair<AppController, String> {
        val ctx = RuntimeEnvironment.getApplication() as Application
        AndroidPageCanvas.installFonts(ctx)
        val store = LibraryStore(ctx)
        val d = store.dir
        val id = LibraryOps.createNotebook(d, "Typed notes", "", PageTemplate.BLANK)
        val pageId = d.listFiles { f -> f.name == "$id.content" }!!.single().readText().substringAfter("\"pages\":[\"").substringBefore("\"")
        val ed = PageEditor.blank()
        if (withText) {
            val body = "Meeting notes\nAgenda for the week\nThe quick brown fox jumps over the lazy dog, and then it keeps running through the long field until the text has to wrap onto a second line.\nFirst item\nSecond item with some more words so that it wraps around the end of the line as well\nOne\nTwo\nTodo\nDone"
            ed.editText { it.insert(0, body) }
            val c = TextContent.from(ed.rootText)
            ed.editText { b ->
                b.setParagraphStyle(0, ParagraphStyle.HEADING)
                b.setParagraphStyle(1, ParagraphStyle.BOLD)
                b.setParagraphStyle(3, ParagraphStyle.BULLET)
                b.setParagraphStyle(4, ParagraphStyle.BULLET)
                b.setParagraphStyle(5, ParagraphStyle.NUMBERED)
                b.setParagraphStyle(6, ParagraphStyle.NUMBERED)
                b.setParagraphStyle(7, ParagraphStyle.CHECKBOX)
                b.setParagraphStyle(8, ParagraphStyle.CHECKBOX_CHECKED)
                val q = c.text.indexOf("quick brown"); b.setFormat(q, q + 11, bold = true, italic = null)
                val f = c.text.indexOf("lazy dog"); b.setFormat(f, f + 8, bold = null, italic = true)
            }
            ed.addStroke(PenSpec(PenTool.FINELINER, thickness = 2), (0..40).map { InputPoint(-300f + it * 14, 1200f + Math.sin(it / 4.0).toFloat() * 30, 0.6f, 0f, 0f, it * 5L) })
        }
        PageFiles.save(File(File(d, id), "$pageId.rm"), ed.toBytes())
        val app = AppController(store, Prefs(ctx), kotlinx.coroutines.MainScope())
        rule.setContent { InkBridgeApp(store, Prefs(ctx), app) }
        settle()
        val nb = app.library.entries.first { it.name == "Typed notes" }
        rule.runOnUiThread { app.prefs.toolbarPosition = ToolbarPosition.LEFT; app.screen = Screen.Notebook(nb.id, 0) }
        settle()
        return app to id
    }

    private fun fingerTap(x: Float, y: Float, t0: Long = SystemClock.uptimeMillis()) {
        val view = findSurface(rule.activity.window.decorView)!!
        fun event(action: Int, t: Long): MotionEvent {
            val props = arrayOf(MotionEvent.PointerProperties().apply { id = 0; toolType = MotionEvent.TOOL_TYPE_FINGER })
            val coords = arrayOf(MotionEvent.PointerCoords().apply { this.x = x; this.y = y; pressure = 1f; size = 1f })
            return MotionEvent.obtain(t0, t, action, 1, props, coords, 0, 0, 1f, 1f, 0, 0, InputDevice.SOURCE_TOUCHSCREEN, 0)
        }
        rule.runOnUiThread {
            view.dispatchTouchEvent(event(MotionEvent.ACTION_DOWN, t0))
            view.dispatchTouchEvent(event(MotionEvent.ACTION_UP, t0 + 40))
        }
    }

    @Test fun textOnAPage() {
        launch()
        snapshot("text_on_page")
    }

    @Test fun typingFoldoutFormatMenuAndTyping() {
        val (app, id) = launch(withText = false)
        rule.onNodeWithContentDescription("Typing").performClick(); settle(); snapshot("text_typing_foldout")
        rule.onNodeWithText("Add text").performClick(); settle()
        val input = findInput(rule.activity.window.decorView)!!
        val ic = input.onCreateInputConnection(EditorInfo())!!
        rule.runOnUiThread {
            ic.commitText("Shopping", 1)
            ic.commitText("\n", 1)
            ic.commitText("Milk and eggs", 1)
        }
        settle(); snapshot("text_typed")
        // The soft keyboard's bar sets the styles: the first paragraph becomes the title, the second a check box.
        val c = input.controller!!
        rule.runOnUiThread { c.moveTo(0, false) }; settle()
        rule.onNodeWithContentDescription("Title").performClick(); settle()
        rule.runOnUiThread { c.moveTo(c.content.length, false) }; settle()
        rule.onNodeWithContentDescription("Checkbox").performClick(); settle(); snapshot("text_title_and_checkbox")

        // Triple tap on the second line selects the paragraph.
        val surface = findSurface(rule.activity.window.decorView)!!
        val t = surface.listenerForTest()
        assertTrue(t != null)
        // Leaving the page saves the text.
        rule.onNodeWithContentDescription("Selection tool").performClick(); settle()
        rule.onNodeWithContentDescription("Close notebook").performClick(); settle()
        val nb = app.library[id]!!
        val file = LibraryScanner.pageFile(app.store.dir, nb, 0)
        val saved = TextContent.from(PageEditor.fromBytes(file.readBytes()).rootText)
        assertEquals("Shopping\nMilk and eggs", saved.text)
        assertEquals(ParagraphStyle.HEADING, saved.paragraphs[0].style)
        assertEquals(ParagraphStyle.CHECKBOX, saved.paragraphs[1].style)
    }

    /** The format menu that sits beside the paragraph when no soft keyboard is up (a hardware keyboard), on its own over a page. */
    @Test fun floatingFormatMenu() {
        val ctx = RuntimeEnvironment.getApplication() as Application
        AndroidPageCanvas.installFonts(ctx)
        val file = File(ctx.cacheDir, "float.rm")
        val ed = PageEditor.blank()
        ed.editText { it.insert(0, "Shopping list\nMilk and eggs\nBread") }
        ed.editText { it.setParagraphStyle(0, ParagraphStyle.HEADING) }
        PageFiles.save(file, ed.toBytes())
        val session = PageSession(file)
        session.resize(1404, 1872)
        rule.setContent {
            app.inkbridge.ui.RmDensity {
                androidx.compose.foundation.layout.Box(androidx.compose.ui.Modifier.fillMaxSize()) {
                    val c = androidx.compose.runtime.remember { app.inkbridge.text.TextController(session).also { it.moveTo(20, false) } }
                    app.inkbridge.text.TextEditLayer(session, c, 0, 0, showKeyboard = false, softKeyboard = false)
                }
            }
        }
        settle(); drawWithPage(session, "text_format_button")
        rule.onNodeWithContentDescription("Text formatting").performClick(); settle(); drawWithPage(session, "text_format_menu")
        rule.onNodeWithContentDescription("Bold").performClick(); settle()
        rule.onNodeWithContentDescription("Bullet points").performClick(); settle(); drawWithPage(session, "text_format_menu_bullet")
    }

    private fun drawWithPage(session: PageSession, name: String) {
        val decor = rule.activity.window.decorView
        val bmp = android.graphics.Bitmap.createBitmap(decor.width, decor.height, android.graphics.Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(bmp)
        canvas.drawColor(android.graphics.Color.WHITE)
        decor.draw(canvas)
        session.bitmap?.let { canvas.drawBitmap(it, 0f, 0f, android.graphics.Paint().apply { xfermode = android.graphics.PorterDuffXfermode(android.graphics.PorterDuff.Mode.DARKEN) }) }
        val wmg = Class.forName("android.view.WindowManagerGlobal")
        val global = wmg.getMethod("getInstance").invoke(null)
        for (n in wmg.getMethod("getViewRootNames").invoke(global) as Array<*>) {
            val root = wmg.getMethod("getRootView", String::class.java).invoke(global, n) as? View ?: continue
            if (root === decor || root.width == 0) continue
            val lp = root.layoutParams as? android.view.WindowManager.LayoutParams
            canvas.save(); canvas.translate((lp?.x ?: 0).toFloat(), (lp?.y ?: 0).toFloat()); root.draw(canvas); canvas.restore()
        }
        val out = File("build/ui-snapshots").apply { mkdirs() }
        File(out, "$name.png").outputStream().use { bmp.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, it) }
    }

    @Test fun doubleTapEntersTypingAndSelectionByTaps() {
        launch()
        val surface = findSurface(rule.activity.window.decorView)!!
        val l = surface.listenerForTest()
        assertTrue(l != null)
        // Double tap on the body paragraph (second tap within 300 ms and 0.6 cm of the first).
        val t = SystemClock.uptimeMillis()
        val view = surface
        val x = view.width * 0.4f; val y = view.height * 0.2f
        fingerTap(x, y, t); fingerTap(x + 4f, y + 2f, t + 120)
        settle()
        assertTrue("typing mode: the input view exists", findInput(rule.activity.window.decorView) != null)
        snapshot("text_double_tap")
        // Triple tap selects the paragraph, fourth everything.
        SystemClock.sleep(2000)
        val t1 = SystemClock.uptimeMillis()
        fingerTap(x, y, t1); fingerTap(x, y, t1 + 120); fingerTap(x, y, t1 + 240)
        settle()
        val c = findInput(rule.activity.window.decorView)!!.controller!!
        assertTrue(c.hasSelection)
        assertEquals("Agenda for the week", c.selectedText())
        snapshot("text_paragraph_selected")
        SystemClock.sleep(2000)
        val t2 = SystemClock.uptimeMillis()
        fingerTap(x, y, t2); fingerTap(x, y, t2 + 120); fingerTap(x, y, t2 + 240); fingerTap(x, y, t2 + 360)
        settle(); snapshot("text_all_selected")
        assertEquals(c.content.length, c.selEnd - c.selStart)
    }

    @Test fun textSettingsPage() {
        launch()
        rule.onNodeWithContentDescription("Typing").performClick(); settle()
        rule.onNodeWithText("Text settings").performClick(); settle(); snapshot("text_settings")
        rule.onNodeWithContentDescription("font-scale-1.5").performClick(); settle(); snapshot("text_settings_confirm")
        rule.onNodeWithText("Confirm").performClick(); settle()
        rule.onNodeWithContentDescription("align-justify").performClick(); settle()
        rule.onNodeWithContentDescription("line-height-maximum").performClick(); settle()
        rule.onNodeWithContentDescription("Noto Serif").performClick(); settle(); snapshot("text_settings_changed")
        assertEquals(1.5f, TextSettings.current.scale, 0f)
        rule.onNodeWithText("Save").performClick(); settle(); snapshot("text_settings_applied")
    }
}
