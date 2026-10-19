package app.inkbridge.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import app.inkbridge.PdfStructure
import app.inkbridge.rm.library.LibraryEntry
import java.io.File

/** A table-of-contents entry resolved to a page of the notebook (0-based). */
data class TocEntry(val name: String, val level: Int, val page: Int)

/** The PDF's outline as entries of this notebook: pages that were removed from the notebook are skipped. */
internal fun tocFor(doc: LibraryEntry, pdf: File): List<TocEntry> {
    if (doc.fileType != "pdf" || !pdf.isFile) return emptyList()
    return PdfStructure.outline(pdf).mapNotNull { t ->
        val page = if (doc.redirectMap.isEmpty()) t.page else doc.redirectMap.indexOf(t.page)
        if (page in doc.pageIds.indices) TocEntry(t.title, t.level, page) else null
    }
}

/**
 * The firmware's TableOfContent page (00d9aa25): a secondary navigation bar titled "Table of contents" with Back, then one 75 px row per
 * chapter (the name indented 50 px per level, bold for the chapter holding the current page; its page number at the right) with a 2 px
 * rule under it. A tap opens the chapter's page.
 */
@Composable
internal fun TableOfContentsScreen(entries: List<TocEntry>, currentPage: Int, onPick: (Int) -> Unit, onBack: () -> Unit) {
    // The current chapter is the last one that starts on or before the current page, as the firmware's isCurrentChapter works it out.
    val current = entries.indices.lastOrNull { entries[it].page <= currentPage } ?: -1
    val state = rememberLazyListState()
    LaunchedEffect(Unit) { if (current > 0) state.scrollToItem(current) }
    androidx.activity.compose.BackHandler(onBack = onBack)
    Column(Modifier.fillMaxSize().background(Ink.White)) {
        NavigationBar("Table of contents", onBack)
        LazyColumn(Modifier.fillMaxSize(), state = state, contentPadding = PaddingValues(start = 147.dp, end = 147.dp, top = 75.dp, bottom = 75.dp)) {
            itemsIndexed(entries) { i, e ->
                Box(Modifier.fillMaxWidth().height(75.dp).tap { onPick(e.page) }.semantics { contentDescription = e.name }) {
                    Row(Modifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            e.name, style = RmText.LabelLg.copy(fontWeight = if (i == current) FontWeight.Bold else FontWeight.Medium),
                            maxLines = 1, overflow = androidx.compose.ui.text.style.TextOverflow.Ellipsis,
                            modifier = Modifier.weight(1f).padding(start = (e.level * 50).dp, end = 15.dp),
                        )
                        Text("${e.page + 1}", style = RmText.Caption)
                    }
                    Box(Modifier.align(Alignment.BottomStart).padding(start = (e.level * 50).dp).fillMaxWidth().height(Rm.Outline).background(Ink.Black))
                }
            }
        }
    }
}
