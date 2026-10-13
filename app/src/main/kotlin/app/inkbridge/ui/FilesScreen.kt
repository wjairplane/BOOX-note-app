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
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
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
    data class Delete(val e: LibraryEntry) : Dialogs
    data class Move(val e: LibraryEntry) : Dialogs
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

    val pdfPicker = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        if (uri != null) app.importPdf(uri, s.folderId)
    }

    val entries = remember(lib, s, prefs.sortBy) { visibleEntries(lib, s, prefs.sortBy) }
    val title = when {
        s.section != Section.MY_FILES -> s.section.title
        s.folderId.isEmpty() -> "My files"
        else -> lib[s.folderId]?.name ?: "My files"
    }

    Box(Modifier.fillMaxSize()) {
        Column(Modifier.fillMaxSize()) {
            // --- top bar ---
            Row(Modifier.fillMaxWidth().padding(horizontal = 12.dp, vertical = 10.dp), verticalAlignment = Alignment.CenterVertically) {
                IconBtn(Icons.Default.Menu, "Menu", { menuOpen = true })
                Spacer(Modifier.width(8.dp))
                if (s.folderId.isNotEmpty() && s.section == Section.MY_FILES) {
                    IconBtn(Icons.Default.ArrowBack, "Up", { app.screen = Screen.Files(s.section, lib[s.folderId]?.parentId ?: "") })
                    Spacer(Modifier.width(4.dp))
                }
                Text(title, fontSize = 32.sp, fontWeight = FontWeight.Bold, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f))
                if (s.section == Section.TRASH) {
                    EButton("Empty trash", { dialog = Dialogs.EmptyTrash }, enabled = entries.isNotEmpty())
                } else {
                    var sortMenu by remember { mutableStateOf(false) }
                    Box {
                        EButton("Sort", { sortMenu = true })
                        DropdownMenu(sortMenu, { sortMenu = false }) {
                            SortBy.entries.forEach { o -> DropdownMenuItem(text = { Text(o.label + if (o == prefs.sortBy) "  ✓" else "", fontSize = 20.sp) }, onClick = { prefs.sortBy = o; sortMenu = false }) }
                        }
                    }
                    Spacer(Modifier.width(8.dp))
                    EButton(if (prefs.gridView) "List" else "Grid", { prefs.gridView = !prefs.gridView })
                    if (s.section == Section.MY_FILES) {
                        Spacer(Modifier.width(8.dp))
                        var newMenu by remember { mutableStateOf(false) }
                        Box {
                            EButton("+ New", { newMenu = true }, selected = true)
                            DropdownMenu(newMenu, { newMenu = false }) {
                                DropdownMenuItem(text = { Text("Notebook", fontSize = 20.sp) }, onClick = { newMenu = false; dialog = Dialogs.NewNotebook })
                                DropdownMenuItem(text = { Text("Folder", fontSize = 20.sp) }, onClick = { newMenu = false; dialog = Dialogs.NewFolder })
                                DropdownMenuItem(text = { Text("Import PDF", fontSize = 20.sp) }, onClick = { newMenu = false; pdfPicker.launch(arrayOf("application/pdf")) })
                            }
                        }
                    }
                }
            }
            // --- breadcrumb ---
            if (s.section == Section.MY_FILES && s.folderId.isNotEmpty()) {
                Text(
                    (listOf("My files") + lib.path(s.folderId)).joinToString("  /  "),
                    fontSize = 16.sp, color = Ink.Grey, modifier = Modifier.padding(start = 24.dp, bottom = 6.dp),
                )
            }
            Rule()
            if (app.message.isNotEmpty()) {
                Row(Modifier.fillMaxWidth().background(Ink.Panel).padding(horizontal = 24.dp, vertical = 10.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text(app.message, fontSize = 17.sp, modifier = Modifier.weight(1f))
                    EButton("Dismiss", { app.message = "" }, size = 44.dp)
                }
            }

            // --- content ---
            if (entries.isEmpty()) {
                Text(
                    when (s.section) {
                        Section.MY_FILES -> "Nothing here yet.\nTap “+ New” to make a notebook or a folder, or import a PDF to annotate."
                        Section.FAVORITES -> "No favorites yet.\nPress and hold a notebook or folder in My files, then choose Favorite."
                        Section.TRASH -> "The trash is empty."
                    },
                    fontSize = 22.sp, color = Ink.Grey, modifier = Modifier.padding(32.dp),
                )
            } else if (prefs.gridView) {
                LazyVerticalGrid(GridCells.Adaptive(minSize = 210.dp), contentPadding = PaddingValues(20.dp), horizontalArrangement = Arrangement.spacedBy(20.dp), verticalArrangement = Arrangement.spacedBy(24.dp)) {
                    items(entries, key = { it.id }) { e -> Card(app, e, s, lib, onOpen = { open(app, e, s) }, onDialog = { dialog = it }, grid = true) }
                }
            } else {
                LazyColumn {
                    items(entries, key = { it.id }) { e ->
                        Card(app, e, s, lib, onOpen = { open(app, e, s) }, onDialog = { dialog = it }, grid = false)
                        Rule()
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
        is Dialogs.Delete -> ConfirmDialog(
            if (d.e.parentId == Library.TRASH) "Delete forever?" else "Move to trash?",
            if (d.e.parentId == Library.TRASH) "“${d.e.name}” will be deleted permanently." else "“${d.e.name}” will be moved to the trash.",
            if (d.e.parentId == Library.TRASH) "Delete" else "Move to trash", { dialog = null },
        ) { if (d.e.parentId == Library.TRASH) app.deleteForever(d.e) else app.trash(d.e); dialog = null }
        is Dialogs.Move -> MoveDialog(lib, d.e, { dialog = null }) { app.move(d.e, it); dialog = null }
        Dialogs.EmptyTrash -> ConfirmDialog("Empty the trash?", "Everything in the trash will be deleted permanently.", "Empty trash", { dialog = null }) { app.emptyTrash(); dialog = null }
    }
}

private fun open(app: AppController, e: LibraryEntry, s: Screen.Files) {
    if (s.section == Section.TRASH) return // trashed items are managed, not opened
    app.screen = if (e.isFolder) Screen.Files(Section.MY_FILES, e.id) else Screen.Notebook(e.id, 0)
}

private fun visibleEntries(lib: Library, s: Screen.Files, sort: SortBy): List<LibraryEntry> {
    val base = when (s.section) {
        Section.MY_FILES -> lib.children(s.folderId)
        Section.FAVORITES -> lib.entries.filter { it.pinned && it.parentId != Library.TRASH }
        Section.TRASH -> lib.trash
    }
    val byDate = compareByDescending<LibraryEntry> { it.lastModified }.thenBy { it.name.lowercase() }
    val byName = compareBy<LibraryEntry> { it.name.lowercase() }
    // Folders always come first, as in the tablet's file browser.
    return base.sortedWith(compareBy<LibraryEntry> { !it.isFolder }.then(if (sort == SortBy.NAME) byName else byDate))
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun Card(app: AppController, e: LibraryEntry, s: Screen.Files, lib: Library, onOpen: () -> Unit, onDialog: (Dialogs) -> Unit, grid: Boolean) {
    var menu by remember { mutableStateOf(false) }
    val date = remember(e.lastModified) { if (e.lastModified > 0) DateFormat.getDateInstance(DateFormat.MEDIUM).format(Date(e.lastModified)) else "" }
    val sub = if (e.isFolder) "${lib.children(e.id).size} items" else "${e.pageIds.size} page${if (e.pageIds.size == 1) "" else "s"}  ·  $date"

    Box {
        if (grid) {
            Column(Modifier.combinedClickable(onClick = onOpen, onLongClick = { menu = true })) {
                Thumb(app, e, Modifier.fillMaxWidth().aspectRatio(0.75f))
                Spacer(Modifier.height(8.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    if (e.pinned) Text("★ ", fontSize = 18.sp)
                    Text(e.name, fontSize = 19.sp, fontWeight = FontWeight.Medium, maxLines = 2, overflow = TextOverflow.Ellipsis)
                }
                Text(sub, fontSize = 14.sp, color = Ink.Grey, maxLines = 1)
            }
        } else {
            Row(Modifier.fillMaxWidth().combinedClickable(onClick = onOpen, onLongClick = { menu = true }).padding(horizontal = 24.dp, vertical = 12.dp), verticalAlignment = Alignment.CenterVertically) {
                Thumb(app, e, Modifier.width(66.dp).height(88.dp))
                Spacer(Modifier.width(20.dp))
                Column(Modifier.weight(1f)) {
                    Text((if (e.pinned) "★ " else "") + e.name, fontSize = 22.sp, fontWeight = FontWeight.Medium, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    Text(sub, fontSize = 15.sp, color = Ink.Grey)
                }
                EButton("⋯", { menu = true }, size = 48.dp)
            }
        }
        DropdownMenu(menu, { menu = false }) {
            @Composable fun item(label: String, action: () -> Unit) = DropdownMenuItem(text = { Text(label, fontSize = 20.sp) }, onClick = { menu = false; action() })
            if (s.section == Section.TRASH) {
                item("Restore") { app.restore(e) }
                item("Delete forever") { onDialog(Dialogs.Delete(e)) }
            } else {
                item("Open") { onOpen() }
                item("Rename") { onDialog(Dialogs.Rename(e)) }
                item(if (e.pinned) "Remove from favorites" else "Favorite") { app.togglePinned(e) }
                item("Move") { onDialog(Dialogs.Move(e)) }
                item("Delete") { onDialog(Dialogs.Delete(e)) }
            }
        }
    }
}

/** A notebook's first page, or a folder shape. */
@Composable
private fun Thumb(app: AppController, e: LibraryEntry, modifier: Modifier) {
    if (e.isFolder) {
        Box(modifier.border(1.5.dp, Ink.Black).background(Ink.Panel), contentAlignment = Alignment.Center) {
            Text("▤", fontSize = 40.sp, color = Ink.Black)
        }
        return
    }
    val bmp by produceState<Bitmap?>(null, e.id, e.lastModified, e.pageIds.firstOrNull(), e.template) {
        value = withContext(Dispatchers.IO) { runCatching { app.thumbnails.render(e, 0, 320) }.getOrNull() }
    }
    Box(modifier.border(1.5.dp, Ink.Black).background(Ink.White)) {
        bmp?.let { Image(it.asImageBitmap(), contentDescription = e.name, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize()) }
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
        Spacer(Modifier.height(16.dp))
        Text("Page template", fontSize = 18.sp, color = Ink.Grey)
        PageTemplate.entries.forEach { t -> ChoiceRow(t.label, template == t, { template = t }) }
    }
}

@Composable
private fun MoveDialog(lib: Library, e: LibraryEntry, onDismiss: () -> Unit, onPick: (String) -> Unit) {
    // A folder can't be moved into itself or one of its own descendants.
    fun isInside(id: String): Boolean {
        var cur: String? = id
        val seen = HashSet<String>()
        while (!cur.isNullOrEmpty() && seen.add(cur)) { if (cur == e.id) return true; cur = lib[cur]?.parentId }
        return false
    }
    val targets = lib.entries.filter { it.isFolder && it.parentId != Library.TRASH && !isInside(it.id) }.sortedBy { (lib.path(it.id) + it.name).joinToString(" / ").lowercase() }
    EDialog("Move “${e.name}” to", onDismiss, actions = { EButton("Cancel", onDismiss) }) {
        Column(Modifier.heightIn(max = 420.dp).verticalScroll(rememberScrollState())) {
            ChoiceRow("My files", e.parentId.isEmpty(), { onPick("") })
            targets.forEach { f -> ChoiceRow((lib.path(f.id) + f.name).joinToString(" / "), e.parentId == f.id, { onPick(f.id) }) }
        }
    }
}

@Composable
private fun Sidebar(app: AppController, s: Screen.Files, onClose: () -> Unit) {
    Row(Modifier.fillMaxSize()) {
        Column(Modifier.width(360.dp).fillMaxHeight().background(Ink.White).border(1.5.dp, Ink.Black).padding(vertical = 16.dp)) {
            Text("InkBridge", fontSize = 28.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(horizontal = 24.dp, vertical = 12.dp))
            Rule()
            Section.entries.forEach { sec ->
                val selected = s.section == sec
                Text(
                    sec.title, fontSize = 24.sp, color = if (selected) Ink.White else Ink.Black,
                    modifier = Modifier.fillMaxWidth().background(if (selected) Ink.Black else Ink.White)
                        .tap { app.screen = Screen.Files(sec); onClose() }.padding(horizontal = 24.dp, vertical = 18.dp),
                )
            }
            Spacer(Modifier.weight(1f))
            Rule()
            Row(
                Modifier.fillMaxWidth().tap { app.screen = Screen.Settings; onClose() }.padding(horizontal = 24.dp, vertical = 18.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(Icons.Default.Settings, "Settings", Modifier.size(28.dp))
                Spacer(Modifier.width(14.dp))
                Text("Settings", fontSize = 24.sp)
            }
        }
        // Tap outside to close. (No scrim animation: it would smear on e-ink.)
        Box(Modifier.weight(1f).fillMaxHeight().background(Ink.White.copy(alpha = 0.55f)).tap(onClick = onClose))
    }
}
