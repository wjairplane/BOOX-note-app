package app.inkbridge.rm.export

import app.inkbridge.rm.render.PageCanvas
import app.inkbridge.rm.render.PageLayout
import app.inkbridge.rm.render.PageRenderer
import java.util.Locale

/** [PageCanvas] that writes an SVG document: vector strokes, so exports stay sharp at any zoom. */
class SvgCanvas(private val layout: PageLayout) : PageCanvas {
    private val body = StringBuilder()

    override fun polyline(xy: FloatArray, pointCount: Int, width: Float, argb: Int, cap: PageCanvas.Cap) {
        body.append("<polyline fill=\"none\" stroke=\"").append(color(argb)).append('"')
        opacity(argb)?.let { body.append(" stroke-opacity=\"").append(it).append('"') }
        body.append(" stroke-width=\"").append(num(width)).append("\" stroke-linecap=\"")
            .append(cap.name.lowercase()).append("\" stroke-linejoin=\"round\" points=\"")
        for (i in 0 until pointCount) {
            if (i > 0) body.append(' ')
            body.append(num(xy[i * 2])).append(',').append(num(xy[i * 2 + 1]))
        }
        body.append("\"/>\n")
    }

    override fun fillRect(x: Float, y: Float, w: Float, h: Float, argb: Int) {
        body.append("<rect x=\"").append(num(x)).append("\" y=\"").append(num(y))
            .append("\" width=\"").append(num(w)).append("\" height=\"").append(num(h))
            .append("\" fill=\"").append(color(argb)).append('"')
        opacity(argb)?.let { body.append(" fill-opacity=\"").append(it).append('"') }
        body.append("/>\n")
    }

    override fun fillPolygon(xy: FloatArray, pointCount: Int, argb: Int) {
        body.append("<polygon fill=\"").append(color(argb)).append('"')
        opacity(argb)?.let { body.append(" fill-opacity=\"").append(it).append('"') }
        body.append(" points=\"")
        for (i in 0 until pointCount) {
            if (i > 0) body.append(' ')
            body.append(num(xy[i * 2])).append(',').append(num(xy[i * 2 + 1]))
        }
        body.append("\"/>\n")
    }

    override fun text(s: String, x: Float, y: Float, size: Float, bold: Boolean, italic: Boolean, argb: Int) {
        body.append("<text x=\"").append(num(x)).append("\" y=\"").append(num(y))
            .append("\" font-family=\"sans-serif\" font-size=\"").append(num(size)).append('"')
        if (bold) body.append(" font-weight=\"bold\"")
        if (italic) body.append(" font-style=\"italic\"")
        body.append(" fill=\"").append(color(argb)).append("\">").append(escape(s)).append("</text>\n")
    }

    /** A raster image drawn under everything else (e.g. the PDF page being annotated). Rect is in page units. */
    class Background(val png: ByteArray, val x: Float, val y: Float, val width: Float, val height: Float)

    fun toSvg(background: Background? = null): String {
        val sb = StringBuilder()
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
        sb.append("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"").append(num(layout.width))
            .append("\" height=\"").append(num(layout.height)).append("\" viewBox=\"")
            .append(num(layout.xMin)).append(' ').append(num(layout.yMin)).append(' ')
            .append(num(layout.width)).append(' ').append(num(layout.height)).append("\">\n")
        sb.append("<rect x=\"").append(num(layout.xMin)).append("\" y=\"").append(num(layout.yMin))
            .append("\" width=\"").append(num(layout.width)).append("\" height=\"").append(num(layout.height))
            .append("\" fill=\"#ffffff\"/>\n")
        background?.let {
            sb.append("<image x=\"").append(num(it.x)).append("\" y=\"").append(num(it.y))
                .append("\" width=\"").append(num(it.width)).append("\" height=\"").append(num(it.height))
                .append("\" href=\"data:image/png;base64,").append(java.util.Base64.getEncoder().encodeToString(it.png)).append("\"/>\n")
        }
        sb.append(body).append("</svg>\n")
        return sb.toString()
    }

    private fun num(v: Float): String = String.format(Locale.ROOT, "%.2f", v).trimEnd('0').trimEnd('.').ifEmpty { "0" }
    private fun color(argb: Int): String = String.format(Locale.ROOT, "#%06x", argb and 0xFFFFFF)
    private fun opacity(argb: Int): String? {
        val a = (argb ushr 24) and 0xFF
        return if (a == 255) null else String.format(Locale.ROOT, "%.3f", a / 255f)
    }
    private fun escape(s: String) = s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;")
}

object PageExport {
    /** Render [renderer]'s page as a standalone SVG document. */
    fun svg(renderer: PageRenderer, background: SvgCanvas.Background? = null, template: app.inkbridge.rm.render.PageTemplate? = null): String =
        SvgCanvas(renderer.layout).also { c ->
            template?.draw(c, renderer.layout)
            renderer.render(c)
        }.toSvg(background)
}
