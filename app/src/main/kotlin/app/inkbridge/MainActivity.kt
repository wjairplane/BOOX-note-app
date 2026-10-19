package app.inkbridge

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import app.inkbridge.ui.InkBridgeApp

class MainActivity : ComponentActivity() {
    private lateinit var prefs: Prefs

    // The firmware asks for the passcode after every standby: when the screen goes off the app locks.
    private val screenOff = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) { prefs.lock.onScreenOff() }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        prefs = Prefs(applicationContext)
        registerReceiver(screenOff, IntentFilter(Intent.ACTION_SCREEN_OFF))
        setContent { InkBridgeApp(LibraryStore(applicationContext), prefs) }
    }

    override fun onDestroy() {
        runCatching { unregisterReceiver(screenOff) }
        super.onDestroy()
    }

    override fun onStart() {
        super.onStart()
        prefs.lock.onStart()
    }

    override fun onStop() {
        prefs.lock.onStop()
        super.onStop()
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
