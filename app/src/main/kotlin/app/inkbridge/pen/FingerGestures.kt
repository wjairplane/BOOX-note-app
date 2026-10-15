package app.inkbridge.pen

import android.view.MotionEvent
import kotlin.math.abs
import kotlin.math.hypot

/**
 * The reMarkable's touch gestures (xochitl 3.27.1.0, the document view's touch area), for finger input:
 *
 * - one finger, horizontal swipe: flip page. A short swipe (0.6 cm) counts when the finger lifts; a long one (3 cm) at once.
 * - one finger, vertical swipe: jump (scroll a screen at a time inside a zoomed page), when the finger lifts.
 * - one finger, swipe down from the top edge (1 cm zone): close the document; from the top-right corner: quick settings.
 * - one finger, swipe up from the bottom edge: quick browse (the page slider).
 * - two fingers, swipe down from the top edge: the document drawer.
 * - two or more fingers, drag and pinch: pan and zoom.
 * - a quick tap with two fingers undoes, with three redoes, with five clears ghosting.
 *
 * Gestures are ignored for a moment after the pen was used, so a resting palm never turns a page.
 */
class FingerGestures(private val pixelsPerCm: Float, private val host: Host) {

    interface Host {
        val viewWidth: Int
        val viewHeight: Int
        /** Milliseconds since the pen last touched or hovered near the screen. */
        fun msSincePen(): Long
        fun onTap(fingers: Int)
        fun onPageSwipe(forward: Boolean)
        fun onJump(down: Boolean)
        fun onEdgeSwipe(edge: Edge)
        fun onViewBegin()
        /** The view gesture so far: zoom [scale] about ([focusX], [focusY]) (the fingers' first centre), then pan by ([panX], [panY]). */
        fun onViewUpdate(scale: Float, focusX: Float, focusY: Float, panX: Float, panY: Float)
        fun onViewEnd(scale: Float, focusX: Float, focusY: Float, panX: Float, panY: Float)
    }

    enum class Edge { CLOSE, QUICK_SETTINGS, DRAWER, QUICK_BROWSE }

    private val cm get() = pixelsPerCm
    private val edge get() = cm                      // the zone along an edge where edge swipes start
    private val quickSettingsWidth get() = 3.9f * cm // 350 reMarkable px

    private enum class Mode { IDLE, BLOCKED, ONE, MULTI, DONE }
    private var mode = Mode.IDLE

    private var downTime = 0L
    private var startX = 0f
    private var startY = 0f
    private var maxFingers = 0
    private var moved = false

    // Two or more fingers.
    private var c0x = 0f; private var c0y = 0f; private var span0 = 1f
    private var multiTime = 0L
    private var viewActive = false
    private var lastScale = 1f; private var lastPanX = 0f; private var lastPanY = 0f
    private var multiStartTop = false

    /** True while a pinch / pan is being followed (the surface shows a live preview then). */
    val viewGestureActive: Boolean get() = viewActive

    /** Feed one touch event (finger only). */
    fun onTouchEvent(e: MotionEvent) {
        when (e.actionMasked) {
            MotionEvent.ACTION_DOWN -> down(e)
            MotionEvent.ACTION_POINTER_DOWN -> pointerDown(e)
            MotionEvent.ACTION_MOVE -> move(e)
            MotionEvent.ACTION_POINTER_UP -> pointerUp(e)
            MotionEvent.ACTION_UP -> up(e)
            MotionEvent.ACTION_CANCEL -> cancel()
        }
    }

    private fun down(e: MotionEvent) {
        startX = e.x; startY = e.y; downTime = e.eventTime; maxFingers = 1; moved = false; viewActive = false
        mode = if (host.msSincePen() < PEN_QUIET_MS) Mode.BLOCKED else Mode.ONE
    }

    private fun pointerDown(e: MotionEvent) {
        maxFingers = maxOf(maxFingers, e.pointerCount)
        if (mode == Mode.BLOCKED || mode == Mode.DONE) return
        if (mode == Mode.ONE || (mode == Mode.MULTI && !viewActive && e.pointerCount > 2)) beginMulti(e)
    }

    private fun beginMulti(e: MotionEvent) {
        mode = Mode.MULTI
        c0x = centreX(e); c0y = centreY(e); span0 = span(e).coerceAtLeast(1f); multiTime = if (maxFingers <= 2) downTime else e.eventTime
        // Both fingers must start in the top strip (the drawer's area is 200 px high) for the drawer.
        multiStartTop = startY < 1.7f * cm && e.getY(e.pointerCount - 1) < 1.7f * cm
    }

    private fun move(e: MotionEvent) {
        when (mode) {
            Mode.ONE -> moveOne(e)
            Mode.MULTI -> moveMulti(e)
            else -> Unit
        }
    }

    private fun moveOne(e: MotionEvent) {
        val dx = e.x - startX; val dy = e.y - startY
        if (hypot(dx, dy) > TAP_SLOP_CM * cm) moved = true
        val horizontal = abs(dx) > abs(dy) * 1.5f
        val vertical = abs(dy) > abs(dx) * 1.5f
        // A long swipe turns the page without waiting for the finger to lift.
        if (horizontal && abs(dx) >= LONG_SWIPE_CM * cm && startedAwayFromEdges()) {
            mode = Mode.DONE; host.onPageSwipe(forward = dx < 0); return
        }
        if (vertical && dy >= EDGE_SWIPE_CM * cm && startY < edge) {
            mode = Mode.DONE
            host.onEdgeSwipe(if (startX >= host.viewWidth - quickSettingsWidth) Edge.QUICK_SETTINGS else Edge.CLOSE); return
        }
        if (vertical && -dy >= EDGE_SWIPE_CM * cm && startY > host.viewHeight - edge) {
            mode = Mode.DONE; host.onEdgeSwipe(Edge.QUICK_BROWSE)
        }
    }

    private fun startedAwayFromEdges() = startY >= edge && startY <= host.viewHeight - edge

    private fun moveMulti(e: MotionEvent) {
        if (e.pointerCount < 2) return
        val cx = centreX(e); val cy = centreY(e)
        val scale = span(e) / span0
        val dx = cx - c0x; val dy = cy - c0y
        if (!viewActive) {
            val travelled = hypot(dx, dy)
            if (travelled > TAP_SLOP_CM * cm) moved = true
            if (maxFingers == 2 && multiStartTop && dy >= DRAWER_SWIPE_CM * cm && abs(dy) > abs(dx) * 1.5f) {
                mode = Mode.DONE; host.onEdgeSwipe(Edge.DRAWER); return
            }
            if (maxFingers > 2) return // taps only
            if (travelled > PAN_START_CM * cm || abs(scale - 1f) > SCALE_START) {
                viewActive = true; lastScale = 1f; lastPanX = 0f; lastPanY = 0f
                host.onViewBegin()
            } else return
        }
        lastScale = scale; lastPanX = dx; lastPanY = dy
        host.onViewUpdate(scale, c0x, c0y, dx, dy)
    }

    private fun pointerUp(e: MotionEvent) {
        if (mode == Mode.MULTI && viewActive) finishView()
    }

    private fun up(e: MotionEvent) {
        when (mode) {
            Mode.ONE -> upOne(e)
            Mode.MULTI -> if (viewActive) finishView() else if (!moved && e.eventTime - downTime < TAP_MS) tapped()
            else -> Unit
        }
        mode = Mode.IDLE; viewActive = false
    }

    private fun tapped() {
        when (maxFingers) { 2, 3, 5 -> if (host.msSincePen() >= (if (maxFingers == 5) PEN_QUIET_MS else UNDO_QUIET_MS)) host.onTap(maxFingers) }
    }

    private fun upOne(e: MotionEvent) {
        val dx = e.x - startX; val dy = e.y - startY
        val horizontal = abs(dx) > abs(dy) * 1.5f
        val vertical = abs(dy) > abs(dx) * 1.5f
        when {
            horizontal && abs(dx) >= SHORT_SWIPE_CM * cm -> host.onPageSwipe(forward = dx < 0)
            vertical && abs(dy) >= JUMP_SWIPE_CM * cm -> host.onJump(down = dy < 0)
        }
    }

    private fun finishView() {
        viewActive = false; mode = Mode.DONE
        host.onViewEnd(lastScale, c0x, c0y, lastPanX, lastPanY)
    }

    /** Back to idle (a cancelled touch must not leave the preview on screen). */
    fun cancel() {
        if (viewActive) { viewActive = false; host.onViewEnd(1f, c0x, c0y, 0f, 0f) }
        mode = Mode.IDLE
    }

    private fun centreX(e: MotionEvent): Float { var s = 0f; for (i in 0 until e.pointerCount) s += e.getX(i); return s / e.pointerCount }
    private fun centreY(e: MotionEvent): Float { var s = 0f; for (i in 0 until e.pointerCount) s += e.getY(i); return s / e.pointerCount }
    /** Mean distance of the fingers from their centre, times two (the distance between two fingers). */
    private fun span(e: MotionEvent): Float {
        val cx = centreX(e); val cy = centreY(e); var s = 0f
        for (i in 0 until e.pointerCount) s += hypot(e.getX(i) - cx, e.getY(i) - cy)
        return 2f * s / e.pointerCount
    }

    companion object {
        const val SHORT_SWIPE_CM = 0.6f
        const val LONG_SWIPE_CM = 3.0f
        const val JUMP_SWIPE_CM = 1.5f
        const val EDGE_SWIPE_CM = 1.0f
        const val DRAWER_SWIPE_CM = 0.3f
        const val TAP_SLOP_CM = 0.4f
        const val PAN_START_CM = 0.5f
        const val SCALE_START = 0.08f
        const val TAP_MS = 350L
        const val PEN_QUIET_MS = 500L
        const val UNDO_QUIET_MS = 200L
    }
}
