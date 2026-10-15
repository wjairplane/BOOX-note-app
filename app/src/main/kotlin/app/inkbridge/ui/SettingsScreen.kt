package app.inkbridge.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
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
import app.inkbridge.BooxGestureGuard
import app.inkbridge.BuildConfig
import app.inkbridge.Screen
import app.inkbridge.ToolbarPosition
import app.inkbridge.rm.render.PageTemplate

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
    // The system Back from a deeper page returns to the page it came from.
    BackHandler(enabled = deeper != null) { sub = if (deeper == "Copyrights and licenses") "About" else null }
    if (deeper != null) {
        Column(Modifier.fillMaxSize().background(Ink.White)) {
            NavigationBar(deeper, onBack = { sub = if (deeper == "Copyrights and licenses") "About" else null })
            Column(Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(horizontal = 132.dp, vertical = 64.dp), verticalArrangement = Arrangement.spacedBy(64.dp)) {
                Text(deeper, style = RmText.TitleLg)
                when (deeper) {
                    "Storage" -> Storage(app)
                    "Copyrights and licenses" -> Licenses()
                    else -> About(onLicenses = { sub = "Copyrights and licenses" })
                }
            }
        }
        return
    }
    Row(Modifier.fillMaxSize().background(Ink.White)) {
        // The sidebar: 112 px rows with a 2 px divider under Back only, and one divider along its right edge.
        Row(Modifier.fillMaxHeight()) {
            Column(Modifier.width(IntrinsicSize.Max)) {
                @Composable fun item(label: String, selected: Boolean, onClick: () -> Unit, divider: Boolean = false, icon: @Composable (Color) -> Unit) {
                    val fg = if (selected) Ink.White else Ink.Black
                    Row(
                        Modifier.fillMaxWidth().height(Rm.ToolButton).background(if (selected) Ink.Black else Ink.White).tap(onClick = onClick).semantics { contentDescription = label }.padding(start = 32.dp, end = 96.dp),
                        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp),
                    ) { icon(fg); Text(label, style = RmText.LabelLg, color = fg, maxLines = 1) }
                    if (divider) Rule()
                }
                item("Back", false, { app.screen = Screen.Files() }, divider = true) { InkIcons.ChevronLeft(tint = it) }
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
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) { Text(title, style = RmText.LabelLg); content() }

@Composable
private fun General(app: AppController, onStorage: () -> Unit) {
    val p = app.prefs
    val (battery, _) = rememberBattery()
    val disk = rememberDiskSpace(app)
    CellList {
        CellRow("Software", "Version ${BuildConfig.VERSION_NAME}")
        CellRow("Battery", "$battery %")
        CellRow("Storage", "${formatGb(disk.used)} GB of ${formatGb(disk.total)} GB", onStorage, divider = false)
    }
    val activity = androidx.compose.ui.platform.LocalContext.current.let { c -> generateSequence(c) { (it as? android.content.ContextWrapper)?.baseContext }.filterIsInstance<android.app.Activity>().firstOrNull() }
    Column {
        SwitchRow("Swipe to turn pages", p.swipeToTurn, { p.swipeToTurn = it }, "Swipe a finger left or right. Swiping left on the last page offers a new page.")
        SwitchRow(
            "Block the device's edge gestures", p.blockDeviceGestures, { p.blockDeviceGestures = it; activity?.let { a -> BooxGestureGuard.update(a, it) } },
            "Keeps the BOOX's own swipes from the screen edges (status bar, back) from firing while InkBridge is open. Touch along the very edge of the screen is ignored.",
        )
        if (!app.isBoox) SwitchRow("Draw with finger", p.fingerDrawing, { p.fingerDrawing = it }, "For testing on devices without a stylus.")
    }
    // Where the firmware has Restart / Turn off: one secondary button (80 px, icon and label).
    Row(
        Modifier.fillMaxWidth().height(Rm.Control).border(Rm.Outline, Ink.Black).tap { activity?.finishAndRemoveTask() }.semantics { contentDescription = "Exit InkBridge" },
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterHorizontally),
    ) { InkIcons.Power(); Text("Exit InkBridge", style = RmText.LabelLg) }
}

@Composable
private fun Accessibility(app: AppController) {
    val p = app.prefs
    Group("Toolbar position") {
        Text("Choose your preferred toolbar position.", style = RmText.Body)
        Spacer(Modifier.height(8.dp))
        Text("Portrait", style = RmText.LabelLg)
        SegmentedRow(ToolbarPosition.entries.map { it.label }, ToolbarPosition.entries.indexOf(p.toolbarPosition), { p.toolbarPosition = ToolbarPosition.entries[it] })
        Spacer(Modifier.height(24.dp))
        Text("Landscape", style = RmText.LabelLg)
        SegmentedRow(ToolbarPosition.entries.map { it.label }, ToolbarPosition.entries.indexOf(p.toolbarLandscape), { p.toolbarLandscape = ToolbarPosition.entries[it] })
        Spacer(Modifier.height(16.dp))
        Text("To reposition the toolbar while in a document, drag the hide/show button to any edge of the screen.", style = RmText.Caption)
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
    Group("Pen preview") {
        Text("Exact draws the stroke while you write with the reMarkable pen renderer, so it looks the same before and after you lift the pen, and it is always under the toolbar and menus. Fast lets the tablet's own pen layer draw a quicker, plainer trail.", style = RmText.Body)
        Spacer(Modifier.height(8.dp))
        SegmentedRow(listOf("Exact", "Fast"), if (p.penExact) 0 else 1, { p.penExact = it == 0 })
    }
}

@Composable
private fun Help(onAbout: () -> Unit) {
    CellList { CellRow("About", null, onAbout, divider = false) }
}

/** Total and used bytes of the storage the library lives on (the Storage cell and page). */
private class DiskSpace(val total: Long, val used: Long)

@Composable
private fun rememberDiskSpace(app: AppController): DiskSpace {
    val dir = app.store.dir
    // Re-read when the library changes (notes take space).
    return remember(app.library) {
        runCatching {
            val st = android.os.StatFs(dir.path)
            DiskSpace(st.blockCountLong * st.blockSizeLong, (st.blockCountLong - st.availableBlocksLong) * st.blockSizeLong)
        }.getOrDefault(DiskSpace(0L, 0L))
    }
}

@Composable
private fun Storage(app: AppController) {
    val disk = rememberDiskSpace(app)
    val fraction = if (disk.total > 0) (disk.used.toFloat() / disk.total).coerceIn(0f, 1f) else 0f
    Group("Disk space") {
        // ProgressBar (large): 40 px high, a 2 px border, fully rounded, black fill.
        Box(Modifier.fillMaxWidth().height(40.dp).border(Rm.Outline, Ink.Black, CircleShape).padding(5.dp)) {
            Box(Modifier.fillMaxWidth(fraction).fillMaxHeight().background(Ink.Black, CircleShape))
        }
    }
    Text("${formatGb(disk.used)} GB of ${formatGb(disk.total)} GB used", style = RmText.LabelLg)
    if (fraction >= 0.9f) {
        Row(Modifier.fillMaxWidth().background(Ink.Black).padding(24.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            InkIcons.InformationCircle(tint = Ink.White)
            Text("Disk is almost full", style = RmText.Body, color = Ink.White)
        }
    }
}

@Composable
private fun About(onLicenses: () -> Unit) {
    CellList {
        CellRow("Version", BuildConfig.VERSION_NAME)
        CellRow("Copyrights and licenses", null, onLicenses, divider = false)
    }
    Group("InkBridge") {
        Text("A handwriting notes app for BOOX e-ink tablets, with a notebook-style files screen and a pen set modelled on the reMarkable 2.", style = RmText.Body)
    }
    Group("Not affiliated") {
        Text("InkBridge is an independent project. It is not made by, affiliated with or endorsed by reMarkable AS. “reMarkable” is a trademark of its owner.", style = RmText.Body)
    }
}

@Composable
private fun Licenses() {
    Text(
        "Page storage follows the open reverse-engineered v6 line format, ported from rmscene and rmc (MIT, © Rick Lupton). " +
            "Pen input uses Onyx's pen SDK.",
        style = RmText.Body,
    )
}

/** Decimal gigabytes with two decimals, as the firmware's storage line ("1.43 GB of 6.60 GB"). */
private fun formatGb(bytes: Long): String = String.format(java.util.Locale.US, "%.2f", bytes / 1e9)
