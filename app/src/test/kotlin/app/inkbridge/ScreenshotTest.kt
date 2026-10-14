package app.inkbridge

import android.app.Application
import androidx.activity.ComponentActivity
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.hasSetTextAction
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performTextInput
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.longClick
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

    /**
     * Draw the whole window into a PNG, plus any popup windows (menus) on top of it at their own positions.
     * (Compose's captureToImage waits for a draw callback Robolectric never sends.)
     */
    private fun snapshot(name: String) {
        val decor = rule.activity.window.decorView
        val bmp = android.graphics.Bitmap.createBitmap(decor.width.coerceAtLeast(1), decor.height.coerceAtLeast(1), android.graphics.Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(bmp)
        decor.draw(canvas)
        runCatching {
            val wmg = Class.forName("android.view.WindowManagerGlobal")
            val global = wmg.getMethod("getInstance").invoke(null)
            val names = wmg.getMethod("getViewRootNames").invoke(global) as Array<*>
            for (n in names) {
                val root = wmg.getMethod("getRootView", String::class.java).invoke(global, n) as? android.view.View ?: continue
                if (root === decor || root.width == 0 || root.height == 0) continue
                val lp = root.layoutParams as? android.view.WindowManager.LayoutParams
                canvas.save()
                // Dialogs are centred in the window; popups carry their own position.
                val centred = lp != null && (lp.gravity and android.view.Gravity.CENTER_VERTICAL) != 0
                if (centred) canvas.translate((bmp.width - root.width) / 2f, (bmp.height - root.height) / 2f)
                else canvas.translate((lp?.x ?: 0).toFloat(), (lp?.y ?: 0).toFloat())
                root.draw(canvas)
                canvas.restore()
            }
        }
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

        // The sort dropdown (a popup window)
        rule.onNodeWithText("Last modified").performClick(); settle(); snapshot("menu_sort")
        rule.onAllNodesWithText("Last modified")[1].performClick(); settle() // choosing the current order closes the menu
        rule.runOnUiThread { app.screen = Screen.Files() }; settle()

        // Create menu (the pill gains a round close button while open)
        rule.onNodeWithContentDescription("Create").performClick(); settle(); snapshot("create_menu")
        rule.onNodeWithText("Folder").performClick(); settle(); snapshot("dialog_new_folder")
        rule.onNodeWithText("Cancel").performClick(); settle()
        rule.onNodeWithContentDescription("Create").performClick(); settle()
        rule.onNodeWithContentDescription("Close").performClick(); settle()

        // Press and hold selects: the black action bar replaces the header
        rule.onNodeWithText("Journal").performTouchInput { longClick() }; settle(); snapshot("selection")
        rule.onNodeWithText("Cancel").performClick(); settle()

        // Search
        rule.onNodeWithContentDescription("Search").performClick(); settle()
        rule.onNode(hasSetTextAction()).performTextInput("ee"); settle(); snapshot("search")
        rule.runOnUiThread { app.screen = Screen.Files() }; settle()

        // Sidebar
        rule.onNodeWithContentDescription("Menu").performClick(); settle(); snapshot("sidebar")
        rule.onNodeWithText("Favorites").performClick(); settle(); snapshot("favorites")
        app.screen = Screen.Files(); settle()

        // Settings
        rule.runOnUiThread { app.screen = Screen.Settings }; settle(); snapshot("settings_general")
        rule.onNodeWithText("Accessibility").performClick(); settle(); snapshot("settings_accessibility")

        // Notebook: toolbar at the top (the default), pen menu, page overview
        val nb = app.library.entries.first { it.name == "Meeting notes" }
        rule.runOnUiThread { app.screen = Screen.Notebook(nb.id, 0) }; settle(); snapshot("notebook_top")
        rule.onNodeWithContentDescription("Writing tool 1: Fineliner").performClick(); settle(); snapshot("pen_menu")
        rule.onNodeWithContentDescription("Writing tool 2: Highlighter").performClick(); settle()
        rule.onNodeWithContentDescription("Writing tool 2: Highlighter").performClick(); settle(); snapshot("pen_menu_highlighter")
        rule.onNodeWithContentDescription("Writing tool 2: Highlighter").performClick(); settle()
        rule.onNodeWithContentDescription("Page overview").performClick(); settle(); snapshot("overview")
        rule.onNodeWithText("Close").performClick(); settle()

        // Hiding the toolbar leaves only the round button
        rule.onNodeWithContentDescription("Hide toolbar").performClick(); settle(); snapshot("notebook_collapsed")
        rule.onNodeWithContentDescription("Show toolbar").performClick(); settle()

        // The other toolbar positions
        rule.runOnUiThread { app.prefs.toolbarPosition = ToolbarPosition.LEFT }; settle()
        rule.onNodeWithContentDescription("Writing tool 1: Fineliner").performClick(); settle(); snapshot("notebook_left_menu")
        rule.runOnUiThread { app.prefs.toolbarPosition = ToolbarPosition.BOTTOM }; settle(); snapshot("notebook_bottom")
        rule.onNodeWithContentDescription("More").performClick(); settle(); snapshot("menu_more")
    }
}
