import QtQuick
import com.remarkable
import common
import device.ui.text

import ark.controls as ArkControls

Item {
    id: root
    property var loader
    property alias selectedText: selectorText.text
    property alias title: descriptionText.text
    property string textColor: Values.colorBlack
    signal selected

    function text() {
        return selectedText;
    }

    ArkControls.Label {
        id: descriptionText
        color: root.textColor
        anchors.left: parent.left
    }

    Rectangle {
        anchors.top: descriptionText.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        color: "transparent"
        border.color: root.textColor
        border.width: Values.outlineSize
        width: parent.width
        height: 2 * Values.navigatorContentGridItemPinnWidth

        Text {
            id: selectorText
            color: root.textColor
            anchors.left: parent.left
            anchors.leftMargin: Values.navigatorSidebarIndentation
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Values.fontSizeH2
        }

        ArkControls.Icon {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: Values.navigatorHeaderTitleMargin
            }
            size: ArkControls.Values.iconSize.small
            source: "qrc:/ark/icons/angle_right"
            color: root.textColor
        }

        MouseArea {
            anchors.fill: parent
            objectName: "inputComponentMouseArea"
            onClicked: root.selected()
        }
    }
}
