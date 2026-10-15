package app.inkbridge

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import app.inkbridge.ui.InkBridgeApp

class MainActivity : ComponentActivity() {
    private lateinit var prefs: Prefs

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        prefs = Prefs(applicationContext)
        setContent { InkBridgeApp(LibraryStore(applicationContext), prefs) }
    }

    // The device's edge gestures are held off only while InkBridge is on screen.
    override fun onResume() {
        super.onResume()
        if (prefs.blockDeviceGestures) BooxGestureGuard.apply(this)
    }

    override fun onPause() {
        BooxGestureGuard.release(this)
        super.onPause()
    }
}
