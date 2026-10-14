import QtQuick
import common
import device.ui.text

import ark.controls as ArkControls

Rectangle {
    id: root

    property alias source: iconItem.source
    property alias textTitle: titleItem.text
    property bool horizontalMargins: true

    property bool blackOnWhite: true
    readonly property color foregroundColor: blackOnWhite ? Values.colorBlack : Values.colorWhite
    readonly property color backgroundColor: blackOnWhite ? Values.colorWhite : Values.colorBlack

    property int margin: 28
    property int rowSpacing: 50

    property bool mouseAreaEnabled: false

    signal clicked

    height: titleItem.height + root.margin * 2
    color: backgroundColor

    MouseArea {
        anchors.fill: parent
        enabled: root.mouseAreaEnabled
        onClicked: root.clicked()
    }

    ArkControls.Icon {
        id: iconItem
        size: ArkControls.Values.iconSize.medium
        color: foregroundColor
        anchors {
            left: parent.left
            leftMargin: root.margin
            top: parent.top
            topMargin: root.height / 2 - iconItem.height / 2
        }
    }

    TextParagraphSmall {
        id: titleItem
        anchors {
            left: iconItem.right
            leftMargin: root.rowSpacing
            top: parent.top
            topMargin: Values.designGridVerticalGutter
            right: parent.right
            rightMargin: root.rowSpacing
        }
        font.pixelSize: Values.fontSizeBody2
        lineHeight: Values.lineHeight
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
        color: foregroundColor
    }
}
