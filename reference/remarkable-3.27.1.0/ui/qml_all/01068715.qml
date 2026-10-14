import QtQuick
import ark.tokens as ArkTokens
import ark.controls as ArkControls

import xofm.libs.pincode

FocusScope {
    id: root
    focus: true
    required property PasscodeHandler passcodeHandler
    property alias headerText: setPasscode.headerText
    property alias actionButton: setPasscode.buttonText

    property bool removePasscode: false
    readonly property bool shouldVerifyOldPasscode: passcodeHandler.hasPasscode && !setPasscode.oldPasscode

    signal cancel
    signal action
    signal remove
    signal enablePasscode(string newPasscode)

    PincodeDialogPage {
        id: setPasscode
        anchors.fill: parent
        focus: true

        property string currentAttempt
        property string oldPasscode // We capture it when we verify it, so we can use it when setting a new one

        passcodeLength: shouldVerifyOldPasscode ? passcodeHandler.passcodeLength : setPasscode.selectedPasscodeLength
        selectedPasscodeLength: Math.max(passcodeHandler.passcodeLength, passcodeHandler.minimumPincodeLength)
        showLengthSelection: !currentAttempt && !shouldVerifyOldPasscode
        minimumPincodeLength: passcodeHandler.minimumPincodeLength
        goBackButton: true
        title: {
            if (root.shouldVerifyOldPasscode) {
                return qsTr("Enter your passcode");
            } else if (!currentAttempt) {
                return qsTr("Enter your new passcode");
            } else {
                return qsTr("Verify your new passcode");
            }
        }
        warning: {
            return qsTr("Incorrect passcode. Try again.");
        }

        onGoBack: root.cancel()
        onAction: root.action()
        onAttempt: (attempt) => {
            if (root.removePasscode) {
                setPasscode.removePasscode(attempt);
            } else if (root.shouldVerifyOldPasscode) {
                setPasscode.verifyOldPasscode(attempt);
            } else {
                setPasscode.newPasscode(attempt);
            }
        }

        function removePasscode(attempt) {
            if (passcodeHandler.verifyCurrentPasscode(attempt)) {
                passcodeHandler.removePasscode();
                root.remove();
                return;
            }
            setPasscode.showPasscodeWarning = true;
        }

        function verifyOldPasscode(attempt) {
            if (!passcodeHandler.verifyCurrentPasscode(attempt)) {
                setPasscode.showPasscodeWarning = true;
                return;
            }
            setPasscode.oldPasscode = attempt;
            setPasscode.clear();
        }

        function newPasscode(attempt) {
            setPasscode.clear();
            if(!setPasscode.currentAttempt) {
                setPasscode.currentAttempt = attempt;
                return;
            }

            if (setPasscode.currentAttempt === attempt) {
                root.enablePasscode(attempt);
                passcodeHandler.setNewPasscode(setPasscode.oldPasscode, attempt);
            } else {
                setPasscode.showPasscodeWarning = true;
            }
            setPasscode.currentAttempt = "";
        }
    }
}
