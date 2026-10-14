import QtQuick

import common
import device.ui.controls

import ark.controls as ArkControls

DeviceKeyboardNavigationHandler {
    id: root

    required property Item container
    property int currentIndex: 0
    required property size boxSize

    height: currentValue.height + (internal.isOpen ? dropdownMenu.height : 0)
    width: boxSize.width
    focus: internal.isOpen

    property alias model: items.model

    signal select(key : int)

    navigationModel: [items]

    MouseArea {
        id: outsideArea
        parent: container
        anchors.fill: parent
        enabled: internal.isOpen
        z: dropdownMenu.z - 1
        onClicked: {
            internal.isOpen = false;
        }
    }

    Background {
        anchors.fill: parent
    }

    QtObject {
        id: internal

        property int leftMargin: 20
        property bool isOpen: false
        property int borderWidth: 2
    }

    MouseArea {
        id: currentValue
        width: root.boxSize.width
        height: root.boxSize.height
        onClicked: {
            internal.isOpen = !internal.isOpen;
        }

        Rectangle {
            anchors.fill: parent
            color: Values.colorWhite
            border {
                color: Values.colorBlack
                width: internal.borderWidth
            }
        }

        ArkControls.Label {
            id: label
            leftPadding: 20
            width: parent.width - internal.leftMargin * 2
            text: root.model.get(root.currentIndex).value
            type: ArkControls.Label.Medium
            anchors.verticalCenter: parent.verticalCenter
        }

        ArkControls.Icon {
            id: icon
            anchors {
                right: parent.right
                rightMargin: 24
                verticalCenter: parent.verticalCenter
            }
            source: internal.isOpen ? "qrc:/ark/icons/chevron_up" : "qrc:/ark/icons/chevron_down"
            size: ArkControls.Values.iconSize.medium
        }
    }

    Rectangle {
        id: dropdownMenu
        anchors {
            left: parent.left
            right: parent.right
            top: currentValue.bottom
        }
        height: items.height + internal.borderWidth * 2
        visible: internal.isOpen
        color: Values.colorWhite
        border {
            color: Values.colorBlack
            width: internal.borderWidth
        }

        ListView {
            id: items
            height: childrenRect.height - internal.borderWidth
            width: parent.width - internal.borderWidth * 2
            anchors {
                top: parent.top
                left: parent.left
                leftMargin: internal.borderWidth
            }
            delegate: DropdownButton {
                required property int key
                required property string value
                required property int index
                text: value
                reserveSpace: false
                inverted: root.currentIndex === index
                onClicked: {
                    root.select(key);
                    internal.isOpen = false;
                }
            }
        }
    }
}
