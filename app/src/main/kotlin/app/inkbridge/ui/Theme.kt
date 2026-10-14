package app.inkbridge.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog

/** E-ink palette: pure black on white, one mid grey for secondary text and rules. No tints, no motion. */
object Ink {
    val Black = Color.Black
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

/** Click without a ripple (ripples are animated, which smears on e-ink). */
fun Modifier.tap(enabled: Boolean = true, onClick: () -> Unit): Modifier = composed {
    clickable(enabled = enabled, indication = null, interactionSource = remember { MutableInteractionSource() }, onClick = onClick)
}

@Composable
fun Rule(modifier: Modifier = Modifier) = Box(modifier.fillMaxWidth().height(1.dp).background(Ink.Rule))

/** Text button with a thin border; inverted when [selected]. */
@Composable
fun EButton(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    selected: Boolean = false,
    size: Dp = 52.dp,
) {
    val fg = if (selected) Ink.White else if (enabled) Ink.Black else Ink.Rule
    Box(
        modifier
            .defaultMinSize(minWidth = size, minHeight = size)
            .border(BorderStroke(if (enabled) 1.5.dp else 1.dp, if (enabled) Ink.Black else Ink.Rule), RoundedCornerShape(3.dp))
            .background(if (selected) Ink.Black else Ink.White, RoundedCornerShape(3.dp))
            .tap(enabled, onClick)
            .padding(horizontal = 16.dp, vertical = 10.dp),
        contentAlignment = Alignment.Center,
    ) { Text(label, color = fg, fontSize = 18.sp, maxLines = 1) }
}

/** Icon-only square button (borderless, like a toolbar icon). */
@Composable
fun IconBtn(icon: ImageVector, description: String, onClick: () -> Unit, modifier: Modifier = Modifier, enabled: Boolean = true, selected: Boolean = false) {
    val fg = if (selected) Ink.White else if (enabled) Ink.Black else Ink.Rule
    Box(
        modifier.size(56.dp).background(if (selected) Ink.Black else Ink.White).tap(enabled, onClick),
        contentAlignment = Alignment.Center,
    ) { Icon(icon, contentDescription = description, tint = fg, modifier = Modifier.size(30.dp)) }
}

/** A modal box with a title, content and action buttons. */
@Composable
fun EDialog(title: String, onDismiss: () -> Unit, actions: @Composable RowScope.() -> Unit, content: @Composable ColumnScope.() -> Unit) {
    Dialog(onDismissRequest = onDismiss) {
        Column(Modifier.fillMaxWidth().background(Ink.White).border(2.dp, Ink.Black).padding(24.dp)) {
            Text(title, fontSize = 24.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(16.dp))
            content()
            Spacer(Modifier.height(20.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp, Alignment.End)) { actions() }
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

@Composable
fun NameField(value: String, onChange: (String) -> Unit) {
    BasicTextField(
        value = value,
        onValueChange = onChange,
        singleLine = true,
        textStyle = TextStyle(fontSize = 22.sp, color = Ink.Black),
        cursorBrush = SolidColor(Ink.Black),
        keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences),
        modifier = Modifier.fillMaxWidth().border(1.5.dp, Ink.Black).padding(12.dp),
    )
}

@Composable
fun ConfirmDialog(title: String, message: String, confirm: String, onDismiss: () -> Unit, onConfirm: () -> Unit) {
    EDialog(title, onDismiss, actions = {
        EButton("Cancel", onDismiss)
        EButton(confirm, onConfirm, selected = true)
    }) { Text(message, fontSize = 18.sp) }
}

/** One row in a list of choices; the current one shows a filled marker. */
@Composable
fun ChoiceRow(label: String, selected: Boolean, onClick: () -> Unit, sub: String? = null) {
    Row(Modifier.fillMaxWidth().tap(onClick = onClick).padding(vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.size(24.dp).border(2.dp, Ink.Black, androidx.compose.foundation.shape.CircleShape).padding(5.dp)) {
            if (selected) Box(Modifier.fillMaxSize().background(Ink.Black, androidx.compose.foundation.shape.CircleShape))
        }
        Spacer(Modifier.width(16.dp))
        Column {
            Text(label, fontSize = 20.sp)
            if (sub != null) Text(sub, fontSize = 15.sp, color = Ink.Grey)
        }
    }
}

@Composable
fun SwitchRow(label: String, checked: Boolean, onChange: (Boolean) -> Unit, sub: String? = null) {
    Row(Modifier.fillMaxWidth().tap { onChange(!checked) }.padding(vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
        Column(Modifier.weight(1f)) {
            Text(label, fontSize = 20.sp)
            if (sub != null) Text(sub, fontSize = 15.sp, color = Ink.Grey)
        }
        EButton(if (checked) "On" else "Off", { onChange(!checked) }, selected = checked, size = 64.dp)
    }
}
