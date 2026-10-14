import QtQuick
import QtQuick.Layouts

import device.ui.controls
import common

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import com.remarkable // RetailDemo & PasscodeHandler
import xofm.libs.qtgui // WindowNavigator

Item {
    id: root

    required property WindowNavigator windowNavigator
    required property var iSettings
    property var navigationHandler
    property var nav: []

    function showCredentialsDialog() {
        windowNavigator.open("security-pincode/window/credentials", {
            "remove": true
        })
    }

    function activatePersonalInformation() {
        root.iSettings.idleDetailsVisible = !root.iSettings.idleDetailsVisible;
        if (root.iSettings.idleDetailsVisible && root.iSettings.idleContact.length === 0 && root.iSettings.idleName.length === 0) {
            root.showCredentialsDialog();
        }
    }

    function activateEditPersonalInformation() {
        root.showCredentialsDialog();
    }

    implicitHeight: col.implicitHeight

    ColumnLayout {
        id: col
        width: parent.width
        spacing: 0

        ArkControls.Panel {
            id: ownerName
            Layout.fillWidth: true
            label: qsTr("Personal information")
            description: qsTr("Identify your paper tablet in standby by adding contact details.")

            action: ArkToggleWrapper {
                id: toggle
                enabled: !RetailDemo.enabled
                checked: root.iSettings.idleDetailsVisible
                showFocus: !!navigationHandler && navigationHandler.current === toggle
                extendedMouseArea.onPressed: root.activatePersonalInformation();
                Component.onCompleted: root.nav[0] = toggle
            }
        }

        ArkControls.Cell {
            Layout.fillWidth: true
            visible: root.iSettings.idleDetailsVisible

            ArkControls.CellItem {
                id: item
                Layout.fillWidth: true
                text: qsTr("Edit personal information")
                showFocus: !!navigationHandler && navigationHandler.current === item
                onClicked: root.activateEditPersonalInformation();
                Component.onCompleted: root.nav[1] = item
            }
        }
    }
}
