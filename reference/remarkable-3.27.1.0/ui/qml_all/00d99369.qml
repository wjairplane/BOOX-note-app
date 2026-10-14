import QtQuick
import QtQuick.Layouts

import com.remarkable
import common

import device.ui.text
import device.ui.controls

import ark.tokens as ArkTokens
import ark.controls as ArkControls

import xofm.libs.qtgui

DeviceKeyboardNavigationHandler {
    id: root
    objectName: "Display"

    required property var displayItems
    required property WindowNavigator windowNavigator

    signal close

    function goBack() {
        root.close();
    }

    function overrideNavigation(event) {
        // Handle going to the sidebar
        if (event.key === Qt.Key_Left) {
            root.resetFocusIndex();
            root.focus = false;
            root.navigate();
            return true;
        }
        return false;
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
        contentHeight: itemWrapper.childrenRect.height + column.implicitHeight
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
                    right: parent.right
                    rightMargin: ArkControls.Values.margin.horizontal.large
                }
                //: Title of Display settings page
                text: qsTr("Display settings")
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

                Repeater {
                    id: repeater

                    property int navOffset: 5

                    Layout.fillWidth: true
                    model: root.displayItems
                    delegate: WidgetLoader {
                        id: widgetLoader
                        Layout.fillWidth: true
                        onLoaded: {
                            root.navigationModel[repeater.navOffset++] = widgetLoader.item;
                        }
                    }
                }
            }
        }
    }
}
