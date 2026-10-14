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
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.Dp
import app.inkbridge.ToolSlot
import app.inkbridge.ToolbarPosition
import androidx.compose.foundation.layout.PaddingValues
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

private val TOOLBAR_THICKNESS = 68.dp

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

    // Two quick-switch writing tools (like the tablet's toolbar), plus the eraser.
    var activeSlot by remember(doc.id) { mutableIntStateOf(0) }
    var erasing by remember(doc.id) { mutableStateOf(false) }
    var panel by remember { mutableStateOf(false) }
    var menu by remember { mutableStateOf(false) }
    var overview by remember { mutableStateOf(false) }
    var confirmDelete by remember { mutableStateOf(false) }
    var revision by remember { mutableIntStateOf(0) }
    var surface by remember { mutableStateOf<PenSurface?>(null) }
    var strokes by remember { mutableIntStateOf(0) }
    var message by remember { mutableStateOf("") }

    val slot = prefs.slot(activeSlot)
    val spec = if (erasing) PenSpec(PenTool.ERASER) else PenSpec(slot.tool, slot.colorId, slot.thickness)

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

    val pos = prefs.toolbarPosition
    val horizontal = pos == ToolbarPosition.TOP || pos == ToolbarPosition.BOTTOM

    @Composable
    fun toolbar() {
        @Suppress("UNUSED_EXPRESSION") revision
        val start: @Composable () -> Unit = {
            Box {
                IconTile("Menu", { menu = true }) { InkIcons.MenuDot(tint = it) }
                DropdownMenu(menu, { menu = false }) {
                    @Composable fun item(label: String, enabled: Boolean = true, action: () -> Unit) =
                        DropdownMenuItem(text = { Text(label, fontSize = 20.sp) }, enabled = enabled, onClick = { menu = false; action() })
                    item("My files") { save(session); app.screen = Screen.Files(folderId = doc.parentId.takeIf { it != "trash" } ?: "") }
                    item("Add page after this one", canDraw) { newPageAfterCurrent() }
                    item("Delete this page", doc.pageIds.size > 1) { confirmDelete = true }
                    if (!isPdf) PageTemplate.entries.forEach { t -> item("Template: ${t.label}${if (doc.template == t) "  ✓" else ""}") { save(session); app.setTemplate(doc, t) } }
                    item("Refresh the screen") { surface?.fullRefresh() }
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
            if (canDraw) {
                // Two writing tools: tap the other one to switch, tap the active one to open its menu.
                for (i in 0..1) {
                    val s = prefs.slot(i)
                    val active = !erasing && activeSlot == i
                    IconTile("Writing tool ${i + 1}: ${s.tool.label}", {
                        if (active) panel = !panel else { activeSlot = i; erasing = false; panel = false }
                    }, selected = active) { tint ->
                        Box {
                            InkIcons.Pen(s.tool, tint = tint)
                            ColourDot(s.colorId, active, Modifier.align(Alignment.TopEnd))
                        }
                    }
                }
                IconTile("Eraser", { erasing = true; panel = false }, selected = erasing) { InkIcons.Eraser(tint = it) }
                IconTile("Undo", { if (session?.undo() == true) { surface?.refresh(); revision++ } }, enabled = session?.canUndo == true) { InkIcons.Undo(tint = it) }
                IconTile("Redo", { if (session?.redo() == true) { surface?.refresh(); revision++ } }, enabled = session?.canRedo == true) { InkIcons.Redo(tint = it) }
            }
        }
        val end: @Composable () -> Unit = {
            Text("${pageIndex + 1}/${doc.pageIds.size}", fontSize = 16.sp, color = Ink.Grey, modifier = Modifier.padding(horizontal = 6.dp))
            IconTile("Page overview", { save(session); overview = true }) { InkIcons.Overview(tint = it) }
        }
        if (horizontal) {
            Row(Modifier.fillMaxWidth().height(TOOLBAR_THICKNESS).border(1.dp, Ink.Rule).padding(horizontal = 6.dp), verticalAlignment = Alignment.CenterVertically) {
                start(); Spacer(Modifier.weight(1f)); end()
            }
        } else {
            Column(Modifier.fillMaxHeight().width(TOOLBAR_THICKNESS).border(1.dp, Ink.Rule).padding(vertical = 6.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                start(); Spacer(Modifier.weight(1f)); end()
            }
        }
    }

    @Composable
    fun page() {
        Column(Modifier.fillMaxSize()) {
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

    Box(Modifier.fillMaxSize()) {
        when (pos) {
            ToolbarPosition.TOP -> Column(Modifier.fillMaxSize()) { toolbar(); Box(Modifier.weight(1f)) { page() } }
            ToolbarPosition.BOTTOM -> Column(Modifier.fillMaxSize()) { Box(Modifier.weight(1f)) { page() }; toolbar() }
            ToolbarPosition.LEFT -> Row(Modifier.fillMaxSize()) { toolbar(); Box(Modifier.weight(1f)) { page() } }
            ToolbarPosition.RIGHT -> Row(Modifier.fillMaxSize()) { Box(Modifier.weight(1f)) { page() }; toolbar() }
        }

        // The pen menu opens next to the toolbar, on the side facing the page.
        if (panel && canDraw && !erasing) {
            val align = when (pos) {
                ToolbarPosition.TOP, ToolbarPosition.LEFT -> Alignment.TopStart
                ToolbarPosition.BOTTOM -> Alignment.BottomStart
                ToolbarPosition.RIGHT -> Alignment.TopEnd
            }
            val pad = when (pos) {
                ToolbarPosition.TOP -> PaddingValues(start = 8.dp, top = TOOLBAR_THICKNESS + 4.dp)
                ToolbarPosition.BOTTOM -> PaddingValues(start = 8.dp, bottom = TOOLBAR_THICKNESS + 4.dp)
                ToolbarPosition.LEFT -> PaddingValues(start = TOOLBAR_THICKNESS + 4.dp, top = 8.dp)
                ToolbarPosition.RIGHT -> PaddingValues(end = TOOLBAR_THICKNESS + 4.dp, top = 8.dp)
            }
            Box(Modifier.align(align).padding(pad)) {
                PenMenu(slot, onChange = { prefs.setSlot(activeSlot, it) })
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

/** A toolbar button: icon only, inverted when selected. [description] doubles as its accessibility label. */
@Composable
private fun IconTile(description: String, onClick: () -> Unit, selected: Boolean = false, enabled: Boolean = true, icon: @Composable (Color) -> Unit) {
    val tint = if (selected) Ink.White else if (enabled) Ink.Black else Ink.Rule
    Box(
        Modifier.size(56.dp).background(if (selected) Ink.Black else Ink.White).tap(enabled, onClick).semantics { contentDescription = description },
        contentAlignment = Alignment.Center,
    ) { icon(tint) }
}

/** The small colour marker on a tool slot / colour tile: filled with the colour, ringed so white stays visible. */
@Composable
private fun ColourDot(colorId: Int, onDark: Boolean, modifier: Modifier = Modifier, size: Dp = 14.dp) {
    val rgba = PenPalette.lookup(colorId, null)
    Box(modifier.size(size).background(Color(rgba[0], rgba[1], rgba[2]), CircleShape).border(1.5.dp, if (onDark) Ink.White else Ink.Black, CircleShape))
}

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


// -------------------------------------------------------------------------------------------------

/** One square choice in the pen menu, inverted when selected. */
@Composable
private fun MenuTile(selected: Boolean, description: String, onClick: () -> Unit, modifier: Modifier = Modifier, content: @Composable ColumnScope.(Color) -> Unit) {
    val fg = if (selected) Ink.White else Ink.Black
    Column(
        modifier.size(width = 92.dp, height = 78.dp).background(if (selected) Ink.Black else Ink.White).tap(onClick = onClick).semantics { contentDescription = description },
        horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center,
    ) { content(fg) }
}

/**
 * The pen menu: three stacked sections, as on the tablet. A 3 x 3 grid of the nine pens (titled with the
 * current one), the three thicknesses (titled with the current one), and a 3 x 3 grid of named colours.
 */
@Composable
private fun PenMenu(slot: ToolSlot, onChange: (ToolSlot) -> Unit) {
    val highlighter = slot.tool.usesHighlighterColors
    Column(Modifier.width(92.dp * 3 + 24.dp).background(Ink.White).border(1.dp, Ink.Black)) {
        Section(slot.tool.label) {
            PenTool.PENS.chunked(3).forEach { row ->
                Row { row.forEach { t -> MenuTile(t == slot.tool, t.label, { onChange(slot.copy(tool = t, colorId = colorFor(t, slot))) }) { fg -> InkIcons.Pen(t, tint = fg) } } }
            }
        }
        Rule()
        if (!highlighter) {
            Section(listOf("Thin", "Medium", "Thick")[slot.thickness - 1]) {
                Row {
                    (1..3).forEach { th ->
                        MenuTile(th == slot.thickness, listOf("Thin", "Medium", "Thick")[th - 1], { onChange(slot.copy(thickness = th)) }) { fg -> InkIcons.Thickness(th, tint = fg) }
                    }
                }
            }
            Rule()
        }
        Section(null) {
            val colors = if (highlighter) PenSpec.HIGHLIGHTER_COLORS else PenSpec.INK_COLORS
            colors.toList().chunked(3).forEach { row ->
                Row {
                    row.forEach { c ->
                        val selected = c == slot.colorId
                        MenuTile(selected, PenSpec.colorName(c), { onChange(slot.copy(colorId = c)) }) { fg ->
                            ColourDot(c, selected, size = 26.dp)
                            Spacer(Modifier.height(4.dp))
                            Text(PenSpec.colorName(c), color = fg, fontSize = 15.sp)
                        }
                    }
                }
            }
        }
    }
}

/** Keep the colour valid when switching between ink pens and the highlighter, which use different colour sets. */
private fun colorFor(tool: PenTool, slot: ToolSlot): Int {
    val allowed = if (tool.usesHighlighterColors) PenSpec.HIGHLIGHTER_COLORS else PenSpec.INK_COLORS
    return if (slot.colorId in allowed) slot.colorId else allowed.first()
}

@Composable
private fun Section(title: String?, content: @Composable ColumnScope.() -> Unit) {
    Column(Modifier.padding(start = 12.dp, end = 12.dp, top = 8.dp, bottom = 8.dp)) {
        if (title != null) Text(title, fontSize = 16.sp, color = Ink.Grey, modifier = Modifier.padding(bottom = 4.dp))
        content()
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
