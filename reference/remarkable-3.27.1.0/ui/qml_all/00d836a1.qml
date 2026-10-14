import QtQuick

import common
import device.ui.text

import ark.controls as ArkControls

Item {
    id: root

    property alias title: titleItem.text
    property alias font: titleItem.font
    property int elideTitle: Text.ElideRight
    property int elideCaption: Text.ElideRight
    property alias caption: caption.text
    property int wrapMode: elideTitle !== Text.ElideNone ? Text.NoWrap : Text.WrapAtWordBoundaryOrAnywhere
    property int size: ArkControls.Values.iconSize.medium
    property int rowSpacing: Values.designGridMargin
    property int textSpacing: arkIcon.visible ? root.rowSpacing : 0
    property color color: Values.colorBlack
    property int layoutDirection: Qt.LeftToRight
    property int leftPadding: 0
    property int rightPadding: 0
    property alias titleItem: titleItem
    property alias spacing: textColumn.spacing

    property alias iconSource: arkIcon.source

    implicitWidth: {
        const w = arkIcon.visible ? arkIcon.width : 0;
        return w + root.textSpacing + titleItem.implicitWidth + leftPadding;
    }
    implicitHeight: {
        const h = arkIcon.visible ? arkIcon.height : 0;
        return Math.max(h, textColumn.implicitHeight)
    }
    antialiasing: true

    ArkControls.Icon {
        id: arkIcon
        size: root.size
        color: root.color
        visible: source.length > 0
        antialiasing: root.antialiasing
        anchors.verticalCenter: parent.verticalCenter
        x: root.layoutDirection === Qt.LeftToRight ? root.leftPadding : root.width - arkIcon.width
    }

    Column {
        id: textColumn

        anchors.verticalCenter: arkIcon.verticalCenter
        width: root.width - (arkIcon.visible ? arkIcon.width + arkIcon.x : 0) - root.textSpacing
        spacing: 0
        x: {
            if (root.layoutDirection === Qt.LeftToRight) {
                return arkIcon.visible ? arkIcon.x + arkIcon.width + root.textSpacing : root.leftPadding;
            } else if (root.layoutDirection === Qt.RightToLeft) {
                return arkIcon.visible ? arkIcon.x - root.textSpacing - width : root.width - root.rightPadding;
            }
            return root.leftPadding;
        }

        TextHeaderRegular {
            id: titleItem

            color: root.color
            width: parent.width
            elide: root.elideTitle
            wrapMode: root.wrapMode
            maximumLineCount: 2
            antialiasing: root.antialiasing
            horizontalAlignment: root.layoutDirection === Qt.LeftToRight ? Qt.AlignLeft : Qt.AlignRight
        }

        ArkControls.Caption {
            id: caption
            width: parent.width
            visible: !!text
            elide: root.elideCaption
            color: root.color
        }
    }
}
