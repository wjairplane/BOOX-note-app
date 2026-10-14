package app.inkbridge.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import app.inkbridge.R

/*
 * The layout follows xochitl 3.27.1.0 (reference/remarkable-3.27.1.0/ui). xochitl lays everything out in pixels on a
 * 1404 x 1872 screen. [RmDensity] makes one dp equal one of those pixels on whatever screen this runs on, so the
 * numbers below (and in the screens) are the firmware's own token values.
 */

/** Runs [content] with 1 dp == 1 reMarkable pixel: the screen's short side is 1404 of them. */
@Composable
fun RmDensity(content: @Composable () -> Unit) {
    val metrics = LocalContext.current.resources.displayMetrics
    val short = minOf(metrics.widthPixels, metrics.heightPixels).toFloat()
    val base = LocalDensity.current
    CompositionLocalProvider(LocalDensity provides Density(density = short / RM_WIDTH, fontScale = base.fontScale), content = content)
}

private const val RM_WIDTH = 1404f

/** Dimension tokens from ArkTokens / Values, in reMarkable pixels (== dp under [RmDensity]). */
object Rm {
    val Icon = 48.dp                    // content.icon.*.sizing
    val ToolButton = 112.dp             // controlsHeight.large: toolbar buttons and foldout rows
    val Control = 80.dp                 // controlsHeight.small: buttons, list rows
    val Outline = 2.dp                  // outlineSize: borders and dividers
    val FoldoutPad = 32.dp              // foldout horizontal padding
    val ViewMargin = 18.dp              // viewHorizontalMargin
    val NavigatorMargin = 40.dp
    val SidebarWidth = 414.dp
    val CreateMenuHeight = 112.dp
    val CreateMenuBottomMargin = 100.dp
    val WritingFoldoutWidth = 480.dp
    val EraserFoldoutWidth = 376.dp
}

val RmSans = FontFamily(
    Font(R.font.rm_sans_light, FontWeight.Light),
    Font(R.font.rm_sans_regular, FontWeight.Normal),
    Font(R.font.rm_sans_medium, FontWeight.Medium),
    Font(R.font.rm_sans_bold, FontWeight.Bold),
)
val RmSerif = FontFamily(
    Font(R.font.rm_serif_regular, FontWeight.Normal),
    Font(R.font.rm_serif_bold, FontWeight.Bold),
)

/** The firmware's Style typography (rM-paper-tablet tokens): size in px, line height as a multiple of it. */
object RmText {
    private fun sans(size: Int, weight: FontWeight, line: Float) = TextStyle(fontFamily = RmSans, fontSize = size.sp, fontWeight = weight, lineHeight = (size * line).sp)
    private fun serif(size: Int, line: Float) = TextStyle(fontFamily = RmSerif, fontSize = size.sp, fontWeight = FontWeight.Normal, lineHeight = (size * line).sp)

    val BodyLg = sans(36, FontWeight.Normal, 1.5f)
    val Body = sans(28, FontWeight.Normal, 1.5f)
    val BodySm = sans(25, FontWeight.Normal, 1.5f)
    val Caption = sans(22, FontWeight.Normal, 1.45f)
    val Label = sans(25, FontWeight.Medium, 1.58f)
    val LabelLg = sans(28, FontWeight.Medium, 1.56f)
    val LabelLgStrong = sans(28, FontWeight.Bold, 1.56f)
    val LabelSm = sans(22, FontWeight.Medium, 1.44f)
    val TitleMd = sans(28, FontWeight.Bold, 1.5f)
    val TitleMdAlt = serif(42, 1.5f)
    val TitleLg = serif(48, 1.25f)
}

/** E-ink palette: pure black on white, one mid grey for secondary text. Selected fills are plain black, as on the tablet. */
object Ink {
    val Black = Color.Black
    val Dark = Color.Black
    val White = Color.White
    val Grey = Color(0xFF6E6E6E)
    val Rule = Color(0xFF9A9A9A)
    val Panel = Color(0xFFF1F1F1)
}

val EInkColors = lightColorScheme(
    primary = Ink.Black, onPrimary = Ink.White,
    background = Ink.White, onBackground = Ink.Black,
    surface = Ink.White, onSurface = Ink.Black,
    outline = Ink.Black,
)

/** Material text styles, all set in reMarkable Sans so unstyled [Text] matches the tablet. */
val RmTypography = Typography().let {
    fun TextStyle.rm() = copy(fontFamily = RmSans)
    it.copy(
        displayLarge = it.displayLarge.rm(), displayMedium = it.displayMedium.rm(), displaySmall = it.displaySmall.rm(),
        headlineLarge = it.headlineLarge.rm(), headlineMedium = it.headlineMedium.rm(), headlineSmall = it.headlineSmall.rm(),
        titleLarge = it.titleLarge.rm(), titleMedium = it.titleMedium.rm(), titleSmall = it.titleSmall.rm(),
        bodyLarge = RmText.Body, bodyMedium = RmText.Body, bodySmall = RmText.BodySm,
        labelLarge = RmText.Label, labelMedium = RmText.Label, labelSmall = RmText.LabelSm,
    )
}

/** Click without a ripple (ripples are animated, which smears on e-ink). */
fun Modifier.tap(enabled: Boolean = true, onClick: () -> Unit): Modifier = composed {
    clickable(enabled = enabled, indication = null, interactionSource = remember { MutableInteractionSource() }, onClick = onClick)
}

/** A divider: 2 px black, as the firmware's Style.divider. */
@Composable
fun Rule(modifier: Modifier = Modifier) = Box(modifier.fillMaxWidth().height(Rm.Outline).background(Ink.Black))

/** Text button: 80 px high, sharp corners, 2 px border; inverted when [selected]. */
@Composable
fun EButton(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    selected: Boolean = false,
    size: Dp = Rm.Control,
) {
    val fg = if (selected) Ink.White else if (enabled) Ink.Black else Ink.Rule
    Box(
        modifier
            .defaultMinSize(minWidth = size, minHeight = size)
            .background(if (selected) Ink.Dark else Ink.White)
            .border(Rm.Outline, if (enabled) Ink.Black else Ink.Rule)
            .tap(enabled, onClick)
            .padding(horizontal = 32.dp),
        contentAlignment = Alignment.Center,
    ) { Text(label, color = fg, style = RmText.Label, maxLines = 1) }
}

/** Icon-only square button for header bars: an 80 px tile with a 48 px glyph. */
@Composable
fun IconBtn(description: String, onClick: () -> Unit, modifier: Modifier = Modifier, enabled: Boolean = true, selected: Boolean = false, icon: @Composable (Color) -> Unit) {
    val fg = if (selected) Ink.White else if (enabled) Ink.Black else Ink.Rule
    Box(
        modifier.size(Rm.Control).background(if (selected) Ink.Dark else Ink.White).tap(enabled, onClick).semantics { contentDescription = description },
        contentAlignment = Alignment.Center,
    ) { icon(fg) }
}

/** A modal box (the firmware's Card): 2 px border, 64 px padding, serif title. */
@Composable
fun EDialog(title: String, onDismiss: () -> Unit, actions: @Composable RowScope.() -> Unit, content: @Composable ColumnScope.() -> Unit) {
    Dialog(onDismissRequest = onDismiss) {
        Column(Modifier.fillMaxWidth().background(Ink.White).border(Rm.Outline, Ink.Black).padding(64.dp)) {
            Text(title, style = RmText.TitleMdAlt)
            Spacer(Modifier.height(24.dp))
            content()
            Spacer(Modifier.height(32.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(24.dp, Alignment.End)) { actions() }
        }
    }
}

@Composable
fun NameDialog(title: String, initial: String, confirm: String, onDismiss: () -> Unit, onConfirm: (String) -> Unit) {
    var text by remember { mutableStateOf(initial) }
    EDialog(title, onDismiss, actions = {
        EButton("Cancel", onDismiss)
        EButton(confirm, { onConfirm(text.trim()) }, enabled = text.isNotBlank(), selected = text.isNotBlank())
    }) { NameField(text) { text = it } }
}

/** The firmware's input field: a 96 px line of body text over a 2 px underline. */
@Composable
fun NameField(value: String, onChange: (String) -> Unit) {
    Column(Modifier.fillMaxWidth()) {
        BasicTextField(
            value = value,
            onValueChange = onChange,
            singleLine = true,
            textStyle = RmText.BodyLg.copy(color = Ink.Black),
            cursorBrush = SolidColor(Ink.Black),
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences),
            modifier = Modifier.fillMaxWidth().height(96.dp).wrapContentHeight(Alignment.CenterVertically).padding(horizontal = 4.dp),
        )
        Box(Modifier.fillMaxWidth().height(Rm.Outline).background(Ink.Black))
    }
}

@Composable
fun ConfirmDialog(title: String, message: String, confirm: String, onDismiss: () -> Unit, onConfirm: () -> Unit) {
    EDialog(title, onDismiss, actions = {
        EButton("Cancel", onDismiss)
        EButton(confirm, onConfirm, selected = true)
    }) { Text(message, style = RmText.Body) }
}

/** One row in a list of choices (the firmware's Cell): 48 px marker, body text, 24 px padding; the current one is filled. */
@Composable
fun ChoiceRow(label: String, selected: Boolean, onClick: () -> Unit, sub: String? = null) {
    Row(Modifier.fillMaxWidth().tap(onClick = onClick).padding(vertical = 24.dp), verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.size(Rm.Icon).border(Rm.Outline, Ink.Black, CircleShape).padding(10.dp)) {
            if (selected) Box(Modifier.fillMaxSize().background(Ink.Black, CircleShape))
        }
        Spacer(Modifier.width(24.dp))
        Column {
            Text(label, style = RmText.Body)
            if (sub != null) Text(sub, style = RmText.Caption, color = Ink.Grey)
        }
    }
}

/** A row with an on/off toggle: a pill with a 32 px handle, as the firmware's Toggle. */
@Composable
fun SwitchRow(label: String, checked: Boolean, onChange: (Boolean) -> Unit, sub: String? = null) {
    Row(Modifier.fillMaxWidth().tap { onChange(!checked) }.padding(vertical = 24.dp), verticalAlignment = Alignment.CenterVertically) {
        Column(Modifier.weight(1f)) {
            Text(label, style = RmText.Body)
            if (sub != null) Text(sub, style = RmText.Caption, color = Ink.Grey)
        }
        Spacer(Modifier.width(24.dp))
        Box(
            Modifier.size(width = 104.dp, height = 56.dp).background(if (checked) Ink.Black else Ink.White, CircleShape).border(Rm.Outline, Ink.Black, CircleShape).padding(horizontal = 12.dp),
            contentAlignment = if (checked) Alignment.CenterEnd else Alignment.CenterStart,
        ) { Box(Modifier.size(32.dp).background(if (checked) Ink.White else Ink.Black, CircleShape)) }
    }
}
