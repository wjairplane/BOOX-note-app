import QtQuick

import xofm.libs.pincode

PincodeDialogPage {
    id: root

    property string currentAttempt

    signal passcodeChanged(string passcode)

    title: !currentAttempt ? qsTr("Set retail passcode") : qsTr("Verify retail passcode")
    warning: qsTr("Incorrect passcode. Try again.")
    minimumPincodeLength: 0

    onAttempt: (attempt) => {
        if (!root.currentAttempt) {
            root.currentAttempt = attempt;
            clear();
            return;
        }
        if (root.currentAttempt === attempt) {
            clear();
            passcodeChanged(attempt);
            return;
        }
        clear();
        showPasscodeWarning = true;
    }
}
