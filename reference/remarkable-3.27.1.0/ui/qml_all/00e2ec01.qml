import QtQuick
import QtQuick.Layouts
import ark.tokens as ArkTokens
import ark.controls as ArkControls
import xofm.libs.batterymanager

ArkControls.InfoMessage {
    type: ArkTokens.InfoMessage.primary
    required property ShutdownCommand shutdownCommand
    Layout.fillWidth: true
    message: qsTr("Tap to restart device to complete update.")
    iconSource: "qrc:/ark/icons/restore"

    MouseArea {
        anchors.fill: parent
        onClicked: shutdownCommand.execute(ShutdownCommand.Reason.Reboot, "Updated software")
    }
}
