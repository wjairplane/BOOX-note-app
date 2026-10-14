import QtQuick

import xofm.libs.pincode

PincodeDialogPage {
    id: root

    required property var retailSettings

    signal accepted
    signal close

    title: qsTr("Enter passcode")
    warning: qsTr("Incorrect passcode. Try again.")
    minimumPincodeLength: 0
    goBackButton: true
    onGoBack: root.close()
    passcodeLength: retailSettings.passcodeLength
    onAttempt: (attempt) => {
        if(retailSettings?.verifyCurrentPasscode(attempt)) {
            clear();
            root.accepted();
        } else {
            clear();
            showPasscodeWarning = true;
        }
    }
}
