import QtQuick

import xofm.libs.dialogs

DialogScreen {
    id: root

    signal enterRecovery()
    signal factoryReset()

    gobackButton: false
    text: qsTr("Recover your paper tablet")
    description: qsTr("Enter the recovery code that you got when setting a passcode. If you can't find it, a factory reset is required.")
    iconSource: "qrc:/ark/icons/padlock"
    accidentalTouchPrevention: true
    buttons: {
        const enterRecoveryButton = {
            text: qsTr("Enter recovery code"),
            highlight: true,
            action: function() {
                root.enterRecovery()
            }
        };
        const factoryResetButton = {
            text: qsTr("Factory reset"),
            highlight: false,
            action: function() {
                root.factoryReset()
            }
        }

        return [factoryResetButton, enterRecoveryButton]
    }
}
