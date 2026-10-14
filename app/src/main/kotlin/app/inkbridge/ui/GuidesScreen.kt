package app.inkbridge.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.annotation.DrawableRes
import androidx.compose.foundation.Image
import androidx.compose.material3.Text
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import app.inkbridge.R
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import app.inkbridge.AppController
import app.inkbridge.Screen

/*
 * Guides, after the firmware's Guides view (topic cards, a gestures overview and the "Ways of working" tutorial).
 * Only what InkBridge supports is kept: the firmware's meeting-note, reMarkable Methods / Getting started web links, the
 * tooltips tour, and the gestures and tutorial steps about features this app doesn't have are left out.
 */

private sealed interface GuideView {
    data object Topics : GuideView
    data object Gestures : GuideView
    data class Tutorial(val page: Int) : GuideView
}

@Composable
fun GuidesScreen(app: AppController) {
    var view by remember { mutableStateOf<GuideView>(GuideView.Topics) }
    Column(Modifier.fillMaxSize()) {
        val title = when (view) { GuideView.Topics -> "Guides"; GuideView.Gestures -> "Gestures"; is GuideView.Tutorial -> "Ways of working" }
        NavigationBar(title, onBack = { if (view == GuideView.Topics) app.screen = Screen.Files() else view = GuideView.Topics })
        when (val v = view) {
            GuideView.Topics -> Topics(onGestures = { view = GuideView.Gestures }, onTutorial = { view = GuideView.Tutorial(0) })
            GuideView.Gestures -> Gestures()
            is GuideView.Tutorial -> Tutorial(v.page, onPage = { view = GuideView.Tutorial(it) }, onClose = { view = GuideView.Topics })
        }
    }
}

/** The firmware's NavigationBar: a Back button (chevron and label) at the left, the title, a 2 px divider below. */
@Composable
fun NavigationBar(title: String, onBack: () -> Unit) {
    Column {
        Box(Modifier.fillMaxWidth().height(Rm.NavigationHeader)) {
            Row(Modifier.align(Alignment.CenterStart).heightIn(min = Rm.ToolButton).tap(onClick = onBack).padding(horizontal = 16.dp).semantics { contentDescription = "Back" }, verticalAlignment = Alignment.CenterVertically) {
                InkIcons.ChevronLeft(); Text("Back", style = RmText.Label)
            }
            Text(title, style = RmText.LabelLgStrong, modifier = Modifier.align(Alignment.Center))
        }
        Rule()
    }
}

/** The firmware's illustrations are single-colour line art; sizes are their own (dp == px here). */
@Composable
private fun Illustration(@DrawableRes id: Int, width: Dp, height: Dp, modifier: Modifier = Modifier) =
    Image(painterResource(id), contentDescription = null, modifier = modifier.size(width, height), colorFilter = ColorFilter.tint(Ink.Black))

/** A card (ArkControls.Card, horizontal design): 2 px border, 64 px padding, serif title, body text, a button, and the artwork. */
@Composable
private fun GuideCard(title: String, description: String, button: String, onClick: () -> Unit, @DrawableRes image: Int, modifier: Modifier = Modifier) {
    Row(modifier.border(Rm.Outline, Ink.Black).padding(64.dp), verticalAlignment = Alignment.CenterVertically) {
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(24.dp)) {
            Text(title, style = RmText.TitleMdAlt)
            Text(description, style = RmText.Body)
            EButton(button, onClick)
        }
        Spacer(Modifier.width(48.dp))
        Illustration(image, 192.dp, 192.dp)
    }
}

@Composable
private fun Topics(onGestures: () -> Unit, onTutorial: () -> Unit) {
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(horizontal = 64.dp, vertical = 48.dp), verticalArrangement = Arrangement.spacedBy(48.dp)) {
        GuideCard("Gestures", "Overview of the gestures that you can use to navigate and manage your notes.", "View all", onGestures, R.drawable.rm_ill_guides, Modifier.fillMaxWidth())
        GuideCard("Ways of working", "A short guide on how to use InkBridge and improve your workflow.", "Start tutorial", onTutorial, R.drawable.rm_ill_distraction_free_software_big, Modifier.fillMaxWidth())
    }
}

private data class Gesture(val title: String, val description: String, @DrawableRes val image: Int)

/** The firmware's gesture wording, for the gestures this app responds to. */
private val GESTURES = listOf(
    Gesture("Select item", "Press and hold with one finger to perform actions when selected", R.drawable.rm_ill_select_item),
    Gesture("Flip page", "Swipe one finger horizontally to move between pages", R.drawable.rm_ill_flip_page),
    Gesture("Zoom", "Pinch or spread two fingers to change the zoom level of the page", R.drawable.rm_ill_zoom),
    Gesture("Pan", "Drag with two fingers to move around a zoomed-in page", R.drawable.rm_ill_pan),
)

@Composable
private fun Gestures() {
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
        GESTURES.forEach { g ->
            Row(Modifier.fillMaxWidth().padding(horizontal = 64.dp, vertical = 40.dp), verticalAlignment = Alignment.CenterVertically) {
                Illustration(g.image, 198.dp, 144.dp)
                Spacer(Modifier.width(48.dp))
                Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(g.title, style = RmText.LabelLgStrong)
                    Text(g.description, style = RmText.Body)
                }
            }
            Rule()
        }
    }
}

private data class Step(val title: String, @DrawableRes val image: Int, val body: List<String>, val points: List<String> = emptyList())

/** "Ways of working" from the firmware, without the steps about the cloud apps and typed text. */
private val STEPS = listOf(
    Step("Ways of working", R.drawable.rm_ill_distraction_free_software_big, listOf(
        "These next steps will show you how to use and navigate InkBridge, introducing you to some important features.",
        "Find more detailed help in Guides.",
    )),
    Step("Types of documents", R.drawable.rm_ill_document_types, listOf("Use the plus icon below to create new items."), listOf(
        "Organize your content into folders",
        "Record ideas, write, and sketch in notebooks",
        "Add quick sheets to jot down your thoughts",
    )),
    Step("Touch gestures", R.drawable.rm_ill_touch_gestures, listOf("Browse pages and manage your files using your fingers. Find the full overview in Guides."), listOf(
        "To perform actions, press and hold the item",
        "Swipe sideways to turn the page",
    )),
    Step("Writing and reading", R.drawable.rm_ill_writing_and_reading, listOf(
        "Pages of notebooks can be as long or short as you need, allowing you to focus and stay uninterrupted as you work.",
        "Take notes in different styles with your pen.",
    )),
)

@Composable
private fun Tutorial(page: Int, onPage: (Int) -> Unit, onClose: () -> Unit) {
    val step = STEPS[page]
    Column(Modifier.fillMaxSize().padding(horizontal = 96.dp, vertical = 64.dp)) {
        Column(Modifier.weight(1f).verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(24.dp)) {
            Illustration(step.image, 384.dp, 384.dp, Modifier.align(Alignment.CenterHorizontally))
            Text(step.title, style = RmText.TitleLg)
            step.body.forEach { Text(it, style = RmText.Body) }
            step.points.forEach { p ->
                Row(verticalAlignment = Alignment.Top) {
                    Box(Modifier.padding(top = 20.dp, end = 20.dp).size(12.dp).background(Ink.Black, androidx.compose.foundation.shape.CircleShape))
                    Text(p, style = RmText.Body)
                }
            }
        }
        // Page dots, then Back and Next/Close, as in the firmware's onboarding dialogue.
        Row(Modifier.fillMaxWidth().padding(bottom = 32.dp), horizontalArrangement = Arrangement.Center, verticalAlignment = Alignment.CenterVertically) {
            STEPS.indices.forEach { i -> Box(Modifier.padding(horizontal = 10.dp).size(20.dp).border(Rm.Outline, Ink.Black, androidx.compose.foundation.shape.CircleShape).background(if (i == page) Ink.Black else Ink.White, androidx.compose.foundation.shape.CircleShape)) }
        }
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(24.dp, Alignment.End)) {
            if (page > 0) EButton("Back", { onPage(page - 1) })
            if (page < STEPS.lastIndex) EButton("Next", { onPage(page + 1) }, selected = true) else EButton("Close", onClose, selected = true)
        }
    }
}
