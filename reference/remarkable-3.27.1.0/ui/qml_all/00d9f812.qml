import QtQuick

import common               // Background
import device.ui.controls   // DropdownButton

import ark.tokens as ArkTokens
import ark.controls as ArkControls

Background {
    id: root
    height: Values.navigatorDropdownHeaderHeight
    width: 360

    // The overlayRoot's area will define the area which will accept clicks to close the menu.
    required property Item overlayRoot
    required property var categoriesModel
    required property string selectedCategory
    property bool shouldPortraitShow: true
    property bool shouldLandscapeShow: true
    readonly property alias isOpen: internal.isOpen
    property bool isLandscape: false

    property var keyTranslator: (key) => key

    onXChanged: closeArea.updateGeometry();
    onYChanged: closeArea.updateGeometry();

    signal updateCategory(string newCategory)
    signal updateOrientation(bool isLandscape)

    function hide() {
        internal.isOpen = false;
    }

    Item {
        id: internal
        property bool isOpen: false
        property string minorHeaderText: {
            return internal.isOpen ? qsTr("Filter") : root.keyTranslator(root.selectedCategory);
        }
    }

    Connections {
         target: overlayRoot
         function onWidthChanged() {
             closeArea.updateGeometry();
         }

         function onHeightChanged() {
             closeArea.updateGeometry();
         }
     }

    // The clickable area to close the menu
    MouseArea {
        id: closeArea
        visible: root.isOpen
        height: overlayRoot.height
        width: overlayRoot.width
        onClicked: root.hide()

        function updateGeometry() {
            const point = overlayRoot.mapToItem(closeArea, closeArea.x, closeArea.y);
            closeArea.x = point.x;
            closeArea.y = point.y;
            closeArea.width = overlayRoot.width;
            closeArea.height = overlayRoot.height;
        }
    }

    MouseArea {
        id: filterMainButton
        anchors.fill: parent
        onClicked: internal.isOpen = !internal.isOpen

        ArkControls.Label {
            id: filterLabel
            text: root.keyTranslator(internal.minorHeaderText)
            type: ArkControls.Label.Medium
            anchors {
                rightMargin: 16
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
            states: [
                State {
                    when: internal.isOpen
                    AnchorChanges {
                        target: filterLabel
                        anchors.left: parent.left
                        anchors.right: undefined
                    }
                },
                State {
                    when: !internal.isOpen
                    AnchorChanges {
                        target: filterLabel
                        anchors.left: undefined
                        anchors.right: menuIcon.left
                    }
                }
            ]
        }

        ArkControls.Icon {
            id: menuIcon
            anchors {
                right: parent.right
                rightMargin: 16
                verticalCenter: parent.verticalCenter
            }
            size: ArkControls.Values.iconSize.medium
            source: internal.isOpen ? "qrc:/ark/icons/chevron_up" : "qrc:/ark/icons/chevron_down"
        }

        Rectangle {
            id: dropdownButtonBorder
            visible: internal.isOpen
            anchors.fill: parent
            color: "transparent"
            border {
                width: 2
                color: Values.colorBlack
            }
        }
    }

    Rectangle {
        id: dropdownContent
        visible: root.isOpen
        width: filterMainButton.width
        height: childrenRect.height + border.width
        anchors.top: filterMainButton.bottom
        border {
            width: 2
            color: Values.colorBlack
        }

        Column {
            id: filterContent
            width: parent.width - parent.border.width * 2
            anchors {
                top: dropdownContent.top
                horizontalCenter: dropdownContent.horizontalCenter
            }

            Repeater {
                id: categoriesButtons
                model: root.categoriesModel

                delegate: DropdownButton {
                    required property var modelData

                    width: filterContent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.keyTranslator(modelData)
                    inverted: modelData === root.selectedCategory
                    onClicked: root.updateCategory(modelData);
                }
            }

            Background {
                id: orientationHeader
                height: Values.navigatorDropdownHeaderHeight
                width: parent.width + border.width * 2
                anchors.horizontalCenter: parent.horizontalCenter

                border {
                    width: 2
                    color: Values.colorBlack
                }

                ArkControls.Label {
                    type: ArkControls.Label.Medium
                    text: qsTr("Orientation")
                    anchors {
                        left: parent.left
                        leftMargin: 16
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            DropdownButton {
                id: portraitButton
                visible: root.shouldPortraitShow
                width: filterContent.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Portrait")
                inverted: !root.isLandscape
                onClicked: root.updateOrientation(false)
            }

            DropdownButton {
                id: landscapeButton
                visible: root.shouldLandscapeShow
                width: filterContent.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Landscape")
                inverted: root.isLandscape
                onClicked: root.updateOrientation(true)
            }
        }
    }
}
