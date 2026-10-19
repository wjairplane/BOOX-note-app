package app.inkbridge.ui

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.os.BatteryManager
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import app.inkbridge.AppController
import app.inkbridge.GridSize
import app.inkbridge.Prefs
import app.inkbridge.R
import app.inkbridge.Screen
import app.inkbridge.Section
import app.inkbridge.SortBy
import app.inkbridge.rm.library.Library
import app.inkbridge.rm.library.LibraryEntry
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext

private sealed interface Dialogs {
    data class Rename(val e: LibraryEntry) : Dialogs
    data class PermanentDelete(val es: List<LibraryEntry>) : Dialogs
    data object NewNotebook : Dialogs
    data object NewFolder : Dialogs
    data object EmptyTrash : Dialogs
    data object TagsAll : Dialogs
}

/** The notification bar stays this long (Values.popupTimeout). */
private const val NOTIFICATION_MS = 4000L

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun FilesScreen(app: AppController, s: Screen.Files) {
    val lib = app.library
    val prefs = app.prefs
    var menuOpen by remember { mutableStateOf(false) }
    var dialog by remember { mutableStateOf<Dialogs?>(null) }
    // Press and hold selects; the header then becomes the black action bar.
    var picked by remember(s) { mutableStateOf(setOf<String>()) }
    var tagMode by remember(s) { mutableStateOf(false) }
    var tagFilter by remember(s) { mutableStateOf(setOf<String>()) }
    var tagTab by remember(s) { mutableStateOf(0) } // 0 = All, 1 = Pages, 2 = Documents
    // Press and hold on a tag pill selects it for editing (the header then offers Rename and Delete).
    var tagEdit by remember(s) { mutableStateOf(setOf<String>()) }
    var tagRename by remember { mutableStateOf<String?>(null) }
    var tagDelete by remember { mutableStateOf(false) }
    LaunchedEffect(s, lib) { app.pendingSelect?.let { id -> if (lib[id] != null) { picked = setOf(id); app.pendingSelect = null } } }
    // The notification bar goes away by itself.
    LaunchedEffect(app.message) { if (app.message.isNotEmpty()) { delay(NOTIFICATION_MS); app.message = "" } }

    val pdfPicker = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        if (uri != null) app.importPdf(uri, s.folderId)
    }

    val entries = remember(lib, s, prefs.sortBy, prefs.sortReversed, tagFilter, tagTab) {
        // Page tags aren't supported, so the Pages tab is always empty.
        if (s.section == Section.TAGS && tagTab == 1) emptyList() else visibleEntries(lib, s, prefs.sortBy, prefs.sortReversed, tagFilter, tagTab == 2)
    }
    val movingItems = app.moving?.mapNotNull { lib[it] }
    val isMoving = movingItems != null
    val inFolder = s.section == Section.MY_FILES && s.folderId.isNotEmpty()
    val goUp: (() -> Unit)? = if (inFolder) ({ app.screen = Screen.Files(Section.MY_FILES, lib[s.folderId]?.parentId ?: "") }) else null

    Box(Modifier.fillMaxSize()) {
        Column(Modifier.fillMaxSize()) {
            val selection = entries.filter { it.id in picked }
            if (movingItems != null) {
                MovingBar(app, s, movingItems, onNewFolder = { dialog = Dialogs.NewFolder }, onCancel = { picked = movingItems.map { it.id }.toSet(); app.moving = null })
            } else if (tagEdit.isNotEmpty() && s.section == Section.TAGS) {
                TagEditBar(tagEdit, onCancel = { tagEdit = emptySet() }, onRename = { tagRename = tagEdit.first() }, onDelete = { tagDelete = true })
            } else if (selection.isNotEmpty()) {
                if (tagMode) TagBar(app, selection, onBack = { tagMode = false })
                else ActionBar(
                    app, s, selection, onCancel = { picked = emptySet() }, onTag = { tagMode = true },
                    onRename = { dialog = Dialogs.Rename(it) }, onDelete = {
                        if (s.section == Section.TRASH) dialog = Dialogs.PermanentDelete(selection) else { app.trashAll(selection); picked = emptySet() }
                    },
                    onMove = { app.moving = selection.map { it.id }; if (s.section != Section.MY_FILES) app.screen = Screen.Files(Section.MY_FILES, "") },
                    onDone = { picked = emptySet() },
                )
            } else {
                // --- ContentHeader (120 px): the menu button, the wordmark, the battery ---
                Box(Modifier.fillMaxWidth().height(Rm.NavigationHeader).padding(horizontal = 8.dp)) {
                    IconBtn("Menu", { menuOpen = true }, Modifier.align(Alignment.CenterStart), size = Rm.ToolButton) { InkIcons.Menu(tint = it) }
                    Text("InkBridge", style = RmText.Wordmark, modifier = Modifier.align(Alignment.Center))
                    val (battery, _) = rememberBattery()
                    BatteryIndicator(battery, highlighted = battery <= 10, modifier = Modifier.align(Alignment.CenterEnd).padding(end = 48.dp).semantics { contentDescription = "Battery" })
                }
            }
            // --- ExplorerHeader (120 px): breadcrumbs and the sort dropdown ---
            Row(Modifier.fillMaxWidth().height(Rm.NavigationHeader).padding(start = Rm.ViewMargin + 10.dp, end = 15.dp), verticalAlignment = Alignment.CenterVertically) {
                Breadcrumbs(app, lib, s, Modifier.weight(1f))
                if (entries.isNotEmpty()) SortDropdown(prefs, trash = s.section == Section.TRASH)
            }
            if (s.section == Section.TAGS) TagsFilter(
                lib, if (tagEdit.isNotEmpty()) tagEdit else tagFilter, tagTab, onTab = { tagTab = it },
                onToggle = { t ->
                    if (tagEdit.isNotEmpty()) tagEdit = if (t in tagEdit) tagEdit - t else tagEdit + t
                    else tagFilter = if (t in tagFilter) tagFilter - t else tagFilter + t
                },
                onLongPress = { t -> if (picked.isEmpty() && !isMoving) tagEdit = tagEdit + t },
            )

            // --- content ---
            val folders = entries.filter { it.isFolder }
            val notebooks = entries.filter { !it.isFolder }
            val toggle: (LibraryEntry) -> Unit = { e -> picked = if (e.id in picked) picked - e.id else picked + e.id }
            val select: (LibraryEntry) -> Unit = { e -> if (picked.isNotEmpty() && !isMoving) toggle(e) else open(app, e, s, isMoving) }
            // Starting a selection while moving is not possible: long-press just opens nothing.
            val longPress: (LibraryEntry) -> Unit = { e -> if (!isMoving) toggle(e) }
            Box(
                Modifier.weight(1f).fillMaxWidth().then(
                    if (goUp != null) Modifier.pointerInput(s) {
                        // A swipe to the right goes up one folder (there is no Up button).
                        var total = 0f
                        detectHorizontalDragGestures(onDragStart = { total = 0f }, onDragEnd = { if (total > size.width / 5f) goUp() }) { _, d -> total += d }
                    } else Modifier,
                ),
            ) {
                if (entries.isEmpty()) {
                    val (title, body) = emptyText(s, tagFilter.isNotEmpty())
                    EmptyState(title, body, emptyArt(s, tagFilter.isNotEmpty()))
                } else if (prefs.gridView) {
                    // Cells are a third, a quarter or a sixth of the 1404 px screen less the 18 px margins (4 columns: 342 px cells).
                    LazyVerticalGrid(
                        GridCells.Fixed(prefs.gridSize.columns), contentPadding = PaddingValues(start = Rm.ViewMargin, end = Rm.ViewMargin, bottom = Rm.CreateMenuBottomMargin + Rm.CreateMenuHeight),
                    ) {
                        items(folders, key = { it.id }) { e -> FolderCell(lib, e, e.id in picked, onClick = { select(e) }, onLongClick = { longPress(e) }) }
                        // The firmware shows the folders in a grid of their own above the documents: the documents start on a new row.
                        item(span = { androidx.compose.foundation.lazy.grid.GridItemSpan(maxLineSpan) }) { Spacer(Modifier.height(0.dp)) }
                        items(notebooks, key = { it.id }) { e -> NotebookCell(app, e, e.id in picked, dimmed = isMoving, small = prefs.gridSize == GridSize.SMALL, onClick = { select(e) }, onLongClick = { longPress(e) }) }
                    }
                } else {
                    LazyColumn(contentPadding = PaddingValues(start = Rm.ViewMargin, end = Rm.ViewMargin, bottom = Rm.CreateMenuBottomMargin + Rm.CreateMenuHeight)) {
                        items(entries, key = { it.id }) { e ->
                            if (e.isFolder) FolderRow(lib, e, e.id in picked, null, onClick = { select(e) }, onLongClick = { longPress(e) })
                            else NotebookRow(app, e, e.id in picked, dimmed = isMoving, path = null, onClick = { select(e) }, onLongClick = { longPress(e) })
                        }
                    }
                }
            }
        }

        // --- the create menu: a pill with search and "+" (the trash view gets a delete button instead). Hidden while selecting or moving. ---
        if ((s.section != Section.TRASH || entries.isNotEmpty()) && picked.isEmpty() && !isMoving) {
            var createOpen by remember { mutableStateOf(false) }
            val showCreate = s.section != Section.TRASH
            val creates = s.section == Section.MY_FILES
            val canNotebook = s.section == Section.MY_FILES || s.section == Section.NOTEBOOKS
            Box(Modifier.align(Alignment.BottomCenter).padding(bottom = Rm.CreateMenuBottomMargin)) {
                // 112 px high, a 2 px outline, the widgets side by side with no divider.
                Row(
                    Modifier.height(Rm.CreateMenuHeight).background(Ink.White, CircleShape).border(Rm.Outline, Ink.Black, CircleShape).padding(horizontal = if (s.section == Section.TRASH) 0.dp else 4.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    if (s.section == Section.TRASH) {
                        Box(Modifier.size(Rm.ToolButton).tap { dialog = Dialogs.EmptyTrash }.semantics { contentDescription = "Empty trash" }, contentAlignment = Alignment.Center) { InkIcons.TrashDelete() }
                    } else {
                        Box(Modifier.size(Rm.ToolButton).tap { createOpen = false; app.searchFrom = s.section; app.screen = Screen.Search }.semantics { contentDescription = "Search" }, contentAlignment = Alignment.Center) { InkIcons.Search() }
                        if (showCreate) {
                            // Tap opens the create card; press and hold makes a quick sheet at once.
                            Box(
                                Modifier.size(Rm.ToolButton).combinedClickable(onClick = { createOpen = !createOpen }, onLongClick = { createOpen = false; app.newQuickSheet() })
                                    .semantics { contentDescription = if (createOpen) "Close" else "Create" },
                                contentAlignment = Alignment.Center,
                            ) { if (createOpen) InkIcons.CloseX() else InkIcons.Plus() }
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

        if (app.message.isNotEmpty()) NotificationBar(app.message, onAction = { app.message = "" }, modifier = Modifier.align(Alignment.BottomCenter), primary = !app.messageIsSuccess)

        if (menuOpen) Sidebar(app, s, onClose = { menuOpen = false }, onImport = { pdfPicker.launch(arrayOf("application/pdf")) })
    }

    tagRename?.let { old ->
        HeaderInputDialog("Enter tag name", "Save", onDismiss = { tagRename = null }, initial = old) { name ->
            app.renameTag(old, name)
            tagFilter = tagFilter.map { if (it == old) name else it }.toSet()
            tagEdit = emptySet(); tagRename = null
        }
    }
    if (tagDelete) {
        val n = tagEdit.size
        ConfirmDialog(
            "Delete $n ${if (n == 1) "tag" else "tags"}?", "If you delete this tag, it'll be removed from all tagged content.", "Delete",
            { tagDelete = false },
        ) { app.deleteTags(tagEdit); tagFilter = tagFilter - tagEdit; tagEdit = emptySet(); tagDelete = false }
    }

    when (val d = dialog) {
        null -> Unit
        Dialogs.NewNotebook -> Box(Modifier.fillMaxSize()) { NewNotebookScreen(app, s.folderId, onDismiss = { dialog = null }) }
        Dialogs.NewFolder -> Box(Modifier.fillMaxSize()) { NewFolderScreen(app, if (s.section == Section.MY_FILES) s.folderId else "", moving = isMoving, onDismiss = { dialog = null }) }
        is Dialogs.Rename -> Box(Modifier.fillMaxSize()) { RenameScreen(app, d.e, onDismiss = { dialog = null }, onDone = { dialog = null; picked = emptySet() }) }
        is Dialogs.PermanentDelete -> ConfirmDialog("Delete permanently?", DELETE_WARNING, "Delete", { dialog = null }) { app.deleteAll(d.es); picked = emptySet(); dialog = null }
        Dialogs.EmptyTrash -> ConfirmDialog("Delete permanently?", DELETE_WARNING, "Delete", { dialog = null }) { app.emptyTrash(); dialog = null }
        Dialogs.TagsAll -> {
            val selection = entries.filter { it.id in picked }
            val all = remember(lib) { knownTags(lib) }
            val on = all.filter { t -> selection.isNotEmpty() && selection.all { t in it.tags } }.toSet()
            Box(Modifier.fillMaxSize()) {
                TagsWindow(all, on, { t -> selection.forEach { e -> app.setTags(e, if (t in on) e.tags - t else (e.tags + t).distinct()) } }, { dialog = null })
            }
        }
    }
}

private const val DELETE_WARNING = "If you delete the items, you won't be able to get them back."

private fun open(app: AppController, e: LibraryEntry, s: Screen.Files, moving: Boolean) {
    if (s.section == Section.TRASH) return // trashed items are managed, not opened
    if (moving && !e.isFolder) return // while moving, only folders open
    app.screen = if (e.isFolder) Screen.Files(Section.MY_FILES, e.id) else Screen.Notebook(e.id, 0)
}

/** Long names are shortened in the middle ("FY27 budge…verview"), keeping both the start and the end readable, as on the tablet. */
internal fun middleEllipsis(name: String, head: Int = 8, tail: Int = 6): String =
    if (name.length <= head + tail + 1) name else name.take(head).trimEnd() + "…" + name.takeLast(tail).trimStart()

/** Shorten [text] in the middle until [fits] says it is narrow enough (the longest result that fits; the text itself when it does). */
internal fun elideMiddle(text: String, fits: (String) -> Boolean): String {
    if (text.isEmpty() || fits(text)) return text
    fun keep(k: Int) = text.take((k + 1) / 2).trimEnd() + "…" + text.takeLast(k / 2).trimStart()
    var lo = 0
    var hi = text.length - 1
    while (lo < hi) {
        val mid = (lo + hi + 1) / 2
        if (fits(keep(mid))) lo = mid else hi = mid - 1
    }
    return keep(lo)
}

/** A single line that is elided in the middle by the width it really has (Text.ElideMiddle). */
@Composable
internal fun MiddleText(text: String, style: TextStyle, color: Color, modifier: Modifier = Modifier) {
    val measurer = rememberTextMeasurer()
    BoxWithConstraints(modifier) {
        val max = constraints.maxWidth
        val shown = remember(text, style, max) {
            if (max == androidx.compose.ui.unit.Constraints.Infinity) text
            else elideMiddle(text) { measurer.measure(it, style, softWrap = false, maxLines = 1).size.width <= max }
        }
        Text(shown, style = style, color = color, maxLines = 1, softWrap = false)
    }
}

internal fun visibleEntries(lib: Library, s: Screen.Files, sort: SortBy, reversed: Boolean, tags: Set<String>, documentsOnly: Boolean): List<LibraryEntry> {
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
    // Folders always come first, and always alphabetically, whatever the sort says (as in the tablet's file browser).
    val folders = base.filter { it.isFolder }.sortedBy { it.name.lowercase() }
    val byName = compareBy<LibraryEntry> { it.name.lowercase() }
    val order: Comparator<LibraryEntry> = when (sort) {
        SortBy.MODIFIED -> compareByDescending<LibraryEntry> { it.lastModified }.then(byName)
        SortBy.LAST_OPENED -> compareByDescending<LibraryEntry> { it.lastOpened }.then(byName)
        SortBy.CREATED -> compareByDescending<LibraryEntry> { it.created }.then(byName)
        SortBy.SIZE -> compareByDescending<LibraryEntry> { it.sizeBytes }.then(byName)
        SortBy.PAGES -> compareByDescending<LibraryEntry> { it.pageIds.size }.then(byName)
        SortBy.NAME -> byName
    }
    return folders + base.filter { !it.isFolder }.sortedWith(if (reversed) order.reversed() else order)
}

// ---- header ----

// The first crumb is serif 48 (bold only while it is the current one); the later ones are Title.Medium: sans 28, regular, and bold for the current one.
private val CrumbFirst = RmText.TitleLg
private val CrumbFirstCurrent = RmText.TitleLg.copy(fontWeight = FontWeight.Bold)
private val CrumbDeep = RmText.sans(28, FontWeight.Normal, 1.5f)
private val CrumbLast = RmText.sans(28, FontWeight.Bold, 1.5f)

/** A crumb is at most a third of the 1026 px content grid wide (navigatorContentGridItemWidth) and shortened in the middle. */
private val CrumbMaxWidth = 342.dp

/** ExplorerBreadcrumb: "My files > A > B", every crumb taps through to that folder; the last one is bold. */
@Composable
private fun Breadcrumbs(app: AppController, lib: Library, s: Screen.Files, modifier: Modifier) {
    // (label, target folder id or null for the section itself)
    val crumbs: List<Pair<String, String?>> =
        if (s.section != Section.MY_FILES) listOf(s.section.title to null)
        else {
            val chain = ArrayList<LibraryEntry>()
            var cur = lib[s.folderId]
            val seen = HashSet<String>()
            while (cur != null && seen.add(cur.id)) { chain.add(0, cur); cur = lib[cur.parentId] }
            listOf("My files" to "") + chain.map { it.name to it.id }
        }
    // Long paths keep the first crumb and the last two; the middle is elided.
    val shown: List<Pair<String, String?>?> = if (crumbs.size > 4) listOf(crumbs.first(), null) + crumbs.takeLast(2) else crumbs
    Row(modifier, verticalAlignment = Alignment.CenterVertically) {
        shown.forEachIndexed { i, c ->
            if (i > 0) InkIcons.ChevronSmallRight()
            val last = i == shown.lastIndex
            val style = if (i == 0) (if (last) CrumbFirstCurrent else CrumbFirst) else if (last) CrumbLast else CrumbDeep
            if (c == null) Text("…", style = CrumbDeep)
            else {
                MiddleText(
                    c.first, style, Ink.Black,
                    Modifier.widthIn(max = CrumbMaxWidth).then(if (c.second != null && !last) Modifier.tap { app.screen = Screen.Files(Section.MY_FILES, c.second!!) } else Modifier),
                )
            }
        }
    }
}

/** The navigator's dropdown button: a 358 x 72 px header (label and chevron); open, "[header]" shows and the content hangs below as one shape. */
@Composable
internal fun Dropdown(label: String, header: String, modifier: Modifier = Modifier, content: @Composable ColumnScope.(close: () -> Unit) -> Unit) {
    var open by remember { mutableStateOf(false) }
    Box(modifier.width(DropdownWidth).height(72.dp).tap { open = true }.padding(end = 16.dp), contentAlignment = Alignment.CenterEnd) {
        Row(verticalAlignment = Alignment.CenterVertically) { Text(label, style = RmText.Label); InkIcons.ChevronDown() }
        RmMenu(open, { open = false }, MenuSide.OVER, DropdownWidth) {
            Row(Modifier.fillMaxWidth().height(72.dp).tap { open = false }.padding(start = 20.dp, end = 16.dp), verticalAlignment = Alignment.CenterVertically) {
                Text(header, style = RmText.Label, modifier = Modifier.weight(1f)); InkIcons.ChevronSmallUp()
            }
            Rule()
            content { open = false }
        }
    }
}

internal val DropdownWidth = 358.dp

/** A sort row: 80 px, a 48 px icon slot (kept even when empty) at x = 20, then the label at x = 84; the chosen one is inverted and shows the ascending/descending arrow. */
@Composable
internal fun SortRow(label: String, selected: Boolean, descending: Boolean, onClick: () -> Unit) {
    val fg = if (selected) Ink.White else Ink.Black
    Row(Modifier.fillMaxWidth().height(Rm.Control).background(if (selected) Ink.Black else Ink.White).tap(onClick = onClick).padding(start = 20.dp, end = 16.dp), verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.size(Rm.Icon), contentAlignment = Alignment.Center) { if (selected) { if (descending) InkIcons.Descend(tint = fg) else InkIcons.Ascend(tint = fg) } }
        Spacer(Modifier.width(16.dp))
        Text(label, style = RmText.Label, color = fg, modifier = Modifier.weight(1f))
    }
}

/** Whether a sort key runs newest/largest first by default (alphabetical runs A to Z). */
internal fun naturalDescending(sort: SortBy) = sort != SortBy.NAME

@Composable
private fun SortDropdown(prefs: Prefs, trash: Boolean) {
    val descending = naturalDescending(prefs.sortBy) != prefs.sortReversed
    fun name(k: SortBy) = when {
        k == SortBy.MODIFIED && trash -> "Date removed"
        k == SortBy.NAME -> if (prefs.sortBy == SortBy.NAME && prefs.sortReversed) "Alphabetical (Z-A)" else "Alphabetical (A-Z)"
        else -> k.label
    }
    Dropdown(name(prefs.sortBy), "Sort by") { close ->
        SortBy.entries.forEach { k ->
            SortRow(name(k), prefs.sortBy == k, descending) {
                close()
                if (prefs.sortBy == k) prefs.sortReversed = !prefs.sortReversed else { prefs.sortBy = k; prefs.sortReversed = false }
            }
        }
        // The grid-size block: the chosen size's name, then four icon-only buttons.
        Rule()
        Row(Modifier.fillMaxWidth().height(72.dp).padding(start = 20.dp), verticalAlignment = Alignment.CenterVertically) { Text(prefs.gridSize.label, style = RmText.Label) }
        Row(Modifier.fillMaxWidth().padding(start = 9.dp, end = 9.dp, bottom = 9.dp)) {
            GridSize.entries.forEach { g ->
                val on = prefs.gridSize == g
                val fg = if (on) Ink.White else Ink.Black
                Box(Modifier.weight(1f).height(80.dp).background(if (on) Ink.Black else Ink.White).tap { close(); prefs.gridSize = g }.semantics { contentDescription = g.label }, contentAlignment = Alignment.Center) {
                    when (g) {
                        GridSize.LARGE -> InkIcons.GridLarge(tint = fg)
                        GridSize.MEDIUM -> InkIcons.GridMedium(tint = fg)
                        GridSize.SMALL -> InkIcons.GridSmall(tint = fg)
                        GridSize.LIST -> InkIcons.ListView(tint = fg)
                    }
                }
            }
        }
    }
}

// ---- empty states ----

private fun emptyText(s: Screen.Files, filtered: Boolean): Pair<String, String> = when (s.section) {
    Section.MY_FILES ->
        if (s.folderId.isNotEmpty()) "Organize in folders" to "You can create documents and move any type of content or subfolder here."
        else "Make your mark" to "Fill this with notebooks and folders. When you're in a rush, **press and hold** the plus icon to create a new quick sheet."
    Section.FAVORITES -> "Collect your best content" to "**Press and hold** any page, document, or folder, and add it to your favorites. They will appear right here."
    Section.NOTEBOOKS -> "Fill this with content" to "You can create notebooks and they will appear here."
    Section.PDFS -> "Create a reading list" to "You can import documents as PDF files. Use Import files in the menu to add PDF files."
    Section.TRASH -> "Clear out the clutter" to "Items you delete from My files will be shown here. You can restore or permanently delete them."
    Section.TAGS ->
        if (filtered) "Try a different combination" to "You can sort your pages with combination of tags. Select one that matches what you're looking for."
        else "Label your work" to "You can add tags to documents and pages to categorize your content. They will appear right here."
}

/** The firmware's empty-state artwork (carved from xochitl's `empty_states` resources, here in grey as on the grey screen); the Trash and Folder ones aren't in that table. */
private fun emptyArt(s: Screen.Files, filtered: Boolean): Int? = when (s.section) {
    Section.MY_FILES -> if (s.folderId.isEmpty()) R.drawable.empty_myfiles else null
    Section.FAVORITES -> R.drawable.empty_favorites
    Section.NOTEBOOKS -> R.drawable.empty_notebooks
    Section.PDFS -> R.drawable.empty_pdf
    Section.TAGS -> R.drawable.empty_tags
    Section.TRASH -> null
}

/** Text with **bold** phrases. */
private fun styled(text: String): AnnotatedString = buildAnnotatedString {
    text.split("**").forEachIndexed { i, part -> if (i % 2 == 1) withStyle(SpanStyle(fontWeight = FontWeight.Bold)) { append(part) } else append(part) }
}

/** The empty view: a 716 px column 20 % down with the artwork, 64 px of space, then a centred serif title and a centred sentence 16 px apart. */
@Composable
private fun EmptyState(title: String, body: String, art: Int?) {
    BoxWithConstraints(Modifier.fillMaxSize()) {
        Column(Modifier.align(Alignment.TopCenter).padding(top = maxHeight * 0.2f).width(716.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(64.dp)) {
            if (art != null) Image(painterResource(art), contentDescription = null)
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Text(title, style = RmText.TitleLg, textAlign = TextAlign.Center)
                Text(styled(body), style = RmText.Body, textAlign = TextAlign.Center)
            }
        }
    }
}

// ---- cells ----

/** The firmware's selected look: the whole cell turns black with white text. */
private fun Modifier.cellBackground(selected: Boolean) = background(if (selected) Ink.Black else Ink.White)

/** A notebook in the grid: a 15 px inset around a 3:4 thumbnail (312 x 416 in a 342 px cell), then the name and a caption. */
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun NotebookCell(app: AppController, e: LibraryEntry, selected: Boolean, dimmed: Boolean, small: Boolean, onClick: () -> Unit, onLongClick: () -> Unit) {
    val fg = if (selected) Ink.White else Ink.Black
    Column(Modifier.fillMaxWidth().alpha(if (dimmed) 0.4f else 1f).cellBackground(selected).combinedClickable(onClick = onClick, onLongClick = onLongClick).padding(15.dp)) {
        Box {
            Thumb(app, e, Modifier.fillMaxWidth().aspectRatio(THUMB_ASPECT))
            // Tags sit in the thumbnail's top-left corner (ThumbnailTags, 15 px in).
            if (e.tags.isNotEmpty()) Row(Modifier.align(Alignment.TopStart).padding(15.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                e.tags.take(2).forEach { TagPill(it, selected = false, onClick = {}, small = true, modifier = Modifier.widthIn(max = 120.dp)) }
                if (e.tags.size > 2) TagPill("+${e.tags.size - 2}", selected = false, onClick = {}, small = true)
            }
        }
        Spacer(Modifier.height(10.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            MiddleText(e.name, RmText.Label, fg, Modifier.weight(1f, fill = false))
            if (e.pinned) InkIcons.StarInverted(tint = fg, size = Rm.IconSmall, modifier = Modifier.padding(start = 8.dp))
        }
        if (!small) Text(pageCaption(e), style = RmText.Caption, color = fg, maxLines = 1)
    }
}

/** The page a notebook was last on, kept inside its page range. */
private fun lastPage(e: LibraryEntry) = e.lastOpenedPage.coerceIn(0, (e.pageIds.size - 1).coerceAtLeast(0))

/** The caption under a notebook or PDF: "Page N of M" (N = the page it was last closed on). */
internal fun pageCaption(e: LibraryEntry) = "Page ${lastPage(e) + 1} of ${e.pageIds.size}"

/** A file size as the firmware writes it ("0 B", "845 kB", "3.2 MB"). */
internal fun formatSize(bytes: Long): String = when {
    bytes < 1000 -> "$bytes B"
    bytes < 1_000_000 -> "${bytes / 1000} kB"
    bytes < 1_000_000_000 -> String.format(java.util.Locale.US, "%.1f MB", bytes / 1e6)
    else -> String.format(java.util.Locale.US, "%.2f GB", bytes / 1e9)
}

/** A folder cell: 75 px high, a 15 px margin and 10 px spacing; the icon says whether it has content, then name, favourite and tag marks. */
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun FolderCell(lib: Library, e: LibraryEntry, selected: Boolean, onClick: () -> Unit, onLongClick: () -> Unit) {
    val fg = if (selected) Ink.White else Ink.Black
    val filled = remember(lib, e.id) { lib.children(e.id).isNotEmpty() }
    Row(
        Modifier.fillMaxWidth().height(75.dp).cellBackground(selected).combinedClickable(onClick = onClick, onLongClick = onLongClick).padding(horizontal = 15.dp),
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        if (filled) InkIcons.FolderInverted(tint = fg) else InkIcons.FolderOutline(tint = fg)
        MiddleText(e.name, RmText.Label, fg, Modifier.weight(1f))
        if (e.pinned) InkIcons.StarInverted(tint = fg, size = Rm.IconSmall)
        if (e.tags.isNotEmpty()) InkIcons.TagInverted(tint = fg, size = Rm.IconSmall)
    }
}

/** A 1 px separator in the item colour. */
@Composable
private fun Hairline(color: Color = Ink.Black) = Box(Modifier.fillMaxWidth().height(1.dp).background(color))

/** A folder in the list view: 75 px, icon, title, marks and the item count at the right. */
@OptIn(ExperimentalFoundationApi::class)
@Composable
internal fun FolderRow(lib: Library, e: LibraryEntry, selected: Boolean, path: String?, onClick: () -> Unit, onLongClick: () -> Unit) {
    val fg = if (selected) Ink.White else Ink.Black
    val count = remember(lib, e.id) { lib.children(e.id).size }
    Column(Modifier.fillMaxWidth().cellBackground(selected)) {
        Row(
            Modifier.fillMaxWidth().height(75.dp).combinedClickable(onClick = onClick, onLongClick = onLongClick).padding(horizontal = 15.dp),
            verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            if (count > 0) InkIcons.FolderInverted(tint = fg) else InkIcons.FolderOutline(tint = fg)
            Column(Modifier.weight(1f)) {
                MiddleText(e.name, RmText.Label, fg)
                if (path != null) Text(path, style = RmText.Caption, color = fg, maxLines = 1, overflow = TextOverflow.Ellipsis)
            }
            if (e.pinned) InkIcons.StarInverted(tint = fg, size = Rm.IconSmall)
            if (e.tags.isNotEmpty()) InkIcons.TagInverted(tint = fg, size = Rm.IconSmall)
            Text(if (count == 1) "1 item" else "$count items", style = RmText.Caption, color = fg)
        }
        Hairline(fg)
    }
}

/** A notebook in the list view: 160 px, 16 px margins and spacing, a 96 x 128 thumbnail, name with favourite, tags and a caption; 1 px separator. */
@OptIn(ExperimentalFoundationApi::class)
@Composable
internal fun NotebookRow(app: AppController, e: LibraryEntry, selected: Boolean, dimmed: Boolean, path: String?, onClick: () -> Unit, onLongClick: () -> Unit) {
    val fg = if (selected) Ink.White else Ink.Black
    Column(Modifier.fillMaxWidth().alpha(if (dimmed) 0.4f else 1f).cellBackground(selected)) {
        Row(
            Modifier.fillMaxWidth().height(160.dp).combinedClickable(onClick = onClick, onLongClick = onLongClick).padding(16.dp),
            verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Thumb(app, e, Modifier.width(96.dp).height(128.dp))
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(e.name, style = RmText.Label, color = fg, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f, fill = false))
                    if (e.pinned) InkIcons.StarInverted(tint = fg, size = 30.dp, modifier = Modifier.padding(start = 8.dp))
                }
                if (e.tags.isNotEmpty()) Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    e.tags.take(3).forEach { TagPill(it, selected = false, onClick = {}, small = true, modifier = Modifier.widthIn(max = 160.dp)) }
                    if (e.tags.size > 3) TagPill("+${e.tags.size - 3}", selected = false, onClick = {}, small = true)
                }
                if (path != null) Text(path, style = RmText.Caption, color = fg, maxLines = 1, overflow = TextOverflow.Ellipsis)
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(40.dp, Alignment.End)) {
                    Text(formatSize(e.sizeBytes), style = RmText.Caption, color = fg, maxLines = 1)
                    Text(pageCaption(e), style = RmText.Caption, color = fg, maxLines = 1)
                }
            }
        }
        Hairline(fg)
    }
}

// ---- action bars ----

/** One button of the black bars: a 48 px icon over a caption, 8 px side padding; [selected] turns it white with black marks. */
@Composable
private fun BarButton(label: String, onClick: () -> Unit, modifier: Modifier = Modifier, selected: Boolean = false, icon: @Composable (Color) -> Unit) {
    val fg = if (selected) Ink.Black else Ink.White
    Column(
        modifier.height(104.dp).background(if (selected) Ink.White else Ink.Black).tap(onClick = onClick).padding(horizontal = 8.dp).widthIn(min = 96.dp),
        horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp, Alignment.CenterVertically),
    ) { icon(fg); Text(label, style = RmText.LabelSmLow, color = fg, maxLines = 1) }
}

/** The bar's text-only Cancel at the left. */
@Composable
private fun BarCancel(onClick: () -> Unit) =
    Text("Cancel", style = RmText.LabelLgStrong, color = Ink.White, modifier = Modifier.heightIn(min = Rm.Control).tap(onClick = onClick).padding(horizontal = 24.dp).wrapContentHeight(Alignment.CenterVertically))

/**
 * The firmware's action bar, shown while items are selected: black, a Cancel button, then an icon over a label per action: Rename (one
 * item), Favorite, Tag, Duplicate (not for folders), Move, Delete and More. Favorite keeps the selection.
 */
@Composable
private fun ActionBar(
    app: AppController, s: Screen.Files, selection: List<LibraryEntry>,
    onCancel: () -> Unit, onTag: () -> Unit, onRename: (LibraryEntry) -> Unit, onDelete: () -> Unit, onMove: () -> Unit, onDone: () -> Unit,
) {
    val context = LocalContext.current
    var moreOpen by remember { mutableStateOf(false) }
    Row(Modifier.fillMaxWidth().height(Rm.NavigationHeader).background(Ink.Black).padding(horizontal = 16.dp), verticalAlignment = Alignment.CenterVertically) {
        BarCancel(onCancel)
        Spacer(Modifier.weight(1f))
        if (s.section == Section.TRASH) {
            BarButton("Restore", { app.restoreAll(selection); onDone() }) { InkIcons.RestoreIcon(tint = it) }
            BarButton("Delete", onDelete) { InkIcons.Trash(tint = it) }
        } else {
            if (selection.size == 1) BarButton("Rename", { onRename(selection[0]) }) { InkIcons.Rename(tint = it) }
            val allPinned = selection.all { it.pinned }
            BarButton("Favorite", { app.setPinned(selection, !allPinned) }) { if (allPinned) InkIcons.StarInverted(tint = it) else InkIcons.StarOutline(tint = it) }
            BarButton("Tag", onTag) { InkIcons.Tag(tint = it) }
            if (selection.none { it.isFolder }) BarButton("Duplicate", { app.duplicate(selection); onDone() }) { InkIcons.Duplicate(tint = it) }
            BarButton("Move", onMove) { InkIcons.Move(tint = it) }
            BarButton("Delete", onDelete) { InkIcons.Trash(tint = it) }
            if (selection.any { !it.isFolder }) Box {
                BarButton("More", { moreOpen = !moreOpen }, selected = moreOpen) { InkIcons.ThreeDots(tint = it) }
                // The More foldout hangs from the button, right edges aligned, sharing its border.
                RmMenu(moreOpen, { moreOpen = false }, MenuSide.BELOW_END, Rm.ToolboxFoldoutWidth) {
                    RmFoldoutItem("Export", {
                        moreOpen = false
                        app.exportDocuments(selection, java.io.File(context.getExternalFilesDir(null) ?: context.filesDir, "exports"))
                        onDone()
                    }) { InkIcons.Send(tint = it) }
                }
            }
        }
    }
}

/** The Tags view's edit bar (a long press on a tag): Cancel, then Rename (exactly one tag chosen) and Delete. */
@Composable
private fun TagEditBar(chosen: Set<String>, onCancel: () -> Unit, onRename: () -> Unit, onDelete: () -> Unit) {
    Row(Modifier.fillMaxWidth().height(Rm.NavigationHeader).background(Ink.Black).padding(horizontal = 16.dp), verticalAlignment = Alignment.CenterVertically) {
        BarCancel(onCancel)
        Spacer(Modifier.weight(1f))
        if (chosen.size == 1) BarButton("Rename", onRename) { InkIcons.Rename(tint = it) }
        BarButton("Delete", onDelete) { InkIcons.Trash(tint = it) }
    }
}

/** The tag bar (entryTagActionBar): a centred "Tag item" title, a selected Back button, and the tag popup hanging from the bar. */
@Composable
private fun TagBar(app: AppController, selection: List<LibraryEntry>, onBack: () -> Unit) {
    var openId by remember { mutableIntStateOf(0) }
    Box(Modifier.fillMaxWidth().height(Rm.NavigationHeader).background(Ink.Black).padding(horizontal = 16.dp)) {
        BarButton("Back", onBack, Modifier.align(Alignment.CenterStart), selected = true) { InkIcons.ChevronLeft(tint = it) }
        Text("Tag item", style = RmText.LabelLgStrong, color = Ink.White, modifier = Modifier.align(Alignment.Center))
        Box(Modifier.align(Alignment.CenterEnd).fillMaxHeight().width(1.dp)) {
            TagPopup(app, selection, show = true, openId = openId, onClose = onBack)
        }
    }
}

/** The Moving bar: Cancel, a centred hint, "Move here" (not into the folder the items are already in) and More (New folder, Search). */
@Composable
private fun MovingBar(app: AppController, s: Screen.Files, items: List<LibraryEntry>, onNewFolder: () -> Unit, onCancel: () -> Unit) {
    val lib = app.library
    var moreOpen by remember { mutableStateOf(false) }
    val current = if (s.section == Section.MY_FILES) s.folderId else ""
    val source = items.map { it.parentId }.distinct().singleOrNull()
    // A folder can't be moved into itself or one of its own descendants.
    val inside = run {
        var cur: String? = current
        val seen = HashSet<String>()
        var hit = false
        while (!cur.isNullOrEmpty() && seen.add(cur)) { if (items.any { it.id == cur }) { hit = true; break }; cur = lib[cur]?.parentId }
        hit
    }
    val canDrop = current != source && !inside
    val title = if (current != source) "Choose a placement" else if (items.size == 1) "Select where to move the item" else "Select where to move the items"
    Box(Modifier.fillMaxWidth().height(Rm.NavigationHeader).background(Ink.Black).padding(horizontal = 16.dp)) {
        Box(Modifier.align(Alignment.CenterStart)) { BarCancel(onCancel) }
        Text(title, style = RmText.LabelLgStrong, color = Ink.White, modifier = Modifier.align(Alignment.Center))
        Row(Modifier.align(Alignment.CenterEnd)) {
            if (canDrop) BarButton("Move here", { app.moveAll(items, current); app.moving = null }) { InkIcons.MoveHere(tint = it) }
            Box {
                BarButton("More", { moreOpen = !moreOpen }, selected = moreOpen) { InkIcons.ThreeDots(tint = it) }
                RmMenu(moreOpen, { moreOpen = false }, MenuSide.BELOW_END, Rm.ToolboxFoldoutWidth) {
                    RmFoldoutItem("New folder", { moreOpen = false; onNewFolder() }) { InkIcons.FolderOutline(tint = it) }
                    RmFoldoutItem("Search", { moreOpen = false; app.searchFrom = Section.MY_FILES; app.screen = Screen.Search }) { InkIcons.Lens(tint = it) }
                }
            }
        }
    }
}

/**
 * The tag menu (TagSelectionPopup): 594 px wide, hanging from the bar. Tag chips (partly selected when only some of the
 * chosen items carry the tag; at most three rows, then "View all"), a divider, and a "New tag" row. Changes are applied when it closes.
 */
@OptIn(androidx.compose.foundation.layout.ExperimentalLayoutApi::class)
@Composable
private fun TagPopup(app: AppController, selection: List<LibraryEntry>, show: Boolean, openId: Int, onClose: () -> Unit) {
    val known = remember(app.library) { knownTags(app.library) }
    // 0 = off for every item, 1 = some, 2 = all
    var state by remember(openId, selection.map { it.id }) { mutableStateOf(known.associateWith { t -> selection.count { t in it.tags }.let { n -> if (n == 0) 0 else if (n == selection.size) 2 else 1 } }) }
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
        // With no tags yet the firmware offers two to start with.
        val chips = if (known.isEmpty()) created + listOf("Important", "Follow up").filter { it !in created } else known + created.filter { it !in known }
        androidx.compose.foundation.layout.FlowRow(
            Modifier.fillMaxWidth().padding(30.dp), horizontalArrangement = Arrangement.spacedBy(10.dp), verticalArrangement = Arrangement.spacedBy(40.dp),
            maxLines = 3,
            overflow = androidx.compose.foundation.layout.FlowRowOverflow.expandIndicator { ViewAll({ onClose() }) },
        ) {
            chips.take(20).forEach { t ->
                val st = (state + created.associateWith { 2 })[t] ?: 0
                TagPill(t, selected = st == 2, partial = st == 1, onClick = {
                    if (t in created) created = created - t else if (t in state) state = state + (t to if (st == 2) 0 else 2) else created = created + t
                })
            }
        }
        RmFoldoutItem("New tag", { newTag = true }, topDivider = true) { InkIcons.PlusCircle(tint = it) }
    }
    if (newTag) HeaderInputDialog("Enter tag name", "Create", onDismiss = { newTag = false }) { name ->
        if (name.isNotEmpty() && name !in known) created = created + name
        else if (name in known) state = state + (name to 2)
        newTag = false
    }
}

/** The tag row of the Tags view: All / Documents tabs, then one row of tag chips (tap to filter). */
@OptIn(androidx.compose.foundation.layout.ExperimentalLayoutApi::class)
@Composable
private fun TagsFilter(lib: Library, selected: Set<String>, tab: Int, onTab: (Int) -> Unit, onToggle: (String) -> Unit, onLongPress: (String) -> Unit) {
    val tags = remember(lib) { knownTags(lib) }
    var all by remember { mutableStateOf(false) }
    Column(Modifier.fillMaxWidth().padding(horizontal = Rm.NavigatorMargin)) {
        Row {
            listOf("All" to 200.dp, "Pages" to 230.dp, "Documents" to 270.dp).forEachIndexed { i, (label, w) ->
                Column(Modifier.width(w).tap { onTab(i) }, horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(label, style = if (tab == i) RmText.LabelLgStrong else RmText.LabelLg, modifier = Modifier.padding(vertical = 20.dp))
                    Box(Modifier.fillMaxWidth().height(if (tab == i) 6.dp else Rm.Outline).background(Ink.Black))
                }
            }
        }
        Spacer(Modifier.height(24.dp))
        androidx.compose.foundation.layout.FlowRow(
            horizontalArrangement = Arrangement.spacedBy(20.dp), verticalArrangement = Arrangement.spacedBy(20.dp), maxLines = 1,
            overflow = androidx.compose.foundation.layout.FlowRowOverflow.expandIndicator { ViewAll({ all = true }) },
        ) {
            tags.forEach { t -> TagPill(t, selected = t in selected, onClick = { onToggle(t) }, onLongClick = { onLongPress(t) }) }
        }
        Spacer(Modifier.height(24.dp))
    }
    if (all) Box(Modifier.fillMaxSize()) { TagsWindow(tags, selected, onToggle, { all = false }) }
}

/** Notebook thumbnails are 3:4 (312 x 416 px inside a 342 px cell). */
private const val THUMB_ASPECT = 312f / 416f

/**
 * A notebook's cover page. Notebooks get a black spine line on the left, PDFs a folded top-right corner
 * (the same cues the tablet uses to tell document types apart at a glance).
 */
@Composable
internal fun Thumb(app: AppController, e: LibraryEntry, modifier: Modifier) {
    val shape = androidx.compose.ui.graphics.RectangleShape
    if (e.isFolder) {
        Box(modifier.border(Rm.Outline, Ink.Black, shape).background(Ink.White, shape), contentAlignment = Alignment.Center) { InkIcons.Folder() }
        return
    }
    // The cover is the first page, or (the default) the page the notebook was last closed on.
    val page = if (e.coverPage == 0) 0 else lastPage(e)
    val bmp by produceState<Bitmap?>(null, e.id, e.lastModified, page, e.pageIds.getOrNull(page), e.template) {
        value = withContext(Dispatchers.IO) { runCatching { app.thumbnails.render(e, page, 320) }.getOrNull() }
    }
    Box(modifier.clip(shape).border(Rm.Outline, Ink.Black, shape).background(Ink.White)) {
        bmp?.let { Image(it.asImageBitmap(), contentDescription = e.name, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize()) }
        if (e.fileType == "pdf") {
            Canvas(Modifier.align(Alignment.TopEnd).size(56.dp)) {
                val w = size.width
                val fold = androidx.compose.ui.graphics.Path().apply { moveTo(0f, 0f); lineTo(w, w); lineTo(w, 0f); close() }
                drawPath(fold, Color.White)
                drawLine(Color.Black, Offset(0f, 0f), Offset(w, w), strokeWidth = 4f)
            }
        } else {
            // The cover's spine: a 2 px black line (the firmware's covers are strictly black and white).
            Box(Modifier.align(Alignment.CenterStart).padding(start = 14.dp).fillMaxHeight().width(Rm.Outline).background(Color.Black))
        }
    }
}

// ---- sidebar ----

@Composable
private fun Sidebar(app: AppController, s: Screen.Files, onClose: () -> Unit, onImport: () -> Unit) {
    var filterOpen by remember { mutableStateOf(false) }
    val active = s.section.takeIf { it == Section.NOTEBOOKS || it == Section.PDFS }
    @Composable fun item(label: String, selected: Boolean, onClick: () -> Unit, caption: String? = null, icon: @Composable (Color) -> Unit) {
        val fg = if (selected) Ink.White else Ink.Black
        Row(Modifier.fillMaxWidth().height(Rm.SidebarItem).background(if (selected) Ink.Black else Ink.White).tap(onClick = onClick).padding(start = 32.dp, end = 96.dp), verticalAlignment = Alignment.CenterVertically) {
            icon(fg); Spacer(Modifier.width(16.dp))
            Column {
                Text(label, style = RmText.LabelLg, color = fg, maxLines = 1)
                if (caption != null) Text(caption, style = RmText.Caption, color = fg, maxLines = 1)
            }
        }
    }
    Box(Modifier.fillMaxSize()) {
        Row(Modifier.fillMaxSize()) {
            // navigatorSidebarWidth 414, 120 px items (icon, 16 px, label), a 2 px right border; the sidebar covers the header, from the top edge.
            Column(Modifier.width(Rm.SidebarWidth).fillMaxHeight().background(Ink.White).drawWithContent { drawContent(); drawLine(Color.Black, Offset(size.width - 1f, 0f), Offset(size.width - 1f, size.height), strokeWidth = 2f) }) {
                item("My files", s.section == Section.MY_FILES, { app.screen = Screen.Files(Section.MY_FILES); onClose() }) { InkIcons.MyFiles(tint = it) }
                // "Filter by" opens a flyout to the right; once a filter is chosen the item shows it.
                item(active?.title ?: "Filter by", active != null || filterOpen, { filterOpen = !filterOpen }) {
                    if (active == Section.PDFS) InkIcons.Document(tint = it) else if (active == Section.NOTEBOOKS) InkIcons.Notebook(tint = it) else InkIcons.Filter(tint = it)
                }
                item("Favorites", s.section == Section.FAVORITES, { app.screen = Screen.Files(Section.FAVORITES); onClose() }) { InkIcons.StarOutline(tint = it) }
                item("Tags", s.section == Section.TAGS, { app.screen = Screen.Files(Section.TAGS); onClose() }) { InkIcons.Tag(tint = it) }
                item("Import files", false, { onClose(); onImport() }, caption = "From this device") { InkIcons.Cloud(tint = it) }
                Spacer(Modifier.weight(1f))
                item("Trash", s.section == Section.TRASH, { app.screen = Screen.Files(Section.TRASH); onClose() }) { InkIcons.Trash(tint = it) }
                Rule()
                item("Guides", false, { app.screen = Screen.Guides; onClose() }) { InkIcons.Compass(tint = it) }
                item("Settings", false, { app.screen = Screen.Settings; onClose() }) { InkIcons.Settings(tint = it) }
            }
            // Tap outside to close (no scrim: it would smear on e-ink).
            Box(Modifier.weight(1f).fillMaxHeight().tap(onClick = onClose))
        }
        if (filterOpen) {
            // The flyout: right of the sidebar, level with the "Filter by" item, one sidebar wide, 2 px border.
            Column(Modifier.offset(x = Rm.SidebarWidth, y = Rm.SidebarItem).width(Rm.SidebarWidth).background(Ink.White).border(Rm.Outline, Ink.Black)) {
                item("Notebooks", s.section == Section.NOTEBOOKS, { app.screen = Screen.Files(Section.NOTEBOOKS); onClose() }) { InkIcons.Notebook(tint = it) }
                item("PDFs", s.section == Section.PDFS, { app.screen = Screen.Files(Section.PDFS); onClose() }) { InkIcons.Document(tint = it) }
            }
        }
    }
}
