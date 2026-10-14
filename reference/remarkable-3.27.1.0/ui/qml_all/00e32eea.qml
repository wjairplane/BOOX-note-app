import com.remarkable // RetailDemo
import xofm.libs.settings // QuickSettingsToggle

QuickSettingsToggle {
    id: root

    required property var settings

    selected: root.settings.airplaneMode
    iconSource: root.settings.airplaneMode ? "qrc:/ark/icons/airplane_fill" : "qrc:/ark/icons/airplane"
    enabled: !RetailDemo.enabled
    onClicked: {
        root.settings.airplaneMode = !root.settings.airplaneMode;
    }
    onPressAndHold: {
        windowNavigator?.open("settings/window/main");
        windowNavigator?.close("settings/window/quicksettings");
    }
}
