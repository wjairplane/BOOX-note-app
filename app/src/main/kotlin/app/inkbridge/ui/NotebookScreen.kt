package app.inkbridge.ui

import android.graphics.Bitmap
import android.graphics.Rect
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import app.inkbridge.AndroidPageCanvas
import app.inkbridge.AnnotatedPdfExporter
import app.inkbridge.AppController
import app.inkbridge.PageSession
import app.inkbridge.PdfBackground
import app.inkbridge.Screen
import app.inkbridge.pen.PenListener
import app.inkbridge.pen.PenSample
import app.inkbridge.pen.PenSurface
import app.inkbridge.rm.edit.InputPoint
import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.edit.StrokeBuilder
import app.inkbridge.rm.library.DocumentFactory
import app.inkbridge.rm.library.LibraryEntry
import app.inkbridge.rm.library.LibraryScanner
import app.inkbridge.rm.render.PageRenderer
import app.inkbridge.rm.render.PageTemplate
import app.inkbridge.rm.render.PenPalette
import app.inkbridge.rm.scene.SceneTree
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

/** Radius of the eraser in view pixels. */
private const val ERASER_RADIUS_PX = 22f

@Composable
fun NotebookScreen(app: AppController, nav: Screen.Notebook) {
    val doc = app.library[nav.docId]
    if (doc == null) {
        // The library is still loading (or the notebook was removed): show nothing rather than crash.
        return
    }
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val prefs = app.prefs
    val isPdf = doc.fileType == "pdf"
    val canDraw = doc.fileType == "notebook" || isPdf

    var pageIndex by remember(doc.id) { mutableIntStateOf(nav.page.coerceIn(0, (doc.pageIds.size - 1).coerceAtLeast(0))) }
    if (pageIndex > doc.pageIds.lastIndex) pageIndex = doc.pageIds.lastIndex.coerceAtLeast(0)

    var tool by remember(doc.id) { mutableStateOf(prefs.defaultPen) }
    var inkColor by remember(doc.id) { mutableIntStateOf(prefs.defaultColor) }
    var hlColor by remember(doc.id) { mutableIntStateOf(prefs.highlighterColor) }
    var thickness by remember(doc.id) { mutableIntStateOf(prefs.defaultThickness) }
    var panel by remember { mutableStateOf(false) }
    var menu by remember { mutableStateOf(false) }
    var overview by remember { mutableStateOf(false) }
    var confirmDelete by remember { mutableStateOf(false) }
    var revision by remember { mutableIntStateOf(0) }
    var surface by remember { mutableStateOf<PenSurface?>(null) }
    var strokes by remember { mutableIntStateOf(0) }
    var message by remember { mutableStateOf("") }

    val spec = PenSpec(tool, if (tool.isHighlighter) hlColor else inkColor, thickness)

    val session by produceState<PageSession?>(null, doc.id, pageIndex, doc.template, doc.pageIds.getOrNull(pageIndex)) {
        value = null
        value = withContext(Dispatchers.IO) {
            runCatching {
                val bg = if (isPdf) DocumentFactory.pdfPageFor(doc, pageIndex).takeIf { it >= 0 }?.let { PdfBackground(DocumentFactory.pdfFile(app.store.dir, doc), it) } else null
                PageSession(LibraryScanner.pageFile(app.store.dir, doc, pageIndex), bg, doc.template)
            }.onFailure { message = "Couldn't read this page: ${it.message}" }.getOrNull()
        }
    }

    fun save(s: PageSession?) {
        if (s == null || !s.isDirty) return
        message = try { s.save(); app.touch(doc); "" } catch (e: Exception) { "Save failed: ${e.message}" }
        revision++
    }
    DisposableEffect(session) { val s = session; onDispose { save(s) } }

    fun goTo(i: Int) { if (i in doc.pageIds.indices && i != pageIndex) { save(session); pageIndex = i; if (prefs.refreshEveryStrokes > 0) surface?.fullRefresh() } }
    fun newPageAfterCurrent() { save(session); app.addPage(doc, pageIndex) { pageIndex = it } }

    Box(Modifier.fillMaxSize()) {
        Row(Modifier.fillMaxSize()) {
            // ---------------- left toolbar ----------------
            @Suppress("UNUSED_EXPRESSION") revision
            Column(Modifier.width(92.dp).fillMaxHeight().border(1.dp, Ink.Rule).verticalScroll(rememberScrollState())) {
                ToolTile("Files", { save(session); app.screen = Screen.Files(folderId = doc.parentId.takeIf { it != "trash" } ?: "") })
                Rule()
                if (canDraw) {
                    ToolTile("Pen", { if (tool == PenTool.ERASER) tool = prefs.defaultPen.takeIf { it.isPen } ?: PenTool.FINELINER else panel = !panel }, selected = tool != PenTool.ERASER, sub = tool.takeIf { it != PenTool.ERASER }?.label?.take(10))
                    ToolTile("Eraser", { tool = PenTool.ERASER; panel = false }, selected = tool == PenTool.ERASER)
                    ToolTile("Undo", { if (session?.undo() == true) { surface?.refresh(); revision++ } }, enabled = session?.canUndo == true)
                    ToolTile("Redo", { if (session?.redo() == true) { surface?.refresh(); revision++ } }, enabled = session?.canRedo == true)
                    Rule()
                }
                ToolTile("Pages", { save(session); overview = true }, sub = "${pageIndex + 1} / ${doc.pageIds.size}")
                ToolTile("Refresh", { surface?.fullRefresh() })
                Box {
                    ToolTile("Menu", { menu = true })
                    DropdownMenu(menu, { menu = false }) {
                        @Composable fun item(label: String, enabled: Boolean = true, action: () -> Unit) =
                            DropdownMenuItem(text = { Text(label, fontSize = 20.sp) }, enabled = enabled, onClick = { menu = false; action() })
                        item("Add page after this one", canDraw) { newPageAfterCurrent() }
                        item("Delete this page", doc.pageIds.size > 1) { confirmDelete = true }
                        if (!isPdf) PageTemplate.entries.forEach { t -> item("Template: ${t.label}${if (doc.template == t) "  ✓" else ""}") { save(session); app.setTemplate(doc, t) } }
                        item("Export this page (SVG, PNG, PDF)", session != null) {
                            val s = session ?: return@item
                            val dir = File(context.getExternalFilesDir(null) ?: context.filesDir, "exports")
                            val safe = doc.name.replace(Regex("[^A-Za-z0-9._-]+"), "_").trim('_').ifEmpty { "page" }
                            message = "Exporting…"
                            scope.launch {
                                message = try {
                                    val files = withContext(Dispatchers.IO) { s.export(dir, "${safe}_p${pageIndex + 1}") }
                                    "Exported ${files.joinToString { it.name }} to ${dir.absolutePath}"
                                } catch (e: Exception) { "Export failed: ${e.message}" }
                            }
                        }
                        if (isPdf) item("Export annotated PDF") {
                            save(session)
                            val dir = File(context.getExternalFilesDir(null) ?: context.filesDir, "exports")
                            val safe = doc.name.replace(Regex("[^A-Za-z0-9._-]+"), "_").trim('_').ifEmpty { "document" }
                            val out = File(dir, "${safe}_annotated.pdf")
                            scope.launch {
                                message = try {
                                    withContext(Dispatchers.IO) { AnnotatedPdfExporter.export(app.store, doc, out) { d, t -> message = "Exporting PDF… $d / $t" } }
                                    "Saved ${out.name} (${out.length() / 1024} KB) to ${dir.absolutePath}"
                                } catch (e: Exception) { "PDF export failed: ${e.message}" }
                            }
                        }
                    }
                }
            }

            // ---------------- page ----------------
            Column(Modifier.weight(1f).fillMaxHeight()) {
                if (message.isNotEmpty()) {
                    Row(Modifier.fillMaxWidth().background(Ink.Panel).padding(horizontal = 16.dp, vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text(message, fontSize = 15.sp, modifier = Modifier.weight(1f))
                        EButton("OK", { message = "" }, size = 40.dp)
                    }
                }
                if (!canDraw) Text("This kind of document can't be shown yet.", fontSize = 18.sp, modifier = Modifier.padding(16.dp))
                PageArea(
                    session = session, spec = spec, drawing = canDraw && !overview,
                    swipeEnabled = prefs.swipeToTurn, fingerDraws = prefs.fingerDrawing,
                    onSurface = { surface = it },
                    onChanged = {
                        revision++
                        strokes++
                        val every = prefs.refreshEveryStrokes
                        if (every > 0 && strokes % every == 0) surface?.fullRefresh()
                    },
                    onSwipe = { forward ->
                        if (forward) { if (pageIndex < doc.pageIds.lastIndex) goTo(pageIndex + 1) else if (canDraw) newPageAfterCurrent() }
                        else goTo(pageIndex - 1)
                    },
                )
            }
        }

        // ---------------- pen panel ----------------
        if (panel && canDraw) {
            Box(Modifier.offset(x = 92.dp, y = 12.dp)) {
                PenPanel(
                    tool = tool, inkColor = inkColor, hlColor = hlColor, thickness = thickness,
                    onTool = { tool = it; prefs.defaultPen = it },
                    onInk = { inkColor = it; prefs.defaultColor = it },
                    onHl = { hlColor = it; prefs.highlighterColor = it },
                    onThickness = { thickness = it; prefs.defaultThickness = it },
                    onClose = { panel = false },
                )
            }
        }

        if (overview) PageOverview(app, doc, pageIndex, onPick = { overview = false; goTo(it) }, onAdd = { overview = false; app.addPage(doc, doc.pageIds.lastIndex) { pageIndex = it } }, onClose = { overview = false })
    }

    if (confirmDelete) ConfirmDialog("Delete this page?", "Page ${pageIndex + 1} and its handwriting will be deleted.", "Delete", { confirmDelete = false }) {
        confirmDelete = false
        val idx = pageIndex
        app.deletePage(doc, idx) { pageIndex = (idx - 1).coerceAtLeast(0).coerceAtMost(doc.pageIds.size - 2) }
    }
}

// -------------------------------------------------------------------------------------------------

/** The page itself: a pen surface sized to the space available. */
@Composable
private fun PageArea(
    session: PageSession?, spec: PenSpec, drawing: Boolean, swipeEnabled: Boolean, fingerDraws: Boolean,
    onSurface: (PenSurface?) -> Unit, onChanged: () -> Unit, onSwipe: (Boolean) -> Unit,
) {
    val lifecycle = LocalLifecycleOwner.current.lifecycle
    var surface by remember { mutableStateOf<PenSurface?>(null) }
    var layoutVersion by remember { mutableIntStateOf(0) }
    val currentSession by rememberUpdatedState(session)
    val currentOnChanged by rememberUpdatedState(onChanged)
    val currentOnSwipe by rememberUpdatedState(onSwipe)

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

        LaunchedEffect(surface, spec, drawing, session, layoutVersion, swipeEnabled, fingerDraws) {
            val view = surface ?: return@LaunchedEffect
            view.swipeEnabled = swipeEnabled
            view.fingerDraws = fingerDraws
            view.setTool(spec, session?.transform?.scale ?: 1f)
            view.penEnabled = drawing && session != null
        }

        AndroidView(
            modifier = Modifier.fillMaxSize(),
            factory = { ctx ->
                PenSurface(ctx, object : PenListener {
                    override fun onStroke(samples: List<PenSample>) = apply(samples) { s, sp -> s.addStroke(sp, samples) }
                    override fun onErase(samples: List<PenSample>) = apply(samples) { s, _ -> s.erase(samples, ERASER_RADIUS_PX) }
                    override fun onSwipe(forward: Boolean) { currentOnSwipe(forward) }

                    private fun apply(samples: List<PenSample>, edit: (PageSession, PenSpec) -> Boolean) {
                        val s = currentSession ?: return
                        val view = surface ?: return
                        if (samples.isEmpty()) return
                        if (edit(s, view.currentSpec)) { view.refresh(); currentOnChanged() }
                    }
                }).also { surface = it; onSurface(it) }
            },
        )
    }
}

// -------------------------------------------------------------------------------------------------

@Composable
private fun PenPanel(
    tool: PenTool, inkColor: Int, hlColor: Int, thickness: Int,
    onTool: (PenTool) -> Unit, onInk: (Int) -> Unit, onHl: (Int) -> Unit, onThickness: (Int) -> Unit, onClose: () -> Unit,
) {
    val color = if (tool.isHighlighter) hlColor else inkColor
    Column(Modifier.width(470.dp).background(Ink.White).border(2.dp, Ink.Black).padding(16.dp)) {
        Text("Pens", fontSize = 22.sp, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(8.dp))
        PenTool.PENS.forEach { t ->
            val selected = t == tool
            val previewColor = if (t.isHighlighter) hlColor else inkColor
            Row(
                Modifier.fillMaxWidth().background(if (selected) Ink.Panel else Ink.White).tap { onTool(t) }.padding(vertical = 4.dp, horizontal = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                PenPreview(PenSpec(t, previewColor, thickness), Modifier.width(250.dp).height(48.dp))
                Spacer(Modifier.width(10.dp))
                Text(t.label, fontSize = 18.sp, fontWeight = if (selected) FontWeight.Bold else FontWeight.Normal, modifier = Modifier.weight(1f))
                if (selected) Text("✓", fontSize = 22.sp)
            }
            Rule()
        }
        if (!tool.isHighlighter) {
            Spacer(Modifier.height(12.dp))
            Text("Thickness", fontSize = 16.sp, color = Ink.Grey)
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.padding(top = 6.dp)) {
                listOf(1 to "Thin", 2 to "Medium", 3 to "Thick").forEach { (v, l) -> EButton(l, { onThickness(v) }, selected = thickness == v) }
            }
        }
        Spacer(Modifier.height(12.dp))
        Text("Colour", fontSize = 16.sp, color = Ink.Grey)
        Row(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.padding(top = 6.dp)) {
            val colors = if (tool.isHighlighter) PenSpec.HIGHLIGHTER_COLORS else PenSpec.INK_COLORS
            colors.forEach { c ->
                val rgba = PenPalette.lookup(c, null)
                val fill = Color(rgba[0], rgba[1], rgba[2])
                Box(
                    Modifier.size(52.dp).background(fill, CircleShape).border(if (c == color) 5.dp else 1.5.dp, Ink.Black, CircleShape)
                        .tap { if (tool.isHighlighter) onHl(c) else onInk(c) },
                    contentAlignment = Alignment.Center,
                ) { if (c == color) Text("✓", fontSize = 22.sp, color = if (rgba[0] + rgba[1] + rgba[2] < 380) Color.White else Color.Black) }
            }
        }
        Spacer(Modifier.height(14.dp))
        EButton("Done", onClose, modifier = Modifier.fillMaxWidth())
    }
}

/** A sample stroke drawn with the real pen model, so the panel shows what each pen looks like. */
@Composable
private fun PenPreview(spec: PenSpec, modifier: Modifier) {
    val line = remember(spec) {
        val pts = (0..44).map {
            val t = it / 44f
            InputPoint(14f + t * 272f, 36f + kotlin.math.sin(t * 6.2f).toFloat() * 11f, 0.25f + 0.75f * kotlin.math.sin(t * 3.14f).toFloat(), 20f, 10f, it * 5L)
        }
        StrokeBuilder.build(spec, pts)
    }
    val renderer = remember { PageRenderer(SceneTree()) }
    Canvas(modifier) {
        val s = size.width / 300f
        drawIntoCanvas { c ->
            val n = c.nativeCanvas
            n.save(); n.scale(s, s)
            line?.let { renderer.renderLine(it, 0f, 0f, AndroidPageCanvas(n)) }
            n.restore()
        }
    }
}

@Composable
private fun PageOverview(app: AppController, doc: LibraryEntry, current: Int, onPick: (Int) -> Unit, onAdd: () -> Unit, onClose: () -> Unit) {
    Column(Modifier.fillMaxSize().background(Ink.White)) {
        Row(Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 10.dp), verticalAlignment = Alignment.CenterVertically) {
            Text("${doc.name} · ${doc.pageIds.size} page${if (doc.pageIds.size == 1) "" else "s"}", fontSize = 26.sp, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
            if (doc.fileType == "notebook") { EButton("+ Add page", onAdd); Spacer(Modifier.width(10.dp)) }
            EButton("Close", onClose, selected = true)
        }
        Rule()
        LazyVerticalGrid(GridCells.Adaptive(minSize = 190.dp), contentPadding = PaddingValues(20.dp), horizontalArrangement = Arrangement.spacedBy(18.dp), verticalArrangement = Arrangement.spacedBy(22.dp)) {
            itemsIndexed(doc.pageIds) { i, _ ->
                Column(Modifier.tap { onPick(i) }) {
                    val bmp by produceState<Bitmap?>(null, doc.id, i, doc.pageIds.getOrNull(i), doc.lastModified, doc.template) {
                        value = withContext(Dispatchers.IO) { runCatching { app.thumbnails.render(doc, i, 300) }.getOrNull() }
                    }
                    Box(Modifier.fillMaxWidth().aspectRatio(0.75f).border(if (i == current) 5.dp else 1.5.dp, Ink.Black).background(Ink.White)) {
                        bmp?.let { Image(it.asImageBitmap(), "Page ${i + 1}", contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize()) }
                    }
                    Text("${i + 1}", fontSize = 18.sp, fontWeight = if (i == current) FontWeight.Bold else FontWeight.Normal, modifier = Modifier.align(Alignment.CenterHorizontally).padding(top = 6.dp))
                }
            }
        }
    }
}
