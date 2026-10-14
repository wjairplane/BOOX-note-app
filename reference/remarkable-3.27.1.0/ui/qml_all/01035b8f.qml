import QtQuick
import QtQuick.Layouts
import com.remarkable
import common

import xofm.libs.controls
import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.setup

FocusScope {
    id: root

    signal codeReceived(code: string)

    height: content.implicitHeight

    ColumnLayout {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        ArkControls.Label {
            Layout.fillWidth: true
            type: ArkControls.Label.Type.Medium
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            text: qsTr("Verification code")
        }

        DashedFixedTextField {
            id: oneTimeCodeInput
            height: 80 // provided by Design System
            dashes.spacing: 40
            input.font.letterSpacing: dashes.spacing
            focus: true
            onAccepted: root.codeReceived(text)

            MouseArea {
                anchors.fill: parent
                onPressed: (mouse) => {
                    mouse.accepted = false;
                    oneTimeCodeInput.input.forceActiveFocus();
                }
            }
        }
    }
}
