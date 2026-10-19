package app.inkbridge.text

import androidx.annotation.DrawableRes
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.isImeVisible
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import app.inkbridge.PageSession
import app.inkbridge.R
import app.inkbridge.rm.scene.ParagraphStyle
import app.inkbridge.ui.Ink
import app.inkbridge.ui.InkIcons
import app.inkbridge.ui.Rm
import app.inkbridge.ui.RmText
import app.inkbridge.ui.tap
import kotlinx.coroutines.delay

/** The icons of the typed-text tool (firmware icon set). */
object TextIcons {
    @Composable fun Typing(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: androidx.compose.ui.unit.Dp = Rm.Icon) = glyph(R.drawable.rm_typing, modifier, tint, size)
    @Composable fun glyph(@DrawableRes id: Int, modifier: Modifier, tint: Color, size: androidx.compose.ui.unit.Dp = Rm.Icon) =
        Image(painterResource(id), contentDescription = null, modifier = modifier.size(size), colorFilter = ColorFilter.tint(tint))
}

private class StyleOption(@DrawableRes val icon: Int, val style: ParagraphStyle, val label: String)

private val StyleOptions = listOf(
    StyleOption(R.drawable.rm_formatting_title, ParagraphStyle.HEADING, "Title"),
    StyleOption(R.drawable.rm_text_t_heading, ParagraphStyle.BOLD, "Subheading"),
    StyleOption(R.drawable.rm_formatting_paragraph, ParagraphStyle.PLAIN, "Body text"),
    StyleOption(R.drawable.rm_formatting_bulletlist, ParagraphStyle.BULLET, "Bullet points"),
    StyleOption(R.drawable.rm_formatting_number, ParagraphStyle.NUMBERED, "Numbered list"),
    StyleOption(R.drawable.rm_formatting_checkbox, ParagraphStyle.CHECKBOX, "Checkbox"),
)

/** Does the paragraph style [actual] light up the menu button for [button]? Sub-levels and ticked boxes belong to their list. */
private fun matches(button: ParagraphStyle, actual: ParagraphStyle): Boolean = when (button) {
    ParagraphStyle.PLAIN -> actual == ParagraphStyle.PLAIN || actual == ParagraphStyle.BASIC
    ParagraphStyle.BULLET -> actual == ParagraphStyle.BULLET || actual == ParagraphStyle.BULLET2
    ParagraphStyle.CHECKBOX -> actual == ParagraphStyle.CHECKBOX || actual == ParagraphStyle.CHECKBOX_CHECKED
    else -> actual == button
}

/**
 * Everything the text tool draws over the page: the selection, the caret and its handle, the format menu (the firmware's
 * `FormatMenu`: an 80 px button left of the paragraph that folds out the paragraph styles, here with bold, italic and
 * indent as well; above the soft keyboard it is the black bar of `FormatMenuVirtualKeyboard`) and the selection menu.
 * [revision] makes it redraw after edits made elsewhere (undo, redo); [keyboardRequest] shows the keyboard when it changes.
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun TextEditLayer(
    session: PageSession,
    controller: TextController,
    revision: Int,
    keyboardRequest: Int,
    modifier: Modifier = Modifier,
    /** Whether the soft keyboard is up (the format bar goes above it, else the format menu floats by the paragraph); null asks the system. */
    softKeyboard: Boolean? = null,
    /** Ask the system to show the keyboard when [keyboardRequest] changes (off in tests of the layer on its own). */
    showKeyboard: Boolean = true,
    /** Room the toolbar takes at the screen edges, so the keyboard bar isn't hidden under it. */
    startInset: androidx.compose.ui.unit.Dp = 0.dp,
    endInset: androidx.compose.ui.unit.Dp = 0.dp,
    bottomInset: androidx.compose.ui.unit.Dp = 0.dp,
    onHideKeyboard: () -> Unit = {},
) {
    @Suppress("UNUSED_EXPRESSION") revision
    @Suppress("UNUSED_EXPRESSION") controller.version
    val density = LocalDensity.current
    val clipboard = LocalClipboardManager.current
    var inputView by remember { mutableStateOf<TextInputView?>(null) }
    val imeVisible = softKeyboard ?: WindowInsets.isImeVisible

    LaunchedEffect(inputView, keyboardRequest) { if (showKeyboard) inputView?.showKeyboard() }

    // The caret appears 250 ms after the last interaction (the firmware's show delay); it does not blink, which would refresh the panel.
    var caretShown by remember { mutableStateOf(false) }
    LaunchedEffect(controller.version, revision) { caretShown = false; delay(250); caretShown = true }

    Box(modifier.fillMaxSize()) {
        AndroidView(
            modifier = Modifier.size(1.dp).align(Alignment.TopStart),
            factory = { ctx -> TextInputView(ctx).also { inputView = it } },
            update = {
                it.controller = controller
                it.onClipboardCopy = { s -> if (s.isNotEmpty()) clipboard.setText(AnnotatedString(s)) }
                it.onClipboardPaste = { clipboard.getText()?.text }
            },
        )

        val t = session.transform
        val layout = controller.layout
        if (t != null) {
            Canvas(Modifier.fillMaxSize()) {
                val sel = if (controller.hasSelection && layout != null) layout.selectionRects(controller.selStart, controller.selEnd) else emptyList()
                for (r in sel) {
                    drawRect(Color(0x55000000), Offset(t.toViewX(r[0]), t.toViewY(r[1])), Size((r[2] - r[0]) * t.scale, (r[3] - r[1]) * t.scale))
                }
                if (caretShown) {
                    val c = layout?.caret(controller.caret) ?: TextLayoutDefaults.emptyCaret(session)
                    val x = t.toViewX(c.x); val top = t.toViewY(c.top); val bottom = t.toViewY(c.bottom)
                    drawRect(Color.Black, Offset(x - 1.5f, top), Size(3f, bottom - top))
                    // The drag handle under the caret.
                    drawCircle(Color.Black, 9f * t.scale.coerceAtLeast(0.5f) + 4f, Offset(x, bottom + 14f))
                }
            }

            fun px(dp: androidx.compose.ui.unit.Dp) = with(density) { dp.roundToPx() }

            // The selection's menu: below the selection, cut / copy / delete.
            if (controller.hasSelection && layout != null) {
                val rects = layout.selectionRects(controller.selStart, controller.selEnd)
                if (rects.isNotEmpty()) {
                    val cx = (rects.minOf { it[0] } + rects.maxOf { it[2] }) / 2
                    val bottom = rects.maxOf { it[3] }
                    val barW = px(80.dp) * 3 + px(Rm.Outline) * 2
                    val x = (t.toViewX(cx).toInt() - barW / 2).coerceIn(px(20.dp), (t.viewWidth.toInt() - barW - px(20.dp)).coerceAtLeast(0))
                    val y = (t.toViewY(bottom).toInt() + px(48.dp)).coerceAtMost((t.viewHeight.toInt() - px(100.dp)).coerceAtLeast(0))
                    Row(Modifier.offset { IntOffset(x, y) }.background(Ink.White).border(Rm.Outline, Ink.Black), verticalAlignment = Alignment.CenterVertically) {
                        MenuAction("Cut", false, { clipboard.setText(AnnotatedString(controller.cut())) }) { InkIcons.Scissors() }
                        MenuAction("Copy", true, { clipboard.setText(AnnotatedString(controller.selectedText())) }) { InkIcons.Copy() }
                        MenuAction("Delete", true, { controller.backspace() }) { InkIcons.Trash() }
                    }
                }
            }
        }

        if (t != null && layout != null) {
            if (controller.caretMenu && !controller.hasSelection) {
                val c = layout.caret(controller.caret)
                val x = (t.toViewX(c.x).toInt() - with(density) { 120.dp.roundToPx() }).coerceIn(0, (t.viewWidth.toInt() - with(density) { 240.dp.roundToPx() }).coerceAtLeast(0))
                val y = t.toViewY(c.bottom).toInt() + with(density) { 40.dp.roundToPx() }
                Row(Modifier.offset { IntOffset(x, y) }.background(Ink.White).border(Rm.Outline, Ink.Black)) {
                    Label("Select all") { controller.selectAll(); controller.closeCaretMenu() }
                    Box(Modifier.width(Rm.Outline).height(80.dp).background(Ink.Black))
                    Label("Paste") { clipboard.getText()?.text?.let { controller.paste(it) }; controller.closeCaretMenu() }
                }
            }
        }

        if (imeVisible) {
            FormatBar(controller, Modifier.align(Alignment.BottomCenter).padding(start = startInset, end = endInset, bottom = bottomInset), onHideKeyboard = { inputView?.hideKeyboard(); onHideKeyboard() })
        } else if (t != null) {
            FloatingFormatMenu(session, controller, density)
        }
    }
}

private object TextLayoutDefaults {
    fun emptyCaret(session: PageSession): app.inkbridge.rm.text.Caret {
        val l = app.inkbridge.rm.text.TextLayout.of(null)
        return l.caret(0)
    }
}

@Composable
private fun MenuAction(description: String, divider: Boolean, onClick: () -> Unit, icon: @Composable () -> Unit) {
    if (divider) Box(Modifier.width(Rm.Outline).height(80.dp).background(Ink.Black))
    Box(Modifier.size(80.dp).tap(onClick = onClick).semantics { contentDescription = description }, contentAlignment = Alignment.Center) { icon() }
}

@Composable
private fun Label(text: String, onClick: () -> Unit) {
    Box(Modifier.height(80.dp).width(120.dp).tap(onClick = onClick), contentAlignment = Alignment.Center) { Text(text, style = RmText.Label) }
}

/** An 80 px format button; [inverted] is white on black (the keyboard bar), [selected] flips it. */
@Composable
private fun FormatButton(@DrawableRes icon: Int, description: String, inverted: Boolean, selected: Boolean, enabled: Boolean = true, mirrored: Boolean = false, onClick: () -> Unit) {
    val dark = inverted != selected
    Box(
        Modifier.size(80.dp).background(if (dark) Ink.Black else Ink.White).tap(enabled, onClick).semantics { contentDescription = description },
        contentAlignment = Alignment.Center,
    ) {
        TextIcons.glyph(icon, if (mirrored) Modifier.graphicsLayer { scaleX = -1f } else Modifier, if (!enabled) Ink.Rule else if (dark) Ink.White else Ink.Black)
    }
}

/** The firmware's `FormatMenuVirtualKeyboard`: black bar over the soft keyboard with indent, undo, redo, the styles and hide-keyboard. */
@Composable
private fun FormatBar(c: TextController, modifier: Modifier, onHideKeyboard: () -> Unit) {
    Row(modifier.fillMaxWidth().height(82.dp).background(Ink.Black).padding(horizontal = 12.dp), verticalAlignment = Alignment.CenterVertically) {
        FormatButton(R.drawable.rm_tab, "Indent", true, false) { c.indent(c.paragraphStyle != ParagraphStyle.BULLET2) }
        Spacer(Modifier.width(48.dp))
        FormatButton(R.drawable.rm_undo, "Undo", true, false) { c.undo() }
        FormatButton(R.drawable.rm_redo, "Redo", true, false) { c.redo() }
        Spacer(Modifier.weight(1f))
        for (o in StyleOptions) FormatButton(o.icon, o.label, true, matches(o.style, c.paragraphStyle)) { c.cycleStyle(o.style) }
        FormatButton(R.drawable.rm_text_bold, "Bold", true, c.isBold) { c.toggleBold() }
        FormatButton(R.drawable.rm_text_italic, "Italic", true, c.isItalic) { c.toggleItalic() }
        Spacer(Modifier.weight(1f))
        FormatButton(R.drawable.rm_keyboard_hide, "Hide keyboard", true, false, onClick = onHideKeyboard)
    }
}

/** The firmware's `FormatMenu`: an 80 px button beside the paragraph; it folds the styles out below it (above when there's no room). */
@Composable
private fun FloatingFormatMenu(session: PageSession, c: TextController, density: androidx.compose.ui.unit.Density) {
    val t = session.transform ?: return
    val layout = c.layout
    val b = layout?.paragraphBounds(c.paragraph)
    val button = with(density) { 80.dp.roundToPx() }
    val gap = with(density) { 30.dp.roundToPx() }
    val top = if (b != null) t.toViewY(b[1]) else t.toViewY(TextLayoutDefaults.emptyCaret(session).top)
    val left = if (b != null) t.toViewX(b[0]) else t.toViewX(app.inkbridge.rm.text.TextColumn.DEFAULT.posX.toFloat())
    val offsetY = if (c.paragraphStyle == ParagraphStyle.HEADING) 0 else with(density) { 20.dp.roundToPx() }
    val y = (top.toInt() - offsetY).coerceIn(with(density) { 20.dp.roundToPx() }, (t.viewHeight.toInt() - button).coerceAtLeast(0))
    val x = (left.toInt() - button - gap).coerceAtLeast(0)
    val entries = StyleOptions.size + 3
    val foldDown = y < t.viewHeight.toInt() - button * (entries + 1)
    Box(Modifier.offset { IntOffset(x, y) }) {
        Box(Modifier.size(80.dp).background(Ink.White).border(Rm.Outline, Ink.Black).tap { c.menuOpen = !c.menuOpen }.semantics { contentDescription = "Text formatting" }, contentAlignment = Alignment.Center) {
            TextIcons.glyph(R.drawable.rm_formatting_menu, Modifier, Ink.Black)
        }
        if (c.menuOpen) {
            Column(Modifier.offset { IntOffset(0, if (foldDown) button - with(density) { 1.dp.roundToPx() } else -button * entries + with(density) { 1.dp.roundToPx() }) }.border(Rm.Outline, Ink.Black)) {
                for (o in StyleOptions) FormatButton(o.icon, o.label, false, matches(o.style, c.paragraphStyle)) { c.cycleStyle(o.style); c.menuOpen = false }
                FormatButton(R.drawable.rm_text_bold, "Bold", false, c.isBold) { c.toggleBold() }
                FormatButton(R.drawable.rm_text_italic, "Italic", false, c.isItalic) { c.toggleItalic() }
                FormatButton(R.drawable.rm_tab, "Indent", false, c.paragraphStyle == ParagraphStyle.BULLET2) { c.indent(c.paragraphStyle != ParagraphStyle.BULLET2) }
            }
        }
    }
}
