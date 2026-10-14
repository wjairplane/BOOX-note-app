import QtQuick
import com.remarkable
import QtQuick.Layouts
import common
import device.ui.controls
import xofm.libs.qtgui

import ark.controls as ArkControls
import ark.tokens as ArkTokens
import xofm.modules.softwareupdate
import xofm.libs.batterymanager

BaseView {
    id: root
    required property var updateEnabled
    required property var currentVersion
    required property var updater
    required property ShutdownCommand shutdownCommand
    required property var widgets

    contentItem: Background {

        ArkControls.NavigationBar {
            id: navigationBar
            type: ArkTokens.NavigationBar.secondary
            width: parent.width

            ArkControls.NavigationBar.Button {
                id: back
                text: qsTr("Back")
                textPosition: ArkControls.Button.TextPosition.Right
                iconSource: "qrc:/ark/icons/chevron_left"
                onClicked: root.windowNavigator.close(root.objectName)
            }
        }

        ScrollArea {
            id: flickable
            anchors {
                top: navigationBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            contentWidth: width
            contentHeight: itemWrapper.childrenRect.height + ArkControls.Values.spacing.xlarge +
                           ArkControls.Values.margin.vertical.small_static
            clip: true
            enableScrollbar: true

            Item {
                id: itemWrapper
                implicitWidth: flickable.width

                ArkControls.Title {
                    id: header
                    type: ArkControls.Title.Large
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
                        rightMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
                    }
                    text: qsTr("Software")
                }

                ColumnLayout {
                    id: dynamicContentColumn

                    spacing: 0
                    anchors {
                        top: header.bottom
                        left: header.left
                        right: header.right
                        topMargin: ArkControls.Values.platform.spacing.x2large
                    }

                    UpdatePanel {
                        windowNavigator: root.windowNavigator
                        currentVersion: root.currentVersion
                        updater: root.updater
                        shutdownCommand: root.shutdownCommand
                        updateEnabled: root.updateEnabled.enabled
                        Layout.fillWidth: true
                    }

                    Repeater {
                        model: root.widgets
                        delegate: WidgetLoader {
                            required property int index
                            required property var model
                            Layout.topMargin: ArkControls.Values.platform.spacing.x2large
                            Layout.fillWidth: true
                            id: loader
                        }
                    }
                }
            }
        }

        Timer {
            id: advisoryTimer
            interval: Values.popupTimeout
            running: !root.updateEnabled.enabled
        }

        ArkControls.NotificationBar {
            id: advisoryBanner
            type: ArkTokens.NotificationBar.secondary
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            visible: advisoryTimer.running

            ArkControls.NotificationBar.Message {
                type: advisoryBanner.type
                text: qsTr("Make sure to manually update your device regularly")
                Layout.leftMargin: ArkControls.Values.padding.large
                Layout.rightMargin: ArkControls.Values.padding.large
                Layout.fillWidth: true
            }
        }
    }
}
