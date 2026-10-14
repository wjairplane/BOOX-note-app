package app.inkbridge.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import app.inkbridge.rm.edit.PenTool

/**
 * Simple line icons, drawn in code on a 48 x 48 grid (original drawings; they only follow the usual
 * visual language of thin outlines with a filled tip). Pen icons show the tip pointing up.
 */
object InkIcons {
    private const val GRID = 48f
    private const val LINE = 2.6f

    @Composable
    fun Pen(tool: PenTool, modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) =
        icon(modifier, size) { drawPen(tool, tint) }

    @Composable fun Eraser(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = icon(modifier, size) {
        outline(tint, Path().apply { moveTo(9f, 30f); lineTo(25f, 12f); lineTo(39f, 24f); lineTo(23f, 42f); close() })
        line(tint, 17f, 36f, 31f, 18f)
        line(tint, 14f, 44f, 38f, 44f)
    }

    @Composable fun Undo(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = icon(modifier, size) { drawArrow(tint, mirror = false) }
    @Composable fun Redo(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = icon(modifier, size) { drawArrow(tint, mirror = true) }

    /** Page overview: four small squares. */
    @Composable fun Overview(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = icon(modifier, size) {
        for (x in listOf(10f, 26f)) for (y in listOf(10f, 26f)) outline(tint, Path().apply { addRect(androidx.compose.ui.geometry.Rect(x, y, x + 12f, y + 12f)) })
    }

    /** The round menu button at the end of the toolbar: a circle with a dot. */
    @Composable fun MenuDot(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = icon(modifier, size) {
        drawCircle(tint, radius = 12f, center = Offset(24f, 24f), style = Stroke(LINE))
        drawCircle(tint, radius = 3.2f, center = Offset(24f, 24f))
    }

    /** Thickness sample: a slanted stroke of the given [level] (1..3). */
    @Composable fun Thickness(level: Int, modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = icon(modifier, size) {
        drawLine(tint, Offset(15f, 38f), Offset(33f, 10f), strokeWidth = 2f + level * 2.6f, cap = StrokeCap.Round)
    }

    @Composable fun Search(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = icon(modifier, size) {
        drawCircle(tint, radius = 10f, center = Offset(21f, 21f), style = Stroke(LINE))
        line(tint, 28.5f, 28.5f, 38f, 38f)
    }

    @Composable fun Plus(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = icon(modifier, size) {
        line(tint, 24f, 11f, 24f, 37f); line(tint, 11f, 24f, 37f, 24f)
    }

    /** A filled round close button (white cross on black). */
    @Composable fun CloseDisc(modifier: Modifier = Modifier, size: Dp = 40.dp) = icon(modifier, size) {
        drawCircle(Ink.Dark, radius = 17f, center = Offset(24f, 24f))
        line(Ink.White, 17f, 17f, 31f, 31f); line(Ink.White, 31f, 17f, 17f, 31f)
    }

    /** Three vertical dots: the "more" menu. */
    @Composable fun More(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = icon(modifier, size) {
        for (y in listOf(12f, 24f, 36f)) drawCircle(tint, 3f, Offset(24f, y))
    }

    // ---- drawing helpers ----

    @Composable
    private fun icon(modifier: Modifier, size: Dp, draw: DrawScope.() -> Unit) =
        Canvas(modifier.size(size)) { scale(this.size.minDimension / GRID, pivot = Offset.Zero) { draw() } }

    private fun DrawScope.outline(c: Color, p: Path) = drawPath(p, c, style = Stroke(LINE, cap = StrokeCap.Round, join = StrokeJoin.Round))
    private fun DrawScope.fill(c: Color, p: Path) = drawPath(p, c, style = Fill)
    private fun DrawScope.line(c: Color, x1: Float, y1: Float, x2: Float, y2: Float) =
        drawLine(c, Offset(x1, y1), Offset(x2, y2), strokeWidth = LINE, cap = StrokeCap.Round)

    private fun poly(vararg xy: Float, close: Boolean = true) = Path().apply {
        moveTo(xy[0], xy[1]); for (i in 2 until xy.size step 2) lineTo(xy[i], xy[i + 1]); if (close) close()
    }

    private fun DrawScope.drawArrow(tint: Color, mirror: Boolean) {
        fun x(v: Float) = if (mirror) GRID - v else v
        val p = Path().apply { moveTo(x(36f), 36f); cubicTo(x(37f), 24f, x(26f), 16f, x(14f), 22f) }
        drawPath(p, tint, style = Stroke(LINE, cap = StrokeCap.Round))
        line(tint, x(14f), 22f, x(20f), 14f)
        line(tint, x(14f), 22f, x(22f), 27f)
    }

    /** Common base of every pen icon: a small "A"-frame (flared body with a crossbar), as on the tablet's own icons. */
    private fun DrawScope.penBase(c: Color) {
        outline(c, poly(13f, 44f, 35f, 44f, 30f, 25f, 18f, 25f))
        line(c, 15.5f, 36f, 32.5f, 36f)
    }

    private fun DrawScope.drawPen(tool: PenTool, c: Color) {
        penBase(c)
        when (tool) {
            PenTool.BALLPOINT -> { outline(c, poly(18f, 25f, 30f, 25f, 24f, 13f)); drawCircle(c, 2.8f, Offset(24f, 8.5f)) }
            PenTool.FINELINER -> fill(c, poly(21.5f, 25f, 26.5f, 25f, 24f, 7f))
            PenTool.MARKER -> fill(c, poly(18f, 25f, 30f, 25f, 30f, 14f, 24f, 9f, 18f, 14f))
            PenTool.PENCIL -> { outline(c, poly(18f, 25f, 30f, 25f, 24f, 7f)); fill(c, poly(24f, 7f, 26.4f, 13.5f, 21.6f, 13.5f)) }
            PenTool.MECHANICAL_PENCIL -> { outline(c, poly(21f, 25f, 27f, 25f, 26f, 13f, 22f, 13f)); line(c, 24f, 13f, 24f, 6f) }
            PenTool.PAINTBRUSH -> fill(c, Path().apply {
                moveTo(24f, 6f); cubicTo(31f, 12f, 32f, 19f, 30f, 25f); lineTo(18f, 25f); cubicTo(16f, 19f, 17f, 12f, 24f, 6f); close()
            })
            PenTool.CALLIGRAPHY -> {
                outline(c, poly(24f, 7f, 31f, 16f, 24f, 25f, 17f, 16f))
                fill(c, poly(24f, 7f, 31f, 16f, 24f, 16f))
                line(c, 24f, 16f, 24f, 25f)
            }
            PenTool.HIGHLIGHTER -> fill(c, poly(15f, 25f, 33f, 25f, 33f, 14f, 27f, 8f, 15f, 14f))
            PenTool.SHADER -> {
                outline(c, poly(15f, 25f, 33f, 25f, 33f, 10f, 15f, 10f))
                for (k in 0..2) line(c, 18f + k * 6f, 25f, 24f + k * 6f - 6f, 10f)
            }
            PenTool.ERASER -> Unit
        }
    }
}
