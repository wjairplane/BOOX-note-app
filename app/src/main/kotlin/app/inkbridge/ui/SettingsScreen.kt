package app.inkbridge.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.inkbridge.AppController
import app.inkbridge.BuildConfig
import app.inkbridge.Screen
import app.inkbridge.ToolbarPosition
import app.inkbridge.rm.render.PageTemplate
import java.io.File

private enum class Category(val title: String, val page: String) {
    GENERAL("General", "General settings"), DISPLAY("Display", "Display settings"), ACCESSIBILITY("Accessibility", "Accessibility settings"), HELP("Help", "Help")
}

/**
 * Settings after the firmware: a sidebar (Back, then one row per page with an icon) next to the page, which has its own serif title.
 * Pages that go deeper (Storage, About) open full-screen with a Back bar.
 */
@Composable
fun SettingsScreen(app: AppController) {
    var category by remember { mutableStateOf(Category.GENERAL) }
    var sub by remember { mutableStateOf<String?>(null) }
    val deeper = sub
    if (deeper != null) {
        Column(Modifier.fillMaxSize().background(Ink.White)) {
            NavigationBar(deeper, onBack = { sub = null })
            Column(Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(horizontal = 132.dp, vertical = 64.dp), verticalArrangement = Arrangement.spacedBy(64.dp)) {
                Text(deeper, style = RmText.TitleLg)
                if (deeper == "Storage") Storage(app) else About()
            }
        }
        return
    }
    Row(Modifier.fillMaxSize().background(Ink.White)) {
        // The sidebar: 112 px rows with a 2 px divider under each, and one divider along its right edge.
        Row(Modifier.fillMaxHeight()) {
            Column(Modifier.width(IntrinsicSize.Max)) {
                @Composable fun item(label: String, selected: Boolean, onClick: () -> Unit, icon: @Composable (Color) -> Unit) {
                    val fg = if (selected) Ink.White else Ink.Black
                    Row(
                        Modifier.fillMaxWidth().height(Rm.ToolButton).background(if (selected) Ink.Black else Ink.White).tap(onClick = onClick).semantics { contentDescription = label }.padding(start = 32.dp, end = 96.dp),
                        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp),
                    ) { icon(fg); Text(label, style = RmText.LabelLg, color = fg, maxLines = 1) }
                    Rule()
                }
                item("Back", false, { app.screen = Screen.Files() }) { InkIcons.ChevronLeft(tint = it) }
                Category.entries.forEach { c ->
                    item(c.title, c == category, { category = c }) { tint ->
                        when (c) {
                            Category.GENERAL -> InkIcons.Cog(tint = tint)
                            Category.DISPLAY -> InkIcons.Display(tint = tint)
                            Category.ACCESSIBILITY -> InkIcons.Accessibility(tint = tint)
                            Category.HELP -> InkIcons.QuestionCircle(tint = tint)
                        }
                    }
                }
            }
            Box(Modifier.fillMaxHeight().width(Rm.Outline).background(Ink.Black))
        }
        Column(Modifier.weight(1f).fillMaxHeight().verticalScroll(rememberScrollState()).padding(horizontal = 132.dp, vertical = 64.dp), verticalArrangement = Arrangement.spacedBy(64.dp)) {
            Text(category.page, style = RmText.TitleLg)
            when (category) {
                Category.GENERAL -> General(app, onStorage = { sub = "Storage" })
                Category.DISPLAY -> Display(app)
                Category.ACCESSIBILITY -> Accessibility(app)
                Category.HELP -> Help(onAbout = { sub = "About" })
            }
        }
    }
}

@Composable
private fun Group(title: String, content: @Composable ColumnScope.() -> Unit) =
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) { Text(title, style = RmText.LabelLgStrong); content() }

@Composable
private fun General(app: AppController, onStorage: () -> Unit) {
    val p = app.prefs
    val size by produceState(0L, app.library) { value = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) { dirSize(app.store.dir) } }
    CellList {
        CellRow("Software", "Version ${BuildConfig.VERSION_NAME}")
        CellRow("Storage", formatBytes(size), onStorage, divider = false)
    }
    Group("Template for new notebooks") {
        PageTemplate.entries.forEach { t -> ChoiceRow(t.label, p.defaultTemplate == t, { p.defaultTemplate = t }) }
    }
    Column {
        SwitchRow("Swipe to turn pages", p.swipeToTurn, { p.swipeToTurn = it }, "Swipe a finger left or right. Swiping left on the last page offers a new page.")
        if (!app.isBoox) SwitchRow("Draw with finger", p.fingerDrawing, { p.fingerDrawing = it }, "For testing on devices without a stylus.")
    }
}

@Composable
private fun Accessibility(app: AppController) {
    val p = app.prefs
    Group("Toolbar position") {
        Text("Where the toolbar sits while you write in a notebook.", style = RmText.Body)
        Spacer(Modifier.height(8.dp))
        SegmentedRow(ToolbarPosition.entries.map { it.label }, ToolbarPosition.entries.indexOf(p.toolbarPosition), { p.toolbarPosition = ToolbarPosition.entries[it] })
    }
}

@Composable
private fun Display(app: AppController) {
    val p = app.prefs
    val options = listOf(0 to "Never", 10 to "10 strokes", 25 to "25 strokes", 50 to "50 strokes")
    Group("Full screen refresh while writing") {
        Text("Colour e-ink can leave faint ghosts after lots of writing or erasing. A full refresh clears them (the screen flashes once). \"Never\" leaves it to the Refresh screen button.", style = RmText.Body)
        Spacer(Modifier.height(8.dp))
        SegmentedRow(options.map { it.second }, options.indexOfFirst { it.first == p.refreshEveryStrokes }.coerceAtLeast(0), { p.refreshEveryStrokes = options[it].first })
    }
}

@Composable
private fun Help(onAbout: () -> Unit) {
    CellList { CellRow("About", null, onAbout, divider = false) }
}

@Composable
private fun Storage(app: AppController) {
    var confirm by remember { mutableStateOf(false) }
    val lib = app.library
    val size by produceState(0L, lib) { value = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) { dirSize(app.store.dir) } }
    val notebooks = lib.entries.count { !it.isFolder && it.parentId != "trash" }
    Group("Library") {
        Text("$notebooks notebook${if (notebooks == 1) "" else "s"}, ${formatBytes(size)}", style = RmText.Body)
        Text(app.store.dir.absolutePath, style = RmText.BodySm)
    }
    Group("Trash") {
        Text("${lib.trash.size} item${if (lib.trash.size == 1) "" else "s"} in the trash", style = RmText.Body)
        Spacer(Modifier.height(8.dp))
        EButton("Empty trash", { confirm = true }, enabled = lib.trash.isNotEmpty())
    }
    if (confirm) ConfirmDialog("Delete permanently?", "If you delete the items, you won't be able to get them back.", "Delete", { confirm = false }) { app.emptyTrash(); confirm = false }
}

@Composable
private fun About() {
    Group("InkBridge") {
        Text("Version ${BuildConfig.VERSION_NAME}", style = RmText.Body)
        Spacer(Modifier.height(8.dp))
        Text("A handwriting notes app for BOOX e-ink tablets, with a notebook-style files screen and a pen set modelled on the reMarkable 2.", style = RmText.Body)
    }
    Group("Not affiliated") {
        Text("InkBridge is an independent project. It is not made by, affiliated with or endorsed by reMarkable AS. “reMarkable” is a trademark of its owner.", style = RmText.Body)
    }
    Group("Open-source credits") {
        Text(
            "Page storage follows the open reverse-engineered v6 line format, ported from rmscene and rmc (MIT, © Rick Lupton). " +
                "Pen input uses Onyx's pen SDK.",
            style = RmText.Body,
        )
    }
}

private fun dirSize(d: File): Long = d.walkTopDown().filter { it.isFile }.sumOf { it.length() }

private fun formatBytes(b: Long): String = when {
    b < 1024 -> "$b B"
    b < 1024 * 1024 -> "${b / 1024} KB"
    else -> String.format("%.1f MB", b / 1048576.0)
}
