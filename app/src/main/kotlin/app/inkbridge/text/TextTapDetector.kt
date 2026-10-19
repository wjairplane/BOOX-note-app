package app.inkbridge.text

import android.view.MotionEvent
import kotlin.math.hypot

/**
 * Counts finger taps the way the firmware's touch area does for typed text (`00da6487`): a tap is a short touch that hardly
 * moves, and a tap that follows the last one within [MULTI_TAP_MS] and [MULTI_TAP_CM] adds to a count (1 caret, 2 word,
 * 3 paragraph, 4 everything; a fifth starts again). Only observes the events; it never consumes them.
 */
class TextTapDetector(private val pixelsPerCm: Float, private val onTap: (x: Float, y: Float, count: Int) -> Unit) {
    private var downTime = 0L
    private var downX = 0f
    private var downY = 0f
    private var valid = false

    private var lastUpTime = Long.MIN_VALUE / 2
    private var lastX = 0f
    private var lastY = 0f
    private var count = 0

    fun onTouch(e: MotionEvent) {
        if (e.getToolType(0) != MotionEvent.TOOL_TYPE_FINGER) { valid = false; return }
        when (e.actionMasked) {
            MotionEvent.ACTION_DOWN -> { downTime = e.eventTime; downX = e.x; downY = e.y; valid = true }
            MotionEvent.ACTION_POINTER_DOWN -> valid = false
            MotionEvent.ACTION_MOVE -> if (valid && hypot(e.x - downX, e.y - downY) > TAP_SLOP_CM * pixelsPerCm) valid = false
            MotionEvent.ACTION_CANCEL -> valid = false
            MotionEvent.ACTION_UP -> {
                if (!valid || e.eventTime - downTime > TAP_MS) { valid = false; return }
                valid = false
                val again = downTime - lastUpTime <= MULTI_TAP_MS && hypot(downX - lastX, downY - lastY) <= MULTI_TAP_CM * pixelsPerCm
                count = if (again && count < MAX_TAPS) count + 1 else 1
                lastUpTime = e.eventTime; lastX = downX; lastY = downY
                onTap(downX, downY, count)
            }
        }
    }

    /** Forget the taps so far (e.g. when the mode changes). */
    fun reset() { count = 0; lastUpTime = Long.MIN_VALUE / 2; valid = false }

    companion object {
        const val TAP_MS = 350L
        const val TAP_SLOP_CM = 0.4f
        const val MULTI_TAP_MS = 300L
        const val MULTI_TAP_CM = 0.6f
        const val MAX_TAPS = 4
    }
}
