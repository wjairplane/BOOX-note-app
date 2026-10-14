import QtQuick

import xofm.libs.dialogs
import xofm.libs.controls

FocusScope {
    id: root

    property bool _readyToSetNewPassword: false
    property int pukLength
    property alias dialogSubDescription: dialog.subDescription

    signal attempRecoveryCode(string code)
    signal setNewPassword()
    signal goBack

    DialogScreen {
        id: dialog
        anchors.fill: parent
        gobackButton: true
        subDescription: ""
        focus: true
        text: qsTr("Enter recovery code")
        iconSource: "qrc:/ark/icons/padlock"
        buttons: _readyToSetNewPassword ? [
            {
                text: qsTr("Set new passcode"),
                highlight: true,
                action: function() {
                    root.setNewPassword();
                    root.dialogSubDescription = "";
                }
            }
        ] : []
        onGoBack: root.goBack()

        DashedFixedTextField {
            id: inputField
            anchors.centerIn: parent
            input.inputMethodHints: Qt.ImhNoAutoUppercase
            height: 100
            clearOnFullInput: false
            focus: true
            maximumLength: root.pukLength
            onAccepted: {
                root._readyToSetNewPassword = true;
                root.attempRecoveryCode(text);
                focus = false; // hide the keyboard
            }

            onActiveFocusChanged: {
                if(activeFocus) {
                    inputField.clearInputText();
                }
            }
        }
    }
}
