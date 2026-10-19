package app.inkbridge

import android.app.Application
import androidx.activity.ComponentActivity
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import app.inkbridge.rm.library.DocumentFactory
import app.inkbridge.rm.library.LibraryOps
import app.inkbridge.rm.render.PageTemplate
import app.inkbridge.ui.InkBridgeApp
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.io.File

/** My files with five folders (they get rows of their own), notebooks and PDFs: the document covers and the folder rows. */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w702dp-h936dp-xhdpi")
class FilesCoversTest {
    @get:Rule val rule = createAndroidComposeRule<ComponentActivity>()

    private fun snapshot(name: String) {
        val decor = rule.activity.window.decorView
        val bmp = android.graphics.Bitmap.createBitmap(decor.width.coerceAtLeast(1), decor.height.coerceAtLeast(1), android.graphics.Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(bmp)
        canvas.drawColor(android.graphics.Color.WHITE)
        decor.draw(canvas)
        val out = File("build/ui-snapshots").apply { mkdirs() }
        File(out, "$name.png").outputStream().use { bmp.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, it) }
    }

    private fun settle() = repeat(14) { Thread.sleep(120); rule.mainClock.advanceTimeBy(100); rule.waitForIdle() }

    @Test fun coversAndFolders() {
        val ctx = RuntimeEnvironment.getApplication() as Application
        val store = LibraryStore(ctx)
        val d = store.dir
        for (n in listOf("Archive", "Ideas", "Recipes", "School", "Work")) LibraryOps.createFolder(d, n)
        LibraryOps.createNotebook(d, "Journal", "", PageTemplate.LINES)
        LibraryOps.createNotebook(d, "Sketches", "", PageTemplate.DOTS)
        DocumentFactory.createPdfDocument(d, "Quarterly report", 12, 480_000L)
        DocumentFactory.createPdfDocument(d, "Contract", 4, 120_000L)
        val app = AppController(store, Prefs(ctx), kotlinx.coroutines.MainScope())
        rule.setContent { InkBridgeApp(store, Prefs(ctx), app) }
        settle(); snapshot("files_covers")
    }
}
