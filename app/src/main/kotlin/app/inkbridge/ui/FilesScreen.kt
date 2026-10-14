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
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import app.inkbridge.AndroidPageCanvas
import androidx.compose.ui.graphics.nativeCanvas
import app.inkbridge.rm.render.PageRenderer
import app.inkbridge.rm.scene.SceneTree
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
    var tagFilter by remember(s) { mutableStateOf(setOf<String>()) }
    var tagTab by remember(s) { mutableStateOf(0) } // 0 = All, 1 = Documents

    val pdfPicker = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        if (uri != null) app.importPdf(uri, s.folderId)
    }

    val entries = remember(lib, s, prefs.sortBy, prefs.sortReversed, tagFilter, tagTab) { visibleEntries(lib, s, prefs.sortBy, prefs.sortReversed, tagFilter, tagTab == 1) }
    val title = when {
        s.section != Section.MY_FILES -> s.section.title
        s.folderId.isEmpty() -> "My files"
        else -> lib[s.folderId]?.name ?: "My files"
    }

    Box(Modifier.fillMaxSize()) {
        Column(Modifier.fillMaxSize()) {
            val selection = entries.filter { it.id in picked }
            if (selection.isNotEmpty()) {
                ActionBar(app, s, selection, entries, onCancel = { picked = emptySet() }, onSelectAll = { picked = entries.map { it.id }.toSet() }, onDialog = { dialog = it }, onDone = { picked = emptySet() })
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
                if (s.section != Section.TRASH && s.section != Section.TAGS) {
                    var sortMenu by remember { mutableStateOf(false) }
                    val sortLabel = when { prefs.sortBy == SortBy.MODIFIED -> "Last modified"; prefs.sortReversed -> "Alphabetical (Z-A)"; else -> "Alphabetical (A-Z)" }
                    // The navigator's dropdown: a 360 x 72 px header (label and chevron). Opened, the header gains a border and the
                    // list hangs directly below it, one shape, 80 px rows with the current choice inverted.
                    Box(Modifier.width(Rm.DropdownWidth).height(72.dp).tap { sortMenu = true }.padding(end = 16.dp), contentAlignment = Alignment.CenterEnd) {
                        Row(verticalAlignment = Alignment.CenterVertically) { Text(sortLabel, style = RmText.Label); InkIcons.ChevronDown() }
                        RmMenu(sortMenu, { sortMenu = false }, MenuSide.OVER, Rm.DropdownWidth) {
                            Row(Modifier.fillMaxWidth().height(72.dp).tap { sortMenu = false }.padding(start = 16.dp, end = 16.dp), verticalAlignment = Alignment.CenterVertically) {
                                Text(sortLabel, style = RmText.Label, modifier = Modifier.weight(1f)); InkIcons.ChevronUp()
                            }
                            Rule()
                            @Composable fun item(label: String, checked: Boolean = false, action: () -> Unit) =
                                RmMenuItem(label, { sortMenu = false; action() }, selected = checked)
                            item("Last modified", prefs.sortBy == SortBy.MODIFIED && !prefs.sortReversed) { prefs.sortBy = SortBy.MODIFIED; prefs.sortReversed = false }
                            item("Alphabetical (A-Z)", prefs.sortBy == SortBy.NAME && !prefs.sortReversed) { prefs.sortBy = SortBy.NAME; prefs.sortReversed = false }
                            item("Alphabetical (Z-A)", prefs.sortBy == SortBy.NAME && prefs.sortReversed) { prefs.sortBy = SortBy.NAME; prefs.sortReversed = true }
                            Rule()
                            item("Grid view", prefs.gridView) { prefs.gridView = true }
                            item("List view", !prefs.gridView) { prefs.gridView = false }
                        }
                    }
                }
            }
            if (s.section == Section.TAGS) TagsFilter(lib, tagFilter, tagTab, onTab = { tagTab = it }, onToggle = { t -> tagFilter = if (t in tagFilter) tagFilter - t else tagFilter + t })
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
                        Section.NOTEBOOKS -> "No notebooks yet.\nTap + to make one."
                        Section.PDFS -> "No PDFs yet.\nImport one from the menu to annotate it."
                        Section.TAGS -> "No tagged items yet.\nPress and hold a notebook or folder in My files, then tap Tag."
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

        // --- the create menu: a pill with search and "+" (the trash view gets a delete button instead) ---
        if (s.section != Section.TRASH || entries.isNotEmpty()) {
            var createOpen by remember { mutableStateOf(false) }
            val showCreate = s.section != Section.TRASH
            val creates = s.section == Section.MY_FILES
            val canNotebook = s.section == Section.MY_FILES || s.section == Section.NOTEBOOKS
            Box(Modifier.align(Alignment.BottomCenter).padding(bottom = Rm.CreateMenuBottomMargin)) {
                // The 4 px white ring around the outline, so the pill stays crisp over thumbnails.
                Row(
                    Modifier.border(4.dp, Ink.White, CircleShape).padding(4.dp).height(Rm.CreateMenuHeight - 8.dp).background(Ink.White, CircleShape).border(Rm.Outline, Ink.Black, CircleShape),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    if (s.section == Section.TRASH) {
                        Box(Modifier.size(Rm.ToolButton).tap { dialog = Dialogs.EmptyTrash }.semantics { contentDescription = "Empty trash" }, contentAlignment = Alignment.Center) { InkIcons.TrashDelete() }
                    } else {
                        Box(Modifier.size(Rm.ToolButton).tap { createOpen = false; app.screen = Screen.Search }.semantics { contentDescription = "Search" }, contentAlignment = Alignment.Center) { InkIcons.Search() }
                        if (showCreate) {
                            Box(Modifier.width(Rm.Outline).height(64.dp).background(Ink.Black))
                            Box(Modifier.size(Rm.ToolButton).tap { createOpen = !createOpen }.semantics { contentDescription = if (createOpen) "Close" else "Create" }, contentAlignment = Alignment.Center) {
                                if (createOpen) InkIcons.CloseX() else InkIcons.Plus()
                            }
                        }
                    }
                }
                // The create card: centred 24 px above the pill, 40 px padding, a label, then icon + title + caption per action.
                RmMenu(createOpen, { createOpen = false }, MenuSide.ABOVE_CENTER, width = null, gap = 24.dp + 8.dp) {
                    Column(Modifier.padding(40.dp)) {
                        Text("Create new", style = RmText.Label)
                        @Composable fun action(icon: @Composable () -> Unit, title: String, caption: String, onClick: () -> Unit) =
                            Row(Modifier.padding(top = 40.dp).tap { createOpen = false; onClick() }, verticalAlignment = Alignment.CenterVertically) {
                                icon(); Spacer(Modifier.width(20.dp))
                                Column { Text(title, style = RmText.LabelLgStrong); Text(caption, style = RmText.Caption) }
                            }
                        if (canNotebook) action({ InkIcons.Notebook() }, "Notebook", "Record ideas, write, and sketch") { dialog = Dialogs.NewNotebook }
                        if (creates) action({ InkIcons.FolderOutline() }, "Folder", "Organize your content") { dialog = Dialogs.NewFolder }
                        action({ InkIcons.QuickSheet() }, "Quick sheet", "Jot down your thoughts") { app.newQuickSheet() }
                    }
                }
            }
        }

        if (menuOpen) Sidebar(app, s, onClose = { menuOpen = false }, onImport = { pdfPicker.launch(arrayOf("application/pdf")) })
    }

    when (val d = dialog) {
        null -> Unit
        Dialogs.NewNotebook -> NewNotebookScreen(app, s.folderId, onDismiss = { dialog = null })
        Dialogs.NewFolder -> NewFolderScreen(app, s.folderId, onDismiss = { dialog = null })
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

private fun visibleEntries(lib: Library, s: Screen.Files, sort: SortBy, reversed: Boolean, tags: Set<String>, documentsOnly: Boolean): List<LibraryEntry> {
    val base = when (s.section) {
        Section.MY_FILES -> lib.children(s.folderId)
        // "Filter by": every notebook (or PDF) outside the trash, whichever folder it is in.
        Section.NOTEBOOKS -> lib.entries.filter { !it.isFolder && it.fileType == "notebook" && it.parentId != Library.TRASH }
        Section.PDFS -> lib.entries.filter { !it.isFolder && it.fileType == "pdf" && it.parentId != Library.TRASH }
        Section.FAVORITES -> lib.entries.filter { it.pinned && it.parentId != Library.TRASH }
        // Tagged items anywhere outside the trash; with chips selected, only those carrying every selected tag.
        Section.TAGS -> lib.entries.filter { it.parentId != Library.TRASH && it.tags.isNotEmpty() && it.tags.containsAll(tags) && (!documentsOnly || !it.isFolder) }
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
        Box {
            Thumb(app, e, Modifier.fillMaxWidth().aspectRatio(THUMB_ASPECT))
            // Tags sit in the thumbnail's top-left corner (ThumbnailTags, 15 px in).
            if (e.tags.isNotEmpty()) Row(Modifier.align(Alignment.TopStart).padding(start = 30.dp, top = 15.dp, end = 15.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                e.tags.take(2).forEach { TagPill(it, selected = false, onClick = {}, small = true, modifier = Modifier.widthIn(max = 120.dp)) }
                if (e.tags.size > 2) TagPill("+${e.tags.size - 2}", selected = false, onClick = {}, small = true)
            }
        }
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
 * The firmware's action bar, shown while items are selected: black, a Cancel button, then an icon over a label per action:
 * Rename (single item only), Favorite, Tag, Duplicate, Move, Delete and More. The Tag and More menus hang from their buttons.
 */
@Composable
private fun ActionBar(
    app: AppController, s: Screen.Files, selection: List<LibraryEntry>, all: List<LibraryEntry>,
    onCancel: () -> Unit, onSelectAll: () -> Unit, onDialog: (Dialogs) -> Unit, onDone: () -> Unit,
) {
    val context = androidx.compose.ui.platform.LocalContext.current
    var tagOpen by remember { mutableStateOf(false) }
    var tagOpenCount by remember { mutableIntStateOf(0) } // a fresh popup state for every opening
    var moreOpen by remember { mutableStateOf(false) }
    @Composable fun action(label: String, onClick: () -> Unit, menu: (@Composable () -> Unit)? = null, icon: @Composable () -> Unit) =
        Box {
            Column(Modifier.heightIn(min = Rm.NavigationHeader).tap(onClick = onClick).padding(horizontal = 16.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                icon(); Text(label, style = RmText.LabelSmLow, color = Ink.White, maxLines = 1)
            }
            menu?.invoke()
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
            action("Tag", { if (!tagOpen) tagOpenCount++; tagOpen = !tagOpen; moreOpen = false }, menu = {
                TagPopup(app, selection, show = tagOpen, openId = tagOpenCount, onClose = { tagOpen = false })
            }) { InkIcons.Tag(tint = Ink.White) }
            action("Duplicate", { app.duplicate(selection); onDone() }) { InkIcons.Duplicate(tint = Ink.White) }
            action("Move", { onDialog(Dialogs.Move(selection)) }) { InkIcons.Move(tint = Ink.White) }
            action("Delete", { onDialog(Dialogs.Delete(selection)) }) { InkIcons.Trash(tint = Ink.White) }
            action("More", { moreOpen = !moreOpen; tagOpen = false }, menu = {
                // The More foldout hangs from the button, right edges aligned, sharing its border.
                RmMenu(moreOpen, { moreOpen = false }, MenuSide.BELOW_END, Rm.ToolboxFoldoutWidth) {
                    RmFoldoutItem("Select all", { moreOpen = false; onSelectAll() }) { InkIcons.Check(tint = it) }
                    RmFoldoutItem("Export", {
                        moreOpen = false
                        app.exportDocuments(selection, java.io.File(context.getExternalFilesDir(null) ?: context.filesDir, "exports"))
                        onDone()
                    }, enabled = selection.any { !it.isFolder }, topDivider = true) { InkIcons.Export(tint = it) }
                }
            }) { InkIcons.More(tint = Ink.White) }
        }
    }
}

/**
 * The tag menu (TagSelectionPopup): 594 px wide, hanging from the Tag button. Tag chips (partly selected when only some of the
 * chosen items carry the tag), a divider, and a "New tag" row. Changes are applied when it closes.
 */
@OptIn(androidx.compose.foundation.layout.ExperimentalLayoutApi::class)
@Composable
private fun TagPopup(app: AppController, selection: List<LibraryEntry>, show: Boolean, openId: Int, onClose: () -> Unit) {
    val known = remember(app.library) { app.library.entries.filter { it.parentId != Library.TRASH }.flatMap { it.tags }.distinct().sorted() }
    // 0 = off for every item, 1 = some, 2 = all
    var state by remember(openId, selection) { mutableStateOf(known.associateWith { t -> selection.count { t in it.tags }.let { n -> if (n == 0) 0 else if (n == selection.size) 2 else 1 } }) }
    var created by remember(openId) { mutableStateOf(listOf<String>()) }
    var newTag by remember { mutableStateOf(false) }
    fun apply() {
        val shown = state + created.associateWith { 2 }
        selection.forEach { e ->
            var tags = e.tags
            shown.forEach { (t, st) -> if (st == 2 && t !in tags) tags = tags + t else if (st == 0) tags = tags - t } // partial = leave as is
            if (tags != e.tags) app.setTags(e, tags)
        }
    }
    // Changes are applied whenever the popup closes (or the selection is left while it is open).
    val applyLatest by rememberUpdatedState<() -> Unit>({ apply() })
    DisposableEffect(show) { onDispose { if (show) applyLatest() } }
    RmMenu(show, onClose, MenuSide.BELOW_END, 594.dp) {
        val chips = known + created.filter { it !in known }
        androidx.compose.foundation.layout.FlowRow(Modifier.fillMaxWidth().padding(30.dp), horizontalArrangement = Arrangement.spacedBy(10.dp), verticalArrangement = Arrangement.spacedBy(40.dp)) {
            chips.forEach { t ->
                val st = (state + created.associateWith { 2 })[t] ?: 0
                TagPill(t, selected = st == 2, partial = st == 1, onClick = {
                    if (t in created) created = created - t else state = state + (t to if (st == 2) 0 else 2)
                })
            }
            if (chips.isEmpty()) Text("No tags yet", style = RmText.Caption, color = Ink.Grey)
        }
        RmFoldoutItem("New tag", { newTag = true }, topDivider = true) { InkIcons.Plus(tint = it) }
    }
    if (newTag) NameDialog("New tag", "", "Add", { newTag = false }) { name ->
        val clean = name.trim()
        if (clean.isNotEmpty() && clean !in known) created = created + clean
        else if (clean in known) state = state + (clean to 2)
        newTag = false
    }
}

/** The tag row of the Tags view: All / Documents tabs, then the tag chips (tap to filter). */
@OptIn(androidx.compose.foundation.layout.ExperimentalLayoutApi::class)
@Composable
private fun TagsFilter(lib: Library, selected: Set<String>, tab: Int, onTab: (Int) -> Unit, onToggle: (String) -> Unit) {
    val tags = remember(lib) { lib.entries.filter { it.parentId != Library.TRASH }.flatMap { it.tags }.distinct().sorted() }
    Column(Modifier.fillMaxWidth().padding(horizontal = Rm.NavigatorMargin)) {
        Row {
            listOf("All" to 200.dp, "Documents" to 270.dp).forEachIndexed { i, (label, w) ->
                Column(Modifier.width(w).tap { onTab(i) }, horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(label, style = if (tab == i) RmText.LabelLgStrong else RmText.LabelLg, modifier = Modifier.padding(vertical = 20.dp))
                    Box(Modifier.fillMaxWidth().height(if (tab == i) 6.dp else Rm.Outline).background(Ink.Black))
                }
            }
        }
        Spacer(Modifier.height(24.dp))
        androidx.compose.foundation.layout.FlowRow(horizontalArrangement = Arrangement.spacedBy(20.dp), verticalArrangement = Arrangement.spacedBy(20.dp)) {
            tags.forEach { t -> TagPill(t, selected = t in selected, onClick = { onToggle(t) }) }
            if (tags.isEmpty()) Text("Tags you add show up here.", style = RmText.Caption, color = Ink.Grey)
        }
        Spacer(Modifier.height(24.dp))
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

/** A create form that fills the whole screen (not a popup): a navigation bar with Back, the form, and the main action at the bottom right. */
@Composable
private fun CreateForm(title: String, confirm: String, enabled: Boolean, onDismiss: () -> Unit, onConfirm: () -> Unit, content: @Composable ColumnScope.() -> Unit) {
    androidx.activity.compose.BackHandler(onBack = onDismiss)
    Column(Modifier.fillMaxSize().background(Ink.White).pointerInput(Unit) { detectTapGestures { } }) {
        NavigationBar(title, onDismiss)
        Column(Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(horizontal = 80.dp, vertical = 48.dp), verticalArrangement = Arrangement.spacedBy(24.dp)) { content() }
        Rule()
        Row(Modifier.fillMaxWidth().padding(horizontal = 80.dp, vertical = 32.dp), horizontalArrangement = Arrangement.End) {
            EButton("Cancel", onDismiss)
            Spacer(Modifier.width(24.dp))
            EButton(confirm, onConfirm, enabled = enabled, selected = enabled)
        }
    }
}

@Composable
private fun NewFolderScreen(app: AppController, parentId: String, onDismiss: () -> Unit) {
    var name by remember { mutableStateOf(app.suggestName(parentId, "Folder")) }
    CreateForm("New folder", "Create", name.isNotBlank(), onDismiss, { app.newFolder(name.trim(), parentId); onDismiss() }) {
        Text("Name", style = RmText.Label, color = Ink.Grey)
        NameField(name) { name = it }
    }
}

@Composable
private fun NewNotebookScreen(app: AppController, parentId: String, onDismiss: () -> Unit) {
    var name by remember { mutableStateOf(app.suggestName(parentId)) }
    var template by remember { mutableStateOf(app.prefs.defaultTemplate) }
    CreateForm("New notebook", "Create", name.isNotBlank(), onDismiss, { app.prefs.defaultTemplate = template; app.newNotebook(name.trim(), template, parentId); onDismiss() }) {
        Text("Name", style = RmText.Label, color = Ink.Grey)
        NameField(name) { name = it }
        Spacer(Modifier.height(24.dp))
        Text("Page template", style = RmText.Label, color = Ink.Grey)
        Row(horizontalArrangement = Arrangement.spacedBy(32.dp)) {
            PageTemplate.entries.forEach { t -> TemplateCard(t, template == t, { template = t }, Modifier.width(264.dp)) }
        }
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
private fun Sidebar(app: AppController, s: Screen.Files, onClose: () -> Unit, onImport: () -> Unit) {
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
            // "Filter by" unfolds into Notebooks and PDFs; once one is chosen the item shows it.
            var filterOpen by remember { mutableStateOf(s.section == Section.NOTEBOOKS || s.section == Section.PDFS) }
            val active = s.section.takeIf { it == Section.NOTEBOOKS || it == Section.PDFS }
            item(active?.title ?: "Filter by", active != null && !filterOpen, { filterOpen = !filterOpen }) {
                if (active == Section.PDFS) InkIcons.Document(tint = it) else if (active == Section.NOTEBOOKS) InkIcons.Notebook(tint = it) else InkIcons.Filter(tint = it)
            }
            if (filterOpen) {
                item("Notebooks", s.section == Section.NOTEBOOKS, { app.screen = Screen.Files(Section.NOTEBOOKS); onClose() }) { InkIcons.Notebook(tint = it) }
                item("PDFs", s.section == Section.PDFS, { app.screen = Screen.Files(Section.PDFS); onClose() }) { InkIcons.Document(tint = it) }
            }
            item("Favorites", s.section == Section.FAVORITES, { app.screen = Screen.Files(Section.FAVORITES); onClose() }) { InkIcons.StarOutline(tint = it) }
            item("Tags", s.section == Section.TAGS, { app.screen = Screen.Files(Section.TAGS); onClose() }) { InkIcons.Tag(tint = it) }
            item("Import PDF", false, { onClose(); onImport() }) { InkIcons.Import(tint = it) }
            Spacer(Modifier.weight(1f))
            item("Trash", s.section == Section.TRASH, { app.screen = Screen.Files(Section.TRASH); onClose() }) { InkIcons.Trash(tint = it) }
            Rule()
            item("Guides", false, { app.screen = Screen.Guides; onClose() }) { InkIcons.Compass(tint = it) }
            item("Settings", false, { app.screen = Screen.Settings; onClose() }) { InkIcons.Settings(tint = it) }
        }
        // Tap outside to close. (No scrim animation: it would smear on e-ink.)
        Box(Modifier.weight(1f).fillMaxHeight().background(Ink.White.copy(alpha = 0.55f)).tap(onClick = onClose))
    }
}
