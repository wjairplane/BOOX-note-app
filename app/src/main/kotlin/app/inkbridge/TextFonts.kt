package app.inkbridge

import android.content.Context
import android.graphics.Paint
import android.graphics.Typeface
import androidx.annotation.FontRes
import androidx.core.content.res.ResourcesCompat
import app.inkbridge.rm.text.TextFont
import app.inkbridge.rm.text.TextMeasurer
import app.inkbridge.rm.text.TextMetrics
import app.inkbridge.rm.text.TextSettings

/** The fonts of the typed-text tool (from the firmware image) and the font metrics layout uses. */
object TextFonts {
    private class Family(@FontRes val regular: Int, @FontRes val bold: Int?, @FontRes val italic: Int?, @FontRes val boldItalic: Int?, val fallback: Typeface)

    private val families = HashMap<TextFont, Family>()
    private val cache = HashMap<Triple<TextFont, Boolean, Boolean>, Typeface>()
    private val loaded = HashMap<Int, Typeface?>()
    private var context: Context? = null
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)

    @Synchronized
    fun install(ctx: Context) {
        if (context != null) return
        context = ctx.applicationContext
        families[TextFont.RM_SANS] = Family(R.font.rm_sans_regular, R.font.rm_sans_bold, R.font.rm_sans_italic, R.font.rm_sans_bold_italic, Typeface.SANS_SERIF)
        families[TextFont.EB_GARAMOND] = Family(R.font.eb_garamond, null, R.font.eb_garamond_italic, null, Typeface.SERIF)
        families[TextFont.NOTO_SANS] = Family(R.font.noto_sans, R.font.noto_sans_bold, R.font.noto_sans_italic, R.font.noto_sans_bold_italic, Typeface.SANS_SERIF)
        families[TextFont.NOTO_MONO] = Family(R.font.noto_mono, null, null, null, Typeface.MONOSPACE)
        families[TextFont.NOTO_SERIF] = Family(R.font.noto_serif, R.font.noto_serif_bold, R.font.noto_serif_italic, R.font.noto_serif_bold_italic, Typeface.SERIF)
        TextSettings.current = TextPrefs.load(ctx)
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
        val f = families[font] ?: return@getOrPut Typeface.create(Typeface.SANS_SERIF, style(bold, italic))
        val exact = when {
            bold && italic -> f.boldItalic
            bold -> f.bold
            italic -> f.italic
            else -> f.regular
        }
        exact?.let { load(it) } ?: run {
            // No file for this style: lean on the closest one and let Android thicken or slant it.
            val base = load(if (italic && f.italic != null) f.italic else f.regular)
            if (base == null) Typeface.create(f.fallback, style(bold, italic))
            else Typeface.create(base, style(bold, italic && f.italic == null))
        }
    }

    private fun style(bold: Boolean, italic: Boolean) = when {
        bold && italic -> Typeface.BOLD_ITALIC
        bold -> Typeface.BOLD
        italic -> Typeface.ITALIC
        else -> Typeface.NORMAL
    }
}

/** The text settings the user chose (Font, Font size, Justification, Line spacing); the page margin is kept in the page itself. */
object TextPrefs {
    private const val FILE = "text_settings"

    fun load(context: Context): TextSettings {
        val p = context.getSharedPreferences(FILE, Context.MODE_PRIVATE)
        val d = TextSettings.DEFAULT
        return TextSettings(
            font = runCatching { TextFont.valueOf(p.getString("font", null) ?: d.font.name) }.getOrDefault(d.font),
            scale = p.getFloat("scale", d.scale).takeIf { v -> TextSettings.FONT_SCALES.any { it == v } } ?: d.scale,
            lineSpacing = runCatching { app.inkbridge.rm.text.LineSpacing.valueOf(p.getString("spacing", null) ?: d.lineSpacing.name) }.getOrDefault(d.lineSpacing),
            justify = p.getBoolean("justify", d.justify),
        )
    }

    /** The side margin new text gets (the "Page margins" choice). */
    fun margin(context: Context): Float = context.getSharedPreferences(FILE, Context.MODE_PRIVATE).getFloat("margin", TextSettings.DEFAULT_SIDE_MARGIN)

    fun saveMargin(context: Context, margin: Float) {
        context.getSharedPreferences(FILE, Context.MODE_PRIVATE).edit().putFloat("margin", margin).apply()
    }

    fun save(context: Context, s: TextSettings) {
        context.getSharedPreferences(FILE, Context.MODE_PRIVATE).edit()
            .putString("font", s.font.name).putFloat("scale", s.scale).putString("spacing", s.lineSpacing.name).putBoolean("justify", s.justify).apply()
        TextSettings.current = s
    }
}
