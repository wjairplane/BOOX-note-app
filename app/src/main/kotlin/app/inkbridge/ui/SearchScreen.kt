package app.inkbridge.ui

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
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.inkbridge.AppController
import app.inkbridge.Screen
import app.inkbridge.Section
import app.inkbridge.rm.library.Library

/**
 * Search by name across every notebook, folder and PDF (not the trash). Handwriting search needs
 * text recognition, which isn't built yet.
 */
@Composable
fun SearchScreen(app: AppController) {
    var query by remember { mutableStateOf("") }
    val focus = remember { FocusRequester() }
    LaunchedEffect(Unit) { runCatching { focus.requestFocus() } }

    val lib = app.library
    val q = query.trim()
    val results = remember(lib, q) {
        if (q.isEmpty()) emptyList()
        else lib.entries.filter { it.parentId != Library.TRASH && it.name.contains(q, ignoreCase = true) }
            .sortedWith(compareBy({ !it.isFolder }, { it.name.lowercase() }))
    }

    Column(Modifier.fillMaxSize()) {
        // The dark search bar of the tablet: Cancel, a magnifier, the query, and the result count.
        Row(Modifier.fillMaxWidth().background(Ink.Dark).padding(horizontal = 16.dp, vertical = 12.dp), verticalAlignment = Alignment.CenterVertically) {
            Text("Cancel", color = Ink.White, fontSize = 18.sp, modifier = Modifier.tap { app.screen = Screen.Files() }.padding(8.dp))
            Spacer(Modifier.width(12.dp))
            InkIcons.Search(tint = Ink.White, size = 30.dp)
            Spacer(Modifier.width(8.dp))
            BasicTextField(
                value = query, onValueChange = { query = it }, singleLine = true,
                textStyle = TextStyle(fontSize = 20.sp, color = Ink.White), cursorBrush = SolidColor(Ink.White),
                modifier = Modifier.weight(1f).focusRequester(focus),
                decorationBox = { inner -> Box { if (query.isEmpty()) Text("Search", color = Ink.Rule, fontSize = 20.sp); inner() } },
            )
            if (q.isNotEmpty()) Text("${results.size} found", color = Ink.White, fontSize = 16.sp, modifier = Modifier.padding(start = 8.dp))
        }
        if (q.isNotEmpty() && results.isEmpty()) {
            Text("No notebooks, folders or PDFs match “$q”.", fontSize = 20.sp, color = Ink.Grey, modifier = Modifier.padding(28.dp))
        }
        LazyColumn {
            items(results, key = { it.id }) { e ->
                Row(
                    Modifier.fillMaxWidth().tap {
                        app.screen = if (e.isFolder) Screen.Files(Section.MY_FILES, e.id) else Screen.Notebook(e.id, 0)
                    }.padding(horizontal = 24.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Thumb(app, e, Modifier.width(60.dp).height(80.dp))
                    Spacer(Modifier.width(18.dp))
                    Column(Modifier.weight(1f)) {
                        Text(e.name, fontSize = 21.sp, fontWeight = FontWeight.Medium, maxLines = 1, overflow = TextOverflow.Ellipsis)
                        val where = (listOf("My files") + lib.path(e.id)).joinToString("  /  ")
                        Text(if (e.isFolder) "Folder  ·  $where" else "${e.pageIds.size} page${if (e.pageIds.size == 1) "" else "s"}  ·  $where", fontSize = 15.sp, color = Ink.Grey, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    }
                }
                Rule()
            }
        }
    }
}
