import QtQuick
import common
import com.remarkable
import device.ui.text

import ark.controls as ArkControls

Rectangle {
    id: itemButton

    property alias text: _label.text
    property alias label: _label

    signal edit
    signal remove

    border.color: Values.colorBlack
    height: 60
    width: row.width + row.spacing * 3

    MouseArea {
        anchors.fill: parent
        anchors.margins: -10
        onClicked: itemButton.edit()
    }

    Row {
        id: row
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        spacing: 20

        ArkControls.Icon {
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/ark/icons/x_medium"
            size: ArkControls.Values.iconSize.small
            MouseArea {
                anchors.fill: parent
                anchors.margins: -10
                onClicked: itemButton.remove()
            }
        }

        TextParagraph {
            id: _label
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Values.fontSizeH2
            color: Values.colorBlack
        }
    }
}
