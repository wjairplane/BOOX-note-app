package app.inkbridge.rm.render

import kotlin.math.floor
import kotlin.math.max

/**
 * The seven templates xochitl draws in code instead of from a `.template` file: Hexagon small / medium / large and
 * Calligraphy medium / large (portrait, and landscape for Calligraphy).
 *
 * Recovered from the firmware's `SceneTemplateRenderer` (the decompiled hexagon and calligraphy paint routines and the
 * parameter table the renderer fills in when the template is chosen). Every number below is read from that code; what
 * the code does not say is marked as an estimate:
 *
 *  - the layout and all the constants of the table ([Spec]) are exact;
 *  - the page coordinate space is the same as for `.template` files: x = 0 at the page centre, the page is
 *    templateWidth x templateHeight, the grid starts at the page's left edge ([TemplateRenderer.templateWidth]);
 *  - line colour and width are not the firmware's (black, 0.5 wide, antialiased) but the app's template rule
 *    look ([TemplateRenderer.RULE_COLOR]) so that every template looks alike on the page;
 *  - the dash of the Calligraphy guide lines is 13 and 17 pen widths, with the firmware's pen width 0.5, i.e. 6.5 on and
 *    8.5 off page units (ESTIMATE: the firmware says "13, 17" in pen-width units and the unit is Qt's, not verified).
 */
object NativeTemplates {
    /** Geometry of one template: [step] is the horizontal pitch, [pitch] the vertical one, [x0]/[y0] the grid offset. */
    private class Spec(val hexagon: Boolean, val step: Double, val pitch: Double, val x0: Double, val y0: Double,
        /** Calligraphy only: spacing of the guide lines inside a row, lead-in of the dashed lines, extra slant reach; [large] = the large sheets (own dash start and guide culling). */
        val rule: Double = 0.0, val dashLead: Double = 0.0, val slantExtra: Double = 0.0, val large: Boolean = false)

    private val specs: Map<String, Spec> = mapOf(
        // step (cell width), pitch (cell height = two rows of hexagons), x offset, y offset
        "P Hexagon large" to Spec(true, 112.1, 194.4, -102.1, -147.4),
        "P Hexagon medium" to Spec(true, 87.8, 151.8, -30.0, -138.0),
        "P Hexagon small" to Spec(true, 43.9, 75.9, -8.0, -55.2),
        // Calligraphy: four guide lines per row (dashed, dashed, solid baseline, dashed) [rule] apart.
        "P Calligraphy large" to Spec(false, 72.0, 195.0, -50.5, 65.0, rule = 48.0, dashLead = 5.0, slantExtra = 0.0, large = true),
        "LS Calligraphy large" to Spec(false, 72.0, 195.0, -105.0, 61.0, rule = 48.0, dashLead = 5.0, slantExtra = 0.0, large = true),
        "P Calligraphy medium" to Spec(false, 45.0, 157.5, -35.0, 99.0, rule = 40.2, dashLead = 0.0, slantExtra = 12.0),
        "LS Calligraphy medium" to Spec(false, 45.0, 159.0, 0.0, 64.0, rule = 40.6, dashLead = 12.0, slantExtra = 12.0),
    )

    /** Template file names this object draws. */
    val names: Set<String> get() = specs.keys

    fun has(filename: String) = filename in specs

    private const val DASH_ON = 6.5f
    private const val DASH_OFF = 8.5f

    /** Draw the native template [filename] over [layout] (page units, x = 0 at the page centre). */
    fun draw(filename: String, landscape: Boolean, canvas: PageCanvas, layout: PageLayout) {
        val s = specs[filename] ?: return
        val left = -TemplateRenderer.templateWidth(landscape) / 2.0
        val clipX = layout.xMin.toDouble(); val clipY = layout.yMin.toDouble()
        val clipW = layout.width.toDouble(); val clipH = layout.height.toDouble()
        if (s.hexagon) hexagons(s, canvas, left, clipX, clipY, clipW, clipH) else calligraphy(s, canvas, left, clipX, clipY, clipW, clipH)
    }

    private fun line(c: PageCanvas, x1: Double, y1: Double, x2: Double, y2: Double, cap: PageCanvas.Cap = PageCanvas.Cap.SQUARE) =
        c.polyline(floatArrayOf(x1.toFloat(), y1.toFloat(), x2.toFloat(), y2.toFloat()), 2, TemplateRenderer.RULE_WIDTH, TemplateRenderer.RULE_COLOR, cap)

    /** Rows from `max(0, (clipY - y0) / pitch)` to `(clipY + clipH - y0) / pitch + 1`, columns to the right of the page start. */
    private fun hexagons(s: Spec, c: PageCanvas, left: Double, clipX: Double, clipY: Double, clipW: Double, clipH: Double) {
        val cols = ((clipW - s.x0).toInt() / s.step).toInt()
        val firstRow = max(0, ((clipY - s.y0) / s.pitch).toInt())
        val lastRow = ((clipY + clipH - s.y0).toInt() / s.pitch + 1.0).toInt()
        if (cols < 0) return
        for (row in firstRow..lastRow) {
            val y = s.y0 + row * s.pitch
            for (i in 0..cols) {
                val x = s.x0 + left + i * s.step
                if (x < clipX - s.step || x > clipX + clipW) continue
                val xm = x + s.step * 0.5; val xr = x + s.step
                val yTop = y + s.pitch / 6.0; val yMid = y + s.pitch * 0.5; val yLow = y + s.pitch * 2.0 / 3.0
                line(c, x, y, xm, yTop)
                line(c, xm, yTop, xm, yMid)
                line(c, xm, yTop, xr, y)
                line(c, x, yLow, xm, yMid)
                line(c, xm, yMid, xr, yLow)
                line(c, xr, yLow, xr, y + s.pitch)
            }
        }
    }

    private fun calligraphy(s: Spec, c: PageCanvas, left: Double, clipX: Double, clipY: Double, clipW: Double, clipH: Double) {
        val cols = ((clipW - s.x0).toInt() / s.step).toInt()
        val firstRow = max(0, ((clipY - s.y0) / s.pitch).toInt())
        val lastRow = ((clipY + clipH - s.y0).toInt() / s.pitch + 1.0).toInt()
        val lineStart = (if (s.large) clipX else left) + s.dashLead
        val lineEnd = left + clipW
        for (row in firstRow..lastRow) {
            val top = s.y0 + row * s.pitch
            val y1 = top + s.rule; val y2 = top + 2 * s.rule; val y3 = top + 3 * s.rule
            dashed(c, lineStart, lineEnd, top)
            dashed(c, lineStart, lineEnd, y1)
            dashed(c, lineStart, lineEnd, y3)
            line(c, clipX, y2, lineEnd, y2, PageCanvas.Cap.BUTT) // the baseline is solid
            // The large guides lean to the right, from the lowest to the top line.
            if (cols < 0) continue
            for (i in 0..cols) {
                // Medium sheets pull every second guide one unit closer, so the spacing alternates 45 / 44.
                val x = left + s.x0 + i * s.step - (if (s.large) 0.0 else floor(i / 2.0))
                if (s.large && (x < clipX - 30.0 || x > clipX + clipW)) continue
                line(c, x, y3, x + s.step + s.slantExtra, top, PageCanvas.Cap.BUTT)
            }
        }
    }

    private fun dashed(c: PageCanvas, x1: Double, x2: Double, y: Double) {
        var x = x1
        while (x < x2) {
            val e = minOf(x + DASH_ON, x2)
            line(c, x, y, e, y, PageCanvas.Cap.BUTT)
            x += DASH_ON + DASH_OFF
        }
    }
}
