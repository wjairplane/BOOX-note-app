package app.inkbridge.ui

import android.graphics.Bitmap
import android.graphics.Rect
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import app.inkbridge.pen.FingerGestures
import app.inkbridge.pen.HoldGesture
import app.inkbridge.rm.edit.ShapeSnap
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
import androidx.compose.foundation.gestures.detectDragGestures
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
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.focus.focusRequester
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import app.inkbridge.AndroidPageCanvas
import app.inkbridge.AnnotatedPdfExporter
import app.inkbridge.AppController
import app.inkbridge.PageSession
import app.inkbridge.StrokeClipboard
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
import app.inkbridge.R
import app.inkbridge.TextPrefs
import app.inkbridge.rm.text.TextSettings
import app.inkbridge.text.TextController
import app.inkbridge.text.TextEditLayer
import app.inkbridge.text.TextIcons
import app.inkbridge.text.TextSettingsPanel
import app.inkbridge.text.TextTapDetector
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
    var selecting by remember(doc.id) { mutableStateOf(false) }
    var eraseArea by remember(doc.id) { mutableStateOf(false) } // the eraser's "Erase selection" lasso
    var layersMenu by remember { mutableStateOf(false) }
    var dragEdge by remember { mutableStateOf<ToolbarPosition?>(null) } // the edge a dragged toolbar would snap to
    var pageLabelVisible by remember { mutableStateOf(false) }
    var newPagePrompt by remember { mutableStateOf(false) }
    var templatePicker by remember { mutableStateOf(false) }
    var selectionRect by remember { mutableStateOf<android.graphics.RectF?>(null) }
    var panel by remember { mutableStateOf(false) }
    var collapsed by remember { mutableStateOf(false) }
    var hideBounds by remember { mutableStateOf(UiRect.Zero) }
    var toolbarBounds by remember { mutableStateOf(UiRect.Zero) }
    // Everything that floats over the page and must stay clickable with the pen (the pen's raw-drawing layer would otherwise take those taps).
    val blockers = remember { PenBlockers() }
    var rootSize by remember { mutableStateOf(IntSize.Zero) }
    var menu by remember { mutableStateOf(false) }
    var menuPage by remember { mutableStateOf<String?>(null) } // null = the menu's first level; "add", "template", "share" = a sub-menu
    var eraserMenu by remember { mutableStateOf(false) }
    var eraserThickness by remember { mutableIntStateOf(2) }
    var overview by remember { mutableStateOf(false) }
    var revision by remember { mutableIntStateOf(0) }
    var surface by remember { mutableStateOf<PenSurface?>(null) }
    var strokes by remember { mutableIntStateOf(0) }
    var message by remember { mutableStateOf("") }
    var slider by remember { mutableStateOf(false) }
    // The typed-text tool: typing mode, its toolbar foldout, the Text settings page, and a counter that asks the keyboard to show.
    var typing by remember(doc.id) { mutableStateOf(false) }
    var typingMenu by remember { mutableStateOf(false) }
    var textSettingsOpen by remember { mutableStateOf(false) }
    var keyboardRequest by remember { mutableIntStateOf(0) }
    // Notifications go away after five seconds, except the clipboard hint, which stays until it is dismissed.
    LaunchedEffect(message) { if (message.isNotEmpty() && !message.startsWith("Copied to clipboard")) { kotlinx.coroutines.delay(5000); message = "" } }
    var notebookSettings by remember { mutableStateOf(false) }
    var tagsScreen by remember { mutableStateOf(false) }
    val foldoutOpen = panel || (eraserMenu && erasing) || layersMenu || menu || slider || notebookSettings || tagsScreen || app.overlay != null || typingMenu || textSettingsOpen

    val slot = prefs.slot(activeSlot)
    val spec = if (selecting) PenSpec(PenTool.SELECTION) else if (erasing) PenSpec(if (eraseArea) PenTool.ERASE_AREA else PenTool.ERASER) else PenSpec(slot.tool, slot.colorId, slot.thickness)

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
    // Closing the notebook (or switching to another one) remembers the page it was on, for the cover thumbnail and "Page N of M".
    DisposableEffect(doc.id) { onDispose { app.markOpened(doc.id, pageIndex) } }
    DisposableEffect(surface) { app.onRefresh = { surface?.fullRefresh() }; onDispose { app.onRefresh = null } }

    fun closeDoc() { save(session); app.screen = Screen.Files(folderId = doc.parentId.takeIf { it != "trash" } ?: "") }

    fun leaveSelection() {
        if (!selecting) return
        selecting = false; selectionRect = null
        session?.clearSelection(); surface?.refresh()
    }

    val textController = remember(session) { session?.let { s -> TextController(s) { TextPrefs.margin(context) } } }
    fun enterTyping() {
        leaveSelectionForTyping(selecting) { selecting = false; selectionRect = null; session?.clearSelection(); surface?.refresh() }
        erasing = false; panel = false; eraserMenu = false; menu = false; layersMenu = false; typingMenu = false
        typing = true
        textController?.placeAtEnd()
        keyboardRequest++
    }
    // A double tap on the text enters typing mode; in typing mode taps place the caret and select (1-4 taps).
    val cmPx = remember { (context.resources.displayMetrics.xdpi.takeIf { it > 50f } ?: (160f * context.resources.displayMetrics.density)) / 2.54f }
    val onTextTap by rememberUpdatedState<(Float, Float, Int) -> Unit> { x, y, n ->
        val c = textController
        if (c != null && canDraw && !foldoutOpen && !overview && !templatePicker) {
            if (!typing) {
                if (n == 2 && c.isInTextArea(x, y, 50f)) { enterTyping(); c.tap(x, y, 1, 0.35f * cmPx) }
            } else if (c.isInTextArea(x, y, 50f)) {
                c.tap(x, y, n, 0.35f * cmPx)
                keyboardRequest++
            }
        }
    }
    val tapDetector = remember(cmPx) { TextTapDetector(cmPx) { x, y, n -> onTextTap(x, y, n) } }
    DisposableEffect(surface, tapDetector) {
        val v = surface
        v?.setOnTouchListener { _, e -> tapDetector.onTouch(e); false }
        onDispose { v?.setOnTouchListener(null) }
    }
    androidx.activity.compose.BackHandler(enabled = typing) { typing = false }
    // The page's picture is out of date after a text edit; and the caret must stay inside the text after undo, redo or a page change.
    LaunchedEffect(textController?.editCount) {
        val c = textController; val v = surface; val s = session
        if (c != null && v != null && s != null && c.editCount > 0) { pushView(v, s); revision++ }
    }
    LaunchedEffect(revision) { textController?.clamp() }
    LaunchedEffect(textController) { if (typing) textController?.placeAtEnd() }

    fun goTo(i: Int) { if (i in doc.pageIds.indices && i != pageIndex) { save(session); selectionRect = null; newPagePrompt = false; pageIndex = i; if (prefs.refreshEveryStrokes > 0) surface?.fullRefresh() } }
    fun newPageAfterCurrent() { save(session); app.addPage(doc, pageIndex) { pageIndex = it } }

    val landscape = androidx.compose.ui.platform.LocalConfiguration.current.orientation == android.content.res.Configuration.ORIENTATION_LANDSCAPE
    val pos = prefs.toolbarFor(landscape)
    val horizontal = pos == ToolbarPosition.TOP || pos == ToolbarPosition.BOTTOM
    // Foldouts open on the side of the toolbar that faces the page, level with the button that opened them.
    val side = when (pos) { ToolbarPosition.LEFT -> MenuSide.RIGHT; ToolbarPosition.RIGHT -> MenuSide.LEFT; ToolbarPosition.TOP -> MenuSide.BELOW; ToolbarPosition.BOTTOM -> MenuSide.ABOVE }
    val exportDir = File(context.getExternalFilesDir(null) ?: context.filesDir, "exports")

    @Composable
    fun toolbar() {
        @Suppress("UNUSED_EXPRESSION") revision
        val iconShift = when (pos) { ToolbarPosition.TOP -> 10.dp; ToolbarPosition.BOTTOM -> (-10).dp; else -> 0.dp }
        val start: @Composable () -> Unit = {
            // The round button hides the rest of the toolbar (and brings it back).
            // The round button hides the rest of the toolbar (and brings it back). It is also the handle: drag it to move the toolbar to another edge.
            // The firmware's dragTarget is invisible: the toolbar stays where it is while the finger picks an edge (a 56 px threshold starts it).
            IconTile(if (collapsed) "Show toolbar" else "Hide toolbar", { collapsed = !collapsed; panel = false; eraserMenu = false; menu = false; layersMenu = false },
                plain = true, shift = if (pos == ToolbarPosition.BOTTOM) (-10).dp else 10.dp,
                modifier = Modifier.onGloballyPositioned { hideBounds = it.boundsInRoot() }.pointerInput(pos) {
                    awaitEachGesture {
                        val down = awaitFirstDown(requireUnconsumed = false)
                        val threshold = 56.dp.toPx()
                        var dragging = false
                        while (true) {
                            val change = awaitPointerEvent().changes.firstOrNull { it.id == down.id } ?: break
                            if (!change.pressed) break
                            val moved = (change.position - down.position).getDistance()
                            if (!dragging && moved >= threshold) { dragging = true; panel = false; menu = false; eraserMenu = false; layersMenu = false }
                            if (dragging) {
                                change.consume()
                                val p = change.position + hideBounds.topLeft
                                dragEdge = ToolbarZones.target(pos, p.x, p.y, rootSize.width.toFloat(), rootSize.height.toFloat())
                            }
                        }
                        if (dragging) { dragEdge?.let { prefs.setToolbarFor(landscape, it) }; dragEdge = null }
                    }
                }) { InkIcons.MenuDot(tint = it, modifier = Modifier.graphicsLayer { rotationZ = if (collapsed && pos == ToolbarPosition.RIGHT) 90f else 0f }) }
            if (!collapsed && canDraw) {
                // Two writing tools: tap the other one to switch, tap the active one to open its foldout.
                for (i in 0..1) {
                    val s = prefs.slot(i)
                    val active = !erasing && !selecting && !typing && !typingMenu && activeSlot == i
                    Box {
                        IconTile("Writing tool ${i + 1}: ${s.tool.label}", {
                            if (active) panel = !panel else { leaveSelection(); activeSlot = i; erasing = false; typing = false; typingMenu = false; panel = false; eraserMenu = false }
                        }, selected = active) { tint ->
                            Box {
                                InkIcons.Pen(s.tool, tint = tint)
                                ColourDot(s.colorId, active, Modifier.align(if (pos == ToolbarPosition.RIGHT) Alignment.TopStart else Alignment.TopEnd).padding(8.dp))
                            }
                        }
                        if (active) RmMenu(panel, { panel = false }, side, Rm.WritingFoldoutWidth) { PenMenu(slot, onChange = { prefs.setSlot(activeSlot, it) }) }
                    }
                }
                // The eraser: tap to pick it, tap again for its foldout (tool, thickness, erase all).
                Box {
                    IconTile("Eraser", { if (erasing) eraserMenu = !eraserMenu else { leaveSelection(); erasing = true; typing = false; typingMenu = false; panel = false; eraserMenu = false } }, selected = erasing) { if (eraseArea) InkIcons.EraseSelection(tint = it) else InkIcons.Eraser(tint = it) }
                    RmMenu(eraserMenu && erasing, { eraserMenu = false }, side, Rm.EraserFoldoutMinWidth) {
                        EraserMenu(eraseArea, onTool = { eraseArea = it }, eraserThickness, onThickness = { eraserThickness = it }, onEraseAll = {
                            // "Erase all strokes" clears the current layer only, then goes back to the last pen.
                            eraserMenu = false
                            if (session?.eraseCurrentLayer() == true) { surface?.refresh(); revision++ }
                            erasing = false; eraseArea = false
                        })
                    }
                }
                IconTile("Selection tool", { selecting = true; erasing = false; typing = false; typingMenu = false; panel = false; eraserMenu = false; menu = false }, selected = selecting) { InkIcons.SelectionTool(tint = it) }
                // Typed text: the foldout offers Add text / Edit text and the Text settings.
                Box {
                    IconTile("Typing", { typingMenu = !typingMenu; panel = false; eraserMenu = false; menu = false; layersMenu = false }, selected = typing || typingMenu) { TextIcons.Typing(tint = it) }
                    RmMenu(typingMenu, { typingMenu = false }, side, Rm.FoldoutMinWidth) {
                        if (!typing) RmFoldoutItem(if (textController?.hasText == true) "Edit text" else "Add text", { enterTyping() }, bottomDivider = true) { TextIcons.glyph(R.drawable.rm_keyboard, Modifier, it) }
                        RmFoldoutItem("Text settings", { typingMenu = false; textSettingsOpen = true }) { InkIcons.Sliders(tint = it) }
                    }
                }
                IconTile("Undo", { if (session?.undo() == true) { selectionRect = null; surface?.refresh(); revision++ } }, enabled = session?.canUndo == true) { InkIcons.Undo(tint = it) }
                IconTile("Redo", { if (session?.redo() == true) { selectionRect = null; surface?.refresh(); revision++ } }, enabled = session?.canRedo == true) { InkIcons.Redo(tint = it) }
            }
        }
        val end: @Composable () -> Unit = {
            if (!collapsed) {
                if (canDraw) Box {
                    // Layers and templates: a button of its own in the toolbar (not part of the notebook menu); its foldout lines up with the button.
                    IconTile("Layers", { layersMenu = !layersMenu; menu = false; panel = false; eraserMenu = false }, selected = layersMenu) { InkIcons.Layers(tint = it) }
                    RmMenu(layersMenu, { layersMenu = false }, side, 708.dp, toolbarFoldout = true) {
                        LayersMenu(session, isPdf, revision, onChange = { selectionRect = null; surface?.refresh(); revision++ }, onTemplate = { layersMenu = false; templatePicker = true })
                    }
                }
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
                                // The firmware's notebook menu: Enable shapes, Share, Tags, Adjust view (PDF), Add page between dividers, settings.
                                if (canDraw) Box(Modifier.padding(horizontal = Rm.FoldoutPad)) { SwitchRow("Enable shapes", prefs.shapesEnabled, { prefs.shapesEnabled = it }) }
                                RmFoldoutItem("Share", { menuPage = "share" }, chevron = true, topDivider = canDraw) { InkIcons.Share(tint = it) }
                                RmFoldoutItem("Tags", { close(); tagsScreen = true }) { if (doc.tags.isEmpty()) InkIcons.Tag(tint = it) else InkIcons.TagInverted(tint = it) }
                                if (isPdf) RmFoldoutItem("Adjust view", { menuPage = "view" }, chevron = true, topDivider = true) { InkIcons.Sliders(tint = it) }
                                if (canDraw) RmFoldoutItem(if (isPdf) "Add note page" else "Add page", { close(); newPageAfterCurrent() }, topDivider = true, bottomDivider = true) { InkIcons.PageAdd(tint = it) }
                                RmFoldoutItem(if (isPdf) "PDF settings" else "Notebook settings", { close(); notebookSettings = true }) { InkIcons.Cog(tint = it) }
                                RmFoldoutItem("Refresh screen", { close(); surface?.fullRefresh() }, topDivider = true) { InkIcons.Refresh(tint = it) }
                            }
                            "view" -> {
                                fun changeView(block: (PageSession) -> Unit) {
                                    val s = session ?: return
                                    close()
                                    scope.launch(Dispatchers.Default) {
                                        block(s)
                                        withContext(Dispatchers.Main) { surface?.let { v -> pushView(v, s); v.setTool(v.currentSpec, s.transform?.scale ?: 1f) }; selectionRect = s.selectionRect(); revision++ }
                                    }
                                }
                                RmFoldoutItem("Fit to width", { changeView { it.fitWidth() } }, selected = session?.fitMode == "width") { InkIcons.FitToWidth(tint = it) }
                                RmFoldoutItem("Fit to height", { changeView { it.fitHeight() } }, selected = session?.fitMode == "height") { InkIcons.FitToHeight(tint = it) }
                                RmFoldoutItem("Fit to custom view", { changeView { it.fitCustom() } }, enabled = session?.customView != null, selected = session?.fitMode == "custom") { InkIcons.FitCustom(tint = it) }
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
            }
        }
        // No frame around the toolbar: its icons sit straight on the page, as on the tablet.
        // The toolbar overlays the page (it does not shrink it). Its position is bounded by the toolbar's own box.
        val drag = Modifier
            .onGloballyPositioned { toolbarBounds = it.boundsInRoot() }
            .blocksPen(blockers, "toolbar")
        val bg = if (collapsed) Modifier else Modifier.background(Ink.White)
        if (horizontal) {
            // The close button sits at the top right of the screen, so a top toolbar leaves room for it.
            Row((if (collapsed) Modifier else Modifier.fillMaxWidth()).padding(end = if (pos == ToolbarPosition.TOP && !collapsed) TOOLBAR_THICKNESS else 0.dp).height(TOOLBAR_THICKNESS).then(drag).then(bg), verticalAlignment = Alignment.CenterVertically) {
                androidx.compose.runtime.CompositionLocalProvider(LocalIconShift provides iconShift) { start(); if (!collapsed) Spacer(Modifier.weight(1f)); end() }
            }
        } else {
            Column((if (collapsed) Modifier else Modifier.fillMaxHeight()).width(TOOLBAR_THICKNESS).then(drag).then(bg), horizontalAlignment = Alignment.CenterHorizontally) {
                androidx.compose.runtime.CompositionLocalProvider(LocalIconShift provides iconShift) { start(); if (!collapsed) Spacer(Modifier.weight(1f)); end() }
            }
        }
    }

    @Composable
    fun page() {
        Box(Modifier.fillMaxSize()) {
            if (!canDraw) Text("This kind of document can't be shown yet.", style = RmText.Body, modifier = Modifier.padding(32.dp))
            PageArea(
                session = session, spec = spec, drawing = canDraw && !overview && !foldoutOpen && !templatePicker && !typing,
                swipeEnabled = prefs.swipeToTurn && !typing, fingerDraws = prefs.fingerDrawing,
                eraserRadius = ERASER_RADII[eraserThickness - 1],
                selecting = selecting, selectionRect = selectionRect, onSelectionRect = { selectionRect = it },
                onSelectionAction = { action ->
                    val s = session
                    if (s != null) {
                        val done = when (action) {
                            "delete" -> s.deleteSelection()
                            "cut" -> s.cutSelection().also { if (it) message = "Copied to clipboard. Tap any page with Marker to paste." }
                            else -> s.copySelection().also { if (it) message = "Copied to clipboard. Tap any page with Marker to paste." }
                        }
                        if (done) { surface?.refresh(); revision++ }
                        selectionRect = s.selectionRect()
                    }
                },
                onSurface = { surface = it },
                onChanged = {
                    revision++
                    strokes++
                    val every = prefs.refreshEveryStrokes
                    if (every > 0 && strokes % every == 0) surface?.fullRefresh()
                },
                onSwipe = { forward ->
                    // Past the last page the first swipe only offers a new page; a second swipe (or a tap on the button) adds it.
                    if (forward) { if (pageIndex < doc.pageIds.lastIndex) goTo(pageIndex + 1) else if (canDraw) { if (newPagePrompt) newPageAfterCurrent() else { newPagePrompt = true; pageLabelVisible = true } } }
                    else goTo(pageIndex - 1)
                },
                excludeRects = blockers.rects(),
                blockers = blockers,
                shapes = prefs.shapesEnabled,
                onSelectBelow = { selecting = true; erasing = false; panel = false; eraserMenu = false },
                onEdgeSwipe = { edge ->
                    panel = false; menu = false; eraserMenu = false; layersMenu = false
                    when (edge) {
                        FingerGestures.Edge.CLOSE -> closeDoc()
                        FingerGestures.Edge.QUICK_SETTINGS -> app.overlay = Overlay.QUICK_SETTINGS
                        FingerGestures.Edge.DRAWER -> app.overlay = Overlay.DRAWER
                        FingerGestures.Edge.QUICK_BROWSE -> if (doc.pageIds.size > 1) { save(session); slider = true; pageLabelVisible = false }
                    }
                },
                onFingerTap = { fingers ->
                    // Two fingers tapping undo, three redo (the tablet's shortcuts).
                    if (fingers == 2 && session?.undo() == true) { selectionRect = null; surface?.refresh(); revision++ }
                    else if (fingers == 3 && session?.redo() == true) { selectionRect = null; surface?.refresh(); revision++ }
                },
            )

            // The typed-text tool's caret, selection and format menu, and the Text settings page.
            val tc = textController
            val s = session
            if (typing && tc != null && s != null && !overview) TextEditLayer(
                s, tc, revision, keyboardRequest,
                startInset = if (pos == ToolbarPosition.LEFT && !collapsed) TOOLBAR_THICKNESS else 0.dp,
                endInset = if (pos == ToolbarPosition.RIGHT && !collapsed) TOOLBAR_THICKNESS else 0.dp,
                bottomInset = if (pos == ToolbarPosition.BOTTOM && !collapsed) TOOLBAR_THICKNESS else 0.dp,
            )
            if (textSettingsOpen && s != null) {
                TextSettingsPanel(
                    settings = TextSettings.current, margin = TextPrefs.margin(context), hasAnnotations = s.hasInk(),
                    onChange = { ts, margin ->
                        TextPrefs.save(context, ts)
                        val marginChanged = margin != TextPrefs.margin(context)
                        TextPrefs.saveMargin(context, margin)
                        s.textSettingsChanged()
                        if (marginChanged && s.textLayout != null) s.editText(false, margin) { it.setSideMargin(margin) }
                        surface?.let { v -> pushView(v, s) }
                        revision++
                    },
                    onClose = { textSettingsOpen = false },
                    // Below the close button and beside the toolbar.
                    modifier = Modifier.align(Alignment.TopCenter).padding(
                        start = if (pos == ToolbarPosition.LEFT && !collapsed) TOOLBAR_THICKNESS else 0.dp,
                        end = if (pos == ToolbarPosition.RIGHT && !collapsed) TOOLBAR_THICKNESS else 0.dp,
                        top = TOOLBAR_THICKNESS,
                    ),
                )
            }

            // The zoom button: while zoomed, a tap snaps back to the whole page.
            @Suppress("UNUSED_EXPRESSION") revision
            val zoomNow = session?.zoom ?: 1f
            if (zoomNow > 1.01f && !overview) {
                ZoomButton(zoomNow, session?.fitMode, {
                    val s = session ?: return@ZoomButton
                    scope.launch(Dispatchers.Default) { s.fitPage(); withContext(Dispatchers.Main) { surface?.let { v -> pushView(v, s); v.setTool(v.currentSpec, s.transform?.scale ?: 1f) }; selectionRect = s.selectionRect(); revision++ } }
                }, Modifier.align(if (pos == ToolbarPosition.TOP) Alignment.BottomCenter else Alignment.TopCenter).padding(bottom = if (pos == ToolbarPosition.TOP) (if (message.isNotEmpty()) 96.dp else 0.dp) else 0.dp).blocksPen(blockers, "zoom"))
            }

            // "Page X of Y": a white 258 x 72 label at the bottom centre for four seconds after the page changes.
            LaunchedEffect(pageIndex, doc.pageIds.size) { pageLabelVisible = true; kotlinx.coroutines.delay(4000); pageLabelVisible = false }
            if (pageLabelVisible && !overview && message.isEmpty()) {
                Box(Modifier.align(Alignment.BottomCenter).padding(bottom = if (pos == ToolbarPosition.BOTTOM) TOOLBAR_THICKNESS else 0.dp).size(258.dp, 72.dp).background(Ink.White), contentAlignment = Alignment.Center) {
                    Text("Page ${pageIndex + 1} of ${doc.pageIds.size}", style = RmText.Label)
                }
            }
            if (newPagePrompt && pageIndex == doc.pageIds.lastIndex) {
                // A black button with a white 4 px border and the add-page icon, 80 px from the edge (and clear of a toolbar on the right).
                Box(
                    Modifier.align(Alignment.CenterEnd).padding(end = 80.dp + (if (pos == ToolbarPosition.RIGHT && !collapsed) TOOLBAR_THICKNESS else 0.dp)).blocksPen(blockers, "newPage")
                        .background(Ink.Black).border(4.dp, Ink.White).tap { newPageAfterCurrent() }.size(Rm.ToolButton).semantics { contentDescription = "New page" },
                    contentAlignment = Alignment.Center,
                ) { InkIcons.PageAdd(tint = Ink.White) }
            }

            // The notification bar: along the bottom edge, beside the toolbar when that is on the left, right or bottom.
            if (message.isNotEmpty()) {
                val clipboardHint = message.startsWith("Copied to clipboard")
                NotificationBar(
                    message, { if (clipboardHint) StrokeClipboard.lines = emptyList(); message = "" },
                    action = if (clipboardHint) "OK" else null,
                    primary = !clipboardHint && !(message.startsWith("Exported ") || message.startsWith("Saved ")),
                    modifier = Modifier.align(Alignment.BottomCenter).padding(start = if (pos == ToolbarPosition.LEFT) TOOLBAR_THICKNESS else 0.dp, end = if (pos == ToolbarPosition.RIGHT) TOOLBAR_THICKNESS else 0.dp, bottom = if (pos == ToolbarPosition.BOTTOM) TOOLBAR_THICKNESS else 0.dp).blocksPen(blockers, "notification"),
                )
            }
        }
    }

    Box(Modifier.fillMaxSize().onSizeChanged { rootSize = it }) {
        // The page fills the screen and the toolbar floats over it.
        Box(Modifier.fillMaxSize()) { page() }
        Box(
            Modifier.align(when (pos) { ToolbarPosition.TOP -> Alignment.TopStart; ToolbarPosition.BOTTOM -> Alignment.BottomStart; ToolbarPosition.LEFT -> Alignment.TopStart; ToolbarPosition.RIGHT -> Alignment.TopEnd })
                .then(if (horizontal) Modifier.fillMaxWidth() else Modifier.fillMaxHeight()),
            contentAlignment = Alignment.TopStart,
        ) { toolbar() }
        // While dragging, a 12 px black bar marks the edge the toolbar would go to.
        dragEdge?.let { e ->
            val bar = Modifier.background(Ink.Black)
            when (e) {
                ToolbarPosition.TOP -> Box(Modifier.align(Alignment.TopStart).fillMaxWidth().height(12.dp).then(bar))
                ToolbarPosition.BOTTOM -> Box(Modifier.align(Alignment.BottomStart).fillMaxWidth().height(12.dp).then(bar))
                ToolbarPosition.LEFT -> Box(Modifier.align(Alignment.TopStart).fillMaxHeight().width(12.dp).then(bar))
                ToolbarPosition.RIGHT -> Box(Modifier.align(Alignment.TopEnd).fillMaxHeight().width(12.dp).then(bar))
            }
        }

        // The firmware's close button is not part of the toolbar: it floats in the top right corner of the screen
        // (top left when the toolbar is on the right), on a white square only when the toolbar runs along the top.
        if (!collapsed && dragEdge == null) {
            Box(
                Modifier.align(if (pos == ToolbarPosition.RIGHT) Alignment.TopStart else Alignment.TopEnd).size(TOOLBAR_THICKNESS)
                    .blocksPen(blockers, "close")
                    .background(if (pos == ToolbarPosition.TOP) Ink.White else Color.Transparent)
                    .tap { closeDoc() }
                    .semantics { contentDescription = "Close notebook" },
                contentAlignment = Alignment.Center,
            ) { InkIcons.XCircle(Modifier.offset(y = 10.dp)) }
        }

        // Low battery: a warning at the top right, clear of the close button and the toolbar.
        LowBatteryIndicator(
            Modifier.align(Alignment.TopEnd).padding(
                end = if ((pos == ToolbarPosition.RIGHT || pos != ToolbarPosition.TOP) && !collapsed) 112.dp else 32.dp,
                top = if (pos == ToolbarPosition.TOP && !collapsed) 112.dp else 32.dp,
            ).blocksPen(blockers, "battery"),
        )

        if (notebookSettings) NotebookSettingsScreen(app, doc, onDismiss = { notebookSettings = false })
        if (tagsScreen) DocumentTagsScreen(app, doc, onDismiss = { tagsScreen = false })

        if (slider) PageSlider(app, doc, pageIndex, if (pos == ToolbarPosition.BOTTOM) TOOLBAR_THICKNESS else 0.dp, if (pos == ToolbarPosition.LEFT) TOOLBAR_THICKNESS else 0.dp, if (pos == ToolbarPosition.RIGHT) TOOLBAR_THICKNESS else 0.dp, onPick = { slider = false; goTo(it) }, onClose = { slider = false })

        if (templatePicker) TemplatePickerScreen(doc.template, onPick = { templatePicker = false; save(session); app.setTemplate(doc, it) }, onBack = { templatePicker = false })

        if (overview) PageOverview(app, doc, pageIndex, onPick = { overview = false; goTo(it) }, onAdd = { overview = false; app.addPage(doc, doc.pageIds.lastIndex) { pageIndex = it } }, onClose = { overview = false })
    }
}

/** The icons sit in the 92 px part of a 112 px button when the toolbar is on the top or bottom edge (the other 20 px is the gesture margin). */
private val LocalIconShift = androidx.compose.runtime.compositionLocalOf { 0.dp }

/** A toolbar button: icon only, inverted when selected. [description] doubles as its accessibility label. */
@Composable
private fun IconTile(description: String, onClick: () -> Unit, selected: Boolean = false, enabled: Boolean = true, modifier: Modifier = Modifier, plain: Boolean = false, shift: androidx.compose.ui.unit.Dp = LocalIconShift.current, icon: @Composable (Color) -> Unit) {
    val tint = if (selected) Ink.White else if (enabled) Ink.Black else Ink.Rule
    Box(
        modifier.size(TOOLBAR_THICKNESS).then(if (plain) Modifier else Modifier.background(if (selected) Ink.Dark else Ink.White)).tap(enabled, onClick).semantics { contentDescription = description },
        contentAlignment = Alignment.Center,
    ) { Box(Modifier.offset(y = shift)) { icon(tint) } }
}

/**
 * The colour marker on a pen button: a 28 px dot, outlined only where its colour would melt into the button
 * (black on the selected, black button; white on a white one), as in the firmware.
 */
@Composable
private fun ColourDot(colorId: Int, onDark: Boolean, modifier: Modifier = Modifier, size: Dp = 28.dp, alwaysOutlined: Boolean = false) {
    val rgba = PenPalette.lookup(colorId, null)
    val fill = Color(rgba[0], rgba[1], rgba[2])
    val black = fill == Color.Black; val white = fill == Color.White
    val outline = when {
        alwaysOutlined -> if (onDark) Ink.White else Ink.Black
        onDark && black -> Ink.White
        !onDark && white -> Ink.Black
        else -> null
    }
    Box(modifier.size(size).background(fill, CircleShape).then(if (outline != null) Modifier.border(Rm.Outline, outline, CircleShape) else Modifier))
}

/** The page itself: a pen surface sized to the space available. */
@Composable
private fun PageArea(
    session: PageSession?, spec: PenSpec, drawing: Boolean, swipeEnabled: Boolean, fingerDraws: Boolean, eraserRadius: Float,
    selecting: Boolean, selectionRect: android.graphics.RectF?, onSelectionRect: (android.graphics.RectF?) -> Unit, onSelectionAction: (String) -> Unit,
    onSurface: (PenSurface?) -> Unit, onChanged: () -> Unit, onSwipe: (Boolean) -> Unit,
    excludeRects: List<Rect>, onFingerTap: (Int) -> Unit, blockers: PenBlockers,
    onEdgeSwipe: (FingerGestures.Edge) -> Unit, onSelectBelow: () -> Unit, shapes: Boolean,
) {
    val currentOnEdge by rememberUpdatedState(onEdgeSwipe)
    val currentShapes by rememberUpdatedState(shapes)
    val currentOnSelectBelow by rememberUpdatedState(onSelectBelow)
    val scope = rememberCoroutineScope()
    val currentOnSelectionRect by rememberUpdatedState(onSelectionRect)
    var controlsHidden by remember { mutableStateOf(false) }
    val lifecycle = LocalLifecycleOwner.current.lifecycle
    var surface by remember { mutableStateOf<PenSurface?>(null) }
    var layoutVersion by remember { mutableIntStateOf(0) }
    val currentSession by rememberUpdatedState(session)
    val currentEraserRadius by rememberUpdatedState(eraserRadius)
    val currentOnChanged by rememberUpdatedState(onChanged)
    val currentOnSwipe by rememberUpdatedState(onSwipe)
    val currentOnFingerTap by rememberUpdatedState(onFingerTap)

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
            pushView(view, s)
            layoutVersion++
        }

        LaunchedEffect(surface, excludeRects) { surface?.setExcludeRects(excludeRects) }

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
                    override fun onStroke(samples: List<PenSample>) {
                        val spec = surface?.currentSpec
                        val body = if (spec != null && spec.tool != PenTool.ERASER && currentShapes) HoldGesture.body(samples) else null
                        val shape = body?.let { ShapeSnap.detect(it.map { p -> p.x to p.y }) }
                        if (shape == null) { apply(samples) { s, sp -> s.addStroke(sp, samples) }; return }
                        if (ShapeSnap.isHorizontalLine(shape)) {
                            // A horizontal line held still selects everything below it.
                            val s = currentSession
                            if (s != null && s.selectBelow(shape.points.first().second)) { surface?.refresh(); currentOnSelectBelow(); currentOnSelectionRect(s.selectionRect()); currentOnChanged(); return }
                        }
                        val snapped = HoldGesture.resample(shape.points, body)
                        // The shape comes out selected, so it can be dragged, resized and rotated to fit.
                        val s = currentSession ?: return
                        if (s.addStroke(surface?.currentSpec ?: return, snapped, select = true)) { surface?.refresh(); currentOnSelectBelow(); currentOnSelectionRect(s.selectionRect()); currentOnChanged() }
                    }
                    override fun onErase(samples: List<PenSample>) = apply(samples) { s, _ -> s.erase(samples, currentEraserRadius) }
                    override fun onSwipe(forward: Boolean) { currentOnSwipe(forward) }
                    override fun onFingerTap(fingers: Int) { currentOnFingerTap(fingers) }
                    override fun onEdgeSwipe(edge: FingerGestures.Edge) { currentOnEdge(edge) }
                    override fun onJump(down: Boolean) {
                        val s = currentSession ?: return
                        val view = surface ?: return
                        scope.launch(Dispatchers.Default) {
                            if (s.jump(down)) withContext(Dispatchers.Main) { pushView(view, s); view.setTool(view.currentSpec, s.transform?.scale ?: 1f); currentOnSelectionRect(s.selectionRect()); currentOnChanged() }
                        }
                    }
                    override fun onSelectionGesture(active: Boolean) { controlsHidden = active }
                    override fun onEraseArea(samples: List<PenSample>) = apply(samples) { s, _ -> s.eraseInside(samples) }
                    override fun onLasso(samples: List<PenSample>) {
                        val s = currentSession ?: return
                        if (s.selectionStroke(samples)) { currentOnSelectionRect(s.selectionRect()); surface?.refresh(); currentOnChanged() }
                    }
                    override fun onViewGesture(factor: Float, focusX: Float, focusY: Float, panX: Float, panY: Float) {
                        val s = currentSession ?: return
                        val view = surface ?: return
                        scope.launch(Dispatchers.Default) {
                            s.viewGesture(factor, focusX, focusY, panX, panY)
                            withContext(Dispatchers.Main) { pushView(view, s); view.setTool(view.currentSpec, s.transform?.scale ?: 1f); currentOnSelectionRect(s.selectionRect()); currentOnChanged() }
                        }
                    }

                    private fun apply(samples: List<PenSample>, edit: (PageSession, PenSpec) -> Boolean) {
                        val s = currentSession ?: return
                        val view = surface ?: return
                        if (samples.isEmpty()) return
                        if (edit(s, view.currentSpec)) { view.refresh(); currentOnChanged() }
                    }
                }).also { v ->
                    v.selectionFrameProvider = { currentSession?.selectionFrame() }
                    v.zoomProvider = { currentSession?.zoom ?: 1f }
                    surface = v; onSurface(v)
                }
            },
        )

        // The selection's menu (the firmware's contextual menu): white, a 2 px border, icon-only 80 px buttons (cut, copy, delete),
        // 48 px below the selection (above only when there's no room below), hidden while the selection is being dragged.
        selectionRect?.takeIf { !controlsHidden }?.let { r ->
            val density = androidx.compose.ui.platform.LocalDensity.current
            val button = with(density) { 80.dp.roundToPx() }
            val barW = button * 3 + with(density) { (Rm.Outline * 2 + 2.dp * 2).roundToPx() }
            val barH = button + with(density) { (Rm.Outline * 2).roundToPx() }
            val gap = with(density) { 48.dp.roundToPx() }
            val x = (r.centerX().toInt() - barW / 2).coerceIn(gap.coerceAtMost(w / 4), (w - barW - gap).coerceAtLeast(0))
            val below = r.bottom.toInt() + gap
            val y = (if (below + barH <= h) below else (r.top.toInt() - gap - barH).coerceAtLeast(gap / 2)).coerceAtLeast(gap / 2)
            Row(
                Modifier.offset { androidx.compose.ui.unit.IntOffset(x, y) }.blocksPen(blockers, "selection").background(Ink.White).border(Rm.Outline, Ink.Black),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                @Composable fun action(label: String, id: String, divider: Boolean, icon: @Composable () -> Unit) {
                    if (divider) Box(Modifier.width(2.dp).height(80.dp).background(Ink.Black))
                    Box(Modifier.size(80.dp).tap { onSelectionAction(id) }.semantics { contentDescription = label }, contentAlignment = Alignment.Center) { icon() }
                }
                action("Cut", "cut", false) { InkIcons.Scissors() }
                action("Copy", "copy", true) { InkIcons.Copy() }
                action("Delete", "delete", true) { InkIcons.Trash() }
            }
        }
    }
}

/** Show the session's bitmap on the surface and limit pen input to the visible part of the page. */
private fun pushView(view: PenSurface, s: PageSession) {
    val t = s.transform ?: return
    val bmp = s.bitmap ?: return
    val r = t.visiblePageRect()
    view.setPageArea(Rect(r[0].toInt(), r[1].toInt(), r[2].toInt(), r[3].toInt()))
    view.show(bmp, 0f)
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
 * The pen menu (xochitl's writing-tool foldout): 400 px wide (3 x 112 + 64) with a 2 px border. A pen grid titled with the current pen,
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
                ColourDot(c, selected, size = 39.dp, alwaysOutlined = true)
                Spacer(Modifier.height(4.dp))
                Text(PenSpec.colorName(c), color = fg, style = RmText.LabelSm)
            }
        }
    }
}

/** The eraser foldout (xochitl's eraser menu): the tool, the thickness, then "Erase all strokes" under a divider. */
@Composable
private fun EraserMenu(area: Boolean, onTool: (Boolean) -> Unit, thickness: Int, onThickness: (Int) -> Unit, onEraseAll: () -> Unit) {
    val names = listOf("Thin", "Medium", "Thick")
    Column(Modifier.fillMaxWidth()) {
        FoldoutHeader(if (area) "Erase selection" else "Eraser")
        FoldoutGrid(2, 3, Rm.ToolButton) { i, m ->
            if (i == 0) MenuTile(!area, "Eraser", { onTool(false) }, m) { fg -> InkIcons.Eraser(tint = fg) }
            else MenuTile(area, "Erase selection", { onTool(true) }, m) { fg -> InkIcons.EraseSelection(tint = fg) }
        }
        // Thickness only applies to the plain eraser.
        if (!area) {
            Rule()
            FoldoutHeader(names[thickness - 1])
            FoldoutGrid(3, 3, Rm.ToolButton) { i, m ->
                MenuTile(i + 1 == thickness, names[i], { onThickness(i + 1) }, m) { fg -> InkIcons.Thickness(i + 1, tint = fg) }
            }
        }
        RmFoldoutItem("Erase all strokes", onEraseAll, topDivider = true) { InkIcons.EraseAll(tint = it) }
    }
}

/** Keep the colour valid when switching between ink pens and the highlighter, which use different colour sets. */
private fun colorFor(tool: PenTool, slot: ToolSlot): Int {
    val allowed = if (tool.usesHighlighterColors) PenSpec.HIGHLIGHTER_COLORS else PenSpec.INK_COLORS
    return if (slot.colorId in allowed) slot.colorId else allowed.first()
}

/**
 * The page overview (the firmware's Pages view): a Back bar with the notebook's name, a grid of page thumbnails with a hairline border and
 * the page number below (the current page has a thick bar under it), press and hold to select pages (the bar then offers Delete and
 * Add page before/after), and a round button for a new page at the bottom right.
 */
@Composable
private fun PageOverview(app: AppController, doc: LibraryEntry, current: Int, onPick: (Int) -> Unit, onAdd: () -> Unit, onClose: () -> Unit) {
    var selected by remember { mutableStateOf(setOf<Int>()) }
    var confirmDelete by remember { mutableStateOf(false) }
    var more by remember { mutableStateOf(false) }
    androidx.activity.compose.BackHandler { if (selected.isNotEmpty()) selected = emptySet() else onClose() }
    Box(Modifier.fillMaxSize().background(Ink.White)) {
        Column(Modifier.fillMaxSize()) {
            if (selected.isEmpty()) NavigationBar(doc.name, onClose)
            else {
                // Selection mode: the firmware's PagesActions replace the navigation bar.
                Column {
                    Row(Modifier.fillMaxWidth().height(Rm.NavigationHeader), verticalAlignment = Alignment.CenterVertically) {
                        EButton("Cancel", { selected = emptySet() }, modifier = Modifier.padding(start = 16.dp))
                        Text("${selected.size} selected", style = RmText.LabelLgStrong, modifier = Modifier.weight(1f).wrapContentWidth(Alignment.CenterHorizontally))
                        if (doc.fileType == "notebook") {
                            Box(Modifier.size(Rm.ToolButton).tap(enabled = selected.size < doc.pageIds.size) { confirmDelete = true }.semantics { contentDescription = "Delete" }, contentAlignment = Alignment.Center) {
                                InkIcons.Trash(tint = if (selected.size < doc.pageIds.size) Ink.Black else Ink.Rule)
                            }
                            Box {
                                Box(Modifier.size(Rm.ToolButton).background(if (more) Ink.Black else Ink.White).tap { more = !more }.semantics { contentDescription = "More" }, contentAlignment = Alignment.Center) { InkIcons.More(tint = if (more) Ink.White else Ink.Black) }
                                RmMenu(more, { more = false }, MenuSide.BELOW_END, Rm.FoldoutMinWidth) {
                                    RmFoldoutItem("Add page before", { more = false; val i = selected.min(); selected = emptySet(); app.addPage(doc, i - 1) { onPick(it) } }) { InkIcons.PageAdd(tint = it) }
                                    RmFoldoutItem("Add page after", { more = false; val i = selected.max(); selected = emptySet(); app.addPage(doc, i) { onPick(it) } }) { InkIcons.PageAdd(tint = it) }
                                }
                            }
                        }
                    }
                    Rule()
                }
            }
            LazyVerticalGrid(GridCells.Fixed(3), contentPadding = PaddingValues(Rm.NavigatorMargin), horizontalArrangement = Arrangement.spacedBy(30.dp), verticalArrangement = Arrangement.spacedBy(32.dp)) {
                itemsIndexed(doc.pageIds) { i, _ ->
                    val isSelected = i in selected
                    Column(
                        Modifier.pointerInput(i, selected.isEmpty()) {
                            detectTapGestures(
                                onTap = { if (selected.isNotEmpty()) selected = if (isSelected) selected - i else selected + i else onPick(i) },
                                onLongPress = { selected = if (isSelected) selected - i else selected + i },
                            )
                        }.semantics { contentDescription = "Page ${i + 1}" },
                    ) {
                        val bmp by produceState<Bitmap?>(null, doc.id, i, doc.pageIds.getOrNull(i), doc.lastModified, doc.template) {
                            value = withContext(Dispatchers.IO) { runCatching { app.thumbnails.render(doc, i, 300) }.getOrNull() }
                        }
                        Box(Modifier.fillMaxWidth().aspectRatio(0.75f).border(1.dp, Ink.Black).background(Ink.White)) {
                            bmp?.let { Image(it.asImageBitmap(), null, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize()) }
                            if (isSelected) Box(Modifier.fillMaxSize().background(Ink.Black.copy(alpha = 0.35f)))
                        }
                        // The page being edited is marked by a bar under its thumbnail.
                        Box(Modifier.fillMaxWidth().height(8.dp).background(if (i == current && !isSelected) Ink.Black else Color.Transparent))
                        Box(Modifier.fillMaxWidth().background(if (isSelected) Ink.Black else Color.Transparent).padding(vertical = 8.dp), contentAlignment = Alignment.Center) {
                            Text("${i + 1}", style = RmText.Label, color = if (isSelected) Ink.White else Ink.Black)
                        }
                    }
                }
            }
        }
        if (selected.isEmpty() && doc.fileType == "notebook") {
            Box(
                Modifier.align(Alignment.BottomEnd).padding(Rm.NavigatorMargin).size(112.dp).background(Ink.White, CircleShape).border(Rm.Outline, Ink.Black, CircleShape).tap(onClick = onAdd).semantics { contentDescription = "New page" },
                contentAlignment = Alignment.Center,
            ) { InkIcons.PageAdd() }
        }
    }
    if (confirmDelete) {
        val n = selected.size
        ConfirmDialog(
            "Delete $n page${if (n == 1) "" else "s"} permanently?",
            if (n == 1) "If you delete the page, you won't be able to get it back." else "If you delete the pages, you won't be able to get them back.",
            "Delete", { confirmDelete = false },
        ) {
            confirmDelete = false
            val gone = selected; selected = emptySet()
            app.deletePages(doc, gone) { }
        }
    }
}

/**
 * The layers foldout (the firmware's LayerComponent rows): one 112 px row per layer, topmost first, with the eye, the name
 * (tap = current layer, press and hold = rename in place) and four icon buttons (up, down, merge, delete); then the template
 * (notes) or PDF page row, and "New layer" (at most 5 layers).
 */
@Composable
private fun LayersMenu(session: PageSession?, isPdf: Boolean, revision: Int, onChange: () -> Unit, onTemplate: () -> Unit) {
    @Suppress("UNUSED_EXPRESSION") revision
    val layers = session?.layers().orEmpty()
    var renaming by remember { mutableStateOf<app.inkbridge.rm.scene.CrdtId?>(null) }
    var draft by remember { mutableStateOf("") }
    Column(Modifier.fillMaxWidth()) {
        layers.withIndex().reversed().forEach { (index, l) ->
            val fg = if (l.current) Ink.White else Ink.Black
            Row(Modifier.fillMaxWidth().height(Rm.ToolButton).background(if (l.current) Ink.Black else Ink.White).padding(16.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                Box(Modifier.size(80.dp).tap { session?.setLayerVisible(l.id, !l.visible); onChange() }.semantics { contentDescription = (if (l.visible) "Hide " else "Show ") + l.label }, contentAlignment = Alignment.Center) {
                    if (l.visible) InkIcons.Eye(tint = fg) else InkIcons.EyeClosed(tint = fg)
                }
                if (renaming == l.id) {
                    val focus = remember { androidx.compose.ui.focus.FocusRequester() }
                    androidx.compose.foundation.text.BasicTextField(
                        value = draft, onValueChange = { draft = it }, singleLine = true,
                        textStyle = RmText.Label.copy(color = fg), cursorBrush = androidx.compose.ui.graphics.SolidColor(fg),
                        keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(imeAction = androidx.compose.ui.text.input.ImeAction.Done),
                        keyboardActions = androidx.compose.foundation.text.KeyboardActions(onDone = { if (draft.isNotBlank()) session?.renameLayer(l.id, draft); renaming = null; onChange() }),
                        modifier = Modifier.width(196.dp).focusRequester(focus).semantics { contentDescription = "Layer name" },
                    )
                    LaunchedEffect(Unit) { focus.requestFocus() }
                } else {
                    Text(l.label, style = RmText.Label, color = fg, maxLines = 1, overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.width(196.dp).fillMaxHeight().pointerInput(l.id) {
                            detectTapGestures(onTap = { session?.selectLayer(l.id); onChange() }, onLongPress = { draft = l.label; renaming = l.id })
                        }.wrapContentHeight(Alignment.CenterVertically))
                }
                Spacer(Modifier.weight(1f))
                // Hidden buttons keep their room so the others don't shift.
                @Composable fun action(label: String, visible: Boolean, enabled: Boolean = true, onClick: () -> Unit, icon: @Composable (Color) -> Unit) {
                    val tint = if (enabled) fg else if (l.current) Ink.Grey else Ink.Rule
                    Box(Modifier.size(80.dp).then(if (visible) Modifier.tap(enabled, onClick).semantics { contentDescription = "$label ${l.label}" } else Modifier), contentAlignment = Alignment.Center) { if (visible) icon(tint) }
                }
                action("Move up", layers.size > 1, enabled = index < layers.lastIndex, onClick = { if (session?.moveLayer(l.id, true) == true) onChange() }) { InkIcons.ArrowUp(tint = it) }
                action("Move down", layers.size > 1, enabled = index > 0, onClick = { if (session?.moveLayer(l.id, false) == true) onChange() }) { InkIcons.ArrowDown(tint = it) }
                action("Merge down", index > 0, onClick = { if (session?.mergeLayerDown(l.id) == true) onChange() }) { InkIcons.Merge(tint = it) }
                action("Delete", layers.size > 1, onClick = { if (session?.deleteLayer(l.id) == true) onChange() }) { InkIcons.Trash(tint = it) }
            }
        }
        // The page's own background: the template of a notebook page (tap the name to choose another) or the PDF page.
        val bgVisible = session?.backgroundVisible() ?: true
        Row(Modifier.fillMaxWidth().height(Rm.ToolButton).padding(16.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            Box(Modifier.size(80.dp).tap { session?.setBackgroundVisible(!bgVisible); onChange() }.semantics { contentDescription = (if (bgVisible) "Hide " else "Show ") + "background" }, contentAlignment = Alignment.Center) {
                if (bgVisible) InkIcons.Eye() else InkIcons.EyeClosed()
            }
            Text(if (isPdf) "Background" else "Template", style = RmText.Label, modifier = Modifier.width(196.dp).fillMaxHeight().tap { if (!isPdf) onTemplate() else { session?.setBackgroundVisible(!bgVisible); onChange() } }.wrapContentHeight(Alignment.CenterVertically))
            Spacer(Modifier.weight(1f))
            if (!isPdf) Box(Modifier.size(80.dp).tap(onClick = onTemplate).semantics { contentDescription = "Choose template" }, contentAlignment = Alignment.Center) { InkIcons.Template() }
        }
        val full = layers.size >= MAX_LAYERS
        RmFoldoutItem(if (full) "Limit of $MAX_LAYERS layers reached" else "New layer", { if (!full) { session?.addLayer("Layer ${layers.size + 1}"); onChange() } }, topDivider = true) {
            if (full) InkIcons.InformationCircle(tint = it) else InkIcons.PlusCircle(tint = it)
        }
    }
}

private const val MAX_LAYERS = 5

/** The screen rectangles of the controls that float over the page, so the pen can be kept off them. */
internal class PenBlockers {
    private val map = androidx.compose.runtime.mutableStateMapOf<String, Rect>()
    fun set(key: String, r: Rect) { if (map[key] != r) map[key] = r }
    fun remove(key: String) { map.remove(key) }
    fun rects(): List<Rect> = map.values.filter { !it.isEmpty }.sortedWith(compareBy({ it.left }, { it.top }, { it.right }, { it.bottom }))
}

/** Report this element's bounds to [blockers] while it is on screen. */
@Composable
internal fun Modifier.blocksPen(blockers: PenBlockers, key: String): Modifier {
    DisposableEffect(blockers, key) { onDispose { blockers.remove(key) } }
    return onGloballyPositioned {
        val b = it.boundsInRoot()
        blockers.set(key, Rect(b.left.toInt(), b.top.toInt(), b.right.toInt(), b.bottom.toInt()))
    }
}

/** Leave the selection tool (used when typing starts): [clear] does the work if a selection is active. */
private inline fun leaveSelectionForTyping(selecting: Boolean, clear: () -> Unit) { if (selecting) clear() }
