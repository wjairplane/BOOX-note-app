import QtQuick
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import device.global

import xofm.libs.settings

import ark.controls as ArkControls

Item {
    id: dropdown
    signal selected(var selectedKey)
    property var _model: null
    property var keys: null
    property var values: null
    property var key
    property alias name: dropdownContent.objectName
    property bool isOpen: false
    property Item overlayRoot: navigator
    property bool showModel: !!_model
    readonly property bool accessibilityMode: Settings.accessibilityMode

    property string closedText: {
        switch (thumbnailSize) {
            case ThumbnailSettings.Large:
                return qsTr("Large grid");
            case ThumbnailSettings.Medium:
                return qsTr("Medium grid");
            case ThumbnailSettings.Small:
                return qsTr("Small grid");
            case ThumbnailSettings.List:
                return qsTr("List view");
            default:
                return "";
        }
    }

    // Enum: ThumbnailSettings.ThumbnailSize
    required property int thumbnailSize
    signal updateThumbnailSize(int thumbnailSize)

    height: Values.navigatorDropdownHeaderHeight
    width: isOpen ? Values.navigatorContentGridItemWidth :
                    sortLabel.width + sortLabel.anchors.rightMargin + icon.width + icon.anchors.rightMargin + 40
    onKeysChanged: _model = createModel(keys, values)
    onValuesChanged: _model = createModel(keys, values)

    onHeightChanged: dropdownContent.updateGeometry()
    onWidthChanged: dropdownContent.updateGeometry()
    onOverlayRootChanged: dropdownContent.updateGeometry()

    // There is no large grid in accessibility mode
    onAccessibilityModeChanged: {
        if (dropdown.accessibilityMode && (dropdown.thumbnailSize === ThumbnailSettings.ThumbnailSize.Large)) {
            dropdown.updateThumbnailSize(ThumbnailSettings.ThumbnailSize.Medium);
        }
    }

    function hide() {
        dropdown.isOpen = false;
    }

    // To be able to be called from the outside
    function updateGeometry() {
        dropdownContent.updateGeometry();
    }

    function createModel(k, v) {
        if (!k || !v || k.length !== v.length) {
            return null;
        }
        return k.map((key, index) => { return {key: key, value: v[index]}; });
    }

    MouseArea {
        id: closeArea
        parent: overlayRoot
        anchors.fill: parent
        onClicked: dropdown.hide()
        visible: dropdown.isOpen
        z: parent.z + 1
    }

    MouseArea {
        id: dropdownButton
        anchors.fill: parent

        onClicked: {
            dropdown.isOpen = !dropdown.isOpen;
        }

        ArkControls.Label {
            id: sortLabel
            text: dropdown.isOpen ? qsTr("View") : closedText
            type: ArkControls.Label.Medium
            anchors {
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
            states: [
                State {
                    when: dropdown.isOpen
                    AnchorChanges {
                        target: sortLabel
                        anchors.left: dropdownButton.left
                        anchors.right: undefined
                    }
                },
                State {
                    when: !dropdown.isOpen
                    AnchorChanges {
                        target: sortLabel
                        anchors.right: icon.left
                        anchors.left: undefined
                    }
                }
            ]
        }

        ArkControls.Icon {
            id: icon
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            source: dropdown.isOpen ? "qrc:/ark/icons/chevron_small_up" : "qrc:/ark/icons/chevron_small_down"
            anchors.rightMargin: 16
        }

        Rectangle {
            visible: dropdown.isOpen
            id: dropdownButtonBorder
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
        visible: dropdown.isOpen
        parent: overlayRoot
        z: parent.z + 2

        function updateGeometry() {
            const dropdownAbsolutePosition = dropdownButton.mapToItem(overlayRoot, 0, dropdownButton.height);
            x = dropdownAbsolutePosition.x;
            y = dropdownAbsolutePosition.y;
        }

        width: dropdown.width
        height: childrenRect.height + border.width

        border {
            color: Values.colorBlack
            width: 2
        }

        ListView {
            id: listView
            anchors.top: parent.top
            visible: showModel
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - parent.border.width * 2
            height: childrenRect.height
            interactive: false
            model: _model
            delegate: DropdownButton {
                required property var modelData
                section: "sortType"
                inverted: modelData.key === key
                onClicked: {
                    selected(modelData.key);
                    dropdown.hide();
                }
                text: modelData.value
            }
        }

        Rectangle {
            id: viewHeader
            visible: showModel
            height: Values.navigatorDropdownHeaderHeight
            width: parent.width
            anchors.top: listView.bottom
            border {
                width: 2
                color: Values.colorBlack
            }
            color: Values.colorWhite

            //intercept clicks on the header - they should prevent the dropdown from closing
            MouseArea {
                anchors.fill: parent
            }

            ArkControls.Label {
                type: ArkControls.Label.Medium
                text: qsTr("View")
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Column {
            id: viewColumn
            anchors.top: showModel ? viewHeader.bottom : parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - parent.border.width * 2
            height: childrenRect.height

            DropdownButton {
                id: largeGrid
                text: qsTr("Large grid")
                section: "sortOrder"
                iconSource: "qrc:/ark/icons/grid_large"
                inverted: dropdown.thumbnailSize === ThumbnailSettings.Large
                visible: !dropdown.accessibilityMode
                onClicked: {
                    if (inverted) {
                        dropdown.hide();
                    }

                    updateThumbnailSize(ThumbnailSettings.Large);
                }
            }

            DropdownButton {
                id: gridButton
                text: qsTr("Medium grid")
                section: "sortOrder"
                iconSource: "qrc:/ark/icons/grid"
                inverted: dropdown.thumbnailSize === ThumbnailSettings.Medium
                onClicked: {
                    if (inverted) {
                        dropdown.hide();
                    }

                    updateThumbnailSize(ThumbnailSettings.Medium);
                }
            }

            DropdownButton {
                id: smallGrid
                text: qsTr("Small grid")
                section: "sortOrder"
                iconSource: "qrc:/ark/icons/grid_small"
                inverted: dropdown.thumbnailSize === ThumbnailSettings.Small
                onClicked: {
                    if (inverted) {
                        dropdown.hide();
                    }

                    updateThumbnailSize(ThumbnailSettings.Small);
                }
            }

            DropdownButton {
                id: listButton
                text: qsTr("List")
                section: "sortOrder"
                iconSource: "qrc:/ark/icons/list"
                inverted: dropdown.thumbnailSize === ThumbnailSettings.List
                onClicked: {
                    if (inverted) {
                        dropdown.hide();
                    }

                    updateThumbnailSize(ThumbnailSettings.List);
                }
            }
        }
    }
}
