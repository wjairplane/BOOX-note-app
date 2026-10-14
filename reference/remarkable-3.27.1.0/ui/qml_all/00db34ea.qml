import QtQuick
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import device.global

import xofm.libs.settings
import xofm.libs.orientation
import xofm.libs.devicescreen

import ark.controls as ArkControls

DeviceKeyboardNavigationHandler {
    id: root

    // let's try to figure out whether the dropdown fits in the available height; to do so
    // we rely on DeviceScreenInfo, and the height of the sortListView
    // note: DeviceScreenInfo does not automatically take rotation in consideration
    property bool _shiftGridSelector: sortListView.height > (orientation.isPortraitOrientation ? DeviceScreenInfo.height : DeviceScreenInfo.width) / 2
    property alias name: dropdownContent.objectName
    // Something like [ {key: EntitySortedListModel.SortType, name: string} ]
    property var model
    required property Item overlayRoot
    required property Orientation orientation
    property bool accessibilityMode: Settings.accessibilityMode

    // Enum: EntitySortedListModel.SortType
    required property int sortType
    required property bool ascending
    // Enum: ThumbnailSettings.ThumbnailSize
    required property int thumbnailSize
    readonly property int _borderWidth: 2

    property var navigationHandler
    property bool drawFocus: !!navigationHandler && navigationHandler.current === root
    property bool showThumbnailOptions: true
    readonly property alias isOpen: internal.isOpen

    signal updateSortType(int sortType)
    signal updateAscending(bool ascending)
    signal updateThumbnailSize(int thumbnailSize)

    function requestUpdateGeometry() {
        updateGeometryTimer.start()
    }

    function hide() {
        internal.isOpen = false;
    }

    function toggleOpen() {
        dropdownButton.clicked(null);
        if (internal.isOpen) {
            root.forceActiveFocus();
        } else {
            root.focus = false;
        }
    }

    navigationModel: [sortListView]
    nextNavigationHandler: buttonHandler
    height: Values.navigatorDropdownHeaderHeight
    // Width adjusted for French translation needs
    width: Values.accessibilityMode ? 432 : 358 // more responsiveness will be brought by the future Ark dropdown component

    onActivated: current.activate()

    // There is no large grid in accessibility mode
    onAccessibilityModeChanged: {
        if (root.accessibilityMode && (root.thumbnailSize === ThumbnailSettings.ThumbnailSize.Large)) {
            root.updateThumbnailSize(ThumbnailSettings.ThumbnailSize.Medium);
        }
    }

    Background {
        anchors.fill: parent
    }

    QtObject {
        id: internal

        property bool isOpen: false
        property string minorHeaderText: {
            if (internal.isOpen) {
                return qsTr("Sort by");
            }
            const mapping = root.model?.find((elem) => { return elem.key === root.sortType; });
            if (!!mapping) {
                return qsTr(mapping.name);
            }
            return "";
        }
    }

    Timer {
        id: updateGeometryTimer
        interval: 50
        onTriggered: closeArea.updateGeometry()
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

    MouseArea {
        id: closeArea
        width: overlayRoot.width
        height: overlayRoot.height
        onClicked: root.hide()
        visible: internal.isOpen

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
        anchors.fill: parent

        onClicked: {
            internal.isOpen = !internal.isOpen;
            if (internal.isOpen) {
                root.requestUpdateGeometry();
            }
            Qt.inputMethod.hide();
        }

        ArkControls.Label {
            id: sortLabel
            text: qsTranslate("ExplorerHeader", internal.minorHeaderText)
            type: ArkControls.Label.Medium
            anchors {
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }
            states: [
                State {
                    when: internal.isOpen
                    AnchorChanges {
                        target: sortLabel
                        anchors.left: dropdownButton.left
                        anchors.right: undefined
                    }
                },
                State {
                    when: !internal.isOpen
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
            objectName: "icon"
            anchors {
                right: parent.right
                rightMargin: 16
                verticalCenter: parent.verticalCenter
            }
            source: internal.isOpen ? "qrc:/ark/icons/chevron_small_up" : "qrc:/ark/icons/chevron_small_down"
        }

        Rectangle {
            id: dropdownButtonBorder
            visible: internal.isOpen
            anchors.fill: parent
            color: "transparent"
            border {
                width: _borderWidth
                color: Values.colorBlack
            }
        }
    }

    Rectangle {
        id: dropdownContent

        property int highlightedSortType: root.sortType

        objectName: "dropdownContent"
        visible: internal.isOpen
        anchors.top: dropdownButton.bottom
        width: root.width
        height: {
            const ignoreGridSelectorHeight = root._shiftGridSelector || !root.showThumbnailOptions;
            return sortListView.height + (ignoreGridSelectorHeight ? _borderWidth : gridSizeSelector.height);
        }
        border {
            color: Values.colorBlack
            width: _borderWidth
        }

        // Please do not remove this timer as it improves the _percieved_
        // responsiveness.
        Timer {
            id: sortTimer
            interval: 50
            onTriggered: {
                root.updateSortType(dropdownContent.highlightedSortType);
                dropdownContent.highlightedSortType = Qt.binding( () => { return root.sortType; });
            }
        }

        ListView {
            id: sortListView
            objectName: "sortListView"
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            height: childrenRect.height
            width: parent.width - 2*_borderWidth
            interactive: false
            model: root.model
            delegate: DropdownButton {
                required property var modelData

                function activate() {
                    if (dropdownContent.highlightedSortType === modelData.key) {
                        root.updateAscending(!root.ascending);
                        return;
                    }
                    dropdownContent.highlightedSortType = modelData.key;
                    sortTimer.start();
                }

                section: "sortType"
                width: sortListView.width
                inverted: modelData.key === dropdownContent.highlightedSortType
                iconSource: {
                    if (!inverted) { // Only show the icon on the selected sort type
                        return "";
                    }

                    return root.ascending ? "qrc:/ark/icons/ascend" : "qrc:/ark/icons/descend";
                }
                onClicked: activate()
                text: qsTranslate("ExplorerHeader", modelData.name)
                navigationHandler: root
                focusFrame.z: dropdownContent.z + 1
            }
        }

        Background {
            id: gridSizeSelector
            width: parent.width
            height: root.showThumbnailOptions ? col.childrenRect.height : 0
            visible: root.showThumbnailOptions
            border {
                width: _borderWidth
                color: "black"
            }
            anchors.rightMargin: _shiftGridSelector ? -_borderWidth : 0
            anchors.topMargin: _shiftGridSelector ? -root.height : 0

            states: [
                State {
                    when: _shiftGridSelector
                    AnchorChanges {
                        target: gridSizeSelector
                        anchors.top: sortListView.top
                        anchors.right: parent.left
                        anchors.left: undefined
                    }
                },
                State {
                    when: !_shiftGridSelector
                    AnchorChanges {
                        target: gridSizeSelector
                        anchors.top: sortListView.bottom
                        anchors.bottom: undefined
                        anchors.right: undefined
                        anchors.left: parent.left
                    }
                }
            ]

            Column {
                id: col
                width: parent.width

                Item {
                    id: gridSizeHeader
                    objectName: "gridSizeHeader"
                    width: parent.width
                    height: Values.navigatorDropdownHeaderHeight

                    ArkControls.Label {
                        objectName: "gridSizeHeaderLabel"
                        type: ArkControls.Label.Medium
                        text: {
                            switch (buttonHandler.highlightedView) {
                            case ThumbnailSettings.ThumbnailSize.Large:
                                return qsTr("Large grid");
                            case ThumbnailSettings.ThumbnailSize.Medium:
                                return qsTr("Medium grid");
                            case ThumbnailSettings.ThumbnailSize.Small:
                                return qsTr("Small grid");
                            case ThumbnailSettings.ThumbnailSize.List:
                                return qsTr("List");
                            }
                            return "";
                        }
                        anchors {
                            left: parent.left
                            leftMargin: 20 // c.f. figma
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Separate handler here as we cannot mix the listview
                // with buttons in the model (for now)
                DeviceKeyboardNavigationHandler {
                    id: buttonHandler
                    objectName: "buttonHandler"

                    property int highlightedView: root.thumbnailSize
                    property int padding: 9

                    visible: showThumbnailOptions
                    navigationModel: [gridButtonLarge, gridButtonMedium, gridButtonSmall, listButton]
                    previousNavigationHandler: root
                    onActivated: current.activate()
                    width: parent.width - (dropdownContent.border.width * 2) - (2 * padding)
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: visible ? Values.navigatorDropdownButtonHeight + padding : 0 // 14 is the bottom padding value from Figma

                    // Please do not remove this timer as it improves the _perceived_
                    // responsiveness.
                    Timer {
                        id: viewTimer
                        interval: 50
                        onTriggered: {
                            updateThumbnailSize(buttonHandler.highlightedView)
                            buttonHandler.highlightedView = Qt.binding( () => { return root.thumbnailSize; });
                        }
                    }

                    Row {
                        id: viewRow
                        objectName: "viewRow"
                        anchors.fill: parent

                        DropdownButton {
                            id: gridButtonLarge

                            // Keyboard Navigation
                            function activate() {
                                buttonHandler.highlightedView = ThumbnailSettings.ThumbnailSize.Large;
                                viewTimer.start();
                            }

                            objectName: "gridButtonLarge"
                            text: qsTr("Large grid")
                            visible: !root.accessibilityMode
                            section: "sortOrder"
                            iconSource: "qrc:/ark/icons/grid_large"
                            inverted: buttonHandler.highlightedView === ThumbnailSettings.ThumbnailSize.Large
                            navigationHandler: buttonHandler
                            focusFrame.z: parent.z + 1
                            width: parent.width / (root.accessibilityMode ? 3 : 4)
                            iconOnly: true
                            onClicked: activate()
                        }

                        DropdownButton {
                            id: gridButtonMedium

                            // Keyboard Navigation
                            function activate() {
                                buttonHandler.highlightedView = ThumbnailSettings.ThumbnailSize.Medium;
                                viewTimer.start();
                            }

                            objectName: "gridButtonMedium"
                            text: qsTr("Medium grid")
                            section: "sortOrder"
                            iconSource: "qrc:/ark/icons/grid"
                            inverted: buttonHandler.highlightedView === ThumbnailSettings.ThumbnailSize.Medium
                            navigationHandler: buttonHandler
                            focusFrame.z: parent.z + 1
                            width: parent.width / (root.accessibilityMode ? 3 : 4)
                            iconOnly: true
                            onClicked: activate()
                        }

                        DropdownButton {
                            id: gridButtonSmall

                            // Keyboard Navigation
                            function activate() {
                                buttonHandler.highlightedView = ThumbnailSettings.ThumbnailSize.Small;
                                viewTimer.start();
                            }

                            objectName: "gridButtonSmall"
                            text: qsTr("Small grid")
                            section: "sortOrder"
                            iconSource: "qrc:/ark/icons/grid_small"
                            inverted: buttonHandler.highlightedView === ThumbnailSettings.ThumbnailSize.Small
                            navigationHandler: buttonHandler
                            focusFrame.z: parent.z + 1
                            width: parent.width / (root.accessibilityMode ? 3 : 4)
                            iconOnly: true
                            onClicked: activate()
                        }

                        DropdownButton {
                            id: listButton

                            // Keyboard Navigation
                            function activate() {
                                buttonHandler.highlightedView = ThumbnailSettings.ThumbnailSize.List;
                                viewTimer.start();
                            }

                            objectName: "listButton"
                            text: qsTr("List")
                            section: "sortOrder"
                            iconSource: "qrc:/ark/icons/list"
                            inverted: buttonHandler.highlightedView === ThumbnailSettings.ThumbnailSize.List
                            navigationHandler: buttonHandler
                            focusFrame.z: parent.z + 1
                            width: parent.width / (root.accessibilityMode ? 3 : 4)
                            iconOnly: true
                            onClicked: activate()
                        }
                    }
                }
            }
        }
    }
    FocusFrame {
        id: focus
        anchors.fill: parent
        visible: drawFocus
        borderColor: Values.colorBlack
    }
}
