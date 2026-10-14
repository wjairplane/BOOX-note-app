package app.inkbridge

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import app.inkbridge.ui.InkBridgeApp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { InkBridgeApp(LibraryStore(applicationContext), Prefs(applicationContext)) }
    }
}
