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

    private fun DrawScope.drawPen(tool: PenTool, c: Color) {
        when (tool) {
            PenTool.BALLPOINT -> {
                outline(c, poly(24f, 8f, 30f, 24f, 30f, 44f, 18f, 44f, 18f, 24f))
                drawCircle(c, 2.6f, Offset(24f, 8f))
                line(c, 18f, 34f, 30f, 34f)
            }
            PenTool.FINELINER -> {
                outline(c, poly(24f, 4f, 27.5f, 20f, 27.5f, 44f, 20.5f, 44f, 20.5f, 20f))
                fill(c, poly(24f, 4f, 25.8f, 12f, 22.2f, 12f))
                line(c, 20.5f, 30f, 27.5f, 30f)
            }
            PenTool.MARKER -> {
                outline(c, poly(20f, 8f, 28f, 8f, 32f, 24f, 32f, 44f, 16f, 44f, 16f, 24f))
                fill(c, poly(20f, 8f, 28f, 8f, 32f, 24f, 16f, 24f))
            }
            PenTool.PENCIL -> {
                outline(c, poly(24f, 5f, 31f, 22f, 17f, 22f))
                fill(c, poly(24f, 5f, 26.6f, 11.5f, 21.4f, 11.5f))
                outline(c, poly(17f, 22f, 31f, 22f, 31f, 44f, 17f, 44f))
                line(c, 17f, 29f, 31f, 29f)
            }
            PenTool.MECHANICAL_PENCIL -> {
                line(c, 24f, 4f, 24f, 14f)
                outline(c, poly(20f, 14f, 28f, 14f, 30f, 22f, 18f, 22f))
                outline(c, poly(18f, 22f, 30f, 22f, 30f, 44f, 18f, 44f))
                for (y in listOf(29f, 34f, 39f)) line(c, 21f, y, 27f, y)
            }
            PenTool.PAINTBRUSH -> {
                fill(c, Path().apply { moveTo(24f, 4f); cubicTo(31f, 12f, 31f, 20f, 28f, 26f); lineTo(20f, 26f); cubicTo(17f, 20f, 17f, 12f, 24f, 4f); close() })
                outline(c, poly(20f, 26f, 28f, 26f, 28f, 32f, 20f, 32f))
                outline(c, poly(21.5f, 32f, 26.5f, 32f, 26f, 44f, 22f, 44f))
            }
            PenTool.CALLIGRAPHY -> {
                outline(c, poly(24f, 4f, 33f, 17f, 24f, 27f, 15f, 17f))
                fill(c, poly(24f, 4f, 33f, 17f, 24f, 18f))
                line(c, 24f, 18f, 24f, 27f)
                outline(c, poly(19f, 27f, 29f, 27f, 29f, 44f, 19f, 44f))
            }
            PenTool.HIGHLIGHTER -> {
                outline(c, poly(16f, 8f, 32f, 8f, 35f, 22f, 13f, 22f))
                fill(c, poly(16f, 8f, 32f, 8f, 33.5f, 15f, 14.5f, 15f))
                outline(c, poly(13f, 22f, 35f, 22f, 35f, 44f, 13f, 44f))
                line(c, 18f, 33f, 30f, 33f)
            }
            PenTool.SHADER -> {
                outline(c, poly(11f, 8f, 37f, 8f, 37f, 28f, 11f, 28f))
                for (k in 0..3) line(c, 15f + k * 7f, 26f, 22f + k * 7f - 7f + 3f, 10f)
                outline(c, poly(19f, 28f, 29f, 28f, 29f, 44f, 19f, 44f))
            }
            PenTool.ERASER -> Unit
        }
    }
}
