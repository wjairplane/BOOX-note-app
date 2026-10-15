package app.inkbridge

import android.app.Application
import android.os.Build
import org.lsposed.hiddenapibypass.HiddenApiBypass

class InkBridgeApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        AndroidPageCanvas.installFonts(this)
        // The Onyx pen SDK reaches into hidden Android APIs; on Android 9+ they must be exempted first
        // (same as Onyx's own demo app).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            runCatching { HiddenApiBypass.addHiddenApiExemptions("") }
        }
    }
}
