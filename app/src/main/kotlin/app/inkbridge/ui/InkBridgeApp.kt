package app.inkbridge.ui

import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.inkbridge.LibraryStore
import app.inkbridge.rm.library.Library
import app.inkbridge.rm.library.LibraryEntry
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

// E-ink: black on white, no tints, no motion.
private val EInkColors = lightColorScheme(
    primary = Color.Black, onPrimary = Color.White,
    background = Color.White, onBackground = Color.Black,
    surface = Color.White, onSurface = Color.Black,
    outline = Color.Black,
)

@Composable
fun InkBridgeApp(store: LibraryStore) {
    MaterialTheme(colorScheme = EInkColors) {
        Surface(Modifier.fillMaxSize(), color = Color.White) {
            val scope = rememberCoroutineScope()
            var library by remember { mutableStateOf<Library?>(null) }
            var folderId by remember { mutableStateOf("") }
            var open by remember { mutableStateOf<LibraryEntry?>(null) }
            var status by remember { mutableStateOf("") }

            LaunchedEffect(Unit) { library = withContext(Dispatchers.IO) { store.load() } }

            val picker = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocumentTree()) { uri ->
                if (uri == null) return@rememberLauncherForActivityResult
                scope.launch {
                    status = "Importing…"
                    status = try {
                        val n = withContext(Dispatchers.IO) { store.import(uri) { c -> if (c % 25 == 0) status = "Importing… $c files" } }
                        library = withContext(Dispatchers.IO) { store.load() }
                        "Imported $n files"
                    } catch (e: Exception) {
                        "Import failed: ${e.message}"
                    }
                }
            }

            val doc = open
            if (doc != null) {
                BackHandler { open = null }
                PageScreen(store, doc, onClose = { open = null })
            } else {
                BackHandler(enabled = folderId.isNotEmpty()) {
                    folderId = library?.get(folderId)?.parentId?.takeIf { it != Library.TRASH } ?: ""
                }
                LibraryScreen(
                    library = library,
                    folderId = folderId,
                    status = status,
                    onImport = { picker.launch(null) },
                    onOpenFolder = { folderId = it.id },
                    onUp = { folderId = library?.get(folderId)?.parentId?.takeIf { it != Library.TRASH } ?: "" },
                    onOpenDoc = { open = it },
                )
            }
        }
    }
}

@Composable
private fun LibraryScreen(
    library: Library?,
    folderId: String,
    status: String,
    onImport: () -> Unit,
    onOpenFolder: (LibraryEntry) -> Unit,
    onUp: () -> Unit,
    onOpenDoc: (LibraryEntry) -> Unit,
) {
    Column(Modifier.fillMaxSize().padding(24.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                library?.get(folderId)?.name ?: "InkBridge",
                fontSize = 32.sp, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f),
            )
            if (folderId.isNotEmpty()) BlackButton("Up", onUp)
            Spacer(Modifier.width(12.dp))
            BlackButton("Import folder", onImport)
        }
        if (status.isNotEmpty()) Text(status, fontSize = 18.sp, modifier = Modifier.padding(top = 8.dp))
        Spacer(Modifier.height(16.dp))
        val items = library?.children(folderId).orEmpty()
        if (library != null && items.isEmpty()) {
            Text(
                if (library.entries.isEmpty())
                    "No notebooks yet. Copy a notebook from the reMarkable (the .metadata and .content files and the page folder) onto this device, then tap “Import folder”."
                else "This folder is empty.",
                fontSize = 20.sp,
            )
        }
        LazyColumn {
            items(items, key = { it.id }) { e ->
                Column(
                    Modifier.fillMaxWidth().clickable { if (e.isFolder) onOpenFolder(e) else onOpenDoc(e) }.padding(vertical = 18.dp),
                ) {
                    Text((if (e.isFolder) "▸ " else "") + e.name, fontSize = 24.sp, fontWeight = if (e.isFolder) FontWeight.Bold else FontWeight.Normal)
                    if (!e.isFolder) Text("${e.fileType} · ${e.pageIds.size} pages", fontSize = 16.sp)
                }
                HorizontalDivider(color = Color.Black)
            }
        }
    }
}

@Composable
fun BlackButton(label: String, onClick: () -> Unit, enabled: Boolean = true) {
    OutlinedButton(
        onClick = onClick,
        enabled = enabled,
        border = BorderStroke(2.dp, if (enabled) Color.Black else Color.Gray),
        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.Black, disabledContentColor = Color.Gray),
        shape = androidx.compose.foundation.shape.RoundedCornerShape(4.dp),
        modifier = Modifier.defaultMinSize(minHeight = 52.dp),
    ) { Text(label, fontSize = 18.sp) }
}
