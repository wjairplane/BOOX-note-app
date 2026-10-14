package app.inkbridge.ui

import android.graphics.Bitmap
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.foundation.Canvas
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.inkbridge.AppController
import app.inkbridge.Screen
import app.inkbridge.Section
import app.inkbridge.SortBy
import app.inkbridge.rm.library.Library
import app.inkbridge.rm.library.LibraryEntry
import app.inkbridge.rm.render.PageTemplate
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.text.DateFormat
import java.util.Date

private sealed interface Dialogs {
    data class Rename(val e: LibraryEntry) : Dialogs
    data class Delete(val es: List<LibraryEntry>) : Dialogs
    data class Move(val es: List<LibraryEntry>) : Dialogs
    data object NewNotebook : Dialogs
    data object NewFolder : Dialogs
    data object EmptyTrash : Dialogs
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun FilesScreen(app: AppController, s: Screen.Files) {
    val lib = app.library
    val prefs = app.prefs
    var menuOpen by remember { mutableStateOf(false) }
    var dialog by remember { mutableStateOf<Dialogs?>(null) }
    // Press and hold selects; the header then becomes the black action bar.
    var picked by remember(s) { mutableStateOf(setOf<String>()) }

    val pdfPicker = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        if (uri != null) app.importPdf(uri, s.folderId)
    }

    val entries = remember(lib, s, prefs.sortBy, prefs.sortReversed) { visibleEntries(lib, s, prefs.sortBy, prefs.sortReversed) }
    val title = when {
        s.section != Section.MY_FILES -> s.section.title
        s.folderId.isEmpty() -> "My files"
        else -> lib[s.folderId]?.name ?: "My files"
    }

    Box(Modifier.fillMaxSize()) {
        Column(Modifier.fillMaxSize()) {
            val selection = entries.filter { it.id in picked }
            if (selection.isNotEmpty()) {
                ActionBar(app, s, selection, onCancel = { picked = emptySet() }, onDialog = { dialog = it }, onDone = { picked = emptySet() })
            } else {
            // --- header (120 px): menu button, wordmark, and the trash button ---
            Box(Modifier.fillMaxWidth().height(Rm.NavigationHeader).padding(horizontal = 8.dp)) {
                Row(Modifier.align(Alignment.CenterStart), verticalAlignment = Alignment.CenterVertically) {
                    IconBtn("Menu", { menuOpen = true }, size = Rm.ToolButton) { InkIcons.Menu(tint = it) }
                    if (s.folderId.isNotEmpty() && s.section == Section.MY_FILES) {
                        IconBtn("Up", { app.screen = Screen.Files(s.section, lib[s.folderId]?.parentId ?: "") }, size = Rm.ToolButton) { InkIcons.Back(tint = it) }
                    }
                }
                Text("InkBridge", style = RmText.Wordmark, modifier = Modifier.align(Alignment.Center))
                Row(Modifier.align(Alignment.CenterEnd).padding(end = 24.dp), verticalAlignment = Alignment.CenterVertically) {
                    if (s.section == Section.TRASH) {
                        EButton("Empty trash", { dialog = Dialogs.EmptyTrash }, enabled = entries.isNotEmpty())
                    }
                }
            }
            }
            // --- title row with the sort/view dropdown on the right ---
            Row(Modifier.fillMaxWidth().padding(horizontal = Rm.NavigatorMargin, vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.weight(1f)) {
                    Text(title, style = RmText.TitleLg, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    if (s.section == Section.MY_FILES && s.folderId.isNotEmpty()) {
                        Text((listOf("My files") + lib.path(s.folderId)).joinToString("  /  "), style = RmText.Caption, color = Ink.Grey)
                    }
                }
                if (s.section != Section.TRASH) {
                    var sortMenu by remember { mutableStateOf(false) }
                    Box {
                        Row(Modifier.heightIn(min = Rm.Control).tap { sortMenu = true }.padding(start = 16.dp), verticalAlignment = Alignment.CenterVertically) {
                            Text(when { prefs.sortBy == SortBy.MODIFIED -> "Last modified"; prefs.sortReversed -> "Alphabetical (Z-A)"; else -> "Alphabetical (A-Z)" }, style = RmText.Label)
                            InkIcons.ChevronDown()
                        }
                        // The navigator's filter dropdown: 360 px wide, 80 px rows, the current choice inverted.
                        RmMenu(sortMenu, { sortMenu = false }, MenuSide.BELOW, Rm.DropdownWidth) {
                            @Composable fun item(label: String, checked: Boolean = false, action: () -> Unit) =
                                RmMenuItem(label, { sortMenu = false; action() }, selected = checked)
                            item("Last modified", prefs.sortBy == SortBy.MODIFIED && !prefs.sortReversed) { prefs.sortBy = SortBy.MODIFIED; prefs.sortReversed = false }
                            item("Alphabetical (A-Z)", prefs.sortBy == SortBy.NAME && !prefs.sortReversed) { prefs.sortBy = SortBy.NAME; prefs.sortReversed = false }
                            item("Alphabetical (Z-A)", prefs.sortBy == SortBy.NAME && prefs.sortReversed) { prefs.sortBy = SortBy.NAME; prefs.sortReversed = true }
                            item("Grid view", prefs.gridView) { prefs.gridView = true }
                            item("List view", !prefs.gridView) { prefs.gridView = false }
                        }
                    }
                }
            }
            if (app.message.isNotEmpty()) {
                Row(Modifier.fillMaxWidth().background(Ink.Panel).padding(horizontal = Rm.NavigatorMargin, vertical = 16.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text(app.message, style = RmText.BodySm, modifier = Modifier.weight(1f))
                    EButton("Dismiss", { app.message = "" })
                }
            }

            // --- content ---
            val folders = entries.filter { it.isFolder }
            val notebooks = entries.filter { !it.isFolder }
            if (entries.isEmpty()) {
                Text(
                    when (s.section) {
                        Section.MY_FILES -> "Nothing here yet.\nTap + to make a notebook or a folder, or to import a PDF to annotate."
                        Section.FAVORITES -> "No favorites yet.\nPress and hold a notebook or folder in My files, then tap Favorite."
                        Section.TRASH -> "The trash is empty."
                    },
                    style = RmText.Body, color = Ink.Grey, modifier = Modifier.padding(Rm.NavigatorMargin),
                )
            } else if (prefs.gridView) {
                val toggle: (LibraryEntry) -> Unit = { e -> picked = if (e.id in picked) picked - e.id else picked + e.id }
                val select: (LibraryEntry) -> Unit = { e -> if (picked.isNotEmpty()) toggle(e) else open(app, e, s) }
                // Four columns across the 1404 px screen with 18 px margins: 342 px cells.
                LazyVerticalGrid(
                    GridCells.Fixed(4), contentPadding = PaddingValues(start = Rm.ViewMargin, end = Rm.ViewMargin, bottom = Rm.CreateMenuBottomMargin + Rm.CreateMenuHeight + 40.dp),
                ) {
                    items(folders, key = { it.id }) { e -> FolderCell(lib, e, e.id in picked, onClick = { select(e) }, onLongClick = { toggle(e) }) }
                    items(notebooks, key = { it.id }) { e -> NotebookCell(app, e, e.id in picked, onClick = { select(e) }, onLongClick = { toggle(e) }) }
                }
            } else {
                LazyColumn(contentPadding = PaddingValues(bottom = Rm.CreateMenuBottomMargin + Rm.CreateMenuHeight + 40.dp)) {
                    items(entries, key = { it.id }) { e ->
                        val toggle = { picked = if (e.id in picked) picked - e.id else picked + e.id }
                        ListRow(app, e, e.id in picked, onClick = { if (picked.isNotEmpty()) toggle() else open(app, e, s) }, onLongClick = toggle)
                        Rule()
                    }
                }
            }
        }

        // --- bottom pill: search and create (open: a "Create now" card above it, and a round close button) ---
        if (s.section == Section.MY_FILES) {
            var createOpen by remember { mutableStateOf(false) }
            Column(Modifier.align(Alignment.BottomCenter).padding(bottom = Rm.CreateMenuBottomMargin), horizontalAlignment = Alignment.CenterHorizontally) {
                if (createOpen) {
                    Column(Modifier.width(600.dp).background(Ink.White).border(Rm.Outline, Ink.Black)) {
                        Text("Create now", style = RmText.Caption, color = Ink.Grey, modifier = Modifier.padding(start = 32.dp, top = 24.dp, bottom = 8.dp))
                        @Composable fun row(title: String, sub: String, action: () -> Unit) =
                            Column(Modifier.fillMaxWidth().heightIn(min = Rm.ToolButton).tap { createOpen = false; action() }.padding(horizontal = 32.dp, vertical = 16.dp), verticalArrangement = Arrangement.Center) {
                                Text(title, style = RmText.LabelLgStrong)
                                Text(sub, style = RmText.Caption, color = Ink.Grey)
                            }
                        row("Notebook", "Record ideas, write, and sketch") { dialog = Dialogs.NewNotebook }
                        row("Folder", "Organise your content") { dialog = Dialogs.NewFolder }
                        row("PDF", "Import a document to annotate") { pdfPicker.launch(arrayOf("application/pdf")) }
                    }
                    Spacer(Modifier.height(24.dp))
                }
                // The create menu bar: 112 px high with a 2 px outline, a 112 px tile per action.
                Row(
                    Modifier.height(Rm.CreateMenuHeight).background(Ink.White, CircleShape).border(Rm.Outline, Ink.Black, CircleShape).padding(horizontal = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Box(Modifier.size(Rm.ToolButton).tap { createOpen = false; app.screen = Screen.Search }.semantics { contentDescription = "Search" }, contentAlignment = Alignment.Center) { InkIcons.Search() }
                    Box(Modifier.size(Rm.ToolButton).tap { createOpen = !createOpen }.semantics { contentDescription = "Create" }, contentAlignment = Alignment.Center) { InkIcons.Plus() }
                    if (createOpen) {
                        Box(Modifier.size(Rm.ToolButton).tap { createOpen = false }.semantics { contentDescription = "Close" }, contentAlignment = Alignment.Center) { InkIcons.CloseDisc() }
                    }
                }
            }
        }

        if (menuOpen) Sidebar(app, s, onClose = { menuOpen = false })
    }

    when (val d = dialog) {
        null -> Unit
        Dialogs.NewNotebook -> NewNotebookDialog(app, s.folderId, onDismiss = { dialog = null })
        Dialogs.NewFolder -> NameDialog("New folder", app.suggestName(s.folderId, "Folder"), "Create", { dialog = null }) { app.newFolder(it, s.folderId); dialog = null }
        is Dialogs.Rename -> NameDialog("Rename", d.e.name, "Rename", { dialog = null }) { app.rename(d.e, it); dialog = null }
        is Dialogs.Delete -> {
            val inTrash = d.es.all { it.parentId == Library.TRASH }
            val what = if (d.es.size == 1) "“${d.es[0].name}”" else "${d.es.size} items"
            ConfirmDialog(
                if (inTrash) "Delete forever?" else "Move to trash?",
                if (inTrash) "$what will be deleted permanently." else "$what will be moved to the trash.",
                if (inTrash) "Delete" else "Move to trash", { dialog = null },
            ) { d.es.forEach { if (inTrash) app.deleteForever(it) else app.trash(it) }; picked = emptySet(); dialog = null }
        }
        is Dialogs.Move -> MoveDialog(lib, d.es, { dialog = null }) { target -> d.es.forEach { app.move(it, target) }; picked = emptySet(); dialog = null }
        Dialogs.EmptyTrash -> ConfirmDialog("Empty the trash?", "Everything in the trash will be deleted permanently.", "Empty trash", { dialog = null }) { app.emptyTrash(); dialog = null }
    }
}

private fun open(app: AppController, e: LibraryEntry, s: Screen.Files) {
    if (s.section == Section.TRASH) return // trashed items are managed, not opened
    app.screen = if (e.isFolder) Screen.Files(Section.MY_FILES, e.id) else Screen.Notebook(e.id, 0)
}

/** Long names are shortened in the middle ("FY27 budge…verview"), keeping both the start and the end readable, as on the tablet. */
internal fun middleEllipsis(name: String, head: Int = 8, tail: Int = 6): String =
    if (name.length <= head + tail + 1) name else name.take(head).trimEnd() + "…" + name.takeLast(tail).trimStart()

private fun visibleEntries(lib: Library, s: Screen.Files, sort: SortBy, reversed: Boolean): List<LibraryEntry> {
    val base = when (s.section) {
        Section.MY_FILES -> lib.children(s.folderId)
        Section.FAVORITES -> lib.entries.filter { it.pinned && it.parentId != Library.TRASH }
        Section.TRASH -> lib.trash
    }
    val byDate = compareByDescending<LibraryEntry> { it.lastModified }.thenBy { it.name.lowercase() }
    val byName = compareBy<LibraryEntry> { it.name.lowercase() }
    // Folders always come first, as in the tablet's file browser.
    val order = if (sort == SortBy.NAME) byName else byDate
    return base.sortedWith(compareBy<LibraryEntry> { !it.isFolder }.then(if (reversed) order.reversed() else order))
}

/** The firmware's selected look: the whole cell turns black with white text. */
private fun Modifier.cellBackground(selected: Boolean) = background(if (selected) Ink.Black else Ink.White)

/** A notebook in the grid: 342 px cell, a 16 px inset around the thumbnail, then the name and a caption. */
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun NotebookCell(app: AppController, e: LibraryEntry, selected: Boolean, onClick: () -> Unit, onLongClick: () -> Unit) {
    val fg = if (selected) Ink.White else Ink.Black
    val pages = "${e.pageIds.size} page${if (e.pageIds.size == 1) "" else "s"}"
    Column(Modifier.fillMaxWidth().cellBackground(selected).combinedClickable(onClick = onClick, onLongClick = onLongClick).padding(start = 16.dp, end = 16.dp, top = 16.dp, bottom = 8.dp)) {
        Thumb(app, e, Modifier.fillMaxWidth().aspectRatio(THUMB_ASPECT))
        Spacer(Modifier.height(10.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(middleEllipsis(e.name), style = RmText.Label, color = fg, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f))
            if (e.pinned) InkIcons.StarInverted(tint = fg, size = Rm.IconSmall, modifier = Modifier.padding(start = 8.dp))
        }
        Text(pages, style = RmText.Caption, color = fg, maxLines = 1)
    }
}

/** A folder: 75 px high, folder icon, name and an item count. */
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun FolderCell(lib: Library, e: LibraryEntry, selected: Boolean, onClick: () -> Unit, onLongClick: () -> Unit) {
    val fg = if (selected) Ink.White else Ink.Black
    val count = remember(lib, e.id) { lib.children(e.id).size }
    Row(
        Modifier.fillMaxWidth().height(75.dp).cellBackground(selected).combinedClickable(onClick = onClick, onLongClick = onLongClick).padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        InkIcons.Folder(tint = fg)
        Spacer(Modifier.width(16.dp))
        Column(Modifier.weight(1f)) {
            Text(e.name, style = RmText.Label, color = fg, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(if (count == 1) "1 item" else "$count items", style = RmText.Caption, color = fg, maxLines = 1)
        }
        if (e.pinned) InkIcons.StarInverted(tint = fg, size = Rm.IconSmall)
    }
}

/** A row in the list view. */
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun ListRow(app: AppController, e: LibraryEntry, selected: Boolean, onClick: () -> Unit, onLongClick: () -> Unit) {
    val fg = if (selected) Ink.White else Ink.Black
    val date = remember(e.lastModified) { if (e.lastModified > 0) DateFormat.getDateInstance(DateFormat.MEDIUM).format(Date(e.lastModified)) else "" }
    val sub = if (e.isFolder) "Folder" else "${e.pageIds.size} page${if (e.pageIds.size == 1) "" else "s"}  ·  $date"
    Row(
        Modifier.fillMaxWidth().cellBackground(selected).combinedClickable(onClick = onClick, onLongClick = onLongClick).padding(horizontal = Rm.NavigatorMargin, vertical = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Thumb(app, e, Modifier.width(96.dp).height(136.dp))
        Spacer(Modifier.width(32.dp))
        Column(Modifier.weight(1f)) {
            Text(e.name, style = RmText.LabelLg, color = fg, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(sub, style = RmText.Caption, color = fg)
        }
        if (e.pinned) InkIcons.StarInverted(tint = fg, size = Rm.IconSmall)
    }
}

/**
 * The firmware's action bar, shown while items are selected: black, a Cancel button, then an icon over a label per action
 * (Rename only for a single item).
 */
@Composable
private fun ActionBar(app: AppController, s: Screen.Files, selection: List<LibraryEntry>, onCancel: () -> Unit, onDialog: (Dialogs) -> Unit, onDone: () -> Unit) {
    @Composable fun action(label: String, onClick: () -> Unit, icon: @Composable () -> Unit) =
        Column(Modifier.heightIn(min = Rm.NavigationHeader).tap(onClick = onClick).padding(horizontal = 16.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
            icon(); Text(label, style = RmText.LabelSmLow, color = Ink.White, maxLines = 1)
        }
    Row(Modifier.fillMaxWidth().height(Rm.NavigationHeader).background(Ink.Black).padding(horizontal = 16.dp), verticalAlignment = Alignment.CenterVertically) {
        Text("Cancel", style = RmText.LabelLgStrong, color = Ink.White, modifier = Modifier.heightIn(min = Rm.Control).tap(onClick = onCancel).padding(horizontal = 16.dp).wrapContentHeight(Alignment.CenterVertically))
        Spacer(Modifier.weight(1f))
        if (s.section == Section.TRASH) {
            action("Restore", { selection.forEach { app.restore(it) }; onDone() }) { InkIcons.Restore(tint = Ink.White) }
            action("Delete", { onDialog(Dialogs.Delete(selection)) }) { InkIcons.Trash(tint = Ink.White) }
        } else {
            if (selection.size == 1) action("Rename", { onDialog(Dialogs.Rename(selection[0])) }) { InkIcons.Rename(tint = Ink.White) }
            val allPinned = selection.all { it.pinned }
            action("Favorite", { selection.filter { it.pinned == allPinned }.forEach { app.togglePinned(it) }; onDone() }) {
                if (allPinned) InkIcons.StarInverted(tint = Ink.White) else InkIcons.StarOutline(tint = Ink.White)
            }
            action("Move", { onDialog(Dialogs.Move(selection)) }) { InkIcons.Move(tint = Ink.White) }
            action("Delete", { onDialog(Dialogs.Delete(selection)) }) { InkIcons.Trash(tint = Ink.White) }
        }
    }
}

/** Notebook thumbnails are taller than the page: 310 x 440 px inside a 342 px cell. */
private const val THUMB_ASPECT = 310f / 440f

/**
 * A notebook's first page. Notebooks get a dark spine on the left, PDFs a folded top-right corner
 * (the same cues the tablet uses to tell document types apart at a glance).
 */
@Composable
internal fun Thumb(app: AppController, e: LibraryEntry, modifier: Modifier) {
    val shape = androidx.compose.ui.graphics.RectangleShape
    if (e.isFolder) {
        Box(modifier.border(Rm.Outline, Ink.Black, shape).background(Ink.White, shape), contentAlignment = Alignment.Center) { InkIcons.Folder() }
        return
    }
    val bmp by produceState<Bitmap?>(null, e.id, e.lastModified, e.pageIds.firstOrNull(), e.template) {
        value = withContext(Dispatchers.IO) { runCatching { app.thumbnails.render(e, 0, 320) }.getOrNull() }
    }
    Box(modifier.clip(shape).border(Rm.Outline, Ink.Black, shape).background(Ink.White)) {
        bmp?.let { Image(it.asImageBitmap(), contentDescription = e.name, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize()) }
        if (e.fileType == "pdf") {
            Canvas(Modifier.align(Alignment.TopEnd).size(56.dp)) {
                val w = size.width
                val fold = androidx.compose.ui.graphics.Path().apply { moveTo(0f, 0f); lineTo(w, w); lineTo(w, 0f); close() }
                drawPath(fold, androidx.compose.ui.graphics.Color.White)
                drawLine(androidx.compose.ui.graphics.Color.Black, androidx.compose.ui.geometry.Offset(0f, 0f), androidx.compose.ui.geometry.Offset(w, w), strokeWidth = 4f)
            }
        } else {
            Box(Modifier.align(Alignment.CenterStart).fillMaxHeight().width(18.dp).background(Color(0xFF3A3A3A)))
        }
    }
}

@Composable
private fun NewNotebookDialog(app: AppController, parentId: String, onDismiss: () -> Unit) {
    var name by remember { mutableStateOf(app.suggestName(parentId)) }
    var template by remember { mutableStateOf(app.prefs.defaultTemplate) }
    EDialog("New notebook", onDismiss, actions = {
        EButton("Cancel", onDismiss)
        EButton("Create", { app.prefs.defaultTemplate = template; app.newNotebook(name.trim(), template, parentId); onDismiss() }, enabled = name.isNotBlank(), selected = name.isNotBlank())
    }) {
        NameField(name) { name = it }
        Spacer(Modifier.height(24.dp))
        Text("Page template", style = RmText.Label, color = Ink.Grey)
        PageTemplate.entries.forEach { t -> ChoiceRow(t.label, template == t, { template = t }) }
    }
}

@Composable
private fun MoveDialog(lib: Library, es: List<LibraryEntry>, onDismiss: () -> Unit, onPick: (String) -> Unit) {
    // A folder can't be moved into itself or one of its own descendants.
    fun isInside(id: String): Boolean {
        var cur: String? = id
        val seen = HashSet<String>()
        while (!cur.isNullOrEmpty() && seen.add(cur)) { if (es.any { it.id == cur }) return true; cur = lib[cur]?.parentId }
        return false
    }
    val targets = lib.entries.filter { it.isFolder && it.parentId != Library.TRASH && !isInside(it.id) }.sortedBy { (lib.path(it.id) + it.name).joinToString(" / ").lowercase() }
    val parent = es.map { it.parentId }.distinct().singleOrNull()
    EDialog(if (es.size == 1) "Move “${es[0].name}” to" else "Move ${es.size} items to", onDismiss, actions = { EButton("Cancel", onDismiss) }) {
        Column(Modifier.heightIn(max = 840.dp).verticalScroll(rememberScrollState())) {
            ChoiceRow("My files", parent == "", { onPick("") })
            targets.forEach { f -> ChoiceRow((lib.path(f.id) + f.name).joinToString(" / "), parent == f.id, { onPick(f.id) }) }
        }
    }
}

@Composable
private fun Sidebar(app: AppController, s: Screen.Files, onClose: () -> Unit) {
    Row(Modifier.fillMaxSize()) {
        // navigatorSidebarWidth 414, 120 px items (icon, label), 2 px right border; it starts below the header so the menu button stays visible.
        Column(Modifier.padding(top = Rm.NavigationHeader).width(Rm.SidebarWidth).fillMaxHeight().background(Ink.White).drawWithContent { drawContent(); drawLine(Color.Black, Offset(size.width - 1f, 0f), Offset(size.width - 1f, size.height), strokeWidth = 2f) }) {
            @Composable fun item(label: String, selected: Boolean, onClick: () -> Unit, icon: @Composable (Color) -> Unit) {
                val fg = if (selected) Ink.White else Ink.Black
                Row(Modifier.fillMaxWidth().height(Rm.SidebarItem).background(if (selected) Ink.Black else Ink.White).tap(onClick = onClick).padding(horizontal = 32.dp), verticalAlignment = Alignment.CenterVertically) {
                    icon(fg); Spacer(Modifier.width(24.dp)); Text(label, style = RmText.LabelLg, color = fg)
                }
            }
            item("My files", s.section == Section.MY_FILES, { app.screen = Screen.Files(Section.MY_FILES); onClose() }) { InkIcons.MyFiles(tint = it) }
            item("Favorites", s.section == Section.FAVORITES, { app.screen = Screen.Files(Section.FAVORITES); onClose() }) { InkIcons.StarOutline(tint = it) }
            Spacer(Modifier.weight(1f))
            item("Trash", s.section == Section.TRASH, { app.screen = Screen.Files(Section.TRASH); onClose() }) { InkIcons.Trash(tint = it) }
            Rule()
            item("Settings", false, { app.screen = Screen.Settings; onClose() }) { InkIcons.Settings(tint = it) }
        }
        // Tap outside to close. (No scrim animation: it would smear on e-ink.)
        Box(Modifier.weight(1f).fillMaxHeight().background(Ink.White.copy(alpha = 0.55f)).tap(onClick = onClose))
    }
}
