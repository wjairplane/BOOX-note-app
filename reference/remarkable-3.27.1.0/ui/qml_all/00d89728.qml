import QtQuick
import common
import com.remarkable
import device.ui.text
import device.ui.controls

import ark.controls as ArkControls

Item {
    id: optionalTextItem

    property alias title: header.text
    property alias text: textArea.text
    property alias placeholderText: addItemButton.title
    property alias textItem: textArea
    property alias textFormat: textArea.textFormat

    property bool editable: true
    property bool wrap: true

    signal clicked

    implicitWidth: parent.width
    implicitHeight: header.height + textMouseArea.y + textMouseArea.height

    TextHeaderRegular {
        id: header
        text: title
    }

    MouseArea {
        id: textMouseArea
        anchors.top: header.bottom
        anchors.topMargin: Values.controlVerticalMargin
        width: parent.width
        height: editItem.y + (editItem.visible ? editItem.height : 0)

        onClicked: optionalTextItem.clicked()

        TextHeaderRegular {
            id: textArea

            // If placed next to another OptionalTextItem with no text, the text should align with
            // the addItemButton text
            y: ArkControls.Values.iconSize.medium / 2 - textFontMetrics.height / 2
            width: parent.width
            wrapMode: optionalTextItem.wrap ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
            elide: Text.ElideRight
            textFormat: Text.PlainText
            maximumLineCount: 3
            font.bold: false
        }

        FontMetrics {
            id: textFontMetrics
            font: textArea.font
        }

        TextHeaderRegular {
            id: editItem
            anchors.top: textArea.bottom
            anchors.topMargin: Values.controlVerticalMargin
            visible: textArea.text.length && editable
            text: qsTr("Edit")
            font.underline: true
            font.bold: true
            elide: Text.ElideRight
            font.pixelSize: Values.fontSizeBody2
        }

        AddItemButton {
            id: addItemButton
            anchors.top: parent.top
            width: parent.width
            visible: !textArea.text.length
            onClicked: optionalTextItem.clicked()
        }
    }
}
