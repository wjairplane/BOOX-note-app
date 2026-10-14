package app.inkbridge.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import app.inkbridge.AppController
import app.inkbridge.Screen
import app.inkbridge.Section
import app.inkbridge.rm.library.Library
import app.inkbridge.rm.library.LibraryEntry
import app.inkbridge.rm.render.PageTemplate
import java.text.DateFormat
import java.util.Date

/*
 * The firmware's full-window forms (create-notebook, create-collection, rename): a secondary NavigationBar with Cancel at the
 * left, the title and the confirming action at the right, then a column inset by the portrait margins (44 px at the sides,
 * 59 px above and between the blocks).
 */

private val FormMarginH = 44.dp
private val FormMarginV = 59.dp

/** The form's bar: [left] (text only, no chevron), a bold centred title, [right] (omitted while null) and a 2 px divider. */
@Composable
internal fun FormBar(title: String, left: String, onLeft: () -> Unit, right: String?, onRight: () -> Unit) {
    Column {
        Box(Modifier.fillMaxWidth().height(Rm.NavigationHeader)) {
            Text(left, style = RmText.Label, modifier = Modifier.align(Alignment.CenterStart).padding(start = 16.dp).heightIn(min = Rm.ToolButton).tap(onClick = onLeft).padding(horizontal = 16.dp).wrapContentHeight(Alignment.CenterVertically))
            Text(title, style = RmText.LabelLgStrong, modifier = Modifier.align(Alignment.Center))
            if (right != null) Text(right, style = RmText.Label, modifier = Modifier.align(Alignment.CenterEnd).padding(end = 16.dp).heightIn(min = Rm.ToolButton).tap(onClick = onRight).padding(horizontal = 16.dp).wrapContentHeight(Alignment.CenterVertically))
        }
        Rule()
    }
}

/** A full-screen form: covers everything below it (taps never reach the browser), Back = Cancel. */
@Composable
internal fun FormScreen(title: String, left: String = "Cancel", right: String?, onDismiss: () -> Unit, onRight: () -> Unit, content: @Composable ColumnScope.() -> Unit) {
    BackHandler(onBack = onDismiss)
    Column(Modifier.fillMaxSize().background(Ink.White).pointerInput(Unit) { detectTapGestures { } }) {
        FormBar(title, left, onDismiss, right, onRight)
        Column(Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(start = FormMarginH, end = FormMarginH, top = FormMarginV, bottom = FormMarginV), verticalArrangement = Arrangement.spacedBy(FormMarginV)) { content() }
    }
}

/**
 * TitleTextInputComponent: a 120 px block with a small title over the text and a 2 px underline. It takes focus when it appears with
 * its text selected (the keyboard opens at once and typing replaces the suggested name); Enter confirms.
 */
@Composable
internal fun FormNameField(label: String, initial: String, onChange: (String) -> Unit, onDone: () -> Unit) {
    var value by remember { mutableStateOf(TextFieldValue(initial, TextRange(0, initial.length))) }
    val focus = remember { FocusRequester() }
    LaunchedEffect(Unit) { runCatching { focus.requestFocus() } }
    Column(Modifier.fillMaxWidth().height(120.dp)) {
        Text(label, style = RmText.Caption, color = Ink.Grey)
        BasicTextField(
            value = value, onValueChange = { value = it; onChange(it.text) }, singleLine = true,
            textStyle = RmText.BodyLg.copy(color = Ink.Black), cursorBrush = SolidColor(Ink.Black),
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences, imeAction = ImeAction.Done),
            keyboardActions = KeyboardActions(onDone = { onDone() }),
            modifier = Modifier.weight(1f).fillMaxWidth().focusRequester(focus).wrapContentHeight(Alignment.CenterVertically),
        )
        Rule()
    }
}

/** ArkControls.ContextualMenu (secondary): the buttons share one bordered row; the checked one is inverted. */
@Composable
internal fun ContextualMenu(options: List<String>, selected: Int, onSelect: (Int) -> Unit) {
    Row(Modifier.fillMaxWidth().border(Rm.Outline, Ink.Black)) {
        options.forEachIndexed { i, label ->
            val on = i == selected
            Box(Modifier.weight(1f).height(Rm.ToolButton).background(if (on) Ink.Black else Ink.White).tap { onSelect(i) }, contentAlignment = Alignment.Center) {
                Text(label, style = RmText.LabelLg, color = if (on) Ink.White else Ink.Black)
            }
        }
    }
}

/** A "View all >" link button (IconButton with a right chevron, text first). */
@Composable
internal fun ViewAll(onClick: () -> Unit, modifier: Modifier = Modifier) {
    Row(modifier.heightIn(min = 50.dp).tap(onClick = onClick), verticalAlignment = Alignment.CenterVertically) {
        Text("View all", style = RmText.Label)
        InkIcons.ChevronSmallRight()
    }
}

// ---- New notebook ----

@Composable
internal fun NewNotebookScreen(app: AppController, parentId: String, onDismiss: () -> Unit) {
    var name by remember { mutableStateOf(app.suggestName(parentId)) }
    var template by remember { mutableStateOf(app.prefs.recentTemplates.first()) }
    var cover by remember { mutableIntStateOf(-1) }
    var picker by remember { mutableStateOf(false) }
    val create = {
        if (name.isNotBlank()) {
            app.prefs.addRecentTemplate(template)
            app.newNotebook(name.trim(), template, parentId, cover)
            onDismiss()
        }
    }
    FormScreen("New notebook", right = if (name.isNotBlank()) "Create" else null, onDismiss = onDismiss, onRight = create) {
        FormNameField("Name", name, { name = it }, create)
        Column(verticalArrangement = Arrangement.spacedBy(24.dp)) {
            Text("Notebook cover", style = RmText.Label)
            ContextualMenu(listOf("Last visited page", "First page"), if (cover == -1) 0 else 1) { cover = if (it == 0) -1 else 0 }
        }
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text("Templates", style = RmText.TitleMdAlt, modifier = Modifier.weight(1f))
            ViewAll({ picker = true })
        }
        // The recent templates: a grid of 329 x 340 px cells, four to a row.
        val recents = app.prefs.recentTemplates.take(8)
        Column {
            recents.chunked(4).forEach { row ->
                Row(Modifier.fillMaxWidth()) {
                    row.forEach { t ->
                        Box(Modifier.weight(1f).height(340.dp), contentAlignment = Alignment.TopCenter) { TemplateCard(t, t == template, { template = t }, Modifier.width(200.dp)) }
                    }
                    repeat(4 - row.size) { Spacer(Modifier.weight(1f)) }
                }
            }
        }
    }
    if (picker) Box(Modifier.fillMaxSize()) { TemplatePickerScreen(template, { template = it; picker = false }, { picker = false }) }
}

// ---- New folder ----

@Composable
internal fun NewFolderScreen(app: AppController, parentId: String, moving: Boolean, onDismiss: () -> Unit) {
    var name by remember { mutableStateOf(app.suggestName(parentId, "Folder")) }
    var tags by remember { mutableStateOf(setOf<String>()) }
    val create = {
        if (name.isNotBlank()) {
            // Moving: the browser steps into the new folder, so the items can be dropped straight into it.
            app.newFolder(name.trim(), parentId, tags.toList(), onCreated = { id -> if (moving && id.isNotEmpty()) app.screen = Screen.Files(Section.MY_FILES, id) })
            onDismiss()
        }
    }
    FormScreen("New folder", right = if (name.isNotBlank()) "Create" else null, onDismiss = onDismiss, onRight = create) {
        FormNameField("Name", name, { name = it }, create)
        TagsSelector(app, tags) { tags = it }
    }
}

/** The tags known to the library (outside the trash), alphabetically. */
internal fun knownTags(lib: Library): List<String> = lib.entries.filter { it.parentId != Library.TRASH }.flatMap { it.tags }.distinct().sortedBy { it.lowercase() }

/** TagsSelector: a "Tags" header with "View all", up to three rows of pills (chosen ones first), and a "New tag" button. */
@OptIn(androidx.compose.foundation.layout.ExperimentalLayoutApi::class)
@Composable
internal fun TagsSelector(app: AppController, selected: Set<String>, onChange: (Set<String>) -> Unit) {
    var created by remember { mutableStateOf(listOf<String>()) }
    var newTag by remember { mutableStateOf(false) }
    var viewAll by remember { mutableStateOf(false) }
    val known = remember(app.library) { knownTags(app.library) }
    val all = known + created.filter { it !in known }
    val sorted = all.sortedBy { if (it in selected) 0 else 1 }
    Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text("Tags", style = RmText.LabelLg, color = Ink.Grey, modifier = Modifier.weight(1f))
            if (all.isNotEmpty()) ViewAll({ viewAll = true })
        }
        androidx.compose.foundation.layout.FlowRow(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(20.dp), verticalArrangement = Arrangement.spacedBy(20.dp), maxLines = 3) {
            sorted.forEach { t -> TagPill(t, selected = t in selected, onClick = { onChange(if (t in selected) selected - t else selected + t) }) }
        }
        Row(
            Modifier.padding(top = 20.dp).height(Rm.Control).border(Rm.Outline, Ink.Black).tap { newTag = true }.padding(horizontal = 24.dp).semantics { contentDescription = "New tag" },
            verticalAlignment = Alignment.CenterVertically,
        ) { InkIcons.PlusCircle(); Spacer(Modifier.width(16.dp)); Text("New tag", style = RmText.LabelLg) }
    }
    if (newTag) HeaderInputDialog("Enter tag name", "Create", onDismiss = { newTag = false }) { t ->
        newTag = false
        if (t.isNotEmpty()) { if (t !in all) created = created + t; onChange(selected + t) }
    }
    if (viewAll) Box(Modifier.fillMaxSize()) {
        TagsWindow(all, selected, { t -> onChange(if (t in selected) selected - t else selected + t) }, { viewAll = false })
    }
}

/** The firmware's "Tags" window: Back bar, then every tag as a pill (tap toggles). */
@OptIn(androidx.compose.foundation.layout.ExperimentalLayoutApi::class)
@Composable
internal fun TagsWindow(tags: List<String>, selected: Set<String>, onToggle: (String) -> Unit, onBack: () -> Unit) {
    BackHandler(onBack = onBack)
    Column(Modifier.fillMaxSize().background(Ink.White).pointerInput(Unit) { detectTapGestures { } }) {
        NavigationBar("Tags", onBack)
        Column(Modifier.verticalScroll(rememberScrollState()).padding(start = FormMarginH, end = FormMarginH, top = FormMarginV), verticalArrangement = Arrangement.spacedBy(24.dp)) {
            Text("All", style = RmText.TitleMdAlt)
            androidx.compose.foundation.layout.FlowRow(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(20.dp), verticalArrangement = Arrangement.spacedBy(20.dp)) {
                tags.forEach { t -> TagPill(t, selected = t in selected, onClick = { onToggle(t) }) }
            }
        }
    }
}

/**
 * HeaderInput: a black bar across the top of the screen with a Cancel button, a text field with a placeholder and a confirm button
 * (shown once there is text). Used for new tags; tapping below the bar cancels. Text is limited to [maxLength] characters.
 */
@Composable
internal fun HeaderInputDialog(placeholder: String, confirm: String, onDismiss: () -> Unit, maxLength: Int = 20, onConfirm: (String) -> Unit) {
    val density = LocalDensity.current
    var text by remember { mutableStateOf("") }
    val focus = remember { FocusRequester() }
    LaunchedEffect(Unit) { runCatching { focus.requestFocus() } }
    Dialog(onDismissRequest = onDismiss, properties = DialogProperties(usePlatformDefaultWidth = false)) {
        (androidx.compose.ui.platform.LocalView.current.parent as? androidx.compose.ui.window.DialogWindowProvider)?.window?.let { w ->
            SideEffect { w.setGravity(android.view.Gravity.TOP); w.setDimAmount(0f); w.setLayout(android.view.ViewGroup.LayoutParams.MATCH_PARENT, android.view.ViewGroup.LayoutParams.WRAP_CONTENT) }
        }
        CompositionLocalProvider(LocalDensity provides density) {
            Row(Modifier.fillMaxWidth().height(Rm.NavigationHeader).background(Ink.Black).padding(horizontal = 32.dp), verticalAlignment = Alignment.CenterVertically) {
                Text("Cancel", style = RmText.Label, color = Ink.White, modifier = Modifier.heightIn(min = Rm.Control).tap(onClick = onDismiss).wrapContentHeight(Alignment.CenterVertically))
                Spacer(Modifier.width(32.dp))
                BasicTextField(
                    value = text, onValueChange = { text = it.take(maxLength) }, singleLine = true,
                    textStyle = RmText.BodyLg.copy(color = Ink.White), cursorBrush = SolidColor(Ink.White),
                    keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences, imeAction = ImeAction.Done),
                    keyboardActions = KeyboardActions(onDone = { onConfirm(text.trim()) }),
                    modifier = Modifier.weight(1f).focusRequester(focus),
                    decorationBox = { inner -> Box { if (text.isEmpty()) Text(placeholder, color = Ink.Rule, style = RmText.BodyLg); inner() } },
                )
                if (text.isNotBlank()) Text(confirm, style = RmText.Label, color = Ink.White, modifier = Modifier.heightIn(min = Rm.Control).tap { onConfirm(text.trim()) }.wrapContentHeight(Alignment.CenterVertically))
            }
        }
    }
}

// ---- Rename ----

@Composable
internal fun RenameScreen(app: AppController, e: LibraryEntry, onDismiss: () -> Unit, onDone: () -> Unit) {
    var name by remember { mutableStateOf(e.name) }
    val save = { if (name.isNotBlank()) { app.rename(e, name.trim()); onDone() } }
    FormScreen("Rename", right = if (name.isNotBlank()) "Save" else null, onDismiss = onDismiss, onRight = save) {
        FormNameField("Name", name, { name = it }, save)
        val fmt = remember { DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT) }
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text("Details", style = RmText.Label)
            Spacer(Modifier.height(8.dp))
            if (e.lastModified > 0) Text("Last modified ${fmt.format(Date(e.lastModified))}", style = RmText.Caption)
            if (e.created > 0) Text("Created ${fmt.format(Date(e.created))}", style = RmText.Caption)
            Text("ID: ${e.id.substringBefore('-')}", style = RmText.Caption)
        }
    }
}
