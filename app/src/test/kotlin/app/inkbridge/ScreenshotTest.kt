package app.inkbridge

import android.app.Application
import androidx.activity.ComponentActivity
import androidx.compose.ui.test.onLast
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.hasSetTextAction
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.performImeAction
import androidx.compose.ui.test.onAllNodesWithContentDescription
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performTextInput
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.longClick
import android.os.SystemClock
import android.view.InputDevice
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import app.inkbridge.pen.FingerGestures
import app.inkbridge.pen.PenSurface
import app.inkbridge.rm.edit.InputPoint
import app.inkbridge.rm.edit.SelectionGesture
import app.inkbridge.rm.edit.PageEditor
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.library.LibraryOps
import app.inkbridge.rm.library.PageFiles
import app.inkbridge.rm.render.PageTemplate
import app.inkbridge.ui.InkBridgeApp
import app.inkbridge.ui.Overlay
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
        // The page itself lives on a SurfaceView, which a view capture leaves out: lay its bitmap over the capture, darkest wins
        // (so the toolbar and menus drawn by Compose stay on top of the white page).
        findSurface(decor)?.takeIf { !(name.startsWith("template_picker") || name.startsWith("overview") || name.startsWith("dialog_delete_page")) }?.let { v ->
            val bitmap = v.shownBitmap ?: return@let
            val at = IntArray(2).also { v.getLocationInWindow(it) }
            canvas.drawBitmap(bitmap, at[0].toFloat(), at[1].toFloat(), android.graphics.Paint().apply { xfermode = android.graphics.PorterDuffXfermode(android.graphics.PorterDuff.Mode.DARKEN) })
        }
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
                val centred = lp != null && (lp.gravity and android.view.Gravity.VERTICAL_GRAVITY_MASK) == android.view.Gravity.CENTER_VERTICAL
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
        rule.onNodeWithText("Sort by").performClick(); settle() // the header closes the menu
        rule.runOnUiThread { app.screen = Screen.Files() }; settle()

        // Create menu (the pill gains a round close button while open)
        rule.onNodeWithContentDescription("Create").performClick(); settle(); snapshot("create_menu")
        rule.onNodeWithText("Folder").performClick(); settle(); snapshot("dialog_new_folder")
        rule.onNodeWithText("Cancel").performClick(); settle()
        rule.onNodeWithContentDescription("Create").performClick(); settle()
        rule.onNodeWithContentDescription("Close").performClick(); settle()

        // Press and hold selects: the black action bar replaces the header
        rule.onNodeWithText("Journal").performTouchInput { longClick() }; settle(); snapshot("selection")
        rule.onNodeWithText("More").performClick(); settle(); snapshot("action_more")
        rule.onNodeWithText("More").performClick(); settle()
        rule.onNodeWithText("Tag").performClick(); settle(); snapshot("tag_popup")
        rule.onNodeWithText("New tag").performClick(); settle()
        rule.onNode(hasSetTextAction() and hasText("", substring = false)).performTextInput("work"); settle(); snapshot("dialog_new_tag")
        rule.onNodeWithText("Create").performClick(); settle(); snapshot("tag_popup_with_tag")
        rule.onNodeWithText("Back").performClick(); settle() // closing the popup applies the tags
        org.junit.Assert.assertEquals(listOf("work"), app.library.entries.first { it.name == "Journal" }.tags)
        rule.onNodeWithText("Duplicate").performClick(); settle()
        org.junit.Assert.assertTrue(app.library.entries.any { it.name == "Journal (copy)" })
        snapshot("after_duplicate")

        // Search
        rule.onNodeWithContentDescription("Search").performClick(); settle()
        rule.onNode(hasSetTextAction()).performTextInput("ee"); settle(); snapshot("search")
        rule.runOnUiThread { app.screen = Screen.Files() }; settle()

        // Sidebar
        rule.onNodeWithContentDescription("Menu").performClick(); settle(); snapshot("sidebar")
        rule.onNodeWithText("Favorites").performClick(); settle(); snapshot("favorites")
        app.screen = Screen.Files(); settle()

        // Tags and Guides from the sidebar
        rule.onNodeWithContentDescription("Menu").performClick(); settle()
        rule.onNodeWithText("Tags").performClick(); settle(); snapshot("tags_view")
        rule.onNodeWithContentDescription("Menu").performClick(); settle()
        rule.onNodeWithText("Guides").performClick(); settle(); snapshot("guides")
        rule.onNodeWithText("View all").performClick(); settle(); snapshot("guides_gestures")
        rule.onNodeWithContentDescription("Back").performClick(); settle()
        rule.onNodeWithText("Start tutorial").performClick(); settle(); snapshot("guides_tutorial")
        rule.runOnUiThread { app.screen = Screen.Files() }; settle()

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
        rule.onNodeWithContentDescription("Back").performClick(); settle()

        // Hiding the toolbar leaves only the round button
        rule.onNodeWithContentDescription("Hide toolbar").performClick(); settle(); snapshot("notebook_collapsed")
        rule.onNodeWithContentDescription("Show toolbar").performClick(); settle()

        // The other toolbar positions
        rule.runOnUiThread { app.prefs.toolbarPosition = ToolbarPosition.LEFT }; settle()
        rule.onNodeWithContentDescription("Writing tool 1: Fineliner").performClick(); settle() // switches to tool 1 (if it isn't active)
        rule.onNodeWithContentDescription("Writing tool 1: Fineliner").performClick(); settle(); snapshot("notebook_left_menu")
        rule.onNodeWithContentDescription("Writing tool 1: Fineliner").performClick(); settle() // closes it
        rule.onNodeWithContentDescription("Eraser").performClick(); settle()
        rule.onNodeWithContentDescription("Eraser").performClick(); settle(); snapshot("eraser_menu")
        rule.onAllNodesWithContentDescription("Eraser")[0].performClick(); settle() // the toolbar button (the foldout has an "Eraser" tile too)
        rule.onNodeWithContentDescription("More").performClick(); settle(); snapshot("notebook_menu")
        rule.onNodeWithText("Add page").performClick(); settle(); snapshot("notebook_menu_add")
        rule.onNodeWithContentDescription("More").performClick(); settle() // the back chevron
        rule.onNodeWithContentDescription("More").performClick(); settle() // closes the menu
        rule.runOnUiThread { app.prefs.toolbarPosition = ToolbarPosition.BOTTOM }; settle(); snapshot("notebook_bottom")
        rule.onNodeWithContentDescription("More").performClick(); settle(); snapshot("menu_more")
    }

    // ---- helpers for the extra scenarios ----

    private fun launch(): AppController {
        val ctx = RuntimeEnvironment.getApplication() as Application
        val store = LibraryStore(ctx)
        seed(store)
        val app = AppController(store, Prefs(ctx), kotlinx.coroutines.MainScope())
        rule.setContent { InkBridgeApp(store, Prefs(ctx), app) }
        settle()
        return app
    }

    private fun findSurface(v: View): PenSurface? =
        if (v is PenSurface) v else (v as? ViewGroup)?.let { g -> (0 until g.childCount).firstNotNullOfOrNull { findSurface(g.getChildAt(it)) } }

    /** A stylus stroke through [points] (view pixels of the page surface), the way a pen on a non-BOOX device arrives. */
    private fun stylusStroke(points: List<Pair<Float, Float>>) {
        val view = findSurface(rule.activity.window.decorView)!!
        val t0 = SystemClock.uptimeMillis()
        val points = if (points.size == 1) points + points else points // a tap: down, then up
        fun event(action: Int, x: Float, y: Float, t: Long): MotionEvent {
            val props = arrayOf(MotionEvent.PointerProperties().apply { id = 0; toolType = MotionEvent.TOOL_TYPE_STYLUS })
            val coords = arrayOf(MotionEvent.PointerCoords().apply { this.x = x; this.y = y; pressure = 0.5f; size = 1f })
            return MotionEvent.obtain(t0, t, action, 1, props, coords, 0, 0, 1f, 1f, 0, 0, InputDevice.SOURCE_STYLUS, 0)
        }
        rule.runOnUiThread {
            points.forEachIndexed { i, (x, y) ->
                val action = when (i) { 0 -> MotionEvent.ACTION_DOWN; points.lastIndex -> MotionEvent.ACTION_UP; else -> MotionEvent.ACTION_MOVE }
                view.dispatchTouchEvent(event(action, x, y, t0 + i * 8L))
            }
        }
    }

    /** Every dialog, popup and list view of the file browser and settings. */
    @Test fun dialogsAndViews() {
        val app = launch()

        rule.onNodeWithContentDescription("Create").performClick(); settle()
        rule.onNodeWithText("Notebook").performClick(); settle(); snapshot("dialog_new_notebook")
        rule.onAllNodesWithText("Cancel").onLast().performClick(); settle()

        // Press and hold, then each action that opens a dialog.
        rule.onNodeWithText("Journal").performTouchInput { longClick() }; settle()
        rule.onNodeWithText("Rename").performClick(); settle(); snapshot("dialog_rename")
        rule.onAllNodesWithText("Cancel").onLast().performClick(); settle()
        // Move is a mode of the browser: Cancel / hint / More, and navigating into a folder offers "Move here".
        rule.onNodeWithText("Move").performClick(); settle(); snapshot("move_mode")
        rule.onNodeWithText("Cancel").performClick(); settle()
        org.junit.Assert.assertNull(app.moving)
        // Delete moves to the trash at once and says so in the bottom notification bar.
        rule.onNodeWithText("Delete").performClick(); settle(); snapshot("notification_trashed")
        org.junit.Assert.assertEquals(1, app.library.trash.size)
        rule.onNodeWithText("1 item was moved to Trash").assertExists()

        // The trash: its own create-menu button, the empty-trash dialog, and restore/delete in the action bar.
        rule.onNodeWithContentDescription("Menu").performClick(); settle()
        rule.onNodeWithText("Trash").performClick(); settle(); snapshot("trash_view")
        rule.onNodeWithContentDescription("Empty trash").performClick(); settle(); snapshot("dialog_empty_trash")
        rule.onAllNodesWithText("Cancel").onLast().performClick(); settle()
        rule.onNodeWithText("Journal").performTouchInput { longClick() }; settle(); snapshot("trash_selection")
        rule.onNodeWithText("Delete").performClick(); settle(); snapshot("dialog_delete_permanently")
        rule.onNodeWithText("Delete permanently?").assertExists()
        rule.onNodeWithContentDescription("Cancel").performClick(); settle()
        org.junit.Assert.assertEquals(1, app.library.trash.size)
        rule.onNodeWithText("Restore").performClick(); settle(); snapshot("notification_restored")
        org.junit.Assert.assertEquals(0, app.library.trash.size)

        // "Filter by": Notebooks and PDFs.
        rule.runOnUiThread { app.screen = Screen.Files() }; settle()
        rule.onNodeWithContentDescription("Menu").performClick(); settle()
        rule.onNodeWithText("Filter by").performClick(); settle(); snapshot("sidebar_filter")
        rule.onNodeWithText("Notebooks").performClick(); settle(); snapshot("notebooks_view")
        rule.onNodeWithContentDescription("Menu").performClick(); settle()
        rule.onAllNodesWithText("Notebooks").onLast().performClick(); settle() // the chosen filter's item opens the flyout again
        rule.onNodeWithText("PDFs").performClick(); settle(); snapshot("pdfs_view")
        rule.runOnUiThread { app.screen = Screen.Files() }; settle()

        // Settings categories.
        rule.runOnUiThread { app.screen = Screen.Settings }; settle()
        rule.onNodeWithText("Display").performClick(); settle(); snapshot("settings_display")
        rule.onNodeWithText("General").performClick(); settle()
        rule.onNodeWithText("Storage").performClick(); settle(); snapshot("settings_storage")
        rule.onNodeWithContentDescription("Back").performClick(); settle()
        rule.onNodeWithText("Help").performClick(); settle(); snapshot("settings_help")
        rule.onNodeWithText("About").performClick(); settle(); snapshot("settings_about")
    }

    /** The create / rename / move / delete flows of the file browser. */
    @Test fun fileFlows() {
        val app = launch()

        // New notebook: one full screen (Cancel / title / Create), a name, the cover choice and the recent templates.
        rule.onNodeWithContentDescription("Create").performClick(); settle()
        rule.onNodeWithText("Notebook").performClick(); settle(); snapshot("new_notebook")
        rule.onNodeWithText("New notebook").assertExists()
        rule.onNodeWithText("Notebook cover").assertExists()
        rule.onNodeWithText("Templates").assertExists()
        rule.onNodeWithText("View all").performClick(); settle(); snapshot("new_notebook_templates")
        rule.onNodeWithContentDescription("Back").performClick(); settle()
        rule.onNodeWithText("First page").performClick(); settle()
        rule.onNodeWithText("Create").performClick(); settle()
        val made = app.library.entries.first { it.name == "Notebook" }
        org.junit.Assert.assertEquals(0, made.coverPage)
        org.junit.Assert.assertTrue(app.screen is Screen.Notebook)
        rule.runOnUiThread { app.screen = Screen.Files() }; settle()

        // New folder: a name and the tags section.
        rule.onNodeWithContentDescription("Create").performClick(); settle()
        rule.onNodeWithText("Folder").performClick(); settle(); snapshot("new_folder")
        rule.onNodeWithText("Tags").assertExists()
        rule.onNodeWithContentDescription("New tag").performClick(); settle()
        rule.onNode(hasSetTextAction() and hasText("", substring = false)).performTextInput("Home"); settle(); snapshot("new_folder_new_tag")
        rule.onNode(hasSetTextAction() and hasText("Home", substring = false)).performImeAction(); settle(); snapshot("new_folder_tagged")
        rule.onNodeWithText("Create").performClick(); settle()
        org.junit.Assert.assertEquals(listOf("Home"), app.library.entries.first { it.name == "Folder" }.tags)

        // Rename is a full screen with details.
        rule.onNodeWithText("Journal").performTouchInput { longClick() }; settle()
        rule.onNodeWithText("Rename").performClick(); settle(); snapshot("rename_screen")
        rule.onNodeWithText("Details").assertExists()
        rule.onAllNodesWithText("Cancel").onLast().performClick(); settle()

        // Move: pick the School folder, "Move here" drops the selection into it (the selection is still there after Cancel).
        rule.onNodeWithText("Move").performClick(); settle()
        rule.onNodeWithText("Select where to move the item").assertExists()
        rule.onNodeWithText("School").performClick(); settle(); snapshot("move_in_folder")
        rule.onNodeWithText("Choose a placement").assertExists()
        rule.onNodeWithText("Move here").performClick(); settle()
        val school = app.library.entries.first { it.name == "School" }
        org.junit.Assert.assertEquals(school.id, app.library.entries.first { it.name == "Journal" }.parentId)
        org.junit.Assert.assertNull(app.moving)

        // Tapping a crumb goes back to My files.
        rule.onNodeWithText("My files").performClick(); settle()
        org.junit.Assert.assertEquals("", (app.screen as Screen.Files).folderId)

        // Quick sheets: a long press on "+" makes (or reuses) the one "Quick sheets" notebook.
        val before = app.library.entries.count { it.name == "Quick sheets" }
        rule.onNodeWithContentDescription("Create").performTouchInput { longClick() }; settle()
        org.junit.Assert.assertEquals(before.coerceAtLeast(1), app.library.entries.count { it.name == "Quick sheets" })
        org.junit.Assert.assertTrue(app.screen is Screen.Notebook)
    }

    /** The notebook's selection tool, layers, view controls and page dialog. */
    @Test fun notebookTools() {
        val app = launch()
        val nb = app.library.entries.first { it.name == "Meeting notes" }
        rule.runOnUiThread { app.prefs.toolbarPosition = ToolbarPosition.LEFT; app.screen = Screen.Notebook(nb.id, 0) }; settle()

        // Selection tool: a lasso around the handwriting; Copy ends the selection, a tap with the pen pastes.
        rule.onNodeWithContentDescription("Selection tool").performClick(); settle()
        stylusStroke(listOf(150f to 150f, 950f to 150f, 950f to 1000f, 150f to 1000f, 150f to 150f)); settle(); snapshot("selection_tool")
        rule.onNodeWithContentDescription("Copy").performClick(); settle(); snapshot("selection_copied")
        stylusStroke(listOf(700f to 1250f)); settle(); snapshot("selection_pasted")
        // Resize the pasted strokes by a corner handle and turn them by the round one.
        val surface = findSurface(rule.activity.window.decorView)!!
        val corner = surface.selectionFrameProvider()!!.corners()[2]
        stylusStroke(listOf(corner.first to corner.second, corner.first + 60f to corner.second + 40f, corner.first + 120f to corner.second + 80f)); settle(); snapshot("selection_resized")
        val frame = surface.selectionFrameProvider()!!
        val handle = frame.rotateHandle(SelectionGesture.ROTATE_OFFSET)
        stylusStroke(listOf(handle.first to handle.second, handle.first + 120f to handle.second + 60f, frame.right + 80f to frame.centerY)); settle(); snapshot("selection_rotated")
        rule.onNodeWithContentDescription("Delete").performClick(); settle(); snapshot("selection_deleted")
        rule.onNodeWithContentDescription("Writing tool 1: Fineliner").performClick(); settle() // back to a pen

        // Layers: a button in the toolbar with its own foldout.
        rule.onNodeWithContentDescription("Layers").performClick(); settle(); snapshot("layers_menu")
        rule.onNodeWithText("New layer").performClick(); settle(); snapshot("layers_menu_two")
        rule.onNodeWithContentDescription("Hide Layer 1").performClick(); settle(); snapshot("layers_hidden")
        rule.onNodeWithContentDescription("Move down Layer 2").performClick(); settle(); snapshot("layers_reordered")
        rule.onNodeWithContentDescription("Merge down Layer 1").performClick(); settle(); snapshot("layers_merged")
        rule.onNodeWithContentDescription("Hide background").performClick(); settle(); snapshot("layers_background_hidden")
        rule.onNodeWithText("Template").performClick(); settle(); snapshot("template_picker")
        rule.onNodeWithContentDescription("Back").performClick(); settle()

        // The notebook menu: Add page adds one after this page; then the overview with a page selected, and the delete confirmation.
        rule.onNodeWithContentDescription("More").performClick(); settle(); snapshot("notebook_menu_firmware")
        rule.onNodeWithText("Add page").performClick(); settle()
        org.junit.Assert.assertEquals(2, app.library[nb.id]!!.pageIds.size)
        rule.onNodeWithContentDescription("Page overview").performClick(); settle(); snapshot("overview_firmware")
        rule.onNodeWithContentDescription("Page 1").performTouchInput { longClick() }; settle(); snapshot("overview_selection")
        rule.onNodeWithContentDescription("Delete").performClick(); settle(); snapshot("dialog_delete_page")
        rule.onAllNodesWithText("Cancel").onLast().performClick(); settle()
    }

    /** The panels the edge-swipe gestures open: quick settings, the document drawer, quick browse, and the zoom button. */
    @Test fun overlays() {
        val app = launch()
        val nb = app.library.entries.first { it.name == "Meeting notes" }
        rule.runOnUiThread { app.prefs.toolbarPosition = ToolbarPosition.LEFT; app.addPage(nb, 0) {} }; settle(); settle()
        rule.runOnUiThread { app.screen = Screen.Notebook(nb.id, 0) }; settle()
        rule.runOnUiThread { app.overlay = Overlay.QUICK_SETTINGS }; settle(); snapshot("quick_settings")
        rule.runOnUiThread { app.overlay = Overlay.DRAWER }; settle(); snapshot("document_drawer")
        rule.runOnUiThread { app.overlay = null }; settle()
        // Quick browse (the page slider): driven through the surface's edge swipe.
        val surface = findSurface(rule.activity.window.decorView)!!
        rule.runOnUiThread { surface.listenerForTest().onEdgeSwipe(FingerGestures.Edge.QUICK_BROWSE) }; settle(); snapshot("page_slider")
    }

    /** The firmware-style template picker on its own: all templates, the filter menu open, then Planners in landscape. */
    @Test fun templatePicker() {
        rule.setContent { app.inkbridge.ui.RmDensity { app.inkbridge.ui.TemplatePickerScreen(PageTemplate.LINES, {}, {}) } }
        settle(); snapshot("template_picker_all")
        rule.onNodeWithContentDescription("Filter").performClick(); settle(); snapshot("template_picker_filter")
        rule.onNodeWithText("Planners").performClick(); settle()
        rule.onNodeWithText("Landscape").performClick(); settle(); snapshot("template_picker_planners_landscape")
        rule.onNodeWithText("Landscape").performClick(); settle(); snapshot("template_picker_planners_landscape_closed")
    }
}
