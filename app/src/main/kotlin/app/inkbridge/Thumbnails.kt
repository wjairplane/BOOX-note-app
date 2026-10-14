package app.inkbridge

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.util.LruCache
import app.inkbridge.rm.io.SceneStream
import app.inkbridge.rm.library.DocumentFactory
import app.inkbridge.rm.library.LibraryEntry
import app.inkbridge.rm.library.LibraryScanner
import app.inkbridge.rm.render.PageRenderer
import app.inkbridge.rm.scene.SceneTree
import java.io.File

/** Small renderings of notebook pages, for the file grid and the page overview. */
class Thumbnails(private val store: LibraryStore) {
    private val cache = LruCache<String, Bitmap>(64)

    /** Cache key changes whenever the page file does, so edited pages refresh. */
    private fun key(entry: LibraryEntry, page: Int, width: Int): String {
        val f = pageFile(entry, page)
        return "${entry.id}/$page/$width/${f.lastModified()}/${f.length()}/${entry.pageIds.getOrNull(page)}"
    }

    private fun pageFile(entry: LibraryEntry, page: Int): File = LibraryScanner.pageFile(store.dir, entry, page)

    /** Render page [page] of [entry] [width] px wide. Blocking; call off the main thread. */
    fun render(entry: LibraryEntry, page: Int, width: Int): Bitmap {
        val k = key(entry, page, width)
        cache.get(k)?.let { return it }

        val f = pageFile(entry, page)
        val tree = runCatching { if (f.isFile) SceneStream.readTree(f.readBytes()) else SceneTree() }.getOrDefault(SceneTree())
        val renderer = PageRenderer(tree)
        val layout = renderer.layout
        val scale = width / layout.width
        val bmp = Bitmap.createBitmap(width, (layout.height * scale).toInt().coerceAtLeast(1), Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        c.drawColor(Color.WHITE)
        c.scale(scale, scale)
        c.translate(-layout.xMin, -layout.yMin)

        val pdfPage = if (entry.fileType == "pdf") DocumentFactory.pdfPageFor(entry, page).takeIf { it >= 0 } else null
        if (pdfPage != null) {
            runCatching {
                val bg = PdfBackground(DocumentFactory.pdfFile(store.dir, entry), pdfPage)
                val p = bg.placement
                val img = bg.render((p.width * scale).toInt())
                c.drawBitmap(img, null, RectF(p.left, p.top, p.left + p.width, p.top + p.height), Paint(Paint.FILTER_BITMAP_FLAG))
            }
        } else {
            entry.template.draw(AndroidPageCanvas(c), layout)
        }
        renderer.render(AndroidPageCanvas(c))
        cache.put(k, bmp)
        return bmp
    }
}
