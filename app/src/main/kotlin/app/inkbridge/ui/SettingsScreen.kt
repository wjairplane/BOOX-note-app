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
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.render.PageTemplate
import java.io.File

private enum class Category(val title: String) {
    GENERAL("General"), PENS("Pens"), DISPLAY("Display"), STORAGE("Storage"), ABOUT("About")
}

@Composable
fun SettingsScreen(app: AppController) {
    var category by remember { mutableStateOf(Category.GENERAL) }
    Column(Modifier.fillMaxSize()) {
        Row(Modifier.fillMaxWidth().padding(horizontal = 12.dp, vertical = 10.dp), verticalAlignment = Alignment.CenterVertically) {
            IconBtn(Icons.Default.ArrowBack, "Back", { app.screen = Screen.Files() })
            Spacer(Modifier.width(8.dp))
            Text("Settings", fontFamily = androidx.compose.ui.text.font.FontFamily.Serif, fontSize = 36.sp)
        }
        Rule()
        Row(Modifier.fillMaxSize()) {
            // Categories on the left, details on the right.
            Column(Modifier.width(280.dp).fillMaxHeight().border(1.dp, Ink.Rule)) {
                Category.entries.forEach { c ->
                    val sel = c == category
                    Text(
                        c.title, fontSize = 22.sp, color = if (sel) Ink.White else Ink.Black,
                        modifier = Modifier.fillMaxWidth().background(if (sel) Ink.Black else Ink.White).tap { category = c }.padding(horizontal = 24.dp, vertical = 20.dp),
                    )
                    Rule()
                }
            }
            Column(Modifier.weight(1f).fillMaxHeight().verticalScroll(rememberScrollState()).padding(horizontal = 32.dp, vertical = 16.dp)) {
                when (category) {
                    Category.GENERAL -> General(app)
                    Category.PENS -> Pens(app)
                    Category.DISPLAY -> Display(app)
                    Category.STORAGE -> Storage(app)
                    Category.ABOUT -> About()
                }
            }
        }
    }
}

@Composable
private fun Heading(text: String) = Text(text, fontSize = 18.sp, color = Ink.Grey, modifier = Modifier.padding(top = 18.dp, bottom = 4.dp))

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
private fun Pens(app: AppController) {
    val p = app.prefs
    Heading("Pen when a notebook opens")
    PenTool.entries.filter { it.isPen }.forEach { t -> ChoiceRow(t.label, p.defaultPen == t, { p.defaultPen = t }) }
    Heading("Thickness")
    listOf(1 to "Thin", 2 to "Medium", 3 to "Thick").forEach { (v, l) -> ChoiceRow(l, p.defaultThickness == v, { p.defaultThickness = v }) }
    Heading("Colour")
    PenSpec.INK_COLORS.forEach { c -> ChoiceRow(PenSpec.colorName(c), p.defaultColor == c, { p.defaultColor = c }) }
    Text("Colours show on this colour e-ink screen; on a black-and-white screen they appear as shades of grey.", fontSize = 15.sp, color = Ink.Grey)
}

@Composable
private fun Display(app: AppController) {
    val p = app.prefs
    Heading("Full screen refresh while writing")
    Text("Colour e-ink can leave faint ghosts after lots of writing or erasing. A full refresh clears them (the screen flashes once).", fontSize = 16.sp, color = Ink.Grey)
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
    Text("$notebooks notebook${if (notebooks == 1) "" else "s"}, ${formatBytes(size)}", fontSize = 22.sp)
    Spacer(Modifier.height(6.dp))
    Text(app.store.dir.absolutePath, fontSize = 14.sp, color = Ink.Grey)
    Heading("Trash")
    Text("${lib.trash.size} item${if (lib.trash.size == 1) "" else "s"} in the trash", fontSize = 20.sp)
    Spacer(Modifier.height(10.dp))
    EButton("Empty trash", { confirm = true }, enabled = lib.trash.isNotEmpty())
    if (confirm) ConfirmDialog("Empty the trash?", "Everything in the trash will be deleted permanently.", "Empty trash", { confirm = false }) { app.emptyTrash(); confirm = false }
}

@Composable
private fun About() {
    Heading("InkBridge")
    Text("Version ${BuildConfig.VERSION_NAME}", fontSize = 22.sp)
    Spacer(Modifier.height(12.dp))
    Text(
        "A handwriting notes app for BOOX e-ink tablets, with a notebook-style files screen and a pen set modelled on the reMarkable 2.",
        fontSize = 18.sp,
    )
    Heading("Not affiliated")
    Text("InkBridge is an independent project. It is not made by, affiliated with or endorsed by reMarkable AS. “reMarkable” is a trademark of its owner.", fontSize = 17.sp)
    Heading("Open-source credits")
    Text(
        "Page storage follows the open reverse-engineered v6 line format, ported from rmscene and rmc (MIT, © Rick Lupton). " +
            "Pen input uses Onyx's pen SDK.",
        fontSize = 17.sp,
    )
}

private fun dirSize(d: File): Long = d.walkTopDown().filter { it.isFile }.sumOf { it.length() }

private fun formatBytes(b: Long): String = when {
    b < 1024 -> "$b B"
    b < 1024 * 1024 -> "${b / 1024} KB"
    else -> String.format("%.1f MB", b / 1048576.0)
}
