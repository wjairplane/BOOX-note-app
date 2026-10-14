import xofm.libs.keyboard // Shortcut
import xofm.libs.qtgui // WindowNavigator

Shortcut {
    id: root
    required property WindowNavigator windowNavigator
    sequence: "F7"
    onActivated: windowNavigator.open("settings/window/quicksettings")
}
