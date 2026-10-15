package app.inkbridge.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import app.inkbridge.AppController
import app.inkbridge.LibraryStore
import app.inkbridge.Prefs
import app.inkbridge.Screen
import app.inkbridge.Section

@Composable
fun InkBridgeApp(store: LibraryStore, prefs: Prefs, controller: AppController? = null) {
    RmDensity {
    MaterialTheme(colorScheme = EInkColors, typography = RmTypography) {
        val scope = rememberCoroutineScope()
        val app = remember { controller ?: AppController(store, prefs, scope) }
        val view = androidx.compose.ui.platform.LocalView.current
        val res = androidx.compose.ui.platform.LocalContext.current.resources
        val pixelsPerCm = (res.displayMetrics.xdpi.takeIf { it > 50f } ?: (160f * res.displayMetrics.density)) / 2.54f
        // The firmware's global gestures: two fingers down from the top edge (the document drawer) and one finger down from the
        // top-right corner (quick settings) work on every screen; in a notebook the page surface reports them itself.
        Surface(Modifier.fillMaxSize().globalSwipes(app.screen !is Screen.Notebook && app.overlay == null, pixelsPerCm, { app.overlay = Overlay.QUICK_SETTINGS }, { app.overlay = Overlay.DRAWER }), color = Ink.White) {

            when (val s = app.screen) {
                is Screen.Files -> {
                    // Back goes up one folder, then back to My files.
                    BackHandler(enabled = s.folderId.isNotEmpty() || s.section != Section.MY_FILES) {
                        app.screen = if (s.folderId.isNotEmpty()) {
                            Screen.Files(s.section, app.library[s.folderId]?.parentId?.takeIf { it != "trash" } ?: "")
                        } else Screen.Files()
                    }
                    FilesScreen(app, s)
                }
                Screen.Settings -> {
                    BackHandler { app.screen = Screen.Files() }
                    SettingsScreen(app)
                }
                Screen.Search -> {
                    BackHandler { app.screen = Screen.Files() }
                    SearchScreen(app)
                }
                Screen.Guides -> {
                    BackHandler { app.screen = Screen.Files() }
                    GuidesScreen(app)
                }
                is Screen.Notebook -> NotebookScreen(app, s)
            }
            // Panels opened by edge swipes float over whatever screen is showing.
            when (app.overlay) {
                Overlay.QUICK_SETTINGS -> {
                    BackHandler { app.overlay = null }
                    QuickSettingsPanel(app, { app.overlay = null }, { app.onRefresh?.invoke() ?: runCatching { com.onyx.android.sdk.api.device.epd.EpdController.refreshScreen(view, com.onyx.android.sdk.api.device.epd.UpdateMode.GC) } })
                }
                Overlay.DRAWER -> {
                    BackHandler { app.overlay = null }
                    DocumentDrawer(app, (app.screen as? Screen.Notebook)?.docId, { app.overlay = null })
                }
                null -> Unit
            }
        }
    }
    }
}

/** Watches touches (without consuming them) for the swipes from the top edge that open the drawer and quick settings. */
private fun Modifier.globalSwipes(enabled: Boolean, pixelsPerCm: Float, onQuickSettings: () -> Unit, onDrawer: () -> Unit): Modifier =
    if (!enabled) this else pointerInput(pixelsPerCm) {
        awaitEachGesture {
            val first = awaitFirstDown(requireUnconsumed = false, pass = androidx.compose.ui.input.pointer.PointerEventPass.Initial)
            val zone = 1.7f * pixelsPerCm
            if (first.position.y > zone) return@awaitEachGesture
            val starts = mutableMapOf(first.id to first.position)
            var fired = false
            while (!fired) {
                val event = awaitPointerEvent(androidx.compose.ui.input.pointer.PointerEventPass.Initial)
                val down = event.changes.filter { it.pressed }
                if (down.isEmpty()) break
                for (c in down) if (c.id !in starts && c.position.y <= zone) starts[c.id] = c.position
                val moved = down.filter { it.id in starts }.map { it.position.y - starts.getValue(it.id).y }
                if (down.size == 2 && moved.size == 2 && moved.all { it >= 0.3f * pixelsPerCm }) { fired = true; onDrawer() }
                else if (down.size == 1 && moved.size == 1 && moved[0] >= 0.3f * pixelsPerCm && starts.getValue(down[0].id).x >= size.width - minOf(400f, size.width / 3f)) { fired = true; onQuickSettings() }
            }
        }
    }
