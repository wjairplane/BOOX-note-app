import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import common

import ark.tokens as ArkTokens
import ark.controls as ArkControls

import xofm.libs.controls
import xofm.libs.wifi
import xofm.modules.wifi

Item {
    id: root
    required property NetworkAdapter networkAdapter
    required property WifiNetworks wifiNetworks
    required property WifiConnection wifiConnection
    required property var windowNavigator

    property alias titleText: header.text

    // Fills the background with a solid color.
    Rectangle {
        id: rectangle

        anchors.fill: parent
        color: Values.colorWhite
    }

    ArkControls.PlaceholderBar {
        id: placeholder
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    ColumnLayout {
        anchors {
            top: placeholder.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: ArkControls.Values.margin.horizontal.large
            rightMargin: ArkControls.Values.margin.horizontal.large
            // Add a bit more space for the WiFi list in landscape
            bottomMargin: Values.isPortraitOrientation ? ArkControls.Values.margin.vertical.large
                                                       : ArkControls.Values.margin.horizontal.small
        }

        spacing: ArkControls.Values.spacing.large

        ArkControls.Title {
            id: header
            type: ArkControls.Title.Large
            text: qsTr("Wi-Fi settings")
            textFormat: Text.StyledText
            Layout.fillWidth: true
        }

        ArkControls.Panel {
            id: wifi
            label: qsTr("Wi-Fi")
            iconSource: "qrc:/ark/icons/wifi_3"
            Layout.fillWidth: true

            action: ArkControls.Toggle {
                checked: networkAdapter.isEnabled
                enabled: true
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -20
                    onClicked: networkAdapter.toggle()
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !networkAdapter.isEnabled
        }

        WifiList {
            id: wifiList
            wifiNetworks: root.wifiNetworks
            wifiConnection: root.wifiConnection
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: networkAdapter.isEnabled
            onRequestOpenConnectDialog: (ssid) =>
                root.windowNavigator.open("wifi/window/network-editor", { "ssid": ssid })
        }

        ArkControls.Button {
            text: qsTr("Join other network")
            type: ArkTokens.Button.secondary
            width: implicitWidth
            Layout.alignment: Qt.AlignRight

            onClicked: root.windowNavigator.open("wifi/window/network-editor")
        }
    }
}
