package app.inkbridge.ui

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.unit.dp
import app.inkbridge.AppController
import app.inkbridge.Screen
import app.inkbridge.Section
import app.inkbridge.SortBy
import app.inkbridge.rm.library.Library
import app.inkbridge.rm.library.LibraryEntry
import kotlinx.coroutines.delay

/** The search filter dropdown's entries (Handwriting and Ebooks need recognition and an ebook reader, which this app doesn't have). */
private enum class SearchFilter(val label: String) { ALL("All"), NOTEBOOKS("Notebooks"), FAVORITES("Favorites"), PDFS("PDFs"), FOLDERS("Folders") }

/** The search results' sort choices (no grid-size block here). */
private val SearchSorts = listOf(SortBy.MODIFIED, SortBy.CREATED, SortBy.NAME)

/**
 * Search by name across every notebook, folder and PDF (not the trash), after the firmware's SearchView: a black bar with Back, a
 * magnifier, the query and Clear; then "N matches" with a filter and a sort dropdown, and the results as list rows with their path.
 * Handwriting search needs text recognition, which isn't built yet.
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun SearchScreen(app: AppController) {
    var query by remember { mutableStateOf("") }
    // The filter starts as the list the search was opened from.
    var filter by remember {
        mutableStateOf(when (app.searchFrom) { Section.NOTEBOOKS -> SearchFilter.NOTEBOOKS; Section.PDFS -> SearchFilter.PDFS; Section.FAVORITES -> SearchFilter.FAVORITES; else -> SearchFilter.ALL })
    }
    var sort by remember { mutableStateOf(SortBy.MODIFIED) }
    var reversed by remember { mutableStateOf(false) }
    val focus = remember { FocusRequester() }
    LaunchedEffect(Unit) { runCatching { focus.requestFocus() } }
    LaunchedEffect(app.message) { if (app.message.isNotEmpty()) { delay(4000); app.message = "" } }

    val lib = app.library
    val moving = app.moving != null
    val effective = if (moving) SearchFilter.FOLDERS else filter
    val q = query.trim()
    val results = remember(lib, q, effective, sort, reversed) {
        if (q.length < 2) emptyList()
        else {
            val byName = compareBy<LibraryEntry> { it.name.lowercase() }
            val order: Comparator<LibraryEntry> = when (sort) {
                SortBy.CREATED -> compareByDescending<LibraryEntry> { it.created }.then(byName)
                SortBy.NAME -> byName
                else -> compareByDescending<LibraryEntry> { it.lastModified }.then(byName)
            }
            lib.entries.filter {
                it.parentId != Library.TRASH && it.name.contains(q, ignoreCase = true) && when (effective) {
                    SearchFilter.ALL -> true
                    SearchFilter.NOTEBOOKS -> !it.isFolder && it.fileType == "notebook"
                    SearchFilter.PDFS -> !it.isFolder && it.fileType == "pdf"
                    SearchFilter.FAVORITES -> it.pinned
                    SearchFilter.FOLDERS -> it.isFolder
                }
            }.sortedWith(if (reversed) order.reversed() else order)
        }
    }

    Box(Modifier.fillMaxSize()) {
        Column(Modifier.fillMaxSize()) {
            // The dark search bar of the tablet (HeaderInput): Back, a magnifier, the query, and Clear while there is text.
            Row(Modifier.fillMaxWidth().height(Rm.NavigationHeader).background(Ink.Dark).padding(horizontal = 32.dp), verticalAlignment = Alignment.CenterVertically) {
                Text("Back", color = Ink.White, style = RmText.Label, modifier = Modifier.heightIn(min = Rm.Control).tap { app.screen = Screen.Files() }.wrapContentHeight(Alignment.CenterVertically))
                Spacer(Modifier.width(32.dp))
                InkIcons.Search(tint = Ink.White)
                Spacer(Modifier.width(16.dp))
                BasicTextField(
                    value = query, onValueChange = { query = it }, singleLine = true,
                    textStyle = RmText.BodyLg.copy(color = Ink.White), cursorBrush = SolidColor(Ink.White),
                    modifier = Modifier.weight(1f).focusRequester(focus),
                    decorationBox = { inner -> Box { if (query.isEmpty()) Text("Search", color = Ink.Rule, style = RmText.BodyLg); inner() } },
                )
                if (q.isNotEmpty()) Text("Clear", color = Ink.White, style = RmText.Label, modifier = Modifier.padding(start = 16.dp).heightIn(min = Rm.Control).tap { query = "" }.wrapContentHeight(Alignment.CenterVertically))
            }
            // The "N matches" row is always there (also with nothing typed yet): 40 px below the bar, 72 px high, no rule.
            run {
                Row(Modifier.fillMaxWidth().padding(top = Rm.NavigatorMargin).height(72.dp).padding(start = Rm.NavigatorMargin, end = 15.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text(if (results.size == 1) "1 match" else "${results.size} matches", style = RmText.TitleLg, modifier = Modifier.weight(1f), maxLines = 1)
                    if (!moving) Dropdown(effective.label, "Filter") { close ->
                        SearchFilter.entries.forEach { f ->
                            val on = f == filter
                            val fg = if (on) Ink.White else Ink.Black
                            Row(Modifier.fillMaxWidth().height(Rm.Control).background(if (on) Ink.Black else Ink.White).tap { close(); filter = f }.padding(start = 20.dp, end = 16.dp), verticalAlignment = Alignment.CenterVertically) {
                                when (f) {
                                    SearchFilter.ALL -> InkIcons.PageFunnel(tint = fg)
                                    SearchFilter.NOTEBOOKS -> InkIcons.Notebook(tint = fg)
                                    SearchFilter.FAVORITES -> InkIcons.StarOutline(tint = fg)
                                    SearchFilter.PDFS -> InkIcons.Document(tint = fg)
                                    SearchFilter.FOLDERS -> InkIcons.FolderOutline(tint = fg)
                                }
                                Spacer(Modifier.width(16.dp))
                                Text(f.label, style = RmText.Label, color = fg)
                            }
                        }
                    }
                    val descending = naturalDescending(sort) != reversed
                    fun sortName(k: SortBy) = if (k == SortBy.NAME) (if (sort == SortBy.NAME && reversed) "Alphabetical (Z-A)" else "Alphabetical (A-Z)") else k.label
                    Dropdown(sortName(sort), "Sort by") { close ->
                        SearchSorts.forEach { k ->
                            SortRow(sortName(k), sort == k, descending) { close(); if (sort == k) reversed = !reversed else { sort = k; reversed = false } }
                        }
                    }
                }
            }
            LazyColumn(contentPadding = PaddingValues(start = Rm.NavigatorMargin, end = Rm.NavigatorMargin, bottom = 120.dp)) {
                items(results, key = { it.id }) { e ->
                    val where = (listOf("My files") + lib.path(e.id)).joinToString("  /  ")
                    val open = { app.screen = if (e.isFolder) Screen.Files(Section.MY_FILES, e.id) else Screen.Notebook(e.id, 0) }
                    // Press and hold shows the item where it lives, selected.
                    val reveal = { if (!moving) { app.pendingSelect = e.id; app.screen = Screen.Files(Section.MY_FILES, e.parentId) } }
                    if (e.isFolder) FolderRow(lib, e, false, where, onClick = open, onLongClick = reveal)
                    else NotebookRow(app, e, false, dimmed = false, path = where, onClick = open, onLongClick = reveal)
                }
            }
        }
        if (app.message.isNotEmpty()) NotificationBar(app.message, onAction = { app.message = "" }, modifier = Modifier.align(Alignment.BottomCenter), primary = !app.messageIsSuccess)
    }
}
