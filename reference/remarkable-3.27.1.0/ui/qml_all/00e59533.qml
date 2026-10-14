import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtQuickControls
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import device.view.settings as SettingsView
import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.setup
import xofm.libs.wifi

SetupBasePage {
    id: root

    required property NetworkAdapter networkAdapter
    required property WifiNetworks wifiNetworks
    required property WifiConnection wifiConnection
    required property var secureSettings
    required property var windowNavigator

    property bool checkForUpdate
    property bool stateWasReset
    property bool showWifiToggle: false
    showSkipButton: !wifiConnection.isConnected || !networkAdapter.isEnabled

    stateName: "Network"
    notificationMessage: qsTr("Wi-Fi is required to get the latest software. Update now (recommended), or later in Settings.")
    onNotificationConfirmed: root.forward()

    function handleBack() {
        return false;
    }

    ArkControls.SetupPage {
        id: _page
        anchors.fill: parent
        title: qsTr("Connect to Wi-Fi")
        primaryButtonText: qsTr("Next")
        primaryOption: wifiConnection.isConnected && wifiConnection.selectedSsid !== ""
        onPrimaryClicked: root.forward()
    }

    ColumnLayout {
        id: column
        anchors {
            fill: parent
            topMargin: _page.contentPosition.topMargin
            leftMargin: _page.contentPosition.leftMargin
            rightMargin: _page.contentPosition.rightMargin
            bottomMargin: _page.contentPosition.bottomMargin
        }
        spacing: ArkControls.Values.platform.spacing.x2large

        ArkControls.Panel {
            visible: root.showWifiToggle
            label: qsTr("Wi-Fi")
            iconSource: "qrc:/ark/icons/wifi_3"
            Layout.fillWidth: true

            action: ArkToggleWrapper {
                id: toggle

                function activate() {
                    networkAdapter.toggle();
                }

                checked: networkAdapter.isEnabled
                enabled: true
                extendedMouseArea.onPressed: toggle.activate()
            }
        }

        WifiList {
            id: wifiList
            wifiNetworks: root.wifiNetworks
            wifiConnection: root.wifiConnection
            simplifiedButtons: true
            onRequestOpenConnectDialog: (ssid) =>
                root.windowNavigator.open("wifi/window/network-editor", { "ssid": ssid })
        }
    }
}
