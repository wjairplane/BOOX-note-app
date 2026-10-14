import QtQuick
import QtQuick.Layouts

import device.ui.controls
import common

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import com.remarkable // RetailDemo
import xofm.modules.security.pincode // PasscodeHandler
import xofm.libs.qtgui // WindowNavigator
import xofm.libs.pincode

Item {
    id: root

    required property WindowNavigator windowNavigator
    required property PasscodeHandler passcodeHandler
    property var navigationHandler
    property var nav: []

    implicitHeight: col.implicitHeight

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

    function activatePasscode() {
        if (passcodeHandler.hasPasscode) {
            root.showRemovePasscodeDialog();
        } else {
            root.showChangePasscodeDialog();
        }
    }

    function activateChangePasscode() {
        root.showChangePasscodeDialog();
    }

    function canDisablePasscode() {
        if (RetailDemo.enabled) {
            return false;
        }
        if (passcodeHandler.minimumPincodeLength > 0) {
            return false;
        }
        return true;
    }

    ColumnLayout {
        id: col
        width: parent.width
        spacing: 0

        ArkControls.Panel {
            id: setPasscode
            Layout.fillWidth: true
            label: qsTr("Passcode")
            description: {
                if (RetailDemo.enabled) {
                    return Strings.notAvailableInRetailString;
                } else {
                    return qsTr("Protect your notebooks and documents with a code.");
                }
            }
            action: ArkToggleWrapper {
                id: toggle
                visible: root.canDisablePasscode()
                checked: passcodeHandler.hasPasscode
                showFocus: !!navigationHandler && navigationHandler.current === toggle
                onCheckedChanged: {
                    // Restore binding overwritten by the switch. We don't need this with the mousearea workaround
                    checked = Qt.binding(() => { return passcodeHandler.hasPasscode; });
                }
                extendedMouseArea.onPressed: {
                    if (toggle.enabled) {
                        root.activatePasscode();
                    }
                }
                width: visible ? implicitWidth : 0
                Component.onCompleted: root.nav[0] = toggle
            }
        }

        ArkControls.Cell {
            Layout.fillWidth: true
            visible: passcodeHandler.hasPasscode

            ArkControls.CellItem {
                id: item
                Layout.fillWidth: true
                text: qsTr("Change passcode")
                status: "-".repeat(passcodeHandler.passcodeLength) // We only need the correct length
                hiddenStatus: true
                showFocus: navigationHandler && navigationHandler.current === item
                onClicked: root.activateChangePasscode();
                Component.onCompleted: root.nav[1] = item
            }
        }
    }
}
