package app.inkbridge

import android.app.Activity
import android.content.Context
import android.graphics.Rect
import android.os.Build
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.onyx.android.sdk.api.device.epd.EpdController

/**
 * Keeps the device's own edge gestures (the BOOX's swipes from the screen edges for its status bar, back and navigation ball, and
 * Android's back gesture) from firing while InkBridge is on screen, so the app's own gestures are the only ones. It
 *  - hides the system bars and keeps them hidden,
 *  - asks Android not to treat edge swipes as system gestures, and
 *  - on a BOOX, switches off finger touch in a thin strip along each screen edge (Onyx's per-app touch-disable region),
 *    which is where the BOOX's own gestures begin. The strips are released again when the app leaves the screen.
 */
object BooxGestureGuard {
    /** Width of the edge strips (pixels) where finger touch is switched off on a BOOX. */
    private const val STRIP_PX = 36

    private val isOnyx: Boolean get() = Build.MANUFACTURER.equals("onyx", ignoreCase = true) || Build.BRAND.equals("onyx", ignoreCase = true)

    fun apply(activity: Activity) {
        runCatching {
            WindowCompat.setDecorFitsSystemWindows(activity.window, false)
            val c = WindowInsetsControllerCompat(activity.window, activity.window.decorView)
            c.systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            c.hide(WindowInsetsCompat.Type.systemBars())
        }
        if (Build.VERSION.SDK_INT >= 29) runCatching {
            val d = activity.window.decorView
            d.post {
                val w = d.width; val h = d.height
                val dp = activity.resources.displayMetrics.density
                val reach = (200 * dp).toInt() // Android lets an app exclude at most 200 dp from each edge
                d.systemGestureExclusionRects = listOf(Rect(0, 0, reach, h), Rect(w - reach, 0, w, h))
            }
        }
        if (isOnyx) runCatching {
            val m = activity.resources.displayMetrics
            val w = m.widthPixels; val h = m.heightPixels
            EpdController.setAppCTPDisableRegion(
                activity,
                arrayOf(Rect(0, 0, w, STRIP_PX), Rect(0, h - STRIP_PX, w, h), Rect(0, 0, STRIP_PX, h), Rect(w - STRIP_PX, 0, w, h)),
            )
        }
    }

    fun release(context: Context) {
        if (isOnyx) runCatching { EpdController.appResetCTPDisableRegion(context) }
    }

    /** Switch the guard on or off right away (the Settings toggle). */
    fun update(activity: Activity, on: Boolean) = if (on) apply(activity) else {
        release(activity)
        runCatching { WindowInsetsControllerCompat(activity.window, activity.window.decorView).show(WindowInsetsCompat.Type.systemBars()) }
        Unit
    }
}
