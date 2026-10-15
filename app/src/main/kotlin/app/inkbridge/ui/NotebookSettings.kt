package app.inkbridge.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.unit.dp
import app.inkbridge.AppController
import app.inkbridge.rm.library.LibraryEntry

/**
 * The firmware's notebook settings (`00df1d27`): a Cancel / Save bar, the "Name" field, and the "Notebook cover" choice between the
 * last visited page and the first page. Save is only offered while the name is not empty.
 */
@Composable
internal fun NotebookSettingsScreen(app: AppController, doc: LibraryEntry, onDismiss: () -> Unit) {
    val pdf = doc.fileType == "pdf"
    var name by remember { mutableStateOf(doc.name) }
    var cover by remember { mutableStateOf(if (doc.coverPage == 0) 1 else 0) }
    val save = {
        if (name.isNotBlank()) {
            if (name.trim() != doc.name) app.rename(doc, name.trim())
            val value = if (cover == 1) 0 else -1
            if (value != doc.coverPage) app.setCoverPage(doc, value)
            onDismiss()
        }
    }
    FormScreen(if (pdf) "PDF settings" else "Notebook settings", right = if (name.isNotBlank()) "Save" else null, onDismiss = onDismiss, onRight = save) {
        FormNameField("Name", name, { name = it }, save)
        Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
            Text(if (pdf) "PDF cover" else "Notebook cover", style = RmText.LabelLg)
            ContextualMenu(listOf("Last visited page", "First page"), cover) { cover = it }
        }
    }
}

/** The document's tags: the same selector the New folder form uses; Done saves. */
@Composable
internal fun DocumentTagsScreen(app: AppController, doc: LibraryEntry, onDismiss: () -> Unit) {
    var tags by remember { mutableStateOf(doc.tags.toSet()) }
    FormScreen("Tags", left = "Cancel", right = "Done", onDismiss = onDismiss, onRight = { app.setTags(doc, tags.toList()); onDismiss() }) {
        TagsSelector(app, tags) { tags = it }
    }
}
