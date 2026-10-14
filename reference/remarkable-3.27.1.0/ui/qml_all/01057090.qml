import QtQuick
import QtQuick.Layouts

import xofm.libs.qtgui
import xofm.libs.dialogs
import xofm.libs.batterymanager
import xofm.modules.password

import ark.tokens as ArkTokens
import ark.controls as ArkControls

BaseView {
    id: root

    required property ShutdownCommand shutdownCommand

    contentItem: DialogScreen {
        anchors.fill: parent
        gobackButton: false
        text: qsTr("Something went wrong")
        subDescription: qsTr("Please try again by rebooting your device. If this happens consistently you can reset your device by doing a factory reset.")
        iconSource: "qrc:/ark/icons/warning_circle"
        accidentalTouchPrevention: true

        buttons: [
            {
                text: qsTr("Reboot"),
                highlight: false,
                action: function() {
                    root.shutdownCommand.execute(ShutdownCommand.Reason.Reboot, "Critical error in disk encryption");
                }
            },
            {
                text: qsTr("Factory reset"),
                highlight: true,
                action: function() {
                    shutdownCommand.execute(ShutdownCommand.Reason.FactoryReset, "Critical error in disk encryption");
                }
            }
        ]

    }
}
