import com.remarkable // Settings
import xofm.modules.settings // AutosleepDelayDevicePolicy
import device.ui.controls // ArkToggleWrapper

import ark.controls as ArkControls

ArkControls.Panel {
    id: root

    required property AutosleepDelayDevicePolicy autosleepDelayDevicePolicy

    label: qsTr("Visible content")
    description: qsTr("Show your open document or overview when in standby.")
    action: ArkToggleWrapper {
        id: toggle

        function activate() {
            Settings.lightSleepEnabled = !Settings.lightSleepEnabled;
        }

        checked: Settings.lightSleepEnabled
        extendedMouseArea.onClicked: activate()
        enabled: root.autosleepDelayDevicePolicy.maximumValue === 0
        opacity: toggle.enabled ? 1 : 0.5
        showFocus: root.current === toggle
    }
}
