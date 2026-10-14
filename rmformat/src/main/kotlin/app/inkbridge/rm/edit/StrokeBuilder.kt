package app.inkbridge.rm.edit

import app.inkbridge.rm.render.PenPalette
import app.inkbridge.rm.scene.Line
import app.inkbridge.rm.scene.PenColorId
import app.inkbridge.rm.scene.Point
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.roundToInt

/** One digitizer sample in page units. [pressure] is 0..1; tilt is in degrees (0 when unknown). */
data class InputPoint(
    val x: Float,
    val y: Float,
    val pressure: Float,
    val tiltX: Float = 0f,
    val tiltY: Float = 0f,
    val timeMs: Long = 0L,
)

/**
 * Converts raw pen samples into a reMarkable [Line]. Per-pen width formulas and the speed scale
 * are fitted to real device files (sample pages from firmware 3.x), not taken from reMarkable code.
 */
object StrokeBuilder {
    /** Samples closer than this (page units) to the previous kept one are dropped. */
    const val MIN_POINT_SPACING = 0.4f

    /** Nominal digitizer interval used when timestamps are missing or identical. */
    private const val NOMINAL_DT_MS = 5.0

    /** File speed ≈ 2.1 × distance per nominal sample interval (median fit over sample pages). */
    private const val SPEED_PER_UNIT = 2.1

    private const val SHADER_ALPHA = 100

    /**
     * Build a stroke whose points are expressed relative to its layer ([ox], [oy] is the layer's
     * page-space offset). Returns null for non-pen tools or empty input.
     */
    fun build(spec: PenSpec, input: List<InputPoint>, ox: Float = 0f, oy: Float = 0f): Line? {
        if (!spec.tool.isPen || input.isEmpty()) return null

        val kept = ArrayList<InputPoint>(input.size)
        for (p in input) {
            val last = kept.lastOrNull()
            if (last == null || hypot(p.x - last.x, p.y - last.y) >= MIN_POINT_SPACING) kept += p
        }
        // Keep the true end of the stroke even if it was within the spacing of the last kept point.
        val end = input.last()
        if (kept.last() !== end && (end.x != kept.last().x || end.y != kept.last().y)) kept += end
        // A tap: give it a tiny extent so it renders as a dot.
        if (kept.size == 1) kept += kept[0].copy(x = kept[0].x + 0.1f)

        val points = ArrayList<Point>(kept.size)
        for ((i, p) in kept.withIndex()) {
            val prev = kept.getOrNull(i - 1)
            val dist = if (prev == null) 0.0 else hypot((p.x - prev.x).toDouble(), (p.y - prev.y).toDouble())
            val dt = if (prev == null) NOMINAL_DT_MS else (p.timeMs - prev.timeMs).toDouble().takeIf { it > 0 } ?: NOMINAL_DT_MS
            val pressure01 = p.pressure.coerceIn(0f, 1f)
            points += Point(
                x = p.x - ox,
                y = p.y - oy,
                speed = (dist * SPEED_PER_UNIT * (NOMINAL_DT_MS / dt)).roundToInt().coerceIn(0, 0xFFFF),
                direction = direction(p.tiltX, p.tiltY),
                width = widthRaw(spec, pressure01),
                pressure = (pressure01 * 255).roundToInt().coerceIn(0, 255),
            )
        }
        // The shader is stored the way newer firmware stores it: the "highlight" colour id plus an explicit,
        // translucent RGBA (the sample pages use alpha 64..128 of 255).
        val needsRgba = spec.tool == PenTool.SHADER || spec.colorId == PenColorId.ORANGE
        val shaderRgba = if (needsRgba) {
            val c = PenPalette.lookup(spec.colorId, null)
            // Shader: translucent. Orange highlighter: opaque RGBA (the pen's own opacity makes it a highlight).
            intArrayOf(c[0], c[1], c[2], if (spec.tool == PenTool.SHADER) SHADER_ALPHA else 255)
        } else null
        return Line(
            tool = spec.tool.toolId,
            color = if (shaderRgba != null) PenColorId.HIGHLIGHT else spec.colorId,
            points = points,
            thicknessScale = if (spec.tool.isHighlighter) 1.0 else spec.thickness.toDouble(),
            startingLength = 0f,
            colorRgba = shaderRgba,
        )
    }

    /** Pen azimuth from tilt, scaled 0..255 over a full turn (0 when the pen reports no tilt). */
    fun direction(tiltX: Float, tiltY: Float): Int {
        if (tiltX == 0f && tiltY == 0f) return 0
        var a = atan2(tiltY.toDouble(), tiltX.toDouble())
        if (a < 0) a += 2 * PI
        return (a / (2 * PI) * 255).roundToInt().coerceIn(0, 255)
    }

    /**
     * Raw point width (file units: page units x 4).
     * FITTED to real device pages: fineliner (constant, 8 x thickness), ballpoint (grows ~50% with pressure),
     * highlighter (fixed 120).
     * ESTIMATED, no sample data: pencil reuses the ballpoint shape; marker, mechanical pencil, paintbrush and
     * calligraphy use plausible shapes that the renderer's pen formulas then modulate. Tune these by feel.
     */
    fun widthRaw(spec: PenSpec, pressure01: Float): Int {
        val th = spec.thickness
        val ballpointLike = max(6 * th, 8) * (1 + 0.5f * pressure01)
        return when (spec.tool) {
            PenTool.FINELINER -> 8 * th
            PenTool.HIGHLIGHTER -> 120
            // Fitted: thickness 1.2 spans raw 19..56 and thickness 2 spans 29..88 in real pages.
            PenTool.SHADER -> (th * (14 + 30 * pressure01)).roundToInt()
            PenTool.BALLPOINT, PenTool.PENCIL -> ballpointLike.roundToInt()
            PenTool.MARKER -> (16 * th).coerceAtLeast(16)
            PenTool.MECHANICAL_PENCIL -> (5 * th).coerceAtLeast(6)
            PenTool.PAINTBRUSH -> (th * (8 + 16 * pressure01)).roundToInt()
            PenTool.CALLIGRAPHY -> (th * (8 + 12 * pressure01)).roundToInt()
            PenTool.ERASER, PenTool.SELECTION, PenTool.ERASE_AREA -> 0
        }
    }
}
