import QtQuick
import QtQuick.Layouts

import ark.tokens as ArkTokens
import ark.controls as ArkControls

Rectangle {
    id: root

    property bool selected: false
    property alias model: fields.model
    property int selectedBorder

    readonly property int _horizontalMargin: 40
    readonly property int _verticalMargin: 23
    readonly property int _spacing: 16

    signal clicked()

    color: "transparent"
    border {
        width: selected ? selectedBorder : Math.max(2, selectedBorder / 2)
    }
    implicitWidth: rowLayout.implicitWidth + (2 * _horizontalMargin)
    implicitHeight: rowLayout.implicitHeight + (2 * _verticalMargin)


    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: root._spacing

        Repeater {
            id: fields
            delegate: Item {
                required property var modelData

                implicitWidth: body.width
                implicitHeight: body.height
                Layout.minimumWidth: modelData.separator ?? modelData.minWidth

                ArkControls.Body {
                    id: body
                    objectName: "body"
                    anchors.centerIn: parent
                    type: root.selected ? ArkControls.Body.MediumStrong : ArkControls.Body.Medium
                    text: modelData.text
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
