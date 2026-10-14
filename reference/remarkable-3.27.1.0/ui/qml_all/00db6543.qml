import QtQuick
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import device.global

import xofm.libs.settings
import xofm.libs.controls   // InputBlocker

import ark.controls as ArkControls

Item {
    id: root

    required property Item overlayRoot
    required property var filterModel
    property string currentFilter: filterModel[0]?.label ?? ""
    property alias name: dropdownContent.objectName
    property bool isOpen: false
    readonly property int _margin: 20
    readonly property int _borderWidth: 2
    property bool _splitFiltersList: (filterModel.length * dummyButton.height) > (Values._rootSize.height / 2)

    property int _splitFilterItems:  _splitFiltersList ? 5 : filterModel.length // 5 is the maximum amount of filters we want to show in the regular foldout
    property var defaultFilters: filterModel.slice(0, _splitFilterItems)
    property var extraFilters: filterModel.slice(_splitFilterItems)

    signal updateFilter(int filter)
    signal filterButtonClicked

    function requestUpdateGeometry() {
        updateGeometryTimer.start()
    }

    function hide() {
        root.isOpen = false;
    }

    width: isOpen ? Values.accessibilityMode ? 380 : 342 : // more responsiveness will be brought by the future Ark dropdown component
                    filterLabel.width + filterLabel.anchors.rightMargin +
                    menuIcon.width + menuIcon.anchors.rightMargin + 40

    onWidthChanged: root.requestUpdateGeometry()

    DropdownButton {
        // this button allows to use its height value
        id: dummyButton
        visible: false
    }

    Timer {
        id: updateGeometryTimer
        interval: 50
        onTriggered: closeArea.updateGeometry()
    }

    Background {
        anchors.fill: parent
    }

    Connections {
         target: overlayRoot
         function onWidthChanged() {
             requestUpdateGeometry();
         }

         function onHeightChanged() {
             requestUpdateGeometry();
         }
     }

    // The clickable area to close the menu
    MouseArea {
        id: closeArea
        visible: root.isOpen
        width: overlayRoot.width
        height: overlayRoot.height
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
        id: dropdownButton
        objectName: "dropdownButton"
        anchors.fill: parent
        onClicked: {
            root.filterButtonClicked();
            root.isOpen = !root.isOpen;
            if (root.isOpen) {
                root.requestUpdateGeometry();
            }
            Qt.inputMethod.hide();
        }

        ArkControls.Label {
            id: filterLabel
            text: root.isOpen ? qsTr("Filters") : currentFilter
            type: ArkControls.Label.Medium
            anchors {
                leftMargin: root._margin
                verticalCenter: parent.verticalCenter
            }
            states: [
                State {
                    when: root.isOpen
                    AnchorChanges {
                        target: filterLabel
                        anchors.left: dropdownButton.left
                        anchors.right: undefined
                    }
                },
                State {
                    when: !root.isOpen
                    AnchorChanges {
                        target: filterLabel
                        anchors.right: menuIcon.left
                        anchors.left: undefined
                    }
                }
            ]
        }

        ArkControls.Icon {
            id: menuIcon
            anchors {
                right: parent.right
                rightMargin: root._margin
                verticalCenter: parent.verticalCenter
            }
            size: ArkControls.Values.iconSize.medium
            source: root.isOpen ? "qrc:/ark/icons/chevron_small_up" : "qrc:/ark/icons/chevron_small_down"
        }

        Rectangle {
            visible: root.isOpen
            anchors.fill: parent
            color: "transparent"
            border {
                width: root._borderWidth
                color: Values.colorBlack
            }
        }
    }

    InputBlocker {
        id: dropdownContent
        visible: root.isOpen
        anchors.top: dropdownButton.bottom
        width: dropdownButton.width
        height: viewColumn.implicitHeight + border.width
        border {
            color: Values.colorBlack
            width: root._borderWidth
        }

        Column {
            id: viewColumn
            objectName: "viewColumn"
            width: dropdownContent.width - dropdownContent.border.width * 2
            anchors {
                top: dropdownContent.top
                horizontalCenter: dropdownContent.horizontalCenter
            }
            height: childrenRect.height

            Repeater {
                model: root.defaultFilters
                delegate: DropdownButton {
                    required property var modelData
                    required property int index

                    width: viewColumn.width
                    text: modelData.label
                    iconSource: modelData.icon
                    visible: modelData.visible
                    inverted: root.currentFilter === text
                    beta: modelData.beta ?? false
                    onClicked: {
                        if (!inverted) {
                            root.currentFilter = root.defaultFilters[index].label;
                            updateFilter(index);
                        }
                        root.hide();
                    }
                }
            }
        }

        Rectangle {
            visible: _splitFiltersList
            width: dropdownContent.width
            height: shiftedViewColumn.height + (2 * root._borderWidth)
            anchors {
                top: dropdownContent.top
                topMargin: -root._borderWidth
                right: dropdownContent.left
                rightMargin: -root._borderWidth
            }
            border {
                color: Values.colorBlack
                width: root._borderWidth
            }

            Column {
                id: shiftedViewColumn
                objectName: "shiftedViewColumn"
                width: parent.width - (2 * parent.border.width)
                height: childrenRect.height
                anchors {
                    top: parent.top
                    topMargin: root._borderWidth
                    horizontalCenter: parent.horizontalCenter
                }

                Repeater {
                    model: root.extraFilters
                    delegate: DropdownButton {
                        required property var modelData
                        required property int index

                        width: viewColumn.width
                        text: modelData.label
                        iconSource: modelData.icon
                        visible: modelData.visible
                        inverted: root.currentFilter === text
                        onClicked: {
                            if (!inverted) {
                                root.currentFilter = root.extraFilters[index].label;
                                updateFilter(index + root._splitFilterItems);
                            }
                            root.hide();
                        }
                    }
                }
            }
        }
    }
}
