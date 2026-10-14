package app.inkbridge.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.inkbridge.AppController
import app.inkbridge.BuildConfig
import app.inkbridge.Screen
import app.inkbridge.ToolbarPosition
import app.inkbridge.rm.render.PageTemplate
import java.io.File

private enum class Category(val title: String) {
    GENERAL("General"), DISPLAY("Display"), ACCESSIBILITY("Accessibility"), STORAGE("Storage"), ABOUT("About")
}

@Composable
fun SettingsScreen(app: AppController) {
    var category by remember { mutableStateOf(Category.GENERAL) }
    Column(Modifier.fillMaxSize()) {
        Row(Modifier.fillMaxWidth().padding(horizontal = 32.dp, vertical = 16.dp), verticalAlignment = Alignment.CenterVertically) {
            IconBtn("Back", { app.screen = Screen.Files() }) { InkIcons.Back(tint = it) }
            Spacer(Modifier.width(16.dp))
            Text("Settings", style = RmText.TitleLg)
        }
        Rule()
        Row(Modifier.fillMaxSize()) {
            // Categories on the left, details on the right.
            Column(Modifier.width(Rm.SidebarWidth).fillMaxHeight().border(Rm.Outline, Ink.Black)) {
                Category.entries.forEach { c ->
                    val sel = c == category
                    Text(
                        c.title, style = RmText.LabelLg, color = if (sel) Ink.White else Ink.Black,
                        modifier = Modifier.fillMaxWidth().heightIn(min = 120.dp).background(if (sel) Ink.Black else Ink.White).tap { category = c }.padding(horizontal = 32.dp).wrapContentHeight(Alignment.CenterVertically),
                    )
                    Rule()
                }
            }
            Column(Modifier.weight(1f).fillMaxHeight().verticalScroll(rememberScrollState()).padding(horizontal = 64.dp, vertical = 24.dp)) {
                when (category) {
                    Category.GENERAL -> General(app)
                    Category.ACCESSIBILITY -> Accessibility(app)
                    Category.DISPLAY -> Display(app)
                    Category.STORAGE -> Storage(app)
                    Category.ABOUT -> About()
                }
            }
        }
    }
}

@Composable
private fun Heading(text: String) = Text(text, style = RmText.LabelLgStrong, modifier = Modifier.padding(top = 40.dp, bottom = 8.dp))

@Composable
private fun General(app: AppController) {
    val p = app.prefs
    Heading("Template for new notebooks")
    PageTemplate.entries.forEach { t -> ChoiceRow(t.label, p.defaultTemplate == t, { p.defaultTemplate = t }) }
    Heading("Turning pages")
    SwitchRow("Swipe to turn pages", p.swipeToTurn, { p.swipeToTurn = it }, "Swipe a finger left or right. Swiping left on the last page adds a new page.")
    if (!app.isBoox) SwitchRow("Draw with finger", p.fingerDrawing, { p.fingerDrawing = it }, "For testing on devices without a stylus.")
}

@Composable
private fun Accessibility(app: AppController) {
    val p = app.prefs
    Heading("Toolbar position")
    Text("Where the toolbar sits while you write in a notebook.", style = RmText.Caption, color = Ink.Grey)
    ToolbarPosition.entries.forEach { pos -> ChoiceRow(pos.label, p.toolbarPosition == pos, { p.toolbarPosition = pos }) }
}

@Composable
private fun Display(app: AppController) {
    val p = app.prefs
    Heading("Full screen refresh while writing")
    Text("Colour e-ink can leave faint ghosts after lots of writing or erasing. A full refresh clears them (the screen flashes once).", style = RmText.Caption, color = Ink.Grey)
    listOf(0 to "Never (use the Refresh button)", 10 to "Every 10 strokes", 25 to "Every 25 strokes", 50 to "Every 50 strokes").forEach { (v, l) ->
        ChoiceRow(l, p.refreshEveryStrokes == v, { p.refreshEveryStrokes = v })
    }
}

@Composable
private fun Storage(app: AppController) {
    var confirm by remember { mutableStateOf(false) }
    val lib = app.library
    val size by produceState(0L, lib) { value = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) { dirSize(app.store.dir) } }
    val notebooks = lib.entries.count { !it.isFolder && it.parentId != "trash" }
    Heading("Library")
    Text("$notebooks notebook${if (notebooks == 1) "" else "s"}, ${formatBytes(size)}", style = RmText.Body)
    Spacer(Modifier.height(8.dp))
    Text(app.store.dir.absolutePath, style = RmText.Caption, color = Ink.Grey)
    Heading("Trash")
    Text("${lib.trash.size} item${if (lib.trash.size == 1) "" else "s"} in the trash", style = RmText.Body)
    Spacer(Modifier.height(24.dp))
    EButton("Empty trash", { confirm = true }, enabled = lib.trash.isNotEmpty())
    if (confirm) ConfirmDialog("Empty the trash?", "Everything in the trash will be deleted permanently.", "Empty trash", { confirm = false }) { app.emptyTrash(); confirm = false }
}

@Composable
private fun About() {
    Heading("InkBridge")
    Text("Version ${BuildConfig.VERSION_NAME}", style = RmText.Body)
    Spacer(Modifier.height(16.dp))
    Text(
        "A handwriting notes app for BOOX e-ink tablets, with a notebook-style files screen and a pen set modelled on the reMarkable 2.",
        style = RmText.BodySm,
    )
    Heading("Not affiliated")
    Text("InkBridge is an independent project. It is not made by, affiliated with or endorsed by reMarkable AS. “reMarkable” is a trademark of its owner.", style = RmText.BodySm)
    Heading("Open-source credits")
    Text(
        "Page storage follows the open reverse-engineered v6 line format, ported from rmscene and rmc (MIT, © Rick Lupton). " +
            "Pen input uses Onyx's pen SDK.",
        style = RmText.BodySm,
    )
}

private fun dirSize(d: File): Long = d.walkTopDown().filter { it.isFile }.sumOf { it.length() }

private fun formatBytes(b: Long): String = when {
    b < 1024 -> "$b B"
    b < 1024 * 1024 -> "${b / 1024} KB"
    else -> String.format("%.1f MB", b / 1048576.0)
}
