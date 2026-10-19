package app.inkbridge

import android.app.Application
import android.content.Intent
import android.os.BatteryManager
import androidx.activity.ComponentActivity
import androidx.compose.material3.MaterialTheme
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onLast
import androidx.compose.ui.test.performClick
import app.inkbridge.ui.EInkColors
import app.inkbridge.ui.InfoDialog
import app.inkbridge.ui.InkBridgeApp
import app.inkbridge.ui.PageError
import app.inkbridge.ui.PageErrorOverlay
import app.inkbridge.ui.RmDensity
import app.inkbridge.ui.RmTypography
import app.inkbridge.ui.StrokeLimit
import app.inkbridge.ui.offsetText
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.io.File

/** Renders the settings pages, the passcode screens and the page error screens to PNG (build/ui-snapshots) and drives the passcode flows. */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w702dp-h936dp-xhdpi")
class SettingsPagesTest {
    @get:Rule val rule = createAndroidComposeRule<ComponentActivity>()

    private fun snapshot(name: String) {
        val decor = rule.activity.window.decorView
        val bmp = android.graphics.Bitmap.createBitmap(decor.width.coerceAtLeast(1), decor.height.coerceAtLeast(1), android.graphics.Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(bmp)
        decor.draw(canvas)
        // Dialogs (the confirm sheet) are windows of their own: draw them on top at their place.
        runCatching {
            val wmg = Class.forName("android.view.WindowManagerGlobal")
            val global = wmg.getMethod("getInstance").invoke(null)
            val names = wmg.getMethod("getViewRootNames").invoke(global) as Array<*>
            for (n in names) {
                val root = wmg.getMethod("getRootView", String::class.java).invoke(global, n) as? android.view.View ?: continue
                if (root === decor || root.width == 0 || root.height == 0) continue
                val lp = root.layoutParams as? android.view.WindowManager.LayoutParams
                canvas.save()
                val centred = lp != null && (lp.gravity and android.view.Gravity.VERTICAL_GRAVITY_MASK) == android.view.Gravity.CENTER_VERTICAL
                if (centred) canvas.translate((bmp.width - root.width) / 2f, (bmp.height - root.height) / 2f)
                else canvas.translate((lp?.x ?: 0).toFloat(), (lp?.y ?: 0).toFloat())
                root.draw(canvas)
                canvas.restore()
            }
        }
        val out = File("build/ui-snapshots").apply { mkdirs() }
        File(out, "$name.png").outputStream().use { bmp.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, it) }
    }

    private fun settle() = repeat(14) { Thread.sleep(60); rule.mainClock.advanceTimeBy(100); rule.waitForIdle() }

    private fun launch(prefs: Prefs): AppController {
        val ctx = RuntimeEnvironment.getApplication() as Application
        val store = LibraryStore(ctx)
        val app = AppController(store, prefs, kotlinx.coroutines.MainScope())
        rule.setContent { InkBridgeApp(store, prefs, app) }
        settle()
        return app
    }

    private fun type(code: String) { for (c in code) { rule.onNodeWithContentDescription("$c").performClick() }; settle() }

    private fun show(content: @androidx.compose.runtime.Composable () -> Unit) {
        rule.setContent { RmDensity { MaterialTheme(colorScheme = EInkColors, typography = RmTypography) { content() } } }
        settle()
    }

    @Test fun batteryPage() {
        val ctx = RuntimeEnvironment.getApplication() as Application
        ctx.sendStickyBroadcast(
            Intent(Intent.ACTION_BATTERY_CHANGED).putExtra(BatteryManager.EXTRA_LEVEL, 63).putExtra(BatteryManager.EXTRA_SCALE, 100)
                .putExtra(BatteryManager.EXTRA_STATUS, BatteryManager.BATTERY_STATUS_CHARGING).putExtra(BatteryManager.EXTRA_PLUGGED, BatteryManager.BATTERY_PLUGGED_USB)
                .putExtra(BatteryManager.EXTRA_HEALTH, BatteryManager.BATTERY_HEALTH_GOOD).putExtra(BatteryManager.EXTRA_TEMPERATURE, 274).putExtra(BatteryManager.EXTRA_VOLTAGE, 4012),
        )
        val app = launch(Prefs(ctx))
        rule.runOnUiThread { app.screen = Screen.Settings }; settle(); snapshot("settings_general_pages")
        rule.onNodeWithText("Battery").performClick(); settle(); snapshot("settings_battery")
        rule.onNodeWithText("Charging").assertExists()
        rule.onNodeWithText("63 %").assertExists()
        rule.onNodeWithText("27.4 °C").assertExists()
        rule.onNodeWithText("4.01 V").assertExists()
        rule.onNodeWithText("USB").assertExists()
    }

    @Test fun softwareAndTimePages() {
        val app = launch(Prefs(RuntimeEnvironment.getApplication()))
        rule.runOnUiThread { app.screen = Screen.Settings }; settle()
        rule.onNodeWithText("Software").performClick(); settle(); snapshot("settings_software")
        rule.onNodeWithText("About this device").assertExists()
        rule.onNodeWithContentDescription("Back").performClick(); settle()
        rule.onNodeWithText("Help").performClick(); settle(); snapshot("settings_help_clock")
        rule.onNodeWithText("About").assertExists()
        // The clock cell (under its "System time" heading) shows today's date and opens the page.
        val year = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR).toString()
        rule.onNodeWithText(year, substring = true).performClick(); settle(); snapshot("settings_system_time")
        rule.onNodeWithText("Set date and time").assertExists()
        rule.onNodeWithText("Time zone").assertExists()
        rule.onNodeWithText("Date format").assertExists()
        rule.onNodeWithText("Time format").assertExists()
        assertEquals("UTC+02:00", offsetText(7_200_000))
        assertEquals("UTC-03:30", offsetText(-12_600_000))
        assertEquals("UTC+00:00", offsetText(0))
    }

    @Test fun handedness() {
        val ctx = RuntimeEnvironment.getApplication() as Application
        val prefs = Prefs(ctx)
        val app = launch(prefs)
        rule.runOnUiThread { app.screen = Screen.Settings }; settle()
        rule.onNodeWithText("Accessibility").performClick(); settle(); snapshot("settings_accessibility_right")
        assertTrue(prefs.rightHanded)
        assertEquals(ToolbarPosition.LEFT, prefs.toolbarPosition)
        rule.onNodeWithContentDescription("Left hand").performClick(); settle(); snapshot("settings_accessibility_left")
        assertFalse(prefs.rightHanded)
        assertEquals(ToolbarPosition.RIGHT, prefs.toolbarPosition)
        assertEquals(ToolbarPosition.RIGHT, prefs.toolbarLandscape)
        rule.onNodeWithContentDescription("Right hand").performClick(); settle()
        assertTrue(prefs.rightHanded)
        assertEquals(ToolbarPosition.LEFT, prefs.toolbarPosition)
        // Top and bottom toolbars stay where they are.
        prefs.toolbarPosition = ToolbarPosition.TOP
        prefs.setRightHanded(false)
        assertEquals(ToolbarPosition.TOP, prefs.toolbarPosition)
        assertEquals(ToolbarPosition.RIGHT, prefs.toolbarLandscape)
    }

    @Test fun passcodeFlow() {
        val ctx = RuntimeEnvironment.getApplication() as Application
        val prefs = Prefs(ctx)
        val app = launch(prefs)
        rule.runOnUiThread { app.screen = Screen.Settings }; settle()
        rule.onNodeWithText("Security").performClick(); settle(); snapshot("settings_security_off")
        rule.onNodeWithText("Protect your notebooks and documents with a code.").assertExists()

        // Turn on: a length choice, the new code, the code again.
        rule.onNodeWithText("Passcode").performClick(); settle(); snapshot("passcode_new")
        rule.onNodeWithText("Enter your new passcode").assertExists()
        rule.onNodeWithContentDescription("Four digits").performClick(); settle()
        type("12"); snapshot("passcode_typing")
        type("34"); snapshot("passcode_verify")
        rule.onNodeWithText("Verify your new passcode").assertExists()
        type("1235"); snapshot("passcode_mismatch")
        rule.onNodeWithText("Incorrect passcode. Try again.").assertExists()
        rule.onNodeWithText("Enter your new passcode").assertExists()
        type("1234"); type("1234")
        assertTrue(prefs.passcode.hasPasscode)
        assertEquals(4, prefs.passcode.passcodeLength)
        rule.onNodeWithText("Your passcode has been updated").assertExists()
        snapshot("settings_security_on")
        rule.onNodeWithText("Change passcode").assertExists()

        // Change it: the old code first, then six digits.
        rule.onNodeWithText("Change passcode").performClick(); settle()
        rule.onNodeWithText("Enter your passcode").assertExists()
        type("0000"); rule.onNodeWithText("Incorrect passcode. Try again.").assertExists(); snapshot("passcode_old_wrong")
        type("1234")
        rule.onNodeWithText("Enter your new passcode").assertExists()
        rule.onNodeWithContentDescription("Six digits").performClick(); settle(); snapshot("passcode_new_six")
        type("246810"); type("246810")
        assertEquals(6, prefs.passcode.passcodeLength)
        assertTrue(prefs.passcode.verify("246810"))

        // Turn off.
        rule.onNodeWithText("Passcode").performClick(); settle()
        rule.onNodeWithText("Enter your passcode").assertExists()
        type("246810")
        assertFalse(prefs.passcode.hasPasscode)
        rule.onNodeWithText("Your passcode is turned off").assertExists()
    }

    @Test fun unlockScreen() {
        val ctx = RuntimeEnvironment.getApplication() as Application
        val prefs = Prefs(ctx)
        prefs.passcode.set(null, "135790")
        // A new Prefs reads the stored passcode and starts locked.
        val locked = Prefs(ctx)
        assertTrue(locked.lock.locked)
        val app = launch(locked)
        snapshot("unlock")
        rule.onNodeWithText("Enter passcode").assertExists()
        type("111111"); snapshot("unlock_wrong")
        rule.onNodeWithText("Incorrect passcode. Try again.").assertExists()
        assertTrue(locked.lock.locked)
        type("135790")
        assertFalse(locked.lock.locked)
        rule.onNodeWithText("My files").assertExists()
        // Backgrounded for long: locked again.
        rule.runOnUiThread { locked.lock.onScreenOff() }; settle()
        rule.onNodeWithText("Enter passcode").assertExists()
        assertEquals(Screen.Files(), app.screen)
    }

    @Test fun lockoutScreens() {
        val ctx = RuntimeEnvironment.getApplication() as Application
        val prefs = Prefs(ctx)
        prefs.passcode.set(null, "135790")
        val locked = Prefs(ctx)
        val app = launch(locked)
        repeat(5) { type("000000") }
        rule.onNodeWithText("Incorrect passcode. Try again.").assertExists()
        type("000000") // the 6th wrong entry: a one-minute time-out
        assertEquals(PinState.TIMED_OUT, locked.passcode.state)
        rule.onNodeWithText("Too many attempts").assertExists()
        rule.onNodeWithText("Wait 1 minute to try again, or reset passcode.").assertExists()
        snapshot("unlock_timed_out")
        rule.onNodeWithContentDescription("Swipe to continue").assertExists()
        assertTrue(locked.lock.locked)
        assertEquals(Screen.Files(), app.screen)
    }

    @Test fun lockedForGoodAndReset() {
        val ctx = RuntimeEnvironment.getApplication() as Application
        val prefs = Prefs(ctx)
        prefs.passcode.set(null, "135790")
        // Nine wrong entries have been made; the next one is the final try.
        val sp = ctx.getSharedPreferences("security", android.content.Context.MODE_PRIVATE)
        sp.edit().putInt("attempts", 9).putLong("lockedUntil", 0L).commit()
        val locked = Prefs(ctx)
        assertEquals(PinState.FINAL_TRY, locked.passcode.state)
        val app = launch(locked)
        snapshot("unlock_final_try")
        rule.onNodeWithText("Final attempt before you need to reset").assertExists()
        type("000000")
        assertEquals(PinState.LOCKED, locked.passcode.state)
        rule.onNodeWithText("A reset is required to unlock your device.").assertExists()
        snapshot("unlock_locked")
        // Even the right code is refused now.
        type("135790")
        assertTrue(locked.lock.locked)
        rule.onNodeWithText("Reset passcode").performClick(); settle(); snapshot("unlock_reset_confirm")
        rule.onNodeWithText("Reset device").assertExists()
        rule.onNodeWithText("Confirm reset").performClick(); settle()
        assertFalse(locked.lock.locked)
        assertFalse(locked.passcode.hasPasscode)
        assertEquals(Screen.Files(), app.screen)
    }

    @Test fun pageErrors() {
        val current = androidx.compose.runtime.mutableStateOf(PageError.LOAD)
        show { PageErrorOverlay(current.value, "6a1f3c52-8f0e-4a43-9d57-0c2f6b1e7a90", "d41c9e0b-52ab-4b0f-8a7d-3e6f21c8b455", "") }
        for (e in PageError.entries) {
            rule.runOnUiThread { current.value = e }; settle()
            snapshot("page_error_${e.name.lowercase()}")
            rule.onNodeWithText(e.title).assertExists()
        }
    }

    @Test fun infoDialog() {
        show { InfoDialog("Unable to open", "This document contains data that is not supported.", onClose = {}) }
        snapshot("info_dialog")
        rule.onNodeWithText("Unable to open").assertExists()
        rule.onNodeWithText("Close").assertExists()
    }

    @Test fun strokeLimit() {
        val dir = File("build/tmp/strokelimit").apply { mkdirs() }
        val small = File(dir, "small.rm").apply { writeBytes(ByteArray(1000)) }
        assertFalse(StrokeLimit.reached(small))
        assertFalse(StrokeLimit.reached(File(dir, "missing.rm")))
        assertEquals(7_489_828, StrokeLimit.MAX_POINTS)
    }
}
