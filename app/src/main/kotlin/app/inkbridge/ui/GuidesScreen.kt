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
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.foundation.gestures.detectTapGestures
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
    data class Tutorial(val page: Int) : GuideView
}

@Composable
fun GuidesScreen(app: AppController) {
    var view by remember { mutableStateOf<GuideView>(GuideView.Topics) }
    Column(Modifier.fillMaxSize()) {
        val title = when (view) { GuideView.Topics -> "Guides"; is GuideView.Tutorial -> "Ways of working" }
        NavigationBar(title, onBack = { if (view == GuideView.Topics) app.screen = Screen.Files() else view = GuideView.Topics })
        when (val v = view) {
            GuideView.Topics -> Topics(onTutorial = { view = GuideView.Tutorial(0) })
            is GuideView.Tutorial -> Box(Modifier.fillMaxSize()) {
                Topics(onTutorial = {})
                Tutorial(v.page, onPage = { view = GuideView.Tutorial(it) }, onClose = { view = GuideView.Topics })
            }
        }
    }
}

/** The firmware's NavigationBar: a Back button (chevron and label) at the left, the title, a 2 px divider below. */
@Composable
fun NavigationBar(title: String, onBack: () -> Unit) {
    Column {
        Box(Modifier.fillMaxWidth().height(Rm.NavigationHeader)) {
            Row(Modifier.align(Alignment.CenterStart).heightIn(min = Rm.Control).tap(onClick = onBack).padding(horizontal = 32.dp).semantics { contentDescription = "Back" }, verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                InkIcons.ChevronLeft(); Text("Back", style = RmText.LabelLg)
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

/** A card (ArkControls.Card, vertical design): the artwork on top, then the title, the text and a button pushed to the bottom. */
@Composable
private fun VerticalGuideCard(title: String, description: String, button: String, onClick: () -> Unit, @DrawableRes image: Int, modifier: Modifier = Modifier) {
    Column(modifier.border(Rm.Outline, Ink.Black).padding(64.dp), verticalArrangement = Arrangement.spacedBy(24.dp)) {
        Illustration(image, 270.dp, 270.dp, Modifier.align(Alignment.CenterHorizontally))
        Text(title, style = RmText.TitleMdAlt)
        Text(description, style = RmText.Body)
        Spacer(Modifier.weight(1f, fill = false))
        EButton(button, onClick)
    }
}

@Composable
private fun Topics(onTutorial: () -> Unit) {
    // Two columns (88 px margins, 64 px gaps): the tutorial in a half-width card.
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(start = 88.dp, end = 88.dp, bottom = 59.dp), verticalArrangement = Arrangement.spacedBy(64.dp)) {
        Row(Modifier.fillMaxWidth().height(IntrinsicSize.Max), horizontalArrangement = Arrangement.spacedBy(64.dp)) {
            VerticalGuideCard("Ways of working", "A four step guide on how to use your paper tablet and improve your workflow.", "Start tutorial", onTutorial, R.drawable.rm_ill_distraction_free_software_big, Modifier.weight(1f).fillMaxHeight())
            Spacer(Modifier.weight(1f))
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
        "Turn pages from the notebook menu or the page overview",
    )),
    Step("Writing and reading", R.drawable.rm_ill_writing_and_reading, listOf(
        "Pages of notebooks can be as long or short as you need, allowing you to focus and stay uninterrupted as you work.",
        "Take notes in different styles with your pen.",
    )),
)

/**
 * The onboarding dialogue: the Guides screen fades behind it (60% white), a 2 px framed box inset 176 / 234 px holds "N of M" at the top, a close
 * button at the top right (not on the last page), the illustration, the title, the 36 px text, and centred Back / Next buttons.
 */
@Composable
private fun Tutorial(page: Int, onPage: (Int) -> Unit, onClose: () -> Unit) {
    val step = STEPS[page]
    Box(Modifier.fillMaxSize().background(Ink.White.copy(alpha = 0.6f)).pointerInput(Unit) { detectTapGestures { } }) {
        Box(Modifier.fillMaxSize().padding(horizontal = 176.dp, vertical = 234.dp).background(Ink.White).border(Rm.Outline, Ink.Black)) {
            Text("${page + 1} of ${STEPS.size}", style = RmText.BodyLg, modifier = Modifier.align(Alignment.TopCenter).padding(top = 24.dp))
            if (page < STEPS.lastIndex) Box(Modifier.align(Alignment.TopEnd).padding(8.dp).size(Rm.Control).tap(onClick = onClose).semantics { contentDescription = "Close" }, contentAlignment = Alignment.Center) { InkIcons.XMedium() }
            Column(Modifier.fillMaxSize().padding(horizontal = 88.dp, vertical = 88.dp)) {
                Column(Modifier.weight(1f).verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(24.dp)) {
                    Illustration(step.image, 384.dp, 384.dp, Modifier.align(Alignment.CenterHorizontally))
                    Text(step.title, style = RmText.TitleLg)
                    step.body.forEach { Text(it, style = RmText.BodyLg) }
                    step.points.forEach { p ->
                        Row(verticalAlignment = Alignment.Top) {
                            Box(Modifier.padding(top = 22.dp, end = 20.dp).size(12.dp).background(Ink.Black, androidx.compose.foundation.shape.CircleShape))
                            Text(p, style = RmText.BodyLg)
                        }
                    }
                }
                Row(Modifier.fillMaxWidth().padding(top = 32.dp), horizontalArrangement = Arrangement.spacedBy(24.dp, Alignment.CenterHorizontally)) {
                    if (page > 0) EButton("Back", { onPage(page - 1) }, Modifier.widthIn(min = 346.dp))
                    if (page < STEPS.lastIndex) EButton("Next", { onPage(page + 1) }, Modifier.widthIn(min = 346.dp), selected = true) else EButton("Close", onClose, Modifier.widthIn(min = 346.dp), selected = true)
                }
            }
        }
    }
}
