package app.inkbridge.ui

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.provider.Settings
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import app.inkbridge.AppController
import app.inkbridge.BuildConfig
import app.inkbridge.PasscodeLock
import kotlinx.coroutines.delay
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

// Settings pages after the firmware: Battery (`00d98d51`), System time (`0102618e`), Software (`00e2e7cc`), Security (`00d9569b`, with the
// passcode panel `00eb7947`) and the Handedness panel of Accessibility (`00d94a01`, `00d97445`).

/** What Android reports about the battery. */
data class BatteryInfo(
    val percent: Int, val status: Int, val plugged: Int, val health: Int,
    /** Degrees Celsius, or null when the device does not say. */
    val temperature: Float?,
    /** Volts, or null. */
    val voltage: Float?,
) {
    val statusText: String get() = when (status) {
        BatteryManager.BATTERY_STATUS_CHARGING -> "Charging"
        BatteryManager.BATTERY_STATUS_DISCHARGING -> "Discharging"
        BatteryManager.BATTERY_STATUS_FULL -> "Full"
        BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "Not charging"
        else -> "Unknown"
    }
    val sourceText: String get() = when {
        plugged and BatteryManager.BATTERY_PLUGGED_WIRELESS != 0 -> "Wireless"
        plugged and BatteryManager.BATTERY_PLUGGED_AC != 0 -> "AC adapter"
        plugged and BatteryManager.BATTERY_PLUGGED_USB != 0 -> "USB"
        else -> "Battery"
    }
    val healthText: String get() = when (health) {
        BatteryManager.BATTERY_HEALTH_GOOD -> "Good"
        BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheated"
        BatteryManager.BATTERY_HEALTH_DEAD -> "Dead"
        BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "Over voltage"
        BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> "Failure"
        BatteryManager.BATTERY_HEALTH_COLD -> "Cold"
        else -> "Unknown"
    }

    companion object {
        fun from(i: Intent?): BatteryInfo {
            val level = i?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = i?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100
            val temp = i?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, Int.MIN_VALUE) ?: Int.MIN_VALUE
            val volt = i?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 0) ?: 0
            return BatteryInfo(
                percent = if (level < 0 || scale <= 0) 100 else level * 100 / scale,
                status = i?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1,
                plugged = i?.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0) ?: 0,
                health = i?.getIntExtra(BatteryManager.EXTRA_HEALTH, -1) ?: -1,
                temperature = temp.takeIf { it != Int.MIN_VALUE }?.let { it / 10f },
                voltage = volt.takeIf { it > 0 }?.let { it / 1000f },
            )
        }
    }
}

@Composable
private fun rememberBatteryInfo(): BatteryInfo {
    val context = LocalContext.current
    var info by remember { mutableStateOf(BatteryInfo.from(context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED)))) }
    DisposableEffect(context) {
        val receiver = object : BroadcastReceiver() { override fun onReceive(c: Context, i: Intent) { info = BatteryInfo.from(i) } }
        context.registerReceiver(receiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        onDispose { runCatching { context.unregisterReceiver(receiver) } }
    }
    return info
}

/** Battery: the level with the firmware's five-bar icon, then what Android knows. (The firmware's Standby and Power off are the device's own.) */
@Composable
fun BatteryPage() {
    val b = rememberBatteryInfo()
    Row(Modifier.fillMaxWidth().padding(vertical = 8.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("Battery", style = RmText.LabelLg, modifier = Modifier.weight(1f))
        Text("${b.percent} %", style = RmText.LabelLg)
        BatteryIndicator(b.percent, highlighted = b.percent <= 10)
    }
    CellList {
        CellRow("Status", b.statusText)
        CellRow("Power source", b.sourceText)
        CellRow("Health", b.healthText, divider = b.temperature != null || b.voltage != null)
        b.temperature?.let { CellRow("Temperature", String.format(Locale.US, "%.1f °C", it), divider = b.voltage != null) }
        b.voltage?.let { CellRow("Voltage", String.format(Locale.US, "%.2f V", it), divider = false) }
    }
}

/** System time: the clock, a button to Android's date and time settings, and the zone and formats in use. */
@Composable
fun SystemTimePage() {
    val context = LocalContext.current
    var now by remember { mutableStateOf(Date()) }
    LaunchedEffect(Unit) { while (true) { delay(30_000); now = Date() } }
    val date = remember { DateFormat.getDateInstance(DateFormat.MEDIUM) }
    val time = remember { DateFormat.getTimeInstance(DateFormat.SHORT) }
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        InkIcons.SystemClock()
        Text("${date.format(now)} ${time.format(now)}", style = RmText.LabelLg, modifier = Modifier.weight(1f))
        EButton("Set date and time", { runCatching { context.startActivity(Intent(Settings.ACTION_DATE_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)) } })
    }
    val zone = TimeZone.getDefault()
    CellList {
        CellRow("Time zone", "${zone.id} (${offsetText(zone.getOffset(now.time))})")
        CellRow("Date format", (DateFormat.getDateInstance(DateFormat.SHORT) as? SimpleDateFormat)?.toPattern() ?: "-")
        CellRow("Time format", if (android.text.format.DateFormat.is24HourFormat(context)) "24-hour" else "12-hour", divider = false)
    }
}

/** "UTC+02:00" for an offset in milliseconds. */
fun offsetText(ms: Int): String {
    val minutes = ms / 60_000
    val sign = if (minutes < 0) "-" else "+"
    return String.format(Locale.US, "UTC%s%02d:%02d", sign, Math.abs(minutes) / 60, Math.abs(minutes) % 60)
}

/** Software: the app and Android versions. There is no update flow here: the app comes from wherever it was installed. */
@Composable
fun SoftwarePage() {
    CellList {
        CellRow("Version", BuildConfig.VERSION_NAME)
        CellRow("Build", BuildConfig.VERSION_CODE.toString(), divider = false)
    }
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text("About this device", style = RmText.LabelLg)
        CellList {
            CellRow("Model number", listOf(android.os.Build.MANUFACTURER, android.os.Build.MODEL).filter { it.isNotBlank() }.distinctBy { it.lowercase() }.joinToString(" "))
            CellRow("Android", "${android.os.Build.VERSION.RELEASE} (API ${android.os.Build.VERSION.SDK_INT})")
            android.os.Build.VERSION.SECURITY_PATCH.takeIf { it.isNotBlank() }?.let { CellRow("Security patch", it) }
            CellRow("Build number", android.os.Build.DISPLAY, divider = false)
        }
    }
}

/** Security: the passcode panel (a toggle, and "Change passcode" with one dash per digit once it is on). */
@Composable
fun SecurityPage(code: PasscodeLock, onSet: () -> Unit, onRemove: () -> Unit) {
    // Re-read after the full-screen flows return.
    val has = code.hasPasscode
    SwitchRow("Passcode", has, { if (has) onRemove() else onSet() }, "Protect your notebooks and documents with a code.")
    if (has) CellList { CellRow("Change passcode", "-".repeat(code.passcodeLength), onSet, divider = false) }
}

/** Handedness: Left or Right, each a tile with a sketch of the screen that shows where the toolbar starts. */
@Composable
fun HandednessChooser(rightHanded: Boolean, onChange: (Boolean) -> Unit) {
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(48.dp, Alignment.CenterHorizontally)) {
        for (right in listOf(false, true)) {
            val selected = right == rightHanded
            val label = if (right) "Right" else "Left"
            Column(Modifier.tap { onChange(right) }.semantics { contentDescription = "$label hand" }, horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Box(Modifier.size(200.dp, 260.dp).border(if (selected) 6.dp else Rm.Outline, Ink.Black)) {
                    Canvas(Modifier.fillMaxSize().padding(32.dp)) {
                        val d = density
                        // The screen, the toolbar on the writing hand's opposite side, and a few lines of writing.
                        drawRect(Color.Black, Offset.Zero, size, style = Stroke(3f * d))
                        val bar = 20f * d
                        drawRect(Color.Black, Offset(if (right) 0f else size.width - bar, 0f), Size(bar, size.height))
                        val x0 = (if (right) bar else 0f) + 16f * d
                        val x1 = (if (right) size.width else size.width - bar) - 16f * d
                        for (k in 1..4) drawLine(Color.Black, Offset(x0, size.height * k / 5.5f), Offset(x1, size.height * k / 5.5f), 3f * d)
                    }
                }
                Text(label, style = if (selected) RmText.LabelLgStrong else RmText.LabelLg)
            }
        }
    }
}

/** Accessibility > Handedness: the label and description, then the chooser. */
@Composable
fun HandednessPanel(app: AppController) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text("Handedness", style = RmText.LabelLg)
        Text("Choose the hand you prefer to write and draw with.", style = RmText.Body)
        Spacer(Modifier.height(16.dp))
        HandednessChooser(app.prefs.rightHanded) { app.prefs.setRightHanded(it) }
    }
}
