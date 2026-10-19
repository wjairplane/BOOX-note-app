package app.inkbridge.text

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.inkbridge.R
import app.inkbridge.rm.text.LineSpacing
import app.inkbridge.rm.text.PageMargins
import app.inkbridge.rm.text.TextFont
import app.inkbridge.rm.text.TextSettings
import app.inkbridge.ui.ConfirmDialog
import app.inkbridge.ui.FormBar
import app.inkbridge.ui.Ink
import app.inkbridge.ui.Rm
import app.inkbridge.ui.RmText
import app.inkbridge.ui.Rule
import app.inkbridge.ui.tap
import kotlin.math.abs

/** Compose families for the font names in the "Font" grid. */
private fun familyOf(f: TextFont): FontFamily = when (f) {
    TextFont.RM_SANS -> FontFamily(Font(R.font.rm_sans_regular))
    TextFont.EB_GARAMOND -> FontFamily(Font(R.font.eb_garamond))
    TextFont.NOTO_SANS -> FontFamily(Font(R.font.noto_sans))
    TextFont.NOTO_MONO -> FontFamily(Font(R.font.noto_mono))
    TextFont.NOTO_SERIF -> FontFamily(Font(R.font.noto_serif))
}

/**
 * The firmware's "Text settings" (`00dae71c`): a header with Reset and Save over a 550 px area of five blocks - Font size, Font,
 * Justification, Page margins, Line spacing - separated by 2 px rules. A change on a page that already has handwriting asks first
 * ("Misalignment may occur"), once.
 */
@Composable
fun TextSettingsPanel(
    settings: TextSettings,
    margin: Float,
    hasAnnotations: Boolean,
    onChange: (TextSettings, Float) -> Unit,
    onClose: () -> Unit,
    modifier: Modifier = Modifier,
) {
    var s by remember { mutableStateOf(settings) }
    var m by remember { mutableStateOf(margin) }
    var confirmed by remember { mutableStateOf(false) }
    var pending by remember { mutableStateOf<(() -> Unit)?>(null) }

    fun confirmThen(action: () -> Unit) {
        if (hasAnnotations && !confirmed) pending = action else action()
    }
    fun apply(ns: TextSettings, nm: Float) { s = ns; m = nm; onChange(ns, nm) }

    Column(modifier.fillMaxWidth().background(Ink.White).pointerInput(Unit) { detectTapGestures { } }) {
        FormBar("Text settings", "Reset", { confirmThen { apply(TextSettings.DEFAULT, TextSettings.DEFAULT_SIDE_MARGIN) } }, "Save", onClose)
        Column(Modifier.fillMaxWidth().height(550.dp)) {
            Row(Modifier.weight(1f).fillMaxWidth()) {
                FontSizeBlock(s.scale, Modifier.weight(1f).fillMaxHeight()) { v -> confirmThen { apply(s.copy(scale = v), m) } }
                Box(Modifier.width(Rm.Outline).fillMaxHeight().background(Ink.Black))
                FontBlock(s.font, Modifier.weight(1f).fillMaxHeight()) { f -> confirmThen { apply(s.copy(font = f), m) } }
            }
            Rule()
            Row(Modifier.weight(1f).fillMaxWidth()) {
                JustificationBlock(s.justify, Modifier.weight(2f).fillMaxHeight()) { j -> confirmThen { apply(s.copy(justify = j), m) } }
                Box(Modifier.width(Rm.Outline).fillMaxHeight().background(Ink.Black))
                MarginsBlock(m, Modifier.weight(3f).fillMaxHeight()) { v -> confirmThen { apply(s, v) } }
                Box(Modifier.width(Rm.Outline).fillMaxHeight().background(Ink.Black))
                LineSpacingBlock(s.lineSpacing, Modifier.weight(3f).fillMaxHeight()) { v -> confirmThen { apply(s.copy(lineSpacing = v), m) } }
            }
            Rule()
        }
    }

    pending?.let { action ->
        ConfirmDialog(
            "Misalignment may occur",
            "Your annotations, highlights or doodles may lose its alignment with the changed settings. Please confirm that you want to proceed, as this could be irreversible.",
            "Confirm",
            onDismiss = { pending = null },
            onConfirm = { confirmed = true; pending = null; action() },
        )
    }
}

@Composable
private fun BlockTitle(text: String) = Text(text, style = RmText.Label, modifier = Modifier.padding(start = 30.dp, top = 30.dp))

@Composable
private fun FontSizeBlock(scale: Float, modifier: Modifier, onPick: (Float) -> Unit) {
    Column(modifier) {
        BlockTitle("Font size")
        Row(Modifier.weight(1f).fillMaxWidth().padding(15.dp), verticalAlignment = Alignment.CenterVertically) {
            for (v in TextSettings.FONT_SCALES) {
                val on = v == scale
                Box(
                    Modifier.weight(1f).aspectRatio(1f).background(if (on) Ink.Black else Color.Transparent)
                        .tap { onPick(v) }.semantics { contentDescription = "font-scale-$v" },
                    contentAlignment = Alignment.Center,
                ) { Text("A", style = RmText.sans((v * 32).toInt()), color = if (on) Ink.White else Ink.Black) }
            }
        }
    }
}

@Composable
private fun FontBlock(font: TextFont, modifier: Modifier, onPick: (TextFont) -> Unit) {
    Column(modifier) {
        BlockTitle("Font")
        Column(Modifier.weight(1f).fillMaxWidth().padding(start = 30.dp, end = 30.dp, bottom = 20.dp, top = 10.dp)) {
            for (f in TextFont.entries) Row(
                Modifier.weight(1f).fillMaxWidth().tap { onPick(f) }.semantics { contentDescription = f.label },
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Box(Modifier.size(24.dp).border(Rm.Outline, Ink.Black, CircleShape).background(if (f == font) Ink.Black else Color.Transparent, CircleShape))
                Text(f.label, fontFamily = familyOf(f), fontSize = 28.sp, color = Ink.Black, modifier = Modifier.padding(start = 20.dp), maxLines = 1)
            }
        }
    }
}

@Composable
private fun JustificationBlock(justify: Boolean, modifier: Modifier, onPick: (Boolean) -> Unit) {
    Column(modifier) {
        BlockTitle("Justification")
        Row(Modifier.weight(1f).fillMaxWidth().padding(15.dp), verticalAlignment = Alignment.CenterVertically) {
            for (j in listOf(false, true)) Box(Modifier.weight(1f).fillMaxHeight().tap { onPick(j) }.semantics { contentDescription = if (j) "align-justify" else "align-left" }, contentAlignment = Alignment.Center) {
                PageIcon(selected = j == justify) { fg ->
                    val lens = if (j) floatArrayOf(1f, 1f, 1f, 1f, 1f, 1f) else floatArrayOf(1f, 0.8f, 1f, 0.6f, 0.9f, 0.5f)
                    for ((i, l) in lens.withIndex()) {
                        val y = size.height * (0.2f + i * 0.12f)
                        drawLine(fg, Offset(size.width * 0.18f, y), Offset(size.width * (0.18f + 0.64f * l), y), strokeWidth = 3f)
                    }
                }
            }
        }
    }
}

@Composable
private fun MarginsBlock(margin: Float, modifier: Modifier, onPick: (Float) -> Unit) {
    val nearest = PageMargins.entries.minBy { abs(it.margin - margin) }
    Column(modifier) {
        BlockTitle("Page margins")
        Row(Modifier.weight(1f).fillMaxWidth().padding(15.dp), verticalAlignment = Alignment.CenterVertically) {
            for (pm in PageMargins.entries) Box(Modifier.weight(1f).fillMaxHeight().tap { onPick(pm.margin.toFloat()) }.semantics { contentDescription = "margin-${pm.name.lowercase()}" }, contentAlignment = Alignment.Center) {
                PageIcon(selected = pm == nearest) { fg ->
                    val inset = size.width * (0.1f + 0.3f * pm.margin / 225f)
                    for (i in 0 until 6) {
                        val y = size.height * (0.2f + i * 0.12f)
                        drawLine(fg, Offset(inset, y), Offset(size.width - inset, y), strokeWidth = 3f)
                    }
                }
            }
        }
    }
}

@Composable
private fun LineSpacingBlock(spacing: LineSpacing, modifier: Modifier, onPick: (LineSpacing) -> Unit) {
    Column(modifier) {
        BlockTitle("Line spacing")
        Row(Modifier.weight(1f).fillMaxWidth().padding(15.dp), verticalAlignment = Alignment.CenterVertically) {
            for (ls in LineSpacing.entries) Box(Modifier.weight(1f).fillMaxHeight().tap { onPick(ls) }.semantics { contentDescription = "line-height-${ls.name.lowercase()}" }, contentAlignment = Alignment.Center) {
                PageIcon(selected = ls == spacing) { fg ->
                    val step = size.height * 0.07f * ls.percent / 100f
                    var i = 0
                    while (size.height * 0.2f + i * step < size.height * 0.84f) {
                        val y = size.height * 0.2f + i * step
                        drawLine(fg, Offset(size.width * 0.18f, y), Offset(size.width * 0.82f, y), strokeWidth = 3f)
                        i++
                    }
                }
            }
        }
    }
}

/** A page-shaped illustration, black on white and inverted when [selected] (the firmware's `*_inverted` variants). */
@Composable
private fun PageIcon(selected: Boolean, lines: androidx.compose.ui.graphics.drawscope.DrawScope.(Color) -> Unit) {
    Canvas(Modifier.size(width = 110.dp, height = 140.dp)) {
        val bg = if (selected) Ink.Black else Ink.White
        val fg = if (selected) Ink.White else Ink.Black
        drawRect(bg, Offset.Zero, Size(size.width, size.height))
        drawRect(Ink.Black, Offset(1f, 1f), Size(size.width - 2f, size.height - 2f), style = Stroke(width = 3f))
        lines(fg)
    }
}
