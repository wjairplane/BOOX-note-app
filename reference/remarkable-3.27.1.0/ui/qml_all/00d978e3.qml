import QtQuick
import QtQuick.Layouts

import common
import com.remarkable
import xofm.libs.batterymanager
import com.remarkable.devicetelemetry
import com.remarkable.telemetry as Telemetry

import device.ui.text
import device.ui.controls

import xofm.libs.qtgui

import ark.tokens as ArkTokens
import ark.controls as ArkControls

DeviceKeyboardNavigationHandler {
    id: root
    objectName: "Storage"

    required property WindowNavigator windowNavigator
    property bool showheader: true
    property bool fullscreen: false
    readonly property int gb: 1024 * 1024 * 1024
    property real usedGB: SystemMonitor.storageUsed / gb
    property real totalGB: SystemMonitor.storageTotal / gb

    signal close

    navigationModel: []
    canAcceptTabActivation: true

    onActivated: (element) => {
                     if (element) {
                         element.clicked();
                     }
                 }

    Background {
        anchors.fill: parent
    }

    ArkControls.NavigationBar {
        id: navigationBar
        type: ArkTokens.NavigationBar.secondary
        width: parent.width

        ArkControls.NavigationBar.Button {
            id: back
            text: qsTr("Back")
            textPosition: ArkControls.Button.TextPosition.Right
            iconSource: "qrc:/ark/icons/chevron_left"
            onClicked: root.close()
            Component.onCompleted: navigationModel[0] = back
            showFocus: root.current === back
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
        contentHeight: itemWrapper.childrenRect.height + (itemWrapper.children.length - 1) * ArkControls.Values.spacing.xlarge
        enableScrollbar: true
        permanentScrollbar: true
        scrollbarTopMargin: header.y

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
                visible: root.showheader
                //: Title of Storage settings page
                text: qsTr("Storage")
            }

            ColumnLayout {
                id: column
                anchors {
                    top: header.bottom
                    topMargin: ArkControls.Values.platform.spacing.x2large
                    left: parent.left
                    leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
                    right: parent.right
                    rightMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
                }

                ArkControls.Panel {
                    Layout.fillWidth: true
                    label: qsTr("Disk space")
                }

                ArkControls.ProgressBar {
                    id: diskSpaceProgress
                    type: ArkTokens.ProgressBar.primary
                    from: 0
                    to: totalGB
                    value: usedGB
                    Layout.fillWidth: true
                    large: true
                    Layout.topMargin: ArkControls.Values.spacing.medium
                }

                ArkControls.Panel {
                    id: storagePanel
                    label: qsTr("%1 GB of %2 GB used").arg(usedGB.toFixed(2)).arg(totalGB.toFixed(2))
                    Layout.topMargin: ArkControls.Values.spacing.medium
                    Layout.fillWidth: true
                    showAttachment: !SystemMonitor.enoughFreeSpaceForDownload
                    attachment: ArkControls.InfoMessage {
                        type: ArkTokens.InfoMessage.primary
                        width: storagePanel.width
                        title: SystemMonitor.enoughFreeSpaceForCreating ? qsTr("Disk is almost full") : qsTr("Disk is full")
                        iconSource: "qrc:/ark/icons/storage_full"
                        message: SystemMonitor.enoughFreeSpaceForCreating ?
                            qsTr("When the storage on your device has reached its maximum capacity, your device switches to read-only mode. To continue working as normal, free up space by deleting files or archiving content from your tablet to the cloud using the action bar in My files.") :
                            qsTr("Your device is now in read-only mode. To continue working as normal, free up space by deleting files or archiving content from your tablet to the cloud using the action bar in My files.");
                    }
                }

                ArkControls.Panel {
                    id: usbWebInterface

                    readonly property bool available: BatteryManager.battery.chargerState !== Battery.Disconnected

                    function activate() {
                        if (!usbWebInterface.enabled) {
                            return;
                        }
                        Settings.webInterfaceEnabled = !Settings.webInterfaceEnabled;
                    }

                    Layout.fillWidth: true
                    Layout.topMargin: ArkControls.Values.platform.spacing.x2large
                    label: qsTr("USB web interface")
                    description: qsTr("Access your device files in a web browser. Requires a cable&#160;connection.")
                    action: ArkToggleWrapper {
                        id: toggle
                        visible: usbWebInterface.available
                        checked: Settings.webInterfaceEnabled
                        showFocus: root.current === toggle
                        extendedMouseArea.onPressed: usbWebInterface.activate()
                        Component.onCompleted: root.navigationModel[0] = toggle
                    }
                    showAttachment: usbWebInterface.available && Settings.webInterfaceEnabled
                    attachment: ArkControls.InfoMessage {
                        width: usbWebInterface.width
                        type: ArkTokens.InfoMessage.secondary
                        message: qsTr("Open the address: <b>http://10.11.99.1</b> in a web browser.");
                        iconSource: "qrc:/ark/icons/information_circle"
                    }
                }
            }
        }
    }
}
