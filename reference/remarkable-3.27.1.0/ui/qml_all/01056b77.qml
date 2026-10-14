import QtQuick
import QtQuick.Layouts

import device.ui.controls
import common
import com.remarkable // RetailDemo

import xofm.libs.qtgui

import ark.controls as ArkControls
import ark.tokens as ArkTokens

Item {
    id: root

    required property bool isDiskEncrypted
    required property WindowNavigator windowNavigator
    property var navigationHandler
    property var nav: []

    function activateSecurityLevel() {
        if (!RetailDemo.enabled)
            root.windowNavigator.open("password/window/security-level");
    }

    function activateChangePassword() {
        if (!RetailDemo.enabled)
            root.windowNavigator.open("password/window/change-password");
    }

    implicitHeight: RetailDemo.enabled ? 0 : col.implicitHeight
    visible: implicitHeight > 0

    ColumnLayout {
        id: col
        width: parent.width
        visible: !RetailDemo.enabled
        spacing: 0

        ArkControls.Panel {
            id: ownerName
            Layout.fillWidth: true
            label: qsTr("Data protection")
            description: qsTr("Choose whether your disk is encrypted or not.")
        }

        ArkControls.Cell {
            Layout.fillWidth: true

            ArkControls.CellItem {
                id: securityLevelItem
                width: parent.width
                label: qsTr("Security level")
                status: root.isDiskEncrypted ? qsTr("Disk encryption") : qsTr("Standard")
                showFocus: !!root.navigationHandler && root.navigationHandler.current === securityLevelItem
                Component.onCompleted: root.nav[1] = securityLevelItem
                onClicked: root.activateSecurityLevel();
            }

            ArkControls.CellItem {
                id: changePassItem
                width: parent.width
                label: qsTr("Change password")
                status: "-".repeat(8)
                hiddenStatus: true
                showFocus: !!root.navigationHandler && root.navigationHandler.current === changePassItem
                visible: root.isDiskEncrypted
                Component.onCompleted: root.nav[2] = changePassItem
                onClicked: root.activateChangePassword();
            }
        }
    }
}
