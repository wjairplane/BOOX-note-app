package app.inkbridge.ui

import android.graphics.Bitmap
import android.graphics.Canvas
import androidx.compose.foundation.Canvas as ComposeCanvas
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.inkbridge.AndroidPageCanvas
import app.inkbridge.LibraryStore
import app.inkbridge.rm.io.SceneStream
import app.inkbridge.rm.library.LibraryEntry
import app.inkbridge.rm.library.LibraryScanner
import app.inkbridge.rm.render.PageRenderer
import app.inkbridge.rm.scene.SceneTree
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlin.math.min

/** Result of loading one page: a scene tree, or why it couldn't be read. */
private sealed interface PageState {
    data object Loading : PageState
    data class Ready(val renderer: PageRenderer) : PageState
    data class Failed(val message: String) : PageState
}

@Composable
fun PageScreen(store: LibraryStore, doc: LibraryEntry, onClose: () -> Unit) {
    var index by remember(doc.id) { mutableIntStateOf(0) }
    val pageCount = doc.pageIds.size

    Column(Modifier.fillMaxSize()) {
        Row(Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            BlackButton("Library", onClose)
            Spacer(Modifier.width(12.dp))
            Text(doc.name, fontSize = 22.sp, modifier = Modifier.weight(1f), maxLines = 1)
            BlackButton("◀", { index-- }, enabled = index > 0)
            Text(if (pageCount == 0) "–" else "${index + 1} / $pageCount", fontSize = 20.sp, modifier = Modifier.padding(horizontal = 16.dp))
            BlackButton("▶", { index++ }, enabled = index < pageCount - 1)
        }
        if (pageCount == 0) {
            Text("This document has no pages.", fontSize = 20.sp, modifier = Modifier.padding(24.dp))
            return@Column
        }

        val state by produceState<PageState>(PageState.Loading, doc.id, index) {
            value = PageState.Loading
            value = withContext(Dispatchers.IO) {
                try {
                    val file = LibraryScanner.pageFile(store.dir, doc, index)
                    // Pages never drawn on have no .rm file: show them blank.
                    val tree = if (file.isFile) SceneStream.readTree(file.readBytes()) else SceneTree()
                    PageState.Ready(PageRenderer(tree))
                } catch (e: Exception) {
                    PageState.Failed(e.message ?: e.javaClass.simpleName)
                }
            }
        }

        Box(Modifier.fillMaxSize().padding(horizontal = 8.dp, vertical = 4.dp), contentAlignment = Alignment.Center) {
            when (val s = state) {
                PageState.Loading -> Unit
                is PageState.Failed -> Text("Couldn't read this page:\n${s.message}", fontSize = 18.sp)
                is PageState.Ready -> PageBitmap(s.renderer)
            }
        }
    }
}

/**
 * Renders the page once into a bitmap sized to the available space and draws that.
 * One bitmap draw per page keeps e-ink refreshes to a minimum.
 */
@Composable
private fun PageBitmap(renderer: PageRenderer) {
    BoxWithConstraints(Modifier.fillMaxSize()) {
        val w = constraints.maxWidth
        val h = constraints.maxHeight
        val layout = renderer.layout
        val scale = min(w / layout.width, h / layout.height)
        val bw = (layout.width * scale).toInt().coerceAtLeast(1)
        val bh = (layout.height * scale).toInt().coerceAtLeast(1)
        val bitmap = remember(renderer, bw, bh) {
            Bitmap.createBitmap(bw, bh, Bitmap.Config.ARGB_8888).also { bmp ->
                val c = Canvas(bmp)
                c.drawColor(android.graphics.Color.WHITE)
                c.scale(scale, scale)
                c.translate(-layout.xMin, -layout.yMin)
                renderer.render(AndroidPageCanvas(c))
            }
        }
        ComposeCanvas(Modifier.fillMaxSize()) {
            drawRect(Color.White)
            drawIntoCanvas { it.nativeCanvas.drawBitmap(bitmap, (size.width - bw) / 2f, 0f, null) }
        }
    }
}
