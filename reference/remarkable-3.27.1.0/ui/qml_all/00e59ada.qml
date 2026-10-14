import QtQuick
import QtQuick.Layouts
import common
import device.global

import xofm.libs.wifi
import xofm.libs.qtgui
import ark.controls as ArkControls
import ark.tokens as ArkTokens
import xofm.libs.settings // SettingsPage

Item {
    id: root

    required property NetworkAdapter networkAdapter
    required property WifiConnection wifiConnection
    required property WindowNavigator windowNavigator

    implicitWidth: parent ? parent.width : 0
    implicitHeight: visible ? ArkTokens.Style.variable.controlsHeight.small : 0

    RowLayout {
        id: wifiRow
        spacing: ArkTokens.Style.variable.platform.spacing.small
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter

        ArkControls.Label {
            accessibility: false
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            text: wifiConnection.selectedSsid || qsTr("No Wi-Fi")
            elide: Text.ElideMiddle
            Layout.fillWidth: true
        }

        ArkControls.Icon {
            id: wifiIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            size: ArkControls.Values.iconSize.medium
            color: Values.colorBlack
            source: {
                if (!wifiConnection.isConnected || !networkAdapter.isEnabled) {
                    return "qrc:/ark/icons/wifi_off";
                }
                return wifiConnection.selectedSignalIcon;
            }
        }
    }

    MouseArea {
        anchors.fill: root

        onClicked: {
            root.windowNavigator.close("settings/window/quicksettings");
        }

        onPressAndHold: {
            root.windowNavigator.open("settings/window/main", { index: SettingsPage.Wifi });
            root.windowNavigator.close("settings/window/quicksettings");
        }
    }
}
