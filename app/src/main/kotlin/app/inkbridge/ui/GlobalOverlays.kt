package app.inkbridge.ui

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.os.BatteryManager
import android.provider.Settings
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import app.inkbridge.AppController
import app.inkbridge.R
import app.inkbridge.Screen
import app.inkbridge.rm.library.Library
import app.inkbridge.rm.library.LibraryEntry
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext

// The panels the firmware opens with gestures from any screen: quick settings (swipe down from the top-right corner) and the
// document drawer (two fingers down from the top edge); and the notebook's quick browse (swipe up from the bottom edge).

/** The panels that float over every screen. */
enum class Overlay { QUICK_SETTINGS, DRAWER }

/** Battery level and charging state, kept current while the caller is on screen. */
@Composable
internal fun rememberBattery(): Pair<Int, Boolean> {
    val context = LocalContext.current
    var state by remember { mutableStateOf(readBattery(context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED)))) }
    DisposableEffect(context) {
        val receiver = object : android.content.BroadcastReceiver() {
            override fun onReceive(c: Context, i: Intent) { state = readBattery(i) }
        }
        context.registerReceiver(receiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        onDispose { runCatching { context.unregisterReceiver(receiver) } }
    }
    return state
}

private fun readBattery(i: Intent?): Pair<Int, Boolean> {
    val level = i?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
    val scale = i?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100
    val status = i?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
    val charging = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
    return (if (level < 0 || scale <= 0) 100 else level * 100 / scale) to charging
}

/**
 * The firmware's battery icon: a 2 px outline with five 4 x 12 px bars (4 px apart), a notch on the right, and inverted
 * (black with white bars) when [highlighted] (10 % or less).
 */
@Composable
fun BatteryIndicator(percent: Int, highlighted: Boolean = percent <= 10, modifier: Modifier = Modifier) {
    val bars = if (percent < 5) 0 else minOf(5, Math.ceil(percent / 20.0).toInt())
    Canvas(modifier.size(50.dp, 22.dp)) {
        val d = density
        val body = Size(48f * d, 22f * d)
        val border = 2f * d
        if (highlighted) drawRect(Color.Black, Offset.Zero, body)
        else drawRect(Color.Black, Offset.Zero, body, style = androidx.compose.ui.graphics.drawscope.Stroke(border))
        val fill = if (highlighted) Color.White else Color.Black
        val x0 = border + 4f * d; val y0 = border + 3f * d
        if (percent < 5) drawRect(fill, Offset(x0, y0 + 0f), Size(2f * d, 12f * d))
        for (i in 0 until bars) drawRect(fill, Offset(x0 + i * 8f * d, y0), Size(4f * d, 12f * d))
        drawRect(Color.Black, Offset(48f * d, 7f * d), Size(2f * d, 8f * d))
    }
}

/**
 * The quick settings panel (xochitl `00e31b12`): hugs the top-right corner with a 2 px border on its left and bottom; a 120 px battery
 * row (percentage, the five-bar icon; press and hold opens the battery settings), then a grid of 112 px icon toggles with 48 px side
 * padding. Anything outside it closes it.
 */
@Composable
fun QuickSettingsPanel(app: AppController, onClose: () -> Unit, onRefresh: () -> Unit) {
    val context = LocalContext.current
    val (percent, charging) = rememberBattery()
    fun open(intent: Intent) { runCatching { context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)) } }
    Box(Modifier.fillMaxSize().tap(onClick = onClose)) {
        Column(Modifier.align(Alignment.TopEnd).background(Ink.White).tap { }.drawBehind2(left = true, bottom = true).padding(horizontal = 48.dp)) {
            Row(
                Modifier.fillMaxWidth().height(Rm.NavigationHeader).pointerInput(Unit) {
                    detectTapGestures(onTap = { onClose() }, onLongPress = { onClose(); open(Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS)) })
                },
                verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.End,
            ) {
                Text(if (charging) "$percent %  +" else "$percent %", style = RmText.Label, modifier = Modifier.padding(end = 16.dp))
                BatteryIndicator(percent)
            }
            Rule()
            Spacer(Modifier.height(32.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(32.dp), modifier = Modifier.padding(bottom = 48.dp)) {
                @Composable fun toggle(label: String, on: () -> Unit, icon: @Composable (Color) -> Unit) {
                    Box(Modifier.size(Rm.ToolButton).border(Rm.Outline, Ink.Black).tap(onClick = on).semantics { contentDescription = label }, contentAlignment = Alignment.Center) { icon(Ink.Black) }
                }
                toggle("Wi-Fi", {
                    onClose()
                    open(if (android.os.Build.VERSION.SDK_INT >= 29) Intent(Settings.Panel.ACTION_INTERNET_CONNECTIVITY) else Intent(Settings.ACTION_WIFI_SETTINGS))
                }) { Image(painterResource(R.drawable.rm_wifi_3), null, Modifier.size(Rm.Icon), colorFilter = ColorFilter.tint(it)) }
                toggle("Refresh screen", { onClose(); onRefresh() }) { InkIcons.Refresh(tint = it) }
                toggle("Settings", { onClose(); app.screen = Screen.Settings }) { InkIcons.Cog(tint = it) }
            }
        }
    }
}

/** A 2 px black border on the chosen sides (the firmware's panels hug the screen edge, so only the inner sides have one). */
private fun Modifier.drawBehind2(left: Boolean = false, bottom: Boolean = false): Modifier = this.then(
    Modifier.drawBehind {
        val t = 2f * density
        if (left) drawRect(Color.Black, Offset.Zero, Size(t, size.height))
        if (bottom) drawRect(Color.Black, Offset(0f, size.height - t), Size(size.width, t))
    },
)

/**
 * The document drawer (xochitl `00cbcb2c`): a sheet hanging from the top edge with Recent and Favorites tabs, a single row of thumbnails
 * (4 across, the next ones peeking in at the sides, stepping a page at a time) and a 4 px black line. Tapping a document opens it;
 * tapping below the sheet closes it.
 */
@Composable
fun DocumentDrawer(app: AppController, activeId: String?, onClose: () -> Unit) {
    var tab by remember { mutableIntStateOf(0) }
    val docs = app.library.entries.filter { !it.isFolder && it.parentId != Library.TRASH && it.id != activeId }
    val shown = (if (tab == 0) docs.sortedByDescending { it.lastModified } else docs.filter { it.pinned }.sortedByDescending { it.lastModified }).take(12)
    Box(Modifier.fillMaxSize().tap(onClick = onClose)) {
        Column(Modifier.align(Alignment.TopCenter).fillMaxWidth().background(Ink.White).tap { }) {
            Row(Modifier.fillMaxWidth()) {
                listOf("Recent", "Favorites").forEachIndexed { i, label ->
                    Box(Modifier.width(230.dp).height(Rm.ToolButton).tap { tab = i }.semantics { contentDescription = label }, contentAlignment = Alignment.Center) {
                        Text(label, style = if (tab == i) RmText.LabelLgStrong else RmText.LabelLg)
                        Box(Modifier.align(Alignment.BottomCenter).fillMaxWidth().height(if (tab == i) 6.dp else 2.dp).background(Ink.Black))
                    }
                }
                Box(Modifier.weight(1f).height(Rm.ToolButton)) { Box(Modifier.align(Alignment.BottomCenter).fillMaxWidth().height(2.dp).background(Ink.Black)) }
            }
            Spacer(Modifier.height(20.dp))
            androidx.compose.foundation.layout.BoxWithConstraints(Modifier.fillMaxWidth()) {
                val full = maxWidth
                val visible = Math.ceil(((full.value - 342f * 0.4f * 1.2f) / 342f).toDouble()).toInt().coerceAtLeast(1)
                val cellW = (full.value / (visible + 0.4f)).dp
                val cellH = (cellW.value * 510f / 342f).dp
                Box(Modifier.fillMaxWidth().height(cellH + 32.dp), contentAlignment = Alignment.Center) {
                    if (shown.isEmpty()) Text(if (tab == 0) "No recent documents" else "No favorited documents", style = RmText.BodyLg, textAlign = TextAlign.Center)
                    else {
                        val state = androidx.compose.foundation.lazy.rememberLazyListState()
                        LazyRow(Modifier.fillMaxSize(), state = state, flingBehavior = androidx.compose.foundation.gestures.snapping.rememberSnapFlingBehavior(state), contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = cellW * 0.2f, vertical = 16.dp)) {
                            items(shown, key = { it.id }) { e ->
                                Column(Modifier.width(cellW).padding(15.dp).tap { onClose(); app.screen = Screen.Notebook(e.id, 0) }.semantics { contentDescription = e.name }) {
                                    Thumb(app, e, Modifier.fillMaxWidth().aspectRatio(312f / 416f))
                                    Text(e.name, style = RmText.Label, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.padding(top = 8.dp))
                                    Text("${e.pageIds.size} pages", style = RmText.Caption, maxLines = 1)
                                }
                            }
                        }
                    }
                }
            }
            Box(Modifier.fillMaxWidth().height(4.dp).background(Ink.Black))
        }
    }
}

/**
 * Quick browse: the page slider at the bottom of the document. Dragging along it chooses a page, shown as a thumbnail
 * above the handle; lifting the finger opens that page. It closes after four seconds, or on a tap outside it.
 */
@Composable
fun PageSlider(app: AppController, doc: LibraryEntry, current: Int, bottomInset: androidx.compose.ui.unit.Dp, startInset: androidx.compose.ui.unit.Dp, endInset: androidx.compose.ui.unit.Dp, onPick: (Int) -> Unit, onClose: () -> Unit) {
    val last = (doc.pageIds.size - 1).coerceAtLeast(0)
    var picked by remember { mutableIntStateOf(current.coerceIn(0, last)) }
    var pressed by remember { mutableStateOf(false) }
    var size by remember { mutableStateOf(IntSize.Zero) }
    LaunchedEffect(pressed, picked) { if (!pressed) { delay(4000); onClose() } }
    Box(Modifier.fillMaxSize().tap(onClick = onClose)) {
        Column(
            Modifier.align(Alignment.BottomCenter).padding(bottom = 50.dp + bottomInset, start = 48.dp + startInset, end = 48.dp + endInset).fillMaxWidth()
                .background(Ink.White).border(Rm.Outline, Ink.Black).tap { }.padding(horizontal = 40.dp, vertical = 16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(doc.name, style = RmText.LabelLg, maxLines = 2, overflow = TextOverflow.Ellipsis, textAlign = TextAlign.Center, modifier = Modifier.padding(vertical = 16.dp))
            if (pressed) {
                Row(horizontalArrangement = Arrangement.spacedBy(24.dp), verticalAlignment = Alignment.Bottom, modifier = Modifier.padding(bottom = 16.dp)) {
                    for (p in listOf(picked - 1, picked, picked + 1)) {
                        if (p < 0 || p > last) { Spacer(Modifier.width(if (p == picked) 240.dp else 160.dp)); continue }
                        val bmp by produceState<Bitmap?>(null, doc.id, p, doc.lastModified) {
                            value = withContext(Dispatchers.IO) { runCatching { app.thumbnails.render(doc, p, 300) }.getOrNull() }
                        }
                        Box(Modifier.width(if (p == picked) 240.dp else 160.dp).aspectRatio(0.75f).border(if (p == picked) 4.dp else 2.dp, Ink.Black).background(Ink.White)) {
                            bmp?.let { Image(it.asImageBitmap(), null, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize()) }
                        }
                    }
                }
            }
            Text("${picked + 1} of ${last + 1}", style = RmText.Label, modifier = Modifier.padding(bottom = 8.dp))
            // The track: a 2 px line with a round handle that follows the finger.
            Box(
                Modifier.fillMaxWidth().height(80.dp).onSizeChanged { size = it }.pointerInput(last) {
                    awaitEachGesture {
                        val down = awaitFirstDown()
                        pressed = true
                        fun at(x: Float) { val w = size.width.toFloat().coerceAtLeast(1f); picked = ((x / w) * last + 0.5f).toInt().coerceIn(0, last) }
                        at(down.position.x)
                        while (true) {
                            val ev = awaitPointerEvent()
                            val c = ev.changes.firstOrNull() ?: break
                            at(c.position.x); c.consume()
                            if (!c.pressed) break
                        }
                        pressed = false
                        onPick(picked)
                    }
                }.semantics { contentDescription = "Page slider" },
                contentAlignment = Alignment.CenterStart,
            ) {
                Box(Modifier.fillMaxWidth().height(2.dp).background(Ink.Black))
                val frac = if (last == 0) 0f else picked.toFloat() / last
                val handle = 56.dp
                Box(Modifier.padding(start = ((size.width / androidx.compose.ui.platform.LocalDensity.current.density - handle.value) * frac).dp).size(handle).clip(CircleShape).background(Ink.Black))
            }
        }
    }
}


/**
 * The zoom button: a white, borderless button showing the fit icon and the zoom level ("1.5x"); a tap snaps back to the whole page.
 */
@Composable
fun ZoomButton(zoom: Float, mode: String?, onReset: () -> Unit, modifier: Modifier = Modifier) {
    Row(
        modifier.height(Rm.ToolButton).background(Ink.White).tap(onClick = onReset).padding(horizontal = 40.dp).semantics { contentDescription = "Reset zoom" },
        verticalAlignment = Alignment.CenterVertically,
    ) {
        when (mode) {
            "height" -> InkIcons.FitToHeight()
            "custom" -> InkIcons.FitCustom()
            else -> InkIcons.FitToWidth()
        }
        Spacer(Modifier.width(16.dp))
        Text(String.format(java.util.Locale.US, "%.1fx", zoom), style = RmText.LabelLg)
    }
}

/** The low-battery warning shown at the top right of a document when the charge is 10 % or less and not charging. */
@Composable
fun LowBatteryIndicator(modifier: Modifier = Modifier, onClick: () -> Unit = {}) {
    val (percent, charging) = rememberBattery()
    if (percent > 10 || charging) return
    Row(modifier.background(Ink.White).tap(onClick = onClick).padding(8.dp), verticalAlignment = Alignment.CenterVertically) {
        Text("$percent%", style = RmText.Label, modifier = Modifier.padding(end = 12.dp))
        BatteryIndicator(percent)
    }
}
