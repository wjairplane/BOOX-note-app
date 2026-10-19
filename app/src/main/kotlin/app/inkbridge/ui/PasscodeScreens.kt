package app.inkbridge.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.inkbridge.AppLock
import app.inkbridge.PasscodeLock
import app.inkbridge.PinState
import kotlinx.coroutines.delay

// The passcode screens of the firmware (xofm.libs.pincode): the digit keyboard (01067f7f), the dialog page with its circles, show
// toggle, length choice and warning line (01068a3c), the unlock window (00eb6e53), the time-out window (00eb7583), the swipe slider
// (01067a0b) and the set / change / remove flow (01068715).

/** Firmware wording, one place so the tests can check it. */
object PasscodeText {
    const val ENTER = "Enter passcode"
    const val ENTER_YOURS = "Enter your passcode"
    const val ENTER_NEW = "Enter your new passcode"
    const val VERIFY_NEW = "Verify your new passcode"
    const val INCORRECT = "Incorrect passcode. Try again."
    const val FINAL_TRY = "Final attempt before you need to reset"
    const val RESET_REQUIRED = "A reset is required to unlock your device."
    const val TOO_MANY = "Too many attempts"
    const val RESET = "Reset passcode"
    const val TRY_AGAIN = "Try again"
    const val SWIPE = "Swipe to continue"
    const val UPDATED = "Your passcode has been updated"
    const val TURNED_OFF = "Your passcode is turned off"

    fun wait(minutes: Int) = if (minutes <= 1) "Wait 1 minute to try again, or reset passcode." else "Wait $minutes minutes to try again, or reset passcode."
    fun lengthLabel(n: Int) = when (n) { 4 -> "Four digits"; 6 -> "Six digits"; else -> "Eight digits" }
}

/** The swipe-to-continue slider that guards the reset: 112 px high, filled in five steps as the handle is dragged to the end. */
@Composable
fun AccidentalTouchSlider(onAccepted: () -> Unit, modifier: Modifier = Modifier) {
    val steps = 5
    var done by remember { mutableIntStateOf(0) }
    var accepted by remember { mutableStateOf(false) }
    Box(
        modifier.width(560.dp).height(112.dp).border(Rm.Outline, Ink.Black, CircleShape).semantics { contentDescription = PasscodeText.SWIPE }
            .pointerInput(Unit) {
                awaitEachGesture {
                    val down = awaitFirstDown(requireUnconsumed = false, pass = PointerEventPass.Initial)
                    if (accepted) return@awaitEachGesture
                    // A press has to start on the handle; leaving the bar sideways ends the try.
                    val handle = size.height + 0f
                    if (down.position.x > handle) return@awaitEachGesture
                    done = 0
                    while (true) {
                        val e = awaitPointerEvent(PointerEventPass.Initial)
                        val c = e.changes.firstOrNull() ?: break
                        if (!c.pressed) break
                        if (c.position.y < 0 || c.position.y > size.height) break
                        val reached = (c.position.x / (size.width / steps)).toInt()
                        if (reached > done) done = reached.coerceAtMost(steps)
                        if (done >= steps) { accepted = true; onAccepted(); break }
                    }
                    if (!accepted) done = 0
                }
            },
    ) {
        if (done == 0) Text(PasscodeText.SWIPE, style = RmText.Label, modifier = Modifier.align(Alignment.Center))
        val w = if (done == 0) 112.dp else (560.dp / steps) * done
        Box(Modifier.width(maxOf(w, 112.dp)).height(112.dp).background(Ink.Black, CircleShape), contentAlignment = Alignment.CenterEnd) {
            Canvas(Modifier.padding(end = 28.dp).size(48.dp)) {
                val s = size.width
                val p = Path().apply { moveTo(s * 0.2f, s * 0.5f); lineTo(s * 0.8f, s * 0.5f); moveTo(s * 0.55f, s * 0.25f); lineTo(s * 0.8f, s * 0.5f); lineTo(s * 0.55f, s * 0.75f) }
                drawPath(p, Color.White, style = Stroke(4f * density))
            }
        }
    }
}

/** The digit keys: 134 px cells with a 114 px ring (40 px digit), 36 px apart; the bottom row has 0 and the backspace. */
@Composable
fun PinKeyboard(onKey: (Char) -> Unit, onBackspace: () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(36.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        @Composable fun key(c: Char) {
            Box(Modifier.size(134.dp).tap { onKey(c) }.semantics { contentDescription = "$c" }, contentAlignment = Alignment.Center) {
                Box(Modifier.size(114.dp).border(Rm.Outline, Ink.Black, CircleShape), contentAlignment = Alignment.Center) {
                    Text("$c", style = RmText.sans(40, androidx.compose.ui.text.font.FontWeight.Bold, 1.2f))
                }
            }
        }
        for (row in listOf("123", "456", "789")) Row(horizontalArrangement = Arrangement.spacedBy(36.dp)) { row.forEach { key(it) } }
        Row(horizontalArrangement = Arrangement.spacedBy(36.dp)) {
            Spacer(Modifier.size(134.dp))
            key('0')
            Box(Modifier.size(134.dp).tap(onClick = onBackspace).semantics { contentDescription = "Backspace" }, contentAlignment = Alignment.Center) {
                Canvas(Modifier.size(48.dp)) {
                    val w = size.width; val h = size.height; val sw = 3f * density
                    val outline = Path().apply {
                        moveTo(w * 0.04f, h * 0.5f); lineTo(w * 0.3f, h * 0.18f); lineTo(w * 0.96f, h * 0.18f)
                        lineTo(w * 0.96f, h * 0.82f); lineTo(w * 0.3f, h * 0.82f); close()
                    }
                    drawPath(outline, Color.Black, style = Stroke(sw))
                    drawLine(Color.Black, Offset(w * 0.5f, h * 0.36f), Offset(w * 0.78f, h * 0.64f), sw)
                    drawLine(Color.Black, Offset(w * 0.78f, h * 0.36f), Offset(w * 0.5f, h * 0.64f), sw)
                }
            }
        }
    }
}

/**
 * The page every passcode screen shares: a serif [title], 160 px for a [description] or the length choice, the circles (48 px, filled
 * as digits are typed, with an eye to show them), 120 px for the warning, and the keyboard. The last digit is accepted after 100 ms so
 * it shows as pressed; [onAttempt] answers whether the entry was accepted (false shows [warning]). The entry is cleared either way.
 */
@Composable
fun PincodeDialogPage(
    title: String,
    length: Int,
    warning: () -> String,
    onAttempt: (String) -> Boolean,
    modifier: Modifier = Modifier,
    description: String = "",
    lengths: List<Int>? = null,
    onLength: (Int) -> Unit = {},
    warnInitially: Boolean = false,
    below: (@Composable () -> Unit)? = null,
) {
    var input by remember(length) { mutableStateOf("") }
    var showDigits by remember { mutableStateOf(false) }
    var warn by remember { mutableStateOf(warnInitially) }
    var pending by remember { mutableStateOf<String?>(null) }
    LaunchedEffect(pending) {
        val p = pending ?: return@LaunchedEffect
        delay(100)
        val ok = onAttempt(p)
        input = ""; warn = !ok; pending = null
    }
    // As in the firmware (PincodeDialogPage): the title at the top, the entry block centred on the screen, the action button at the bottom.
    Box(modifier.fillMaxSize()) {
        Text(title, style = RmText.TitleLg, textAlign = TextAlign.Center, modifier = Modifier.align(Alignment.TopCenter).padding(top = 48.dp, start = 48.dp, end = 48.dp))
        Column(Modifier.align(Alignment.Center).fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
            Box(Modifier.fillMaxWidth().height(160.dp), contentAlignment = Alignment.Center) {
                if (lengths != null) {
                    Box(Modifier.width(780.dp)) { SegmentedRow(lengths.map { PasscodeText.lengthLabel(it) }, lengths.indexOf(length).coerceAtLeast(0), { onLength(lengths[it]) }) }
                } else if (description.isNotEmpty()) Text(description, style = RmText.Body, textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 132.dp))
            }
            val rowWidth = (48 * length + 24 * (length - 1)).dp
            Box(Modifier.fillMaxWidth().height(48.dp), contentAlignment = Alignment.Center) {
                Row(horizontalArrangement = Arrangement.spacedBy(24.dp)) {
                    repeat(length) { i ->
                        val filled = input.length > i
                        Box(Modifier.size(48.dp).background(if (filled) Ink.Black else Ink.White, CircleShape).border(Rm.Outline, Ink.Black, CircleShape), contentAlignment = Alignment.Center) {
                            if (filled && showDigits) Text("${input[i]}", style = RmText.Label, color = Ink.White)
                        }
                    }
                }
                Box(
                    Modifier.offset(x = rowWidth / 2 + 56.dp).size(112.dp, 80.dp).tap { showDigits = !showDigits }.semantics { contentDescription = if (showDigits) "Hide passcode" else "Show passcode" },
                    contentAlignment = Alignment.Center,
                ) { if (showDigits) InkIcons.Eye() else InkIcons.EyeClosed() }
            }
            Box(Modifier.fillMaxWidth().height(120.dp), contentAlignment = Alignment.Center) {
                if (warn && input.isEmpty()) Text(warning(), style = RmText.Label, textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 132.dp))
            }
            PinKeyboard(
                onKey = { c ->
                    if (pending != null) return@PinKeyboard
                    if (input.length >= length) input = ""
                    input += c
                    if (input.length < length) warn = false else pending = input
                },
                onBackspace = { if (pending == null) input = input.dropLast(1) },
            )
        }
        below?.let { Box(Modifier.align(Alignment.BottomCenter).padding(bottom = 48.dp)) { it() } }
    }
}

/**
 * The window shown at start and after the app has been away: "Enter passcode", with the warnings of the lock-out ladder, and the time-out
 * window once too many wrong entries were made. Resetting erases everything ([onReset]), as the firmware's reset does.
 */
@Composable
fun UnlockScreen(lock: AppLock, onReset: () -> Unit) {
    val code = lock.passcode
    var tick by remember { mutableIntStateOf(0) }
    var confirmReset by remember { mutableStateOf(false) }
    // The remaining time is re-read every 10 s (and on a new attempt): one refresh of the e-ink panel each time.
    val timedOut = remember(tick) { code.state == PinState.TIMED_OUT }
    LaunchedEffect(timedOut) { while (timedOut) { delay(10_000); tick++ } }
    Box(Modifier.fillMaxSize().background(Ink.White).tap { }) {
        if (timedOut) TimedOutScreen(code, onReset = { confirmReset = true }, onTryAgain = { tick++ })
        else Column(Modifier.fillMaxSize()) {
            Box(Modifier.weight(1f)) {
                PincodeDialogPage(
                    title = PasscodeText.ENTER, length = code.passcodeLength,
                    warning = { when (code.state) { PinState.LOCKED -> PasscodeText.RESET_REQUIRED; PinState.FINAL_TRY -> PasscodeText.FINAL_TRY; else -> PasscodeText.INCORRECT } },
                    warnInitially = code.state == PinState.FINAL_TRY || code.state == PinState.LOCKED,
                    onAttempt = { attempt ->
                        val ok = code.verify(attempt)
                        if (ok) lock.unlock() else tick++
                        ok
                    },
                    below = if (code.state == PinState.LOCKED) ({ EButton(PasscodeText.RESET, { confirmReset = true }, Modifier.width(432.dp)) }) else null,
                )
            }
        }
        if (confirmReset) ConfirmDialog(
            "Reset device", "This action will delete all files on the device and restore your device settings to their original state.", "Confirm reset",
            onDismiss = { confirmReset = false }, onConfirm = { confirmReset = false; onReset() },
        )
    }
}

/** "Too many attempts": the padlock, the minutes to wait, a 300 px progress bar, and Try again / Reset passcode behind the slider. */
@Composable
private fun TimedOutScreen(code: PasscodeLock, onReset: () -> Unit, onTryAgain: () -> Unit) {
    val remaining = code.lockRemainingMs()
    val total = code.lockTotalMs().coerceAtLeast(1L)
    var accepted by remember { mutableStateOf(false) }
    Box(Modifier.fillMaxSize()) {
        Column(Modifier.fillMaxSize().padding(horizontal = 176.dp).padding(top = 240.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
            InkIcons.Padlock(size = 96.dp)
            Text(PasscodeText.TOO_MANY, style = RmText.TitleLg, textAlign = TextAlign.Center)
            Text(PasscodeText.wait(Math.ceil(remaining / 60_000.0).toInt()), style = RmText.Body, textAlign = TextAlign.Center)
            Spacer(Modifier.height(80.dp))
            // 300 x 10 px: a 1 px baseline with the elapsed share filled in black.
            Box(Modifier.width(300.dp).height(10.dp)) {
                Box(Modifier.align(Alignment.BottomStart).fillMaxWidth().height(1.dp).background(Ink.Black))
                Box(Modifier.fillMaxHeight().fillMaxWidth((remaining.toFloat() / total).coerceIn(0f, 1f)).background(Ink.Black))
            }
        }
        Box(Modifier.align(Alignment.BottomCenter).padding(bottom = 120.dp)) {
            if (!accepted) AccidentalTouchSlider({ accepted = true })
            else Row(horizontalArrangement = Arrangement.spacedBy(24.dp)) {
                if (remaining == 0L) EButton(PasscodeText.TRY_AGAIN, onTryAgain)
                EButton(PasscodeText.RESET, onReset)
            }
        }
    }
}

/**
 * Set, change or remove the passcode (SetPasscode): verify the current one first when there is one, then the new one twice, with the
 * length chosen on the first entry. [onDone] gets the notification the firmware shows afterwards.
 */
@Composable
fun SetPasscodeScreen(code: PasscodeLock, remove: Boolean, onDone: (String) -> Unit, onCancel: () -> Unit) {
    BackHandler(onBack = onCancel)
    var old by remember { mutableStateOf<String?>(null) }
    var first by remember { mutableStateOf<String?>(null) }
    var chosen by remember { mutableIntStateOf(code.passcodeLength) }
    val verifying = code.hasPasscode && old == null
    Column(Modifier.fillMaxSize().background(Ink.White)) {
        NavigationBar("", onBack = onCancel)
        PincodeDialogPage(
            title = when { verifying -> PasscodeText.ENTER_YOURS; first == null -> PasscodeText.ENTER_NEW; else -> PasscodeText.VERIFY_NEW },
            length = if (verifying) code.passcodeLength else chosen,
            warning = { PasscodeText.INCORRECT },
            lengths = if (!verifying && first == null && !remove) PasscodeLock.LENGTHS else null,
            onLength = { chosen = it },
            onAttempt = { attempt ->
                when {
                    remove -> code.remove(attempt).also { if (it) onDone(PasscodeText.TURNED_OFF) }
                    verifying -> code.verify(attempt).also { if (it) old = attempt }
                    first == null -> { first = attempt; true }
                    first == attempt -> { val ok = code.set(old, attempt); if (ok) onDone(PasscodeText.UPDATED); ok }
                    else -> { first = null; false }
                }
            },
        )
    }
}
