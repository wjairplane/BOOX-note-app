import QtQuick
import QtQuick.Layouts

import xofm.libs.dialogs
import ark.controls as ArkControls

DialogScreen {
    id: root

    property string puk

    signal confirm()

    gobackButton: false
    text: qsTr("Recovery for lost password")
    description: qsTr("Store this alphabetic code somewhere safe (or take a picture) just in case you forget it and don't want to do a factory reset.")
    buttons: [
        {
            text: qsTr("Confirm"),
            highlight: true,
            action: function() {
                root.confirm()
            }
        }
    ]

    optionalComponent: Rectangle {
        height: 215
        width: root.width
        color: "black"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            ArkControls.Body {
                type: ArkControls.Body.Medium
                text: qsTr("Recovery code")
                color: "white"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                font {
                    pixelSize: 48
                    letterSpacing: 8
                    bold: true
                }
                color: "white"
                text: root.puk
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
