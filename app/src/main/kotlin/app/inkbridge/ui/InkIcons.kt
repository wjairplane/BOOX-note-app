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
    fun Pen(tool: PenTool, modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) =
        glyph(penRes(tool), modifier, tint, size)

    @Composable fun Eraser(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_eraser, modifier, tint, size)
    @Composable fun Undo(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_undo, modifier, tint, size)
    @Composable fun Redo(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_redo, modifier, tint, size)

    /** Page overview: four small page tiles. */
    @Composable fun Overview(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_page_overview, modifier, tint, size)

    /** The round toolbar toggle ("toolbar_hide"): a circle with a dot. */
    @Composable fun MenuDot(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_toolbar_hide, modifier, tint, size)

    /** Thickness sample: a slanted stroke of the given [level] (1..3). */
    @Composable fun Thickness(level: Int, modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) =
        glyph(when (level) { 1 -> R.drawable.rm_stroke_thin; 2 -> R.drawable.rm_stroke_medium; else -> R.drawable.rm_stroke_thick }, modifier, tint, size)

    @Composable fun Search(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_lens, modifier, tint, size)
    @Composable fun Plus(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_plus, modifier, tint, size)

    /** A filled round close button (white cross on black). */
    @Composable fun CloseDisc(modifier: Modifier = Modifier, size: Dp = Rm.Icon) =
        Box(modifier.size(size), contentAlignment = Alignment.Center) {
            Canvas(Modifier.size(size)) { drawCircle(Ink.Dark, radius = this.size.minDimension * 17f / 48f, center = Offset(this.size.width / 2, this.size.height / 2)) }
            glyph(R.drawable.rm_x_medium, Modifier, Ink.White, size * 0.6f)
        }

    /** Three vertical dots: the "more" menu. */
    @Composable fun More(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_dots_three_vertical, modifier, tint, size)

    @Composable fun Menu(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_burger, modifier, tint, size)
    @Composable fun Back(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_arrow_left, modifier, tint, size)
    @Composable fun Settings(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_cog, modifier, tint, size)
    @Composable fun Star(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_star_fill, modifier, tint, size)
    @Composable fun Folder(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_folder_fill, modifier, tint, size)
    @Composable fun ChevronDown(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_chevron_small_down, modifier, tint, size)

    @Composable fun MyFiles(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_my_files, modifier, tint, size)
    @Composable fun StarOutline(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_star, modifier, tint, size)
    @Composable fun StarInverted(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_star_inverted, modifier, tint, size)
    @Composable fun Trash(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_trashcan, modifier, tint, size)
    @Composable fun Rename(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_text_edit, modifier, tint, size)
    @Composable fun Move(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_move, modifier, tint, size)
    @Composable fun Restore(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_arrow_counter_clockwise, modifier, tint, size)

    @Composable fun Tag(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_tag, modifier, tint, size)
    @Composable fun Duplicate(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_duplicate, modifier, tint, size)
    @Composable fun Notebook(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_notebook, modifier, tint, size)
    @Composable fun FolderOutline(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_folder, modifier, tint, size)
    @Composable fun QuickSheet(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_quick_sheet, modifier, tint, size)
    @Composable fun TrashDelete(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_trashcan_delete, modifier, tint, size)
    @Composable fun Help(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_question_circle, modifier, tint, size)
    @Composable fun ChevronLeft(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_chevron_left, modifier, tint, size)
    @Composable fun Scissors(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_cut, modifier, tint, size)
    @Composable fun Copy(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_copy, modifier, tint, size)
    @Composable fun Paste(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_paste, modifier, tint, size)
    @Composable fun ArrowUp(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_arrow_up, modifier, tint, size)
    @Composable fun ArrowDown(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_arrow_down, modifier, tint, size)
    @Composable fun Merge(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_merge, modifier, tint, size)
    @Composable fun InformationCircle(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_information_circle, modifier, tint, size)
    @Composable fun EraseSelection(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_erase_selection, modifier, tint, size)
    @Composable fun Cog(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_cog, modifier, tint, size)
    @Composable fun Lens(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_lens, modifier, tint, size)
    @Composable fun ChevronUp(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_chevron_up, modifier, tint, size)
    @Composable fun Share(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_share, modifier, tint, size)
    @Composable fun PageAdd(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_page_add, modifier, tint, size)
    @Composable fun Template(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_template, modifier, tint, size)
    @Composable fun Export(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_export, modifier, tint, size)
    @Composable fun Import(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_import, modifier, tint, size)
    @Composable fun Check(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_checkmark, modifier, tint, size)
    @Composable fun Sliders(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_sliders_horizontal, modifier, tint, size)

    @Composable fun ChevronRight(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_chevron_right, modifier, tint, size)

    @Composable fun CloseX(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_x_medium, modifier, tint, size)

    @Composable fun XCircle(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_x_circle, modifier, tint, size)
    @Composable fun Refresh(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_rotate, modifier, tint, size)

    @Composable fun SelectionTool(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_selection_tool, modifier, tint, size)
    @Composable fun FitToWidth(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_fit_to_width, modifier, tint, size)
    @Composable fun FitToHeight(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_fit_to_height, modifier, tint, size)
    @Composable fun FitCustom(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_fit_custom, modifier, tint, size)
    @Composable fun Eye(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_eye, modifier, tint, size)
    @Composable fun EyeClosed(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_eye_closed, modifier, tint, size)
    @Composable fun Layers(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_layers, modifier, tint, size)
    @Composable fun PlusCircle(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_plus_circle, modifier, tint, size)
    @Composable fun EraseAll(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_erase_all, modifier, tint, size)
    @Composable fun Filter(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_filter, modifier, tint, size)
    @Composable fun Compass(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_compass, modifier, tint, size)
    @Composable fun RestoreIcon(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_restore, modifier, tint, size)

    @Composable fun ChevronSmallRight(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_chevron_small_right, modifier, tint, size)
    @Composable fun ChevronSmallUp(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_chevron_small_up, modifier, tint, size)
    @Composable fun Ascend(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_ascend, modifier, tint, size)
    @Composable fun Descend(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_descend, modifier, tint, size)
    @Composable fun GridLarge(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_grid_large, modifier, tint, size)
    @Composable fun GridMedium(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_grid, modifier, tint, size)
    @Composable fun GridSmall(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_grid_small, modifier, tint, size)
    @Composable fun ListView(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_list, modifier, tint, size)
    @Composable fun FolderInverted(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_folder_inverted, modifier, tint, size)
    @Composable fun TagInverted(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_tag_inverted, modifier, tint, size)
    @Composable fun MoveHere(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_move_here, modifier, tint, size)
    @Composable fun Send(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_send, modifier, tint, size)
    @Composable fun Ebook(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_ebook, modifier, tint, size)
    @Composable fun PageFunnel(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_page_funnel, modifier, tint, size)
    @Composable fun Handwriting(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_note, modifier, tint, size)
    @Composable fun Cloud(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_cloud, modifier, tint, size)
    @Composable fun ThreeDots(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_three_dots_vertical, modifier, tint, size)

    @Composable fun Document(modifier: Modifier = Modifier, tint: Color = Ink.Black, size: Dp = Rm.Icon) = glyph(R.drawable.rm_document, modifier, tint, size)

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
        PenTool.SELECTION -> R.drawable.rm_selection_tool
        PenTool.ERASE_AREA -> R.drawable.rm_erase_selection
    }

    @Composable
    private fun glyph(@DrawableRes id: Int, modifier: Modifier, tint: Color, size: Dp) =
        Image(painterResource(id), contentDescription = null, modifier = modifier.size(size), colorFilter = ColorFilter.tint(tint))
}
