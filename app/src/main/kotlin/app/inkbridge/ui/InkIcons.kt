package app.inkbridge.ui

import androidx.annotation.DrawableRes
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import app.inkbridge.R
import app.inkbridge.rm.edit.PenTool

/**
 * Toolbar and menu icons: the reMarkable 2 icon set (firmware 3.27.1.0), converted to vector drawables
 * `res/drawable/rm_*.xml` by `tools/svg_to_vector.py` (sources under `reference/`). Every icon is a single-colour
 * 48 x 48 glyph, so [tint] recolours it (white on a selected tile, light gray when disabled).
 */
object InkIcons {
    @Composable
    fun Pen(tool: PenTool, modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) =
        glyph(penRes(tool), modifier, tint, size)

    @Composable fun Eraser(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = glyph(R.drawable.rm_eraser, modifier, tint, size)
    @Composable fun Undo(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = glyph(R.drawable.rm_undo, modifier, tint, size)
    @Composable fun Redo(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = glyph(R.drawable.rm_redo, modifier, tint, size)

    /** Page overview: four small page tiles. */
    @Composable fun Overview(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = glyph(R.drawable.rm_page_overview, modifier, tint, size)

    /** The round toolbar toggle ("toolbar_hide"): a circle with a dot. */
    @Composable fun MenuDot(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = glyph(R.drawable.rm_toolbar_hide, modifier, tint, size)

    /** Thickness sample: a slanted stroke of the given [level] (1..3). */
    @Composable fun Thickness(level: Int, modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) =
        glyph(when (level) { 1 -> R.drawable.rm_stroke_thin; 2 -> R.drawable.rm_stroke_medium; else -> R.drawable.rm_stroke_thick }, modifier, tint, size)

    @Composable fun Search(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = glyph(R.drawable.rm_lens, modifier, tint, size)
    @Composable fun Plus(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = glyph(R.drawable.rm_plus, modifier, tint, size)

    /** A filled round close button (white cross on black). */
    @Composable fun CloseDisc(modifier: Modifier = Modifier, size: Dp = 40.dp) =
        Box(modifier.size(size), contentAlignment = Alignment.Center) {
            Canvas(Modifier.size(size)) { drawCircle(Ink.Dark, radius = this.size.minDimension * 17f / 48f, center = Offset(this.size.width / 2, this.size.height / 2)) }
            glyph(R.drawable.rm_x_medium, Modifier, Ink.White, size * 0.55f)
        }

    /** Three vertical dots: the "more" menu. */
    @Composable fun More(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = 40.dp) = glyph(R.drawable.rm_dots_three_vertical, modifier, tint, size)

    @DrawableRes
    private fun penRes(tool: PenTool): Int = when (tool) {
        PenTool.BALLPOINT -> R.drawable.rm_ballpoint
        PenTool.FINELINER -> R.drawable.rm_fineliner
        PenTool.MARKER -> R.drawable.rm_marker
        PenTool.PENCIL -> R.drawable.rm_pencil
        PenTool.MECHANICAL_PENCIL -> R.drawable.rm_mechanical_pencil
        PenTool.PAINTBRUSH -> R.drawable.rm_paintbrush
        PenTool.CALLIGRAPHY -> R.drawable.rm_calligraphy_pen
        PenTool.HIGHLIGHTER -> R.drawable.rm_highlighter
        PenTool.SHADER -> R.drawable.rm_shader
        PenTool.ERASER -> R.drawable.rm_eraser
    }

    @Composable
    private fun glyph(@DrawableRes id: Int, modifier: Modifier, tint: Color, size: Dp) =
        Image(painterResource(id), contentDescription = null, modifier = modifier.size(size), colorFilter = ColorFilter.tint(tint))
}
