package app.inkbridge.rm.edit

import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.sin

/**
 * What a pen stroke made with the selection tool does to the current selection: it moves it (started inside the frame),
 * resizes it (started on a corner handle) or rotates it (started on the round handle above the frame).
 * All numbers are in one coordinate space (view pixels while drawing, page units when applied).
 */
object SelectionGesture {
    enum class Mode { NONE, MOVE, SCALE, ROTATE }

    /** [anchorX]/[anchorY]: the fixed point of a SCALE (the opposite corner) or the centre of a ROTATE. */
    class Hit(val mode: Mode, val anchorX: Float = 0f, val anchorY: Float = 0f)

    class Frame(val left: Float, val top: Float, val right: Float, val bottom: Float) {
        val centerX get() = (left + right) / 2
        val centerY get() = (top + bottom) / 2
        /** Corner handles, clockwise from the top left. */
        fun corners() = listOf(left to top, right to top, right to bottom, left to bottom)
        /** The rotate handle: centred above the top edge. */
        fun rotateHandle(offset: Float) = centerX to (top - offset)
    }

    /** Handles are 30 px squares (rotate: a 40 px circle) with a 15 px touch margin, as in the firmware. */
    const val HANDLE_SIZE = 30f
    const val ROTATE_SIZE = 40f
    const val HANDLE_RADIUS = 30f
    /** The rotate handle is centred on the middle of the top edge. */
    const val ROTATE_OFFSET = 0f

    fun hit(frame: Frame, x: Float, y: Float, radius: Float = HANDLE_RADIUS, rotateOffset: Float = ROTATE_OFFSET): Hit {
        val (rx, ry) = frame.rotateHandle(rotateOffset)
        if (hypot(x - rx, y - ry) <= radius) return Hit(Mode.ROTATE, frame.centerX, frame.centerY)
        // On a small selection the corner handles shrink so the middle can still be grabbed to move it.
        val cornerRadius = minOf(radius, 0.3f * minOf(frame.right - frame.left, frame.bottom - frame.top))
        val corners = frame.corners()
        for ((i, c) in corners.withIndex()) {
            if (hypot(x - c.first, y - c.second) <= cornerRadius) {
                val opposite = corners[(i + 2) % 4]
                return Hit(Mode.SCALE, opposite.first, opposite.second)
            }
        }
        if (x in frame.left..frame.right && y in frame.top..frame.bottom) return Hit(Mode.MOVE)
        return Hit(Mode.NONE)
    }

    /** The map for dragging from ([sx], [sy]) to ([cx], [cy]) with the given [hit]. */
    fun transform(hit: Hit, sx: Float, sy: Float, cx: Float, cy: Float): PageEditor.Affine = when (hit.mode) {
        Mode.MOVE -> PageEditor.Affine(1f, 0f, 0f, 1f, cx - sx, cy - sy)
        Mode.SCALE -> {
            val d0 = hypot(sx - hit.anchorX, sy - hit.anchorY)
            val k = if (d0 < 1f) 1f else (hypot(cx - hit.anchorX, cy - hit.anchorY) / d0).coerceIn(0.1f, 10f)
            PageEditor.Affine(k, 0f, 0f, k, hit.anchorX * (1 - k), hit.anchorY * (1 - k))
        }
        Mode.ROTATE -> {
            var t = atan2(cy - hit.anchorY, cx - hit.anchorX) - atan2(sy - hit.anchorY, sx - hit.anchorX)
            // Snap to the quarter and eighth turns (0, 45, 90, ...) when within about 10 degrees.
            val step = (Math.PI / 4).toFloat()
            val nearest = Math.round(t / step) * step
            if (kotlin.math.abs(t - nearest) < Math.toRadians(10.0)) t = nearest
            val co = cos(t); val si = sin(t)
            PageEditor.Affine(co, si, -si, co, hit.anchorX - (co * hit.anchorX - si * hit.anchorY), hit.anchorY - (si * hit.anchorX + co * hit.anchorY))
        }
        Mode.NONE -> PageEditor.Affine.IDENTITY
    }

    /** The outline of [frame] after [m]: the four corners, clockwise. */
    fun mapped(frame: Frame, m: PageEditor.Affine): List<Pair<Float, Float>> =
        frame.corners().map { (x, y) -> (m.a * x + m.c * y + m.tx) to (m.b * x + m.d * y + m.ty) }

    /**
     * A map expressed in view pixels, as the same map in page units, for a view that shows the page at
     * `view = scale * page + (originX, originY)`.
     */
    fun viewToPage(m: PageEditor.Affine, scale: Float, originX: Float, originY: Float): PageEditor.Affine = PageEditor.Affine(
        m.a, m.b, m.c, m.d,
        (m.a * originX + m.c * originY + m.tx - originX) / scale,
        (m.b * originX + m.d * originY + m.ty - originY) / scale,
    )
}
