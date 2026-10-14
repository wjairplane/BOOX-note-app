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
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.foundation.gestures.detectDragGesturesAfterLongPress
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect as UiRect
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.boundsInRoot
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.unit.IntSize
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
/** Eraser radius in view pixels for thin, medium and thick. */
private val ERASER_RADII = floatArrayOf(14f, 22f, 36f)

/** Toolbar buttons are 112 px square (controlsHeight.large), edge to edge. */
private val TOOLBAR_THICKNESS = Rm.ToolButton

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
    var collapsed by remember { mutableStateOf(false) }
    var dragOffset by remember { mutableStateOf(Offset.Zero) }
    var toolbarBounds by remember { mutableStateOf(UiRect.Zero) }
    var rootSize by remember { mutableStateOf(IntSize.Zero) }
    var menu by remember { mutableStateOf(false) }
    var menuPage by remember { mutableStateOf<String?>(null) } // null = the menu's first level; "add", "template", "share" = a sub-menu
    var eraserMenu by remember { mutableStateOf(false) }
    var eraserThickness by remember { mutableIntStateOf(2) }
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
    // Foldouts open on the side of the toolbar that faces the page, level with the button that opened them.
    val side = when (pos) { ToolbarPosition.LEFT -> MenuSide.RIGHT; ToolbarPosition.RIGHT -> MenuSide.LEFT; ToolbarPosition.TOP -> MenuSide.BELOW; ToolbarPosition.BOTTOM -> MenuSide.ABOVE }
    val exportDir = File(context.getExternalFilesDir(null) ?: context.filesDir, "exports")

    @Composable
    fun toolbar() {
        @Suppress("UNUSED_EXPRESSION") revision
        val start: @Composable () -> Unit = {
            // The round button hides the rest of the toolbar (and brings it back).
            IconTile(if (collapsed) "Show toolbar" else "Hide toolbar", { collapsed = !collapsed; panel = false; eraserMenu = false; menu = false }) { InkIcons.MenuDot(tint = it) }
            if (!collapsed && canDraw) {
                // Two writing tools: tap the other one to switch, tap the active one to open its foldout.
                for (i in 0..1) {
                    val s = prefs.slot(i)
                    val active = !erasing && activeSlot == i
                    Box {
                        IconTile("Writing tool ${i + 1}: ${s.tool.label}", {
                            if (active) panel = !panel else { activeSlot = i; erasing = false; panel = false; eraserMenu = false }
                        }, selected = active) { tint ->
                            Box {
                                InkIcons.Pen(s.tool, tint = tint)
                                ColourDot(s.colorId, active, Modifier.align(Alignment.TopEnd))
                            }
                        }
                        if (active) RmMenu(panel, { panel = false }, side, Rm.WritingFoldoutWidth) { PenMenu(slot, onChange = { prefs.setSlot(activeSlot, it) }) }
                    }
                }
                // The eraser: tap to pick it, tap again for its foldout (tool, thickness, erase all).
                Box {
                    IconTile("Eraser", { if (erasing) eraserMenu = !eraserMenu else { erasing = true; panel = false; eraserMenu = false } }, selected = erasing) { InkIcons.Eraser(tint = it) }
                    RmMenu(eraserMenu && erasing, { eraserMenu = false }, side, Rm.EraserFoldoutMinWidth) {
                        EraserMenu(eraserThickness, onThickness = { eraserThickness = it }, onEraseAll = {
                            eraserMenu = false
                            if (session?.eraseAll() == true) { surface?.refresh(); revision++ }
                        })
                    }
                }
                IconTile("Undo", { if (session?.undo() == true) { surface?.refresh(); revision++ } }, enabled = session?.canUndo == true) { InkIcons.Undo(tint = it) }
                IconTile("Redo", { if (session?.redo() == true) { surface?.refresh(); revision++ } }, enabled = session?.canRedo == true) { InkIcons.Redo(tint = it) }
            }
        }
        val end: @Composable () -> Unit = {
            if (!collapsed) {
                IconTile("Page overview", { save(session); overview = true }) { InkIcons.Overview(tint = it) }
                Box {
                    // The three dots open the notebook menu; inside a sub-menu the button becomes a back chevron.
                    IconTile("More", { if (menu && menuPage != null) menuPage = null else { menu = !menu; menuPage = null } }, selected = menu) {
                        if (menuPage != null) InkIcons.ChevronLeft(tint = it) else InkIcons.More(tint = it)
                    }
                    RmMenu(menu, { menu = false; menuPage = null }, side, Rm.FoldoutMinWidth) {
                        fun close() { menu = false; menuPage = null }
                        when (menuPage) {
                            null -> {
                                if (canDraw) RmFoldoutItem("Add page", { menuPage = "add" }, chevron = true) { InkIcons.PageAdd(tint = it) }
                                RmFoldoutItem("Delete page", { close(); confirmDelete = true }, enabled = doc.pageIds.size > 1) { InkIcons.Trash(tint = it) }
                                if (!isPdf) RmFoldoutItem("Template", { menuPage = "template" }, chevron = true, topDivider = true) { InkIcons.Template(tint = it) }
                                RmFoldoutItem("Share", { menuPage = "share" }, chevron = true, topDivider = !isPdf) { InkIcons.Share(tint = it) }
                                RmFoldoutItem("Refresh screen", { close(); surface?.fullRefresh() }, topDivider = true) { InkIcons.Refresh(tint = it) }
                            }
                            "add" -> {
                                RmFoldoutItem("Add page before", { close(); save(session); app.addPage(doc, pageIndex - 1) { pageIndex = it } }) { InkIcons.PageAdd(tint = it) }
                                RmFoldoutItem("Add page after", { close(); newPageAfterCurrent() }) { InkIcons.PageAdd(tint = it) }
                            }
                            "template" -> PageTemplate.entries.forEach { t ->
                                RmFoldoutItem(t.label, { close(); save(session); app.setTemplate(doc, t) }, selected = doc.template == t)
                            }
                            "share" -> {
                                RmFoldoutItem("Export page", {
                                    close()
                                    val s = session ?: return@RmFoldoutItem
                                    val safe = doc.name.replace(Regex("[^A-Za-z0-9._-]+"), "_").trim('_').ifEmpty { "page" }
                                    message = "Exporting…"
                                    scope.launch {
                                        message = try {
                                            val files = withContext(Dispatchers.IO) { s.export(exportDir, "${safe}_p${pageIndex + 1}") }
                                            "Exported ${files.joinToString { it.name }} to ${exportDir.absolutePath}"
                                        } catch (e: Exception) { "Export failed: ${e.message}" }
                                    }
                                }, enabled = session != null) { InkIcons.Export(tint = it) }
                                if (isPdf) RmFoldoutItem("Export annotated PDF", {
                                    close(); save(session)
                                    val safe = doc.name.replace(Regex("[^A-Za-z0-9._-]+"), "_").trim('_').ifEmpty { "document" }
                                    val out = File(exportDir, "${safe}_annotated.pdf")
                                    scope.launch {
                                        message = try {
                                            withContext(Dispatchers.IO) { AnnotatedPdfExporter.export(app.store, doc, out) { d, t -> message = "Exporting PDF… $d / $t" } }
                                            "Saved ${out.name} (${out.length() / 1024} KB) to ${exportDir.absolutePath}"
                                        } catch (e: Exception) { "PDF export failed: ${e.message}" }
                                    }
                                }) { InkIcons.Export(tint = it) }
                            }
                        }
                    }
                }
                // Close the notebook and go back to My files.
                IconTile("Close notebook", { save(session); app.screen = Screen.Files(folderId = doc.parentId.takeIf { it != "trash" } ?: "") }) { InkIcons.XCircle(tint = it) }
            }
        }
        // No frame around the toolbar: its icons sit straight on the page, as on the tablet.
        // Press and hold the toolbar, then drag it to another edge (the tablet's "moveable toolbar").
        val drag = Modifier
            .onGloballyPositioned { toolbarBounds = it.boundsInRoot() }
            .graphicsLayer { translationX = dragOffset.x; translationY = dragOffset.y }
            .pointerInput(Unit) {
                detectDragGesturesAfterLongPress(
                    onDragStart = { panel = false; menu = false; eraserMenu = false },
                    onDrag = { change, amount -> change.consume(); dragOffset += amount },
                    onDragEnd = {
                        val c = toolbarBounds.center
                        prefs.toolbarPosition = nearestEdge(c.x, c.y, rootSize.width.toFloat(), rootSize.height.toFloat())
                        dragOffset = Offset.Zero
                    },
                    onDragCancel = { dragOffset = Offset.Zero },
                )
            }
        if (horizontal) {
            Row(Modifier.fillMaxWidth().height(TOOLBAR_THICKNESS).then(drag), verticalAlignment = Alignment.CenterVertically) {
                start(); Spacer(Modifier.weight(1f)); end()
            }
        } else {
            Column(Modifier.fillMaxHeight().width(TOOLBAR_THICKNESS).then(drag), horizontalAlignment = Alignment.CenterHorizontally) {
                start(); Spacer(Modifier.weight(1f)); end()
            }
        }
    }

    @Composable
    fun page() {
        Column(Modifier.fillMaxSize()) {
            if (message.isNotEmpty()) {
                Row(Modifier.fillMaxWidth().background(Ink.Panel).padding(horizontal = 32.dp, vertical = 16.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text(message, style = RmText.BodySm, modifier = Modifier.weight(1f))
                    EButton("OK", { message = "" }, size = Rm.Control)
                }
            }
            if (!canDraw) Text("This kind of document can't be shown yet.", style = RmText.Body, modifier = Modifier.padding(32.dp))
            PageArea(
                session = session, spec = spec, drawing = canDraw && !overview,
                swipeEnabled = prefs.swipeToTurn, fingerDraws = prefs.fingerDrawing,
                eraserRadius = ERASER_RADII[eraserThickness - 1],
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

    Box(Modifier.fillMaxSize().onSizeChanged { rootSize = it }) {
        when (pos) {
            ToolbarPosition.TOP -> Column(Modifier.fillMaxSize()) { toolbar(); Box(Modifier.weight(1f)) { page() } }
            ToolbarPosition.BOTTOM -> Column(Modifier.fillMaxSize()) { Box(Modifier.weight(1f)) { page() }; toolbar() }
            ToolbarPosition.LEFT -> Row(Modifier.fillMaxSize()) { toolbar(); Box(Modifier.weight(1f)) { page() } }
            ToolbarPosition.RIGHT -> Row(Modifier.fillMaxSize()) { Box(Modifier.weight(1f)) { page() }; toolbar() }
        }

        if (overview) PageOverview(app, doc, pageIndex, onPick = { overview = false; goTo(it) }, onAdd = { overview = false; app.addPage(doc, doc.pageIds.lastIndex) { pageIndex = it } }, onClose = { overview = false })
    }

    if (confirmDelete) ConfirmDialog("Delete this page?", "Page ${pageIndex + 1} and its handwriting will be deleted.", "Delete", { confirmDelete = false }) {
        confirmDelete = false
        val idx = pageIndex
        app.deletePage(doc, idx) { pageIndex = (idx - 1).coerceAtLeast(0).coerceAtMost(doc.pageIds.size - 2) }
    }
}

/** Which screen edge a toolbar dropped with its centre at ([x], [y]) should snap to. */
internal fun nearestEdge(x: Float, y: Float, width: Float, height: Float): ToolbarPosition {
    val d = mapOf(ToolbarPosition.LEFT to x, ToolbarPosition.RIGHT to width - x, ToolbarPosition.TOP to y, ToolbarPosition.BOTTOM to height - y)
    return d.minBy { it.value }.key
}

/** A toolbar button: icon only, inverted when selected. [description] doubles as its accessibility label. */
@Composable
private fun IconTile(description: String, onClick: () -> Unit, selected: Boolean = false, enabled: Boolean = true, icon: @Composable (Color) -> Unit) {
    val tint = if (selected) Ink.White else if (enabled) Ink.Black else Ink.Rule
    Box(
        Modifier.size(TOOLBAR_THICKNESS).background(if (selected) Ink.Dark else Ink.White).tap(enabled, onClick).semantics { contentDescription = description },
        contentAlignment = Alignment.Center,
    ) { icon(tint) }
}

/** The small colour marker on a tool slot / colour tile: filled with the colour, ringed so white stays visible. */
@Composable
private fun ColourDot(colorId: Int, onDark: Boolean, modifier: Modifier = Modifier, size: Dp = 24.dp) {
    val rgba = PenPalette.lookup(colorId, null)
    Box(modifier.size(size).background(Color(rgba[0], rgba[1], rgba[2]), CircleShape).border(Rm.Outline, if (onDark) Ink.White else Ink.Black, CircleShape))
}

/** The page itself: a pen surface sized to the space available. */
@Composable
private fun PageArea(
    session: PageSession?, spec: PenSpec, drawing: Boolean, swipeEnabled: Boolean, fingerDraws: Boolean, eraserRadius: Float,
    onSurface: (PenSurface?) -> Unit, onChanged: () -> Unit, onSwipe: (Boolean) -> Unit,
) {
    val lifecycle = LocalLifecycleOwner.current.lifecycle
    var surface by remember { mutableStateOf<PenSurface?>(null) }
    var layoutVersion by remember { mutableIntStateOf(0) }
    val currentSession by rememberUpdatedState(session)
    val currentEraserRadius by rememberUpdatedState(eraserRadius)
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
                    override fun onErase(samples: List<PenSample>) = apply(samples) { s, _ -> s.erase(samples, currentEraserRadius) }
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

/** A foldout grid cell (the firmware's FoldoutItem): 112 px high, black with white content when selected. */
@Composable
private fun MenuTile(selected: Boolean, description: String, onClick: () -> Unit, modifier: Modifier = Modifier, content: @Composable ColumnScope.(Color) -> Unit) {
    val fg = if (selected) Ink.White else Ink.Black
    Column(
        modifier.height(Rm.ToolButton).background(if (selected) Ink.Dark else Ink.White).tap(onClick = onClick).semantics { contentDescription = description },
        horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center,
    ) { content(fg) }
}

/** A foldout section title (FoldoutSectionHeader): label text with 24 px above and 16 px below. */
@Composable
private fun FoldoutHeader(title: String) =
    Text(title, style = RmText.Label, color = Ink.Black, modifier = Modifier.fillMaxWidth().padding(start = Rm.FoldoutPad, end = Rm.FoldoutPad, top = 24.dp, bottom = 16.dp))

/** A grid of [columns] equal columns inside a foldout: 32 px side padding and 32 px below (FoldoutGrid). */
@Composable
private fun FoldoutGrid(count: Int, columns: Int, tileWidth: Dp?, cell: @Composable (Int, Modifier) -> Unit) {
    Column(Modifier.fillMaxWidth().padding(start = Rm.FoldoutPad, end = Rm.FoldoutPad, bottom = Rm.FoldoutPad)) {
        for (rowStart in 0 until count step columns) {
            Row(Modifier.fillMaxWidth()) {
                for (c in 0 until columns) {
                    // Tiles keep their own width and sit at the start of their column, as in a Qt GridLayout.
                    Box(Modifier.weight(1f)) { if (rowStart + c < count) cell(rowStart + c, if (tileWidth != null) Modifier.width(tileWidth) else Modifier.fillMaxWidth()) }
                }
            }
        }
    }
}

/**
 * The pen menu (xochitl's writing-tool foldout): 480 px wide with a 2 px border. A pen grid titled with the current pen,
 * a divider, the three thicknesses titled with the current one, a divider, then a 3-column grid of named colours.
 */
@Composable
private fun PenMenu(slot: ToolSlot, onChange: (ToolSlot) -> Unit) {
    val highlighter = slot.tool.usesHighlighterColors
    val pens = PenTool.PENS
    val thicknessNames = listOf("Thin", "Medium", "Thick")
    Column(Modifier.fillMaxWidth()) {
        FoldoutHeader(slot.tool.label)
        // Nine pens in three columns of 112 px tiles.
        FoldoutGrid(pens.size, 3, Rm.ToolButton) { i, m ->
            val t = pens[i]
            MenuTile(t == slot.tool, t.label, { onChange(slot.copy(tool = t, colorId = colorFor(t, slot))) }, m) { fg -> InkIcons.Pen(t, tint = fg) }
        }
        Rule()
        if (!highlighter) {
            FoldoutHeader(thicknessNames[slot.thickness - 1])
            FoldoutGrid(3, 3, Rm.ToolButton) { i, m ->
                val th = i + 1
                MenuTile(th == slot.thickness, thicknessNames[i], { onChange(slot.copy(thickness = th)) }, m) { fg -> InkIcons.Thickness(th, tint = fg) }
            }
            Rule()
        }
        val colors = (if (highlighter) PenSpec.HIGHLIGHTER_COLORS else PenSpec.INK_COLORS).toList()
        Spacer(Modifier.height(Rm.FoldoutPad))
        FoldoutGrid(colors.size, 3, null) { i, m ->
            val c = colors[i]
            val selected = c == slot.colorId
            MenuTile(selected, PenSpec.colorName(c), { onChange(slot.copy(colorId = c)) }, m) { fg ->
                ColourDot(c, selected, size = 39.dp)
                Spacer(Modifier.height(4.dp))
                Text(PenSpec.colorName(c), color = fg, style = RmText.LabelSm)
            }
        }
    }
}

/** The eraser foldout (xochitl's eraser menu): the tool, the thickness, then "Erase all strokes" under a divider. */
@Composable
private fun EraserMenu(thickness: Int, onThickness: (Int) -> Unit, onEraseAll: () -> Unit) {
    val names = listOf("Thin", "Medium", "Thick")
    Column(Modifier.fillMaxWidth()) {
        FoldoutHeader("Eraser")
        FoldoutGrid(1, 3, Rm.ToolButton) { _, m -> MenuTile(true, "Eraser", {}, m) { fg -> InkIcons.Eraser(tint = fg) } }
        Rule()
        FoldoutHeader(names[thickness - 1])
        FoldoutGrid(3, 3, Rm.ToolButton) { i, m ->
            MenuTile(i + 1 == thickness, names[i], { onThickness(i + 1) }, m) { fg -> InkIcons.Thickness(i + 1, tint = fg) }
        }
        RmFoldoutItem("Erase all strokes", onEraseAll, topDivider = true) { InkIcons.Trash(tint = it) }
    }
}

/** Keep the colour valid when switching between ink pens and the highlighter, which use different colour sets. */
private fun colorFor(tool: PenTool, slot: ToolSlot): Int {
    val allowed = if (tool.usesHighlighterColors) PenSpec.HIGHLIGHTER_COLORS else PenSpec.INK_COLORS
    return if (slot.colorId in allowed) slot.colorId else allowed.first()
}

@Composable
private fun PageOverview(app: AppController, doc: LibraryEntry, current: Int, onPick: (Int) -> Unit, onAdd: () -> Unit, onClose: () -> Unit) {
    Column(Modifier.fillMaxSize().background(Ink.White)) {
        Row(Modifier.fillMaxWidth().padding(horizontal = 32.dp, vertical = 16.dp), verticalAlignment = Alignment.CenterVertically) {
            Text("${doc.name} · ${doc.pageIds.size} page${if (doc.pageIds.size == 1) "" else "s"}", style = RmText.TitleMd, modifier = Modifier.weight(1f))
            if (doc.fileType == "notebook") { EButton("+ Add page", onAdd); Spacer(Modifier.width(24.dp)) }
            EButton("Close", onClose, selected = true)
        }
        Rule()
        LazyVerticalGrid(GridCells.Fixed(3), contentPadding = PaddingValues(Rm.NavigatorMargin), horizontalArrangement = Arrangement.spacedBy(30.dp), verticalArrangement = Arrangement.spacedBy(32.dp)) {
            itemsIndexed(doc.pageIds) { i, _ ->
                Column(Modifier.tap { onPick(i) }) {
                    val bmp by produceState<Bitmap?>(null, doc.id, i, doc.pageIds.getOrNull(i), doc.lastModified, doc.template) {
                        value = withContext(Dispatchers.IO) { runCatching { app.thumbnails.render(doc, i, 300) }.getOrNull() }
                    }
                    Box(Modifier.fillMaxWidth().aspectRatio(0.75f).border(if (i == current) 6.dp else Rm.Outline, Ink.Black).background(Ink.White)) {
                        bmp?.let { Image(it.asImageBitmap(), "Page ${i + 1}", contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize()) }
                    }
                    Text("${i + 1}", style = RmText.Label.copy(fontWeight = if (i == current) FontWeight.Bold else FontWeight.Medium), modifier = Modifier.align(Alignment.CenterHorizontally).padding(top = 12.dp))
                }
            }
        }
    }
}
