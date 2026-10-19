package app.inkbridge

import app.inkbridge.pen.HoldGesture
import app.inkbridge.pen.PenSample
import org.junit.Assert.*
import org.junit.Test

/** The firmware's draw-and-hold timing: still for 250 ms, looked at every 100 ms, within 0.5 page units between looks. */
class HoldGestureTest {
    private fun moving(n: Int) = (0 until n).map { PenSample(100f + it * 8f, 300f, 0.5f, 0f, 0f, it * 10L) }
    private fun resting(from: Int, t0: Long, ms: Long, x: Float = 100f + (from - 1) * 8f) =
        (0..(ms / 10)).map { PenSample(x, 300f, 0.5f, 0f, 0f, t0 + it * 10L) }

    @Test fun aHoldOfHalfASecondKeepsTheStrokeAndDropsTheTail() {
        val move = moving(30)
        val body = HoldGesture.body(move + resting(30, 300L, 500), radius = 0.5f)
        assertNotNull(body)
        assertEquals(29, body!!.size - 1)
        assertEquals(100f + 29 * 8f, body.last().x, 0.01f)
    }

    @Test fun twoHundredMillisecondsIsTooShort() {
        assertNull(HoldGesture.body(moving(30) + resting(30, 300L, 200), radius = 0.5f))
    }

    @Test fun creepingFasterThanTheRadiusBreaksTheHold() {
        val creep = (0..60).map { PenSample(330f + it * 1.5f, 300f, 0.5f, 0f, 0f, 300L + it * 10L) } // 15 px per 100 ms
        assertNull(HoldGesture.body(moving(30) + creep, radius = 0.5f))
    }

    @Test fun aStrokeWithFewerThanTenPointsNeverHolds() {
        assertNull(HoldGesture.body(moving(4) + resting(4, 40L, 600, 124f).take(5), radius = 0.5f))
    }
}
