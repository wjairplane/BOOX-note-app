package app.inkbridge.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import app.inkbridge.rm.edit.PageEditor
import java.io.File

/** Why a page cannot be shown or edited: the firmware's page statuses (PageErrorOverlay, `00dbf955`) that apply to this app. */
enum class PageError(val title: String, val content: String) {
    /** The page file could not be read. */
    LOAD("Unable to view page", RESTART),
    /** The page is too big to load into memory. */
    LOW_MEMORY("Unable to view page. Low on memory.", RESTART),
    /** More points than the firmware allows on one page. */
    TOO_LARGE("Stroke limit reached", "Please start a new page or erase something to make further changes"),
    /** The page could not be written. */
    STORAGE("Unable to save page", RESTART),
    /** The notebook's PDF is gone (Document: "Your PDF file seems to be missing. Try importing it again."). */
    MISSING_PDF("Unable to view page", "Your PDF file seems to be missing. Try importing it again."),
    /** The page was written by a newer format than this app reads. */
    VERSION("Update software to view", "This document is not supported by your current software version.\nPlease check for updates");
}

// The firmware says "reMarkable" for the device and "application" elsewhere; this is an application.
private const val RESTART = "Try restarting your application or contact support if the problem persists"

/** The page-sized notice: the title (bold) and the advice centred, and the "Diagnostic information:" block at the bottom. */
@Composable
fun PageErrorOverlay(error: PageError, documentId: String, pageId: String, details: String, modifier: Modifier = Modifier) {
    Box(modifier.fillMaxSize().background(Ink.White).tap { }.semantics { contentDescription = error.title }) {
        Column(Modifier.align(Alignment.Center).fillMaxWidth().padding(horizontal = 96.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(error.title, style = RmText.sans(36, FontWeight.Bold, 1.3f), textAlign = TextAlign.Center)
            Text(error.content, style = RmText.BodyLg, textAlign = TextAlign.Center)
        }
        Column(Modifier.align(Alignment.BottomCenter).padding(bottom = 72.dp, start = 48.dp, end = 48.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            Text("Diagnostic information:", style = RmText.sans(22, FontWeight.Bold, 1.4f))
            for (line in listOf(documentId, pageId, details)) if (line.isNotEmpty()) Text(line, style = RmText.Caption, textAlign = TextAlign.Center)
        }
    }
}

/** The firmware's one limit on a page: 7,489,828 points in total; one point is at least 14 bytes in the page file. */
object StrokeLimit {
    const val MAX_POINTS = 7_489_828
    private const val MIN_BYTES_PER_POINT = 14

    /** True when the page in [file] holds [MAX_POINTS] points or more. Small files are decided by their size, without reading them. */
    fun reached(file: File): Boolean {
        if (!file.isFile || file.length() < MAX_POINTS.toLong() * MIN_BYTES_PER_POINT) return false
        return runCatching { points(PageEditor.fromBytes(file.readBytes())) >= MAX_POINTS }.getOrDefault(false)
    }

    fun points(editor: PageEditor): Long = editor.renderer.placedLines().sumOf { it.line.points.size.toLong() }
}

/**
 * The black "Unable to open" sheet (InfoDialog, `00dbe7d5`): an information icon beside the serif header, the explanation, and a Close
 * button half the sheet wide. It sits at the bottom of the screen.
 */
@Composable
fun InfoDialog(header: String, text: String, onClose: () -> Unit, modifier: Modifier = Modifier) {
    Box(modifier.fillMaxSize()) {
        Column(
            Modifier.align(Alignment.BottomCenter).fillMaxWidth().background(Ink.Black).tap { }.padding(horizontal = 80.dp, vertical = 48.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                InkIcons.InformationCircle(tint = Ink.White, size = 32.dp)
                Text(header, style = RmText.TitleLg, color = Ink.White)
            }
            Text(text, style = RmText.Body, color = Ink.White)
            Spacer(Modifier.height(8.dp))
            Box(
                Modifier.fillMaxWidth(0.5f).height(Rm.Control).background(Ink.Black).border(Rm.Outline, Ink.White).tap(onClick = onClose).semantics { contentDescription = "Close" },
                contentAlignment = Alignment.Center,
            ) { Text("Close", style = RmText.LabelLg, color = Ink.White) }
        }
    }
}
