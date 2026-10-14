package app.inkbridge.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import app.inkbridge.AndroidPageCanvas
import app.inkbridge.rm.render.PageRenderer
import app.inkbridge.rm.render.PageTemplate
import app.inkbridge.rm.scene.SceneTree

/** One template as a page-shaped card with its name below; the chosen one has a thick border. */
@Composable
fun TemplateCard(template: PageTemplate, selected: Boolean, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val layout = remember { PageRenderer(SceneTree()).layout }
    Column(modifier.tap(onClick = onClick).semantics { contentDescription = "Template ${template.label}" }, horizontalAlignment = Alignment.CenterHorizontally) {
        Box(Modifier.fillMaxWidth().aspectRatio(layout.width / layout.height).border(if (selected) 6.dp else Rm.Outline, Ink.Black)) {
            androidx.compose.foundation.Canvas(Modifier.fillMaxSize()) {
                drawIntoCanvas { c ->
                    val n = c.nativeCanvas
                    n.save(); n.scale(size.width / layout.width, size.width / layout.width); n.translate(-layout.xMin, -layout.yMin)
                    template.draw(AndroidPageCanvas(n), layout)
                    n.restore()
                }
            }
        }
        Spacer(Modifier.height(16.dp))
        Text(template.label, style = RmText.Label)
    }
}

/** The firmware's "Choose template" window: a full screen with a Back bar and a grid of templates; tapping one applies it. */
@Composable
fun TemplatePickerScreen(selected: PageTemplate, onPick: (PageTemplate) -> Unit, onBack: () -> Unit) {
    BackHandler(onBack = onBack)
    Column(Modifier.fillMaxSize().background(Ink.White).pointerInput(Unit) { detectTapGestures { } }) {
        NavigationBar("Choose template", onBack)
        LazyVerticalGrid(GridCells.Fixed(4), contentPadding = PaddingValues(40.dp), horizontalArrangement = Arrangement.spacedBy(32.dp), verticalArrangement = Arrangement.spacedBy(40.dp)) {
            items(PageTemplate.entries.toList()) { t -> TemplateCard(t, t == selected, { onPick(t) }) }
        }
    }
}
