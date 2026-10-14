import xofm.libs.keyboard // Shortcut
import xofm.libs.pincode // PasscodeHandler
import xofm.libs.qtgui // WindowNavigator
import xofm.libs.settings // SettingsPage

Shortcut {
    id: root

    required property PasscodeHandler passcodeHandler
    required property WindowNavigator windowNavigator

    sequence: "Ctrl+,"
    enabled: !passcodeHandler.userLocked
    onActivated: {
        root.windowNavigator.open("settings/window/main", { index: SettingsPage.General });
    }
}
