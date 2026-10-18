package app.inkbridge

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

/**
 * Whether the app is behind the passcode screen. It starts locked when a passcode is set, locks whenever the screen goes off (the
 * firmware locks on every standby) and when the app comes back after more than [BACKGROUND_GRACE_MS] away; short trips to a file
 * picker or the share sheet do not ask again.
 */
class AppLock(val passcode: PasscodeLock, private val clock: () -> Long = android.os.SystemClock::elapsedRealtime) {
    var locked by mutableStateOf(passcode.hasPasscode)
        private set

    /** The notebook that was open when the lock came down; it opens again on its last page after unlocking. */
    var resumeDocId: String? = null

    private var stoppedAt = -1L

    fun onStop() { stoppedAt = clock() }

    fun onStart() {
        if (passcode.hasPasscode && stoppedAt >= 0 && clock() - stoppedAt > BACKGROUND_GRACE_MS) locked = true
        stoppedAt = -1L
    }

    fun onScreenOff() { if (passcode.hasPasscode) locked = true }

    fun lock() { if (passcode.hasPasscode) locked = true }

    fun unlock() { locked = false }

    companion object { const val BACKGROUND_GRACE_MS = 30_000L }
}
