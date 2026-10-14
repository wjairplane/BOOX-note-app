import QtQuick
import QtQuick.Layouts

import com.remarkable
import common

import device.ui.text
import device.ui.controls
import device.view.experimental

import xofm.libs.qtgui

import ark.controls as ArkControls

DeviceKeyboardNavigationHandler {
    id: root
    objectName: "Security"

    property bool showheader: true
    property bool removePasscode: false
    required property var iSettings
    required property WindowNavigator windowNavigator
    required property var securityPanels

    navigationModel: []
    canAcceptTabActivation: true
    keyOverrideHandler: overrideNavigation.bind(this)

    onActivated: (element) => {
        if (element) {
            element.activate();
        }
    }

    function overrideNavigation(event) {
        // Handle going to the sidebar
        if (event.key === Qt.Key_Left) {
            root.resetFocusIndex();
            root.focus = false;
            settings.navigate();
            return true;
        }
        return false;
    }

    function showChangePasscodeDialog() {
        windowNavigator.open("security-pincode/window/passcode-update", {
            "remove": false
        })
    }
    function showRemovePasscodeDialog() {
        windowNavigator.open("security-pincode/window/passcode-update", {
            "remove": true
        })
    }
    function showCredentialsDialog() {
        windowNavigator.open("settings/window/credentials", {
            "remove": true
        })
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
                visible: root.showheader
                text: qsTr("Security settings")
            }

            ColumnLayout {
                id: column
                anchors {
                    left: parent.left
                    leftMargin: ArkControls.Values.margin.horizontal.large
                    right: parent.right
                    rightMargin: ArkControls.Values.margin.horizontal.large
                    top: header.bottom
                    topMargin: ArkControls.Values.platform.spacing.x2large
                }
                spacing: ArkControls.Values.platform.spacing.x2large

                Repeater {
                    id: panelsRepeater

                    property int navOffset: 0

                    Layout.fillWidth: true
                    model: root.securityPanels
                    delegate: WidgetLoader {
                        id: panelsWidgetLoader
                        Layout.fillWidth: true
                        onLoaded: {
                            panelsWidgetLoader.item.navigationHandler = root;
                            root.navigationModel[panelsRepeater.navOffset++] = panelsWidgetLoader.item.nav[0];
                            root.navigationModel[panelsRepeater.navOffset++] = panelsWidgetLoader.item.nav[1];
                        }
                    }
                }
            }
        }
    }
}
