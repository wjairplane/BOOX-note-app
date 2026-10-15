package app.inkbridge.ui

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.util.LruCache
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import app.inkbridge.AndroidPageCanvas
import app.inkbridge.rm.render.PageTemplate
import app.inkbridge.rm.render.TemplateCatalog

/** Card thumbnails drawn by the real template renderer, cached by template and pixel width. */
object TemplateThumbnails {
    private val cache = LruCache<String, Bitmap>(160)

    fun get(t: PageTemplate, widthPx: Int): Bitmap {
        val key = "${t.id}@$widthPx"
        cache.get(key)?.let { return it }
        val layout = t.pageLayout
        val scale = widthPx / layout.width
        val bmp = Bitmap.createBitmap(widthPx, (layout.height * scale).toInt().coerceAtLeast(1), Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        c.drawColor(Color.WHITE)
        c.scale(scale, scale)
        c.translate(-layout.xMin, -layout.yMin)
        t.draw(AndroidPageCanvas(c), layout)
        cache.put(key, bmp)
        return bmp
    }
}

/** One template as a page-shaped card with its name below; the chosen one has a thick border. */
@Composable
fun TemplateCard(template: PageTemplate, selected: Boolean, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val bmp = remember(template.id) { AndroidPageCanvas.installFonts(context); TemplateThumbnails.get(template, if (template.landscape) 400 else 300) }
    Column(modifier.tap(onClick = onClick).semantics { contentDescription = "Template ${template.label}" }, horizontalAlignment = Alignment.CenterHorizontally) {
        Box(Modifier.fillMaxWidth().aspectRatio(bmp.width.toFloat() / bmp.height).border(if (selected) 6.dp else Rm.Outline, Ink.Black)) {
            Image(bmp.asImageBitmap(), null, Modifier.fillMaxSize(), contentScale = ContentScale.FillBounds)
        }
        Spacer(Modifier.height(16.dp))
        Text(template.label, style = RmText.Label, maxLines = 1, overflow = TextOverflow.Ellipsis)
    }
}

/**
 * The firmware's "Choose template" window: a Back bar, a filter row (category dropdown with Portrait / Landscape at
 * the right, as FilterDropdown) and a grid of 340 px cells; tapping a template applies it.
 */
@Composable
fun TemplatePickerScreen(selected: PageTemplate, onPick: (PageTemplate) -> Unit, onBack: () -> Unit) {
    BackHandler(onBack = onBack)
    var category by remember { mutableStateOf(TemplateCatalog.ALL) }
    var landscape by remember { mutableStateOf(selected.landscape) }
    var open by remember { mutableStateOf(false) }
    // The firmware falls back to the other orientation when a category has none in this one.
    val effLandscape = if (!TemplateCatalog.hasOrientation(category, landscape) && TemplateCatalog.hasOrientation(category, !landscape)) !landscape else landscape
    val items = remember(category, effLandscape) { TemplateCatalog.filter(category, effLandscape) }
    val categories = remember { listOf(TemplateCatalog.ALL) + TemplateCatalog.categories }

    Column(Modifier.fillMaxSize().background(Ink.White).pointerInput(Unit) { detectTapGestures { } }) {
        NavigationBar("Choose template", onBack)
        Box(Modifier.fillMaxWidth().height(Rm.Control + Rm.Outline)) {
            Box(Modifier.align(Alignment.BottomCenter)) { Rule() }
            Box(Modifier.align(Alignment.CenterEnd).padding(end = Rm.NavigatorMargin)) {
                Row(
                    Modifier.width(Rm.DropdownWidth).height(Rm.Control).border(if (open) Rm.Outline else 0.dp, Ink.Black).tap { open = !open }.padding(horizontal = 16.dp).semantics { contentDescription = "Filter" },
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(if (open) "Filter" else category, style = RmText.LabelLg, modifier = Modifier.weight(1f))
                    if (open) InkIcons.ChevronUp() else InkIcons.ChevronDown()
                }
                RmMenu(open, { open = false }, MenuSide.BELOW, Rm.DropdownWidth) {
                    categories.filter { it == TemplateCatalog.ALL || TemplateCatalog.filter(it, effLandscape).isNotEmpty() || TemplateCatalog.filter(it, !effLandscape).isNotEmpty() }.forEach { c ->
                        RmMenuItem(c, { category = c }, selected = c == category)
                    }
                    Rule()
                    Text("Orientation", style = RmText.LabelLg, modifier = Modifier.padding(horizontal = 16.dp, vertical = 20.dp))
                    if (TemplateCatalog.hasOrientation(category, false)) RmMenuItem("Portrait", { landscape = false }, selected = !effLandscape)
                    if (TemplateCatalog.hasOrientation(category, true)) RmMenuItem("Landscape", { landscape = true }, selected = effLandscape)
                }
            }
        }
        BoxWithConstraints(Modifier.fillMaxSize()) {
            val columns = kotlin.math.ceil(maxWidth.value / 340f).toInt().coerceAtLeast(1)
            LazyVerticalGrid(GridCells.Fixed(columns), contentPadding = PaddingValues(horizontal = 40.dp, vertical = 32.dp), horizontalArrangement = Arrangement.spacedBy(32.dp), verticalArrangement = Arrangement.spacedBy(32.dp)) {
                items(items, key = { it.id }) { t -> TemplateCard(t, t == selected, { onPick(t) }, Modifier.heightIn(min = 276.dp)) }
            }
        }
    }
}
