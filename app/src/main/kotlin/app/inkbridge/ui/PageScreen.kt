package app.inkbridge.ui

import android.graphics.Rect
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import app.inkbridge.LibraryStore
import app.inkbridge.PageSession
import app.inkbridge.pen.PenListener
import app.inkbridge.pen.PenSample
import app.inkbridge.pen.PenSurface
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.library.LibraryEntry
import app.inkbridge.rm.library.LibraryScanner
import app.inkbridge.rm.scene.PenColorId
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

private val InkColorNames = mapOf(
    PenColorId.BLACK to "Black", PenColorId.GRAY to "Gray", PenColorId.BLUE to "Blue",
    PenColorId.RED to "Red", PenColorId.GREEN to "Green",
    PenColorId.YELLOW to "Yellow", PenColorId.PINK to "Pink",
)

/** Radius of the eraser in view pixels. */
private const val ERASER_RADIUS_PX = 22f

@Composable
fun PageScreen(store: LibraryStore, doc: LibraryEntry, onClose: () -> Unit) {
    var index by remember(doc.id) { mutableIntStateOf(0) }
    val pageCount = doc.pageIds.size
    val canDraw = doc.fileType == "notebook"

    // Pen settings.
    var drawing by remember { mutableStateOf(canDraw) }
    var tool by remember { mutableStateOf(PenTool.FINELINER) }
    var inkColor by remember { mutableIntStateOf(PenColorId.BLACK) }
    var hlColor by remember { mutableIntStateOf(PenColorId.YELLOW) }
    var thickness by remember { mutableIntStateOf(2) }
    val spec = PenSpec(tool, if (tool == PenTool.HIGHLIGHTER) hlColor else inkColor, thickness)

    var revision by remember { mutableIntStateOf(0) }   // bumped whenever the session changes, to refresh toolbar state
    var message by remember { mutableStateOf("") }

    val session by produceState<PageSession?>(null, doc.id, index) {
        value = null
        value = withContext(Dispatchers.IO) {
            runCatching { PageSession(LibraryScanner.pageFile(store.dir, doc, index)) }
                .onFailure { message = "Couldn't read this page: ${it.message}" }
                .getOrNull()
        }
    }

    // Save when leaving a page (or the screen). A failed save keeps the edits in memory and says so.
    fun save(s: PageSession?) {
        if (s == null || !s.isDirty) return
        message = try { s.save(); "" } catch (e: Exception) { "Save failed: ${e.message}" }
        revision++
    }
    DisposableEffect(session) {
        val s = session
        onDispose { save(s) }
    }

    Column(Modifier.fillMaxSize()) {
        // Row 1: navigation.
        Row(Modifier.fillMaxWidth().padding(horizontal = 12.dp, vertical = 6.dp), verticalAlignment = Alignment.CenterVertically) {
            BlackButton("Library", onClose)
            Spacer(Modifier.width(10.dp))
            Text(doc.name, fontSize = 20.sp, modifier = Modifier.weight(1f), maxLines = 1)
            BlackButton("◀", { index-- }, enabled = index > 0)
            Text(if (pageCount == 0) "–" else "${index + 1} / $pageCount", fontSize = 18.sp, modifier = Modifier.padding(horizontal = 12.dp))
            BlackButton("▶", { index++ }, enabled = index < pageCount - 1)
        }
        // Row 2+3: pen controls.
        if (canDraw) {
            @Suppress("UNUSED_EXPRESSION") revision
            Row(Modifier.fillMaxWidth().padding(horizontal = 12.dp), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                BlackButton("Pen", { drawing = !drawing }, selected = drawing)
                for (t in listOf(PenTool.FINELINER, PenTool.BALLPOINT, PenTool.PENCIL, PenTool.HIGHLIGHTER, PenTool.ERASER)) {
                    BlackButton(t.label, { tool = t; drawing = true }, selected = drawing && tool == t)
                }
                Spacer(Modifier.weight(1f))
                BlackButton("Undo", { if (session?.undo() == true) { revision++ } }, enabled = session?.canUndo == true)
                BlackButton("Redo", { if (session?.redo() == true) { revision++ } }, enabled = session?.canRedo == true)
                BlackButton(if (session?.isDirty == true) "Save •" else "Saved", { save(session) }, enabled = session?.isDirty == true)
            }
            Row(Modifier.fillMaxWidth().padding(horizontal = 12.dp, vertical = 6.dp), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                if (tool != PenTool.ERASER) {
                    Text("Size", fontSize = 16.sp)
                    listOf(1 to "S", 2 to "M", 3 to "L").forEach { (v, l) ->
                        BlackButton(l, { thickness = v }, selected = thickness == v, enabled = tool != PenTool.HIGHLIGHTER)
                    }
                    Spacer(Modifier.width(12.dp))
                    Text("Colour", fontSize = 16.sp)
                    val colors = if (tool == PenTool.HIGHLIGHTER) PenSpec.HIGHLIGHTER_COLORS else PenSpec.INK_COLORS
                    for (c in colors) {
                        val current = if (tool == PenTool.HIGHLIGHTER) hlColor else inkColor
                        BlackButton(InkColorNames.getValue(c), { if (tool == PenTool.HIGHLIGHTER) hlColor = c else inkColor = c }, selected = current == c)
                    }
                } else {
                    Text("Drag over strokes to erase them.", fontSize = 16.sp)
                }
            }
        }
        if (message.isNotEmpty()) Text(message, fontSize = 16.sp, modifier = Modifier.padding(horizontal = 12.dp))
        if (!canDraw) Text("Drawing is off: ${doc.fileType} pages can't be shown or annotated yet.", fontSize = 16.sp, modifier = Modifier.padding(horizontal = 12.dp))
        if (pageCount == 0) {
            Text("This document has no pages.", fontSize = 20.sp, modifier = Modifier.padding(24.dp))
            return@Column
        }

        PageArea(session = session, spec = spec, drawing = drawing && canDraw, onChanged = { revision++ })
    }
}

/** The page itself: a pen surface sized to the space left under the toolbar. */
@Composable
private fun PageArea(session: PageSession?, spec: PenSpec, drawing: Boolean, onChanged: () -> Unit) {
    val lifecycle = LocalLifecycleOwner.current.lifecycle
    var surface by remember { mutableStateOf<PenSurface?>(null) }
    var layoutVersion by remember { mutableIntStateOf(0) }   // bumped once the page has been sized, so pen settings pick up its scale
    val currentSession by rememberUpdatedState(session)
    val currentOnChanged by rememberUpdatedState(onChanged)

    // The raw-drawing layer must be released whenever the app isn't in the foreground.
    DisposableEffect(lifecycle, surface) {
        val obs = LifecycleEventObserver { _, e ->
            when (e) {
                Lifecycle.Event.ON_PAUSE -> surface?.onPause()
                Lifecycle.Event.ON_RESUME -> surface?.onResume()
                else -> Unit
            }
        }
        lifecycle.addObserver(obs)
        onDispose { lifecycle.removeObserver(obs) }
    }

    BoxWithConstraints(Modifier.fillMaxSize()) {
        val w = constraints.maxWidth
        val h = constraints.maxHeight

        // (Re)layout the page whenever the session or the available size changes.
        LaunchedEffect(session, w, h, surface) {
            val s = session ?: return@LaunchedEffect
            val view = surface ?: return@LaunchedEffect
            withContext(Dispatchers.Default) { s.resize(w, h) }
            val t = s.transform ?: return@LaunchedEffect
            val bmp = s.bitmap ?: return@LaunchedEffect
            view.setPageArea(Rect(t.offsetX.toInt(), 0, t.offsetX.toInt() + bmp.width, bmp.height))
            view.show(bmp, t.offsetX)
            layoutVersion++
        }

        // Pen settings flow to the surface.
        LaunchedEffect(surface, spec, drawing, session, layoutVersion) {
            val view = surface ?: return@LaunchedEffect
            val scale = session?.transform?.scale ?: 1f
            view.setTool(spec, scale)
            view.penEnabled = drawing && session != null
        }

        AndroidView(
            modifier = Modifier.fillMaxSize(),
            factory = { ctx ->
                PenSurface(ctx, object : PenListener {
                    override fun onStroke(samples: List<PenSample>) = apply(samples) { s, sp -> s.addStroke(sp, samples) }
                    override fun onErase(samples: List<PenSample>) = apply(samples) { s, _ -> s.erase(samples, ERASER_RADIUS_PX) }

                    private fun apply(samples: List<PenSample>, edit: (PageSession, PenSpec) -> Boolean) {
                        val s = currentSession ?: return
                        val view = surface ?: return
                        if (samples.isEmpty()) return
                        if (edit(s, currentSpec(view))) {
                            view.refresh()
                            currentOnChanged()
                        }
                    }
                }).also { surface = it }
            },
        )
    }
}

private fun currentSpec(view: PenSurface): PenSpec = view.currentSpec
