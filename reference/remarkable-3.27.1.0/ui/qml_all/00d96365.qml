import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import com.remarkable
import common

import device.ui.controls
import device.ui.text

import xofm.libs.qtgui
import xofm.libs.settings

import ark.tokens as ArkTokens
import ark.controls as ArkControls

DeviceKeyboardNavigationHandler {
    id: root
    objectName: "General"

    required property var generalPaperTabletCells
    required property var paperTabletInfoMessage
    required property var personalCells
    required property var generalAccountInfo
    required property var internalBuildCells
    required property WindowNavigator windowNavigator
    required property var secureSettings

    property alias fullscreen: subpageLoader.active
    property bool showheader: true
    signal wifiClicked

    function goBack() {
        if (subpageLoader.active) {
            if (subpageLoader.item.goBack()) {
                return true;
            }
            subpageLoader.active = false;
            return true;
        }
        return false;
    }

    function overrideNavigation(event) {
        // Handle going to the sidebar
        if (event.key === Qt.Key_Left) {
            root.resetFocusIndex();
            root.focus = false;
            // settings.focus = true;
            settings.navigate();
            return true;
        }
        return false;
    }

    function showSubscription() {
        subpageLoader.sourceComponent = accountComponent;
        subpageLoader.active = true;
    }

    navigationModel: []
    canAcceptTabActivation: true
    keyOverrideHandler: overrideNavigation.bind(this)

    onActivated: (element) => {
        if (element) {
            element.activate();
        }
    }

    ScrollArea {
        id: flickable

        anchors.fill: parent
        contentWidth: width
        contentHeight: itemWrapper.childrenRect.height + (itemWrapper.children.length - 1) * ArkControls.Values.spacing.xlarge
        enableScrollbar: true
        permanentScrollbar: true
        scrollbarTopMargin: header.y

        Item {
            id: itemWrapper
            implicitWidth: flickable.width

            ArkControls.PlaceholderBar {
                id: placeholder
                width: parent.width
            }

            ArkControls.Title {
                id: header
                type: ArkControls.Title.Large
                anchors {
                    top: placeholder.bottom
                    left: parent.left
                    leftMargin: ArkControls.Values.margin.horizontal.large
                }
                //: Title of General settings page
                text: qsTr("General settings")
            }

            ColumnLayout {
                id: column
                anchors {
                    top: header.bottom
                    topMargin: ArkControls.Values.platform.spacing.x2large
                    left: parent.left
                    leftMargin: ArkControls.Values.margin.horizontal.large
                    right: parent.right
                    rightMargin: ArkControls.Values.margin.horizontal.large
                }
                spacing: ArkControls.Values.platform.spacing.x2large

                ArkControls.Cell {
                    id: personalInfo
                    Layout.fillWidth: true

                    Repeater {
                        id: personalRepeater
                        model: root.personalCells
                        delegate: WidgetLoader {
                            id: personalWidgetLoader

                            required property int index

                            onLoaded: {
                                personalWidgetLoader.item.navigationHandler = root;
                                root.navigationModel[personalWidgetLoader.index] = personalWidgetLoader.item;
                            }
                        }
                    }
                }

                Repeater {
                    Layout.fillWidth: true
                    Layout.topMargin: -ArkControls.Values.spacing.small
                    model: root.generalAccountInfo
                    delegate: WidgetLoader {
                        Layout.fillWidth: true
                        Layout.topMargin: -column.spacing
                        visible: item?.visible
                    }
                }

                ArkControls.Cell {
                    id: paperTablet
                    Layout.fillWidth: true

                    Repeater {
                        id: repeater

                        property int navOffset: 5

                        model: root.generalPaperTabletCells
                        delegate: WidgetLoader { // PaperTabletCellItem.qml
                            id: paperTabletWidgetLoader

                            required property int index

                            onLoaded: {
                                paperTabletWidgetLoader.item.navigationHandler = root;
                                root.navigationModel[repeater.navOffset + index] = paperTabletWidgetLoader.item;
                            }
                        }
                    }
                }

                ArkControls.Cell {
                    id: internalCell
                    Layout.fillWidth: true

                    Repeater {
                        id: internalRepeater

                        property int navOffset: 10

                        model: root.internalBuildCells
                        delegate: WidgetLoader {
                            id: internalWidgetLoader

                            required property int index

                            onLoaded: {
                                internalWidgetLoader.item.navigationHandler = root;
                                root.navigationModel[internalRepeater.navOffset + index] = internalWidgetLoader.item;
                            }
                        }
                    }
                }

                Repeater {
                    id: paperTabletInfo
                    Layout.fillWidth: true
                    model: root.paperTabletInfoMessage
                    delegate: WidgetLoader {
                        Layout.fillWidth: true
                        Layout.topMargin: -column.spacing
                    }
                }

                ColumnLayout {
                    spacing: ArkControls.Values.spacing.small

                    ArkControls.Panel {
                        id: flightModePanel
                        Layout.fillWidth: true
                        label: qsTr("Flight mode")
                        iconSource: secureSettings.airplaneMode ? "qrc:/ark/icons/airplane_fill" : "qrc:/ark/icons/airplane"
                        action: ArkToggleWrapper {
                            id: toggle
                            checked: secureSettings.airplaneMode
                            enabled: !RetailDemo.enabled
                            extendedMouseArea.onClicked: secureSettings.airplaneMode = !secureSettings.airplaneMode;
                            showFocus: root.current === toggle
                            Component.onCompleted: root.navigationModel[15] = toggle;
                        }
                    }
                }

                Row {
                    id: rows
                    Layout.fillWidth: true
                    spacing: ArkControls.Values.spacing.medium
                    visible: !RetailDemo.enabled

                    ArkControls.Button {
                        id: rebootButton
                        type: ArkTokens.Button.secondary
                        textPosition: ArkControls.Button.TextPosition.Right
                        text: qsTr("Restart")
                        iconSource: "qrc:/ark/icons/restore"
                        width: (rows.width - rows.spacing)/2
                        onClicked: root.windowNavigator.open("powermanager/window/poweroff", {reboot: true});
                        showFocus: root.current === rebootButton
                        Component.onCompleted: root.navigationModel[16] = rebootButton;
                    }

                    ArkControls.Button {
                        id: powerOffButton
                        type: ArkTokens.Button.secondary
                        textPosition: ArkControls.Button.TextPosition.Right
                        text: qsTr("Turn off")
                        iconSource: "qrc:/ark/icons/power"
                        width: rebootButton.width
                        onClicked: root.windowNavigator.open("powermanager/window/poweroff", {reboot: false || RetailDemo.enabled});
                        showFocus: root.current === powerOffButton
                        Component.onCompleted: root.navigationModel[17] = powerOffButton;
                    }
                }
            }
        }
    }

    Loader {
        id: subpageLoader
        anchors.fill: parent
        active: false
        focus: true
    }
}
