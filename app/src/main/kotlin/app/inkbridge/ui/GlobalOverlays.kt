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
import androidx.compose.foundation.layout.offset
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
 * The quick settings panel (xochitl `00e31b12`): flush to the top-right corner, white with a 2 px border on its left and bottom edges,
 * 48 px side margins and a 48 px spacer at the bottom. A 120 px battery row (charge as "NN %", a bolt while charging, the five-bar icon;
 * press and hold opens the battery settings) over a divider; the Wi-Fi line (network or "No Wi-Fi" and a signal icon, 80 px high; hold
 * opens the Wi-Fi settings); then a grid of 112 px toggles 32 px apart: Flight mode (hold opens the app's settings, as in the firmware)
 * and a screen refresh in the place of the firmware's Screen share. A tap anywhere closes it.
 */
@Composable
fun QuickSettingsPanel(app: AppController, onClose: () -> Unit, onRefresh: () -> Unit) {
    val context = LocalContext.current
    val (percent, charging) = rememberBattery()
    val connectivity = remember { context.getSystemService(Context.CONNECTIVITY_SERVICE) as? android.net.ConnectivityManager }
    val wifiOn = remember {
        runCatching { connectivity?.getNetworkCapabilities(connectivity.activeNetwork)?.hasTransport(android.net.NetworkCapabilities.TRANSPORT_WIFI) == true }.getOrDefault(false)
    }
    val airplane = remember { runCatching { Settings.Global.getInt(context.contentResolver, Settings.Global.AIRPLANE_MODE_ON, 0) == 1 }.getOrDefault(false) }
    fun open(intent: Intent) { runCatching { context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)) } }
    val wifiSettings = if (android.os.Build.VERSION.SDK_INT >= 29) Intent(Settings.Panel.ACTION_INTERNET_CONNECTIVITY) else Intent(Settings.ACTION_WIFI_SETTINGS)
    Box(Modifier.fillMaxSize().pointerInput(Unit) { detectTapGestures(onTap = { onClose() }) }) {
        Column(Modifier.align(Alignment.TopEnd).width(352.dp).background(Ink.White).drawBehind2(left = true, bottom = true).padding(horizontal = 48.dp)) {
            // Battery.
            Row(
                Modifier.fillMaxWidth().height(Rm.NavigationHeader).pointerInput(Unit) {
                    detectTapGestures(onTap = { onClose() }, onLongPress = { onClose(); open(Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS)) })
                },
                verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.End,
            ) {
                if (charging) Image(painterResource(R.drawable.rm_lightning_fill), null, Modifier.size(32.dp), colorFilter = ColorFilter.tint(Ink.Black))
                Text("$percent %", style = RmText.Label, modifier = Modifier.padding(horizontal = 12.dp))
                BatteryIndicator(percent)
            }
            Rule()
            // Wi-Fi.
            Row(
                Modifier.fillMaxWidth().height(Rm.Control).pointerInput(Unit) {
                    detectTapGestures(onTap = { onClose() }, onLongPress = { onClose(); open(wifiSettings) })
                },
                verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                Text(if (wifiOn) "Wi-Fi" else "No Wi-Fi", style = RmText.Label, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f))
                Image(painterResource(if (wifiOn) R.drawable.rm_wifi_3 else R.drawable.rm_wifi_off), null, Modifier.size(Rm.Icon), colorFilter = ColorFilter.tint(Ink.Black))
            }
            // Toggles.
            Spacer(Modifier.height(32.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(32.dp)) {
                @Composable fun toggle(label: String, selected: Boolean, onClick: () -> Unit, onHold: (() -> Unit)? = null, icon: @Composable (Color) -> Unit) {
                    val fg = if (selected) Ink.White else Ink.Black
                    Box(
                        Modifier.size(Rm.ToolButton).background(if (selected) Ink.Black else Ink.White).border(Rm.Outline, Ink.Black)
                            .pointerInput(Unit) { detectTapGestures(onTap = { onClick() }, onLongPress = { onHold?.invoke() ?: onClick() }) }
                            .semantics { contentDescription = label },
                        contentAlignment = Alignment.Center,
                    ) { icon(fg) }
                }
                toggle("Flight mode", airplane, onClick = { open(Intent(Settings.ACTION_AIRPLANE_MODE_SETTINGS)); onClose() }, onHold = { onClose(); app.screen = Screen.Settings }) {
                    Image(painterResource(if (airplane) R.drawable.rm_airplane_fill else R.drawable.rm_airplane), null, Modifier.size(Rm.Icon), colorFilter = ColorFilter.tint(it))
                }
                toggle("Refresh screen", false, onClick = { onClose(); onRefresh() }) { InkIcons.Refresh(tint = it) }
            }
            Spacer(Modifier.height(48.dp))
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
    val shown = (if (tab == 0) docs.sortedByDescending { maxOf(it.lastOpened, 0L) } else docs.filter { it.pinned }.sortedByDescending { it.lastModified }).take(12)
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
                                    Text("Page ${(e.lastOpenedPage + 1).coerceIn(1, e.pageIds.size.coerceAtLeast(1))} of ${e.pageIds.size}", style = RmText.Caption, maxLines = 1)
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
 * Quick browse: the firmware's page slider (xochitl `00d85fe4`, placed by `00d9fd92` and `00da96df`). A 100 px strip 50 px above the
 * bottom edge on a white band, with a pill-shaped 8 px groove, an 18 px black dot where the document was when it opened and a 35 px
 * ringed circle on the current page. Pressing or dragging along it picks a page and shows one monochrome thumbnail above it with
 * "Page N" under it; lifting the finger opens that page, dragging more than 200 px above the strip cancels. The document title
 * hangs from the top. It closes 4 s after the finger lifts, or on any press outside it.
 */
@Composable
fun PageSlider(
    app: AppController, doc: LibraryEntry, current: Int, portrait: Boolean,
    bottomExtra: androidx.compose.ui.unit.Dp, startInset: androidx.compose.ui.unit.Dp, endInset: androidx.compose.ui.unit.Dp, topInset: androidx.compose.ui.unit.Dp,
    onPick: (Int) -> Unit, onClose: () -> Unit,
) {
    val density = androidx.compose.ui.platform.LocalDensity.current
    val n = doc.pageIds.size.coerceAtLeast(1)
    val last = n - 1
    val opened = remember { current.coerceIn(0, last) }
    var value by remember { mutableIntStateOf(opened) }
    var shown by remember { mutableIntStateOf(opened) } // where the ringed circle sits (the current page; moves after a cancelled drag)
    var pressed by remember { mutableStateOf(false) }
    var thumbnail by remember { mutableStateOf(false) }
    var stripWidth by remember { mutableStateOf(0) }
    LaunchedEffect(pressed) { if (!pressed) { delay(4000); onClose() } }

    fun pageAt(xPx: Float): Int {
        val inset = with(density) { 80.dp.toPx() }
        val track = (stripWidth - 2 * inset).coerceAtLeast(1f)
        var page = (((xPx - inset) / track) * last).let { Math.round(it) }.coerceIn(0, last)
        // Beyond 50 pages the previous location and the current page act as magnets (a page within pageCount / 40 snaps to them).
        if (last > 49 && page != 0 && page != last) {
            val threshold = n / 40
            if (threshold > 1) for (target in listOf(opened, shown)) if (kotlin.math.abs(page - target) < threshold) { page = target; break }
        }
        return page
    }

    val bottom = 50.dp + bottomExtra
    Box(
        Modifier.fillMaxSize().pointerInput(Unit) {
            // A press anywhere else closes the slider (and still reaches whatever is underneath).
            awaitEachGesture {
                val down = awaitFirstDown(requireUnconsumed = false, pass = androidx.compose.ui.input.pointer.PointerEventPass.Initial)
                val h = size.height.toFloat()
                val sliderTop = h - with(density) { (bottom + 100.dp).toPx() }
                val bandTop = sliderTop - with(density) { 100.dp.toPx() }
                if (down.position.y < bandTop || down.position.y < 0f) onClose()
            }
        },
    ) {
        // The white band under the slider and its labels, and the title at the top.
        Box(Modifier.align(Alignment.BottomCenter).fillMaxWidth().height(bottom + 200.dp).background(Ink.White))
        Box(Modifier.align(Alignment.TopCenter).padding(top = topInset).fillMaxWidth().height(Rm.ToolButton).background(Ink.White), contentAlignment = Alignment.Center) {
            Text(doc.name, style = RmText.LabelLg, maxLines = 2, overflow = TextOverflow.Ellipsis, textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 112.dp))
        }

        if (pressed && thumbnail) {
            androidx.compose.foundation.layout.BoxWithConstraints(Modifier.align(Alignment.BottomCenter).padding(start = startInset, end = endInset).fillMaxWidth().fillMaxHeight()) {
                val height = minOf(if (portrait) 820.dp else 615.dp, maxHeight - 400.dp)
                val bmp by produceState<Bitmap?>(null, doc.id, value, doc.lastModified) {
                    this.value = withContext(Dispatchers.IO) { runCatching { app.thumbnails.render(doc, value, 640) }.getOrNull() }
                }
                Box(Modifier.align(Alignment.BottomCenter).padding(bottom = bottom + 200.dp).height(height).aspectRatio(0.75f).background(Ink.White).border(2.dp, Ink.Black).padding(2.dp)) {
                    bmp?.let { Image(it.asImageBitmap(), null, contentScale = ContentScale.Crop, colorFilter = ColorFilter.colorMatrix(androidx.compose.ui.graphics.ColorMatrix().apply { setToSaturation(0f) }), modifier = Modifier.fillMaxSize()) }
                }
                Text("Page ${value + 1}", style = RmText.LabelLg, textAlign = TextAlign.Center, modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = bottom + 100.dp).width(120.dp))
            }
        }

        // The strip: 100 px high, with 80 px of margin each side before the track.
        Box(
            Modifier.align(Alignment.BottomCenter).padding(bottom = bottom, start = startInset, end = endInset).fillMaxWidth().height(100.dp)
                .onSizeChanged { stripWidth = it.width }
                .pointerInput(last, stripWidth) {
                    awaitEachGesture {
                        val down = awaitFirstDown()
                        pressed = true; thumbnail = true; value = pageAt(down.position.x)
                        var cancelled = false
                        while (true) {
                            val change = awaitPointerEvent().changes.firstOrNull() ?: break
                            cancelled = change.position.y < -with(density) { 200.dp.toPx() }
                            thumbnail = !cancelled
                            if (!cancelled) value = pageAt(change.position.x)
                            change.consume()
                            if (!change.pressed) break
                        }
                        if (!cancelled) { shown = value; pressed = false; thumbnail = false; onPick(value) } else { pressed = false; thumbnail = false }
                    }
                }.semantics { contentDescription = "Page slider" },
        ) {
            val inset = with(density) { 80.dp.toPx() }
            val track = (stripWidth - 2 * inset).coerceAtLeast(1f)
            // The groove: a black pill 8 px high, 10 px longer than the track at each end.
            Box(Modifier.align(Alignment.CenterStart).offset { androidx.compose.ui.unit.IntOffset((inset - with(density) { 10.dp.toPx() }).toInt(), 0) }.width(with(density) { (track / this.density + 20f).dp }).height(8.dp).clip(CircleShape).background(Ink.Black))
            fun xOf(page: Int) = (inset + (if (last == 0) 0f else page.toFloat() / last * track)).toInt()
            // Where the document was when the slider opened: an 18 px dot.
            Box(Modifier.align(Alignment.CenterStart).offset { androidx.compose.ui.unit.IntOffset(xOf(opened) - with(density) { 9.dp.roundToPx() }, 0) }.size(18.dp).clip(CircleShape).background(Ink.Black))
            // The current page (hidden while dragging): a 35 px white circle with a 2 px ring.
            if (!pressed) Box(Modifier.align(Alignment.CenterStart).offset { androidx.compose.ui.unit.IntOffset(xOf(shown) - with(density) { 17.5.dp.roundToPx() }, 0) }.size(35.dp).clip(CircleShape).background(Ink.White).border(2.dp, Ink.Black, CircleShape))
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
