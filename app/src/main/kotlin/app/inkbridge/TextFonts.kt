package app.inkbridge

import android.content.Context
import android.graphics.Paint
import android.graphics.Typeface
import androidx.annotation.FontRes
import androidx.core.content.res.ResourcesCompat
import app.inkbridge.rm.text.TextFont
import app.inkbridge.rm.text.TextMeasurer
import app.inkbridge.rm.text.TextMetrics

/** The typed-text fonts (reMarkable Sans and Serif Small, from the firmware image) and the font metrics layout uses. */
object TextFonts {
    private class Family(@FontRes val regular: Int, @FontRes val bold: Int, @FontRes val italic: Int, @FontRes val boldItalic: Int, @FontRes val medium: Int? = null)

    private val families = mapOf(
        TextFont.RM_SANS to Family(R.font.rm_sans_regular, R.font.rm_sans_bold, R.font.rm_sans_italic, R.font.rm_sans_bold_italic),
        TextFont.RM_SANS_MEDIUM to Family(R.font.rm_sans_medium, R.font.rm_sans_bold, R.font.rm_sans_italic, R.font.rm_sans_bold_italic),
        TextFont.RM_SERIF to Family(R.font.rm_serif_regular, R.font.rm_serif_bold, R.font.rm_serif_italic, R.font.rm_serif_bold_italic),
    )
    private val cache = HashMap<Triple<TextFont, Boolean, Boolean>, Typeface>()
    private val loaded = HashMap<Int, Typeface?>()
    private var context: Context? = null
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)

    @Synchronized
    fun install(ctx: Context) {
        if (context === ctx.applicationContext) return
        // (A new application, as in each test, starts with fresh font caches.)
        cache.clear(); loaded.clear()
        context = ctx.applicationContext
        TextMetrics.measurer = TextMeasurer { s, size, bold, italic, font ->
            synchronized(paint) {
                paint.textSize = size
                paint.typeface = typeface(font, bold, italic)
                paint.measureText(s)
            }
        }
    }

    private fun load(@FontRes id: Int): Typeface? = loaded.getOrPut(id) {
        runCatching { context?.let { ResourcesCompat.getFont(it, id) } }.getOrNull()
    }

    @Synchronized
    fun typeface(font: TextFont, bold: Boolean, italic: Boolean): Typeface = cache.getOrPut(Triple(font, bold, italic)) {
        val f = families.getValue(font)
        val id = when {
            bold && italic -> f.boldItalic
            bold -> f.bold
            italic -> f.italic
            else -> f.regular
        }
        load(id) ?: Typeface.create(if (font == TextFont.RM_SERIF) Typeface.SERIF else Typeface.SANS_SERIF,
            when { bold && italic -> Typeface.BOLD_ITALIC; bold -> Typeface.BOLD; italic -> Typeface.ITALIC; else -> Typeface.NORMAL })
    }
}
