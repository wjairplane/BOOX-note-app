import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import common

import device.ui.controls
import ark.controls as ArkControls

import xofm.libs.controls
import xofm.libs.wifi
import xofm.modules.wifi

ColumnLayout {
    id: root

    required property WifiNetworks wifiNetworks
    required property WifiConnection wifiConnection
    property bool simplifiedButtons: false

    signal requestOpenConnectDialog(ssid: string)

    WifiNetworksFilterModel {
        id: filterModel
        sourceModel: root.wifiNetworks.model
        excludeSsid: root.wifiConnection.selectedSsid
    }

    Component.onCompleted: {
        root.componentIsAlive = true;
    }
    Component.onDestruction: {
        root.componentIsAlive = false;
    }

    // Stop refreshing when the component is destroyed or not visible.
    // Destroyed components don't get visibility set to false - they just stop existing.
    // Some pages (e.g., setup/onboarding) instantiate this before it's visible, which
    // would otherwise cause unnecessary refreshing and break HiL power tests.
    property bool componentIsAlive: false
    Binding {
        target: root.wifiNetworks
        property: "isRefreshing"
        value: root.componentIsAlive && root.visible
    }

    spacing: ArkControls.Values.spacing.large

    QtObject {
        id: detail

        // Make space for the scrollbar on the right side of the available networks list
        readonly property int wifiListRightMargin: 35

        property string selectedSsid: ""

        onSelectedSsidChanged: {
            if (selectedSsid == "") {
                freezeWifiListTimer.stop();
            } else {
                freezeWifiListTimer.restart();
            }
        }

        function clearSelection() {
            selectedSsid = "";
        }
    }

    // Pause refresh briefly while a network action is selected so the surrounding
    // list stays calm during interaction.
    Timer {
        id: freezeWifiListTimer
        interval: 20000 // Since a WiFi scan can take a few seconds the actual pause will be higher than this
        onRunningChanged: {
            // Lets avoid this pausing for now. Since it entirely prevents refreshing it can create some visual bugs.
            // The wifilist with the better handling of updates keeps it much more stable, and this might be
            // entirely unnecessary. Want to keep it around for a little while if we need it back again.
            //root.wifiNetworks.isRefreshing = !running;
        }
    }

    Column {
        Layout.fillWidth: true
        Layout.rightMargin: detail.wifiListRightMargin
        visible: wifiConnection.isConnected || wifiConnection.isConnecting

        ArkControls.Title {
            type: ArkControls.Title.Medium
            width: parent.width
            text: wifiConnection.isConnected ? qsTr("Connected to") : (wifiConnection.selectedSsid !== "" ?
                                                                      qsTr("Connecting to...") : qsTr("Connecting..."))
        }

        WifiCell {
            width: parent.width
            Layout.alignment: Qt.AlignVCenter

            ssid: wifiConnection.selectedSsid
            signalIcon: wifiConnection.selectedSignalIcon
            selected: true
            configured: false
            security: wifiConnection.selectedSecurity

            showButtons: detail.selectedSsid === ssid
            onClicked: {
                if (detail.selectedSsid == ssid) {
                    detail.clearSelection();
                } else {
                    detail.selectedSsid = ssid;
                }
            }
            onDisconnect: wifiConnection.disconnectWifi()
            onForget: wifiConnection.forgetNetwork(ssid)
        }
    }

    RowLayout {
        height: errorTitle.height
        visible: errorTitle.text !== ""

        ArkControls.Icon {
            source: "qrc:/ark/icons/wifi_x"
        }

        ArkControls.Title {
            id: errorTitle
            type: ArkControls.Title.Medium
            Layout.fillWidth: true
            text: wifiConnection.currentErrorMessage
            elide: Text.ElideMiddle
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ArkControls.Title {
            type: ArkControls.Title.Medium
            Layout.fillWidth: true
            text: {
                if (networkList.count === 0) {
                    return qsTr("Searching for networks...");
                }
                if (wifiConnection.selectedSsid !== "") {
                    return qsTr("Networks");
                }
                return qsTr("Choose a network...");
            }
            visible: text !== ""
        }

        ScrollContainer {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: listHeightIndicator.visible ? ArkControls.Values.spacing.medium : 0

            view: ListView {
                id: networkList
                spacing: 0
                interactive: false
                clip: true

                model: filterModel

                QQC2.ScrollIndicator.vertical: QQC2.ScrollIndicator {
                    visible: listHeightIndicator.visible
                    contentItem: Rectangle {
                        implicitWidth: 6
                        color: Values.colorBlack
                    }
                }

                Rectangle {
                    id: listHeightIndicator
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    width: 2
                    height: parent.height - 4
                    color: Values.colorBlack
                    visible: networkList.height < networkList.contentHeight
                }

                delegate: WifiCell {
                    function doConnect() {
                        detail.clearSelection();
                        if (configured) {
                            root.wifiConnection.connectConfigured(ssid);
                            return;
                        }
                        if (security === WifiTypes.Security.Open) {
                            root.wifiConnection.connectOpen(ssid);
                            return;
                        }
                        root.requestOpenConnectDialog(ssid);
                    }

                    anchors.left: networkList.contentItem.left
                    anchors.right: networkList.contentItem.right
                    anchors.rightMargin: detail.wifiListRightMargin

                    selected: false
                    showButtons: detail.selectedSsid === ssid

                    simplifiedButtons: root.simplifiedButtons

                    onClicked: {
                        if (detail.selectedSsid === ssid) {
                            detail.clearSelection();
                            return;
                        }

                        if (configured || security === WifiTypes.Security.Open) {
                            detail.selectedSsid = ssid;
                        } else {
                            doConnect();
                        }
                    }
                    onConnect: {
                        doConnect();
                    }
                    onEdit: {
                        detail.clearSelection();
                        root.requestOpenConnectDialog(ssid);
                    }
                    onForget: {
                        detail.clearSelection();
                        root.wifiConnection.forgetNetwork(ssid);
                    }
                }
            }
        }
    }
}
