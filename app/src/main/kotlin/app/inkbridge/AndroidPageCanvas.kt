package app.inkbridge

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Typeface
import androidx.core.content.res.ResourcesCompat
import app.inkbridge.rm.render.PageCanvas

/** [PageCanvas] on an Android [Canvas]. The caller sets up the page→pixel transform on [canvas]. */
class AndroidPageCanvas(private val canvas: Canvas) : PageCanvas {
    private val path = Path()
    private val stroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeJoin = Paint.Join.ROUND
    }
    private val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG)

    override fun polyline(xy: FloatArray, pointCount: Int, width: Float, argb: Int, cap: PageCanvas.Cap) {
        path.rewind()
        path.moveTo(xy[0], xy[1])
        for (i in 1 until pointCount) path.lineTo(xy[i * 2], xy[i * 2 + 1])
        stroke.color = argb
        stroke.strokeWidth = width
        stroke.strokeCap = when (cap) {
            PageCanvas.Cap.BUTT -> Paint.Cap.BUTT
            PageCanvas.Cap.ROUND -> Paint.Cap.ROUND
            PageCanvas.Cap.SQUARE -> Paint.Cap.SQUARE
        }
        canvas.drawPath(path, stroke)
    }

    override fun fillRect(x: Float, y: Float, w: Float, h: Float, argb: Int) {
        fill.color = argb
        canvas.drawRect(x, y, x + w, y + h, fill)
    }

    override fun fillPolygon(xy: FloatArray, pointCount: Int, argb: Int) {
        path.rewind()
        path.moveTo(xy[0], xy[1])
        for (i in 1 until pointCount) path.lineTo(xy[i * 2], xy[i * 2 + 1])
        path.close()
        fill.color = argb
        canvas.drawPath(path, fill)
    }

    private fun typeface(bold: Boolean, italic: Boolean): Typeface {
        val rm = sans
        if (rm != null && !italic) return if (bold) Typeface.create(rm, Typeface.BOLD) else rm
        val style = when {
            bold && italic -> Typeface.BOLD_ITALIC
            bold -> Typeface.BOLD
            italic -> Typeface.ITALIC
            else -> Typeface.NORMAL
        }
        return Typeface.create(Typeface.SANS_SERIF, style)
    }

    override fun measureText(s: String, size: Float, bold: Boolean): Float {
        textPaint.textSize = size
        textPaint.typeface = typeface(bold, false)
        return textPaint.measureText(s)
    }

    override fun text(s: String, x: Float, y: Float, size: Float, bold: Boolean, italic: Boolean, argb: Int) {
        textPaint.color = argb
        textPaint.textSize = size
        textPaint.typeface = typeface(bold, italic)
        canvas.drawText(s, x, y, textPaint)
    }

    override fun styledText(s: String, x: Float, y: Float, size: Float, bold: Boolean, italic: Boolean, font: app.inkbridge.rm.text.TextFont, argb: Int) {
        textPaint.color = argb
        textPaint.textSize = size
        textPaint.typeface = TextFonts.typeface(font, bold, italic)
        canvas.drawText(s, x, y, textPaint)
    }

    companion object {
        /** The reMarkable Sans used for page text such as template labels; plain sans until [installFonts] has run. */
        @Volatile private var sans: Typeface? = null

        fun installFonts(context: Context) {
            TextFonts.install(context)
            if (sans == null) sans = runCatching { ResourcesCompat.getFont(context, R.font.rm_sans_regular) }.getOrNull()
        }
    }
}
