package app.inkbridge.rm

import app.inkbridge.rm.render.PageCanvas
import app.inkbridge.rm.render.PageLayout
import java.awt.BasicStroke
import java.awt.Color
import java.awt.Font
import java.awt.RenderingHints
import java.awt.geom.Path2D
import java.awt.geom.Rectangle2D
import java.awt.image.BufferedImage

/** Headless Java2D implementation of [PageCanvas] used to eyeball renders as PNGs. */
class Java2DCanvas(private val layout: PageLayout, scale: Float = 0.5f) : PageCanvas {
    val image = BufferedImage((layout.width * scale).toInt(), (layout.height * scale).toInt(), BufferedImage.TYPE_INT_ARGB)
    private val g = image.createGraphics().apply {
        setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
        setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
        color = Color.WHITE
        fillRect(0, 0, image.width, image.height)
        scale(scale.toDouble(), scale.toDouble())
        translate(-layout.xMin.toDouble(), -layout.yMin.toDouble())
    }

    override fun polyline(xy: FloatArray, pointCount: Int, width: Float, argb: Int, cap: PageCanvas.Cap) {
        val path = Path2D.Float()
        path.moveTo(xy[0], xy[1])
        for (i in 1 until pointCount) path.lineTo(xy[i * 2], xy[i * 2 + 1])
        g.color = Color(argb, true)
        g.stroke = BasicStroke(width, when (cap) { PageCanvas.Cap.BUTT -> BasicStroke.CAP_BUTT; PageCanvas.Cap.ROUND -> BasicStroke.CAP_ROUND; PageCanvas.Cap.SQUARE -> BasicStroke.CAP_SQUARE }, BasicStroke.JOIN_ROUND)
        g.draw(path)
    }

    override fun fillRect(x: Float, y: Float, w: Float, h: Float, argb: Int) {
        g.color = Color(argb, true)
        g.fill(Rectangle2D.Float(x, y, w, h))
    }

    override fun text(s: String, x: Float, y: Float, size: Float, bold: Boolean, italic: Boolean, argb: Int) {
        g.color = Color(argb, true)
        g.font = Font(Font.SANS_SERIF, (if (bold) Font.BOLD else 0) or (if (italic) Font.ITALIC else 0), 1).deriveFont(size)
        g.drawString(s, x, y)
    }

    override fun fillPolygon(xy: FloatArray, pointCount: Int, argb: Int) {
        val path = Path2D.Float()
        path.moveTo(xy[0], xy[1])
        for (i in 1 until pointCount) path.lineTo(xy[i * 2], xy[i * 2 + 1])
        path.closePath()
        g.color = Color(argb, true)
        g.fill(path)
    }

    override fun measureText(s: String, size: Float, bold: Boolean): Float =
        g.getFontMetrics(Font(Font.SANS_SERIF, if (bold) Font.BOLD else 0, 1).deriveFont(size)).stringWidth(s).toFloat()

    fun finish(): BufferedImage { g.dispose(); return image }
}
