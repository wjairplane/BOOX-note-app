package app.inkbridge

import android.view.MotionEvent
import app.inkbridge.pen.FingerGestures
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/** The reMarkable's finger gestures, fed with synthetic touches on a 1860 x 2480 px view at 100 px per cm. */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class FingerGesturesTest {
    private val log = ArrayList<String>()
    private var penAgo = 10_000L
    private val g = FingerGestures(100f, object : FingerGestures.Host {
        override val viewWidth = 1860
        override val viewHeight = 2480
        override fun msSincePen() = penAgo
        override fun onTap(fingers: Int) { log += "tap$fingers" }
        override fun onPageSwipe(forward: Boolean) { log += if (forward) "next" else "prev" }
        override fun onJump(down: Boolean) { log += if (down) "jumpDown" else "jumpUp" }
        override fun onEdgeSwipe(edge: FingerGestures.Edge) { log += edge.name }
        override fun onViewBegin() { log += "viewBegin" }
        override fun onViewUpdate(scale: Float, focusX: Float, focusY: Float, panX: Float, panY: Float) { last = scale to panX }
        override fun onViewEnd(scale: Float, focusX: Float, focusY: Float, panX: Float, panY: Float) { log += "viewEnd"; last = scale to panX }
    })
    private var last = 1f to 0f
    private var t = 0L

    @Before fun reset() { log.clear(); t = 1000; penAgo = 10_000 }

    private fun ev(action: Int, vararg xy: Float): MotionEvent {
        val n = xy.size / 2
        val props = Array(n) { MotionEvent.PointerProperties().also { p -> p.id = it; p.toolType = MotionEvent.TOOL_TYPE_FINGER } }
        val coords = Array(n) { MotionEvent.PointerCoords().also { c -> c.x = xy[it * 2]; c.y = xy[it * 2 + 1] } }
        return MotionEvent.obtain(0, t, action, n, props, coords, 0, 0, 1f, 1f, 0, 0, 0, 0)
    }
    private fun one(x0: Float, y0: Float, x1: Float, y1: Float, ms: Long = 200) {
        g.onTouchEvent(ev(MotionEvent.ACTION_DOWN, x0, y0)); t += ms / 2
        g.onTouchEvent(ev(MotionEvent.ACTION_MOVE, (x0 + x1) / 2, (y0 + y1) / 2)); t += ms / 2
        g.onTouchEvent(ev(MotionEvent.ACTION_MOVE, x1, y1))
        g.onTouchEvent(ev(MotionEvent.ACTION_UP, x1, y1))
    }
    private fun two(ax: Float, ay: Float, bx: Float, by: Float, ax1: Float, ay1: Float, bx1: Float, by1: Float, ms: Long = 150) {
        g.onTouchEvent(ev(MotionEvent.ACTION_DOWN, ax, ay)); t += 10
        g.onTouchEvent(ev(MotionEvent.ACTION_POINTER_DOWN or (1 shl MotionEvent.ACTION_POINTER_INDEX_SHIFT), ax, ay, bx, by)); t += ms / 2
        g.onTouchEvent(ev(MotionEvent.ACTION_MOVE, ax1, ay1, bx1, by1)); t += ms / 2
        g.onTouchEvent(ev(MotionEvent.ACTION_POINTER_UP or (1 shl MotionEvent.ACTION_POINTER_INDEX_SHIFT), ax1, ay1, bx1, by1))
        g.onTouchEvent(ev(MotionEvent.ACTION_UP, ax1, ay1))
    }

    @Test fun shortSwipeFlipsOnRelease() { one(900f, 1200f, 800f, 1210f); assertEquals(listOf("next"), log) }
    @Test fun swipeRightGoesBack() { one(500f, 1200f, 700f, 1190f); assertEquals(listOf("prev"), log) }
    @Test fun tooShortIsNothing() { one(900f, 1200f, 870f, 1200f); assertTrue(log.isEmpty()) }
    @Test fun longSwipeFlipsBeforeRelease() {
        g.onTouchEvent(ev(MotionEvent.ACTION_DOWN, 1500f, 1200f)); t += 50
        g.onTouchEvent(ev(MotionEvent.ACTION_MOVE, 1150f, 1200f))
        assertEquals(listOf("next"), log)
        g.onTouchEvent(ev(MotionEvent.ACTION_UP, 1150f, 1200f))
        assertEquals(listOf("next"), log)
    }
    @Test fun verticalSwipeJumps() { one(900f, 1800f, 905f, 1500f); assertEquals(listOf("jumpDown"), log) }
    @Test fun swipeDownFromTopCloses() { one(500f, 20f, 505f, 200f); assertEquals(listOf("CLOSE"), log) }
    @Test fun topRightCornerIsQuickSettings() { one(1700f, 20f, 1700f, 200f); assertEquals(listOf("QUICK_SETTINGS"), log) }
    @Test fun swipeUpFromBottomIsQuickBrowse() { one(900f, 2470f, 900f, 2250f); assertEquals(listOf("QUICK_BROWSE"), log) }
    @Test fun twoFingersFromTopOpenTheDrawer() { two(800f, 30f, 1000f, 30f, 800f, 90f, 1000f, 90f); assertEquals(listOf("DRAWER"), log) }
    @Test fun twoFingerTapUndoes() { two(800f, 1000f, 1000f, 1000f, 800f, 1000f, 1000f, 1000f, ms = 100); assertEquals(listOf("tap2"), log) }
    @Test fun pinchZooms() {
        two(800f, 1200f, 1000f, 1200f, 600f, 1200f, 1200f, 1200f, ms = 300)
        assertEquals(listOf("viewBegin", "viewEnd"), log)
        assertEquals(3f, last.first, 0.01f)
    }
    @Test fun twoFingerDragPans() {
        two(800f, 1200f, 1000f, 1200f, 800f, 900f, 1000f, 900f, ms = 300)
        assertEquals(listOf("viewBegin", "viewEnd"), log)
        assertEquals(1f, last.first, 0.01f)
    }
    @Test fun gesturesWaitWhileThePenIsClose() { penAgo = 100; one(900f, 1200f, 700f, 1200f); assertTrue(log.isEmpty()) }
}
