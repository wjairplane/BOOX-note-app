import QtQuick.Layouts
import device.ui.controls
import ark.controls as ArkControls
import com.remarkable

ArkControls.Panel {
    required property var updateEnabled
    enabled: !updateEnabled.forced
    Layout.fillWidth: true
    label: qsTr("Updates")
    description: {
        if (updateEnabled.forced) {
            //: Informational message to explain why the user can not turn off automatic updates (button disabled)
            return qsTr("Company policy enforces automatic software updates");
        }
        return updateEnabled.enabled ? qsTr("Install new software versions as they are released.") : ""
    }
    iconSource: "qrc:/ark/icons/rotate"

    action: ArkToggleWrapper {
        checked: updateEnabled.enabled
        enabled: !RetailDemo.enabled
        onCheckedChanged: {
            // Restore binding overwritten by the switch. We don't need this with the mousearea workaround
            checked = Qt.binding(() => { return updateEnabled.enabled; });
        }
        extendedMouseArea.onClicked: {
            updateEnabled.enabled = !updateEnabled.enabled;
        }
    }
}
