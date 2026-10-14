package app.inkbridge

import android.app.Application
import androidx.activity.ComponentActivity
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import app.inkbridge.rm.edit.InputPoint
import app.inkbridge.rm.edit.PageEditor
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.library.LibraryOps
import app.inkbridge.rm.library.PageFiles
import app.inkbridge.rm.render.PageTemplate
import app.inkbridge.ui.InkBridgeApp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.io.File

/** Renders real screens on the JVM so layout can be checked without a device. PNGs go to build/ui-snapshots. */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w702dp-h936dp-xhdpi")
class ScreenshotTest {
    @get:Rule val rule = createAndroidComposeRule<ComponentActivity>()

    /** Draw the whole window into a PNG. (Compose's captureToImage waits for a draw callback Robolectric never sends.) */
    private fun snapshot(name: String) {
        val decor = rule.activity.window.decorView
        val bmp = android.graphics.Bitmap.createBitmap(decor.width.coerceAtLeast(1), decor.height.coerceAtLeast(1), android.graphics.Bitmap.Config.ARGB_8888)
        decor.draw(android.graphics.Canvas(bmp))
        val out = File("build/ui-snapshots").apply { mkdirs() }
        File(out, "$name.png").outputStream().use { bmp.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, it) }
    }

    private fun seed(store: LibraryStore) {
        val d = store.dir
        val school = LibraryOps.createFolder(d, "School")
        LibraryOps.createFolder(d, "Work")
        LibraryOps.createFolder(d, "Ideas")
        LibraryOps.createFolder(d, "Recipes")
        fun notebook(name: String, tpl: PageTemplate, parent: String = "", pinned: Boolean = false, strokes: Boolean = true): String {
            val id = LibraryOps.createNotebook(d, name, parent, tpl)
            if (pinned) LibraryOps.setPinned(d, id, true)
            if (strokes) {
                val ed = PageEditor.blank()
                val pageId = d.listFiles { f -> f.name == "$id.content" }!!.single().readText().substringAfter("\"pages\":[\"").substringBefore("\"")
                for (k in 0 until 5) ed.addStroke(PenSpec(PenTool.FINELINER, thickness = 2), (0..40).map { InputPoint(-420f + it * 14, 300f + k * 130f + Math.sin(it / 4.0).toFloat() * 30, 0.6f, 0f, 0f, it * 5L) })
                PageFiles.save(File(File(d, id), "$pageId.rm"), ed.toBytes())
            }
            return id
        }
        notebook("Quick sheets", PageTemplate.BLANK, pinned = true)
        notebook("Meeting notes", PageTemplate.LINES, pinned = true)
        notebook("Maths", PageTemplate.GRID, school)
        notebook("Sketches", PageTemplate.DOTS)
        notebook("Journal", PageTemplate.LINES)
        notebook("Project plan with a long name that wraps", PageTemplate.GRID)
    }

    private fun settle() = repeat(14) { Thread.sleep(120); rule.mainClock.advanceTimeBy(100); rule.waitForIdle() }

    @Test fun screens() {
        val ctx = RuntimeEnvironment.getApplication() as Application
        val store = LibraryStore(ctx)
        seed(store)
        val app = AppController(store, Prefs(ctx), kotlinx.coroutines.MainScope())
        rule.setContent { InkBridgeApp(store, Prefs(ctx), app) }
        settle(); snapshot("files")

        // Create menu
        rule.onNodeWithText("＋").performClick(); settle(); snapshot("create_menu")
        rule.onNodeWithText("✕").performClick(); settle()

        // Sidebar
        rule.onNodeWithContentDescription("Menu").performClick(); settle(); snapshot("sidebar")
        rule.onNodeWithText("Favorites").performClick(); settle(); snapshot("favorites")
        app.screen = Screen.Files(); settle()

        // Settings
        rule.runOnUiThread { app.screen = Screen.Settings }; settle(); snapshot("settings_general")
        rule.onNodeWithText("Pens").performClick(); settle(); snapshot("settings_pens")

        // Notebook, pen panel, overview
        val nb = app.library.entries.first { it.name == "Meeting notes" }
        rule.runOnUiThread { app.screen = Screen.Notebook(nb.id, 0) }; settle(); snapshot("notebook")
        rule.onNodeWithText("Pen").performClick(); settle(); snapshot("pen_panel")
        rule.onNodeWithText("Done").performClick(); settle()
        rule.onNodeWithText("Pages").performClick(); settle(); snapshot("overview")
    }
}
