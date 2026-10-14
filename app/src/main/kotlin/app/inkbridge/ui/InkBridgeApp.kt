package app.inkbridge.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
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
        Surface(Modifier.fillMaxSize(), color = Ink.White) {
            val scope = rememberCoroutineScope()
            val app = remember { controller ?: AppController(store, prefs, scope) }

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
                is Screen.Notebook -> NotebookScreen(app, s)
            }
        }
    }
    }
}
