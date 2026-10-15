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
 * Converts raw pen samples into a reMarkable [Line] the way the tablet records them ([FirmwareRecorder]).
 */
object StrokeBuilder {
    private const val SHADER_ALPHA = 100

    /**
     * Build a stroke whose points are expressed relative to its layer ([ox], [oy] is the layer's
     * page-space offset). Returns null for non-pen tools or empty input.
     */
    fun build(spec: PenSpec, input: List<InputPoint>, ox: Float = 0f, oy: Float = 0f): Line? {
        if (!spec.tool.isPen || input.isEmpty()) return null

        // The tablet records every sample the digitizer gives; only exact repeats are dropped.
        val kept = ArrayList<InputPoint>(input.size)
        for (p in input) {
            val last = kept.lastOrNull()
            if (last == null || p.x != last.x || p.y != last.y) kept += p
        }
        // A tap: give it a tiny extent so it renders as a dot.
        if (kept.size == 1) kept += kept[0].copy(x = kept[0].x + 0.1f)

        val toRad = (PI / 180.0).toFloat()
        val samples = kept.map { FirmwareRecorder.Sample(it.x - ox, it.y - oy, it.pressure.coerceIn(0f, 1f), it.tiltX * toRad, it.tiltY * toRad) }
        // A highlighter has no thickness setting; its width is the firmware's fixed 30.
        val points = FirmwareRecorder.record(spec.tool.toolId, if (spec.tool.isHighlighter) 1.0 else spec.thickness.toDouble(), samples)
        // A highlighter and the shader are stored the way newer firmware stores them: the "highlight" colour id plus an explicit RGBA
        // (the highlighter's opaque light shade, the shader's translucent one: the sample pages use alpha 64..128 of 255).
        val shaderRgba = when {
            spec.tool == PenTool.HIGHLIGHTER -> PenPalette.highlighter(spec.colorId)
            spec.tool == PenTool.SHADER -> PenPalette.lookup(spec.colorId, null).let { intArrayOf(it[0], it[1], it[2], SHADER_ALPHA) }
            else -> null
        }
        return Line(
            tool = spec.tool.toolId,
            color = if (shaderRgba != null) PenColorId.HIGHLIGHT else spec.colorId,
            points = points,
            thicknessScale = if (spec.tool.isHighlighter) 1.0 else spec.thickness.toDouble(),
            startingLength = 0f,
            colorRgba = shaderRgba,
        )
    }
}
