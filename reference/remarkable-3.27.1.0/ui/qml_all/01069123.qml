import QtQuick
import ark.tokens as ArkTokens
import ark.controls as ArkControls

import xofm.libs.qtgui
import xofm.libs.pincode

FocusScope {
    id: root
    focus: true

    required property PasscodeHandler passcodeHandler
    property var retailSettings
    property alias showBackButton: unlock.goBackButton
    property alias passcodeText: unlock.title
    property alias headerText: unlock.headerText
    property alias description: unlock.description
    readonly property string warningText: unlock.warning
    signal passcodeVerified
    signal cancel

    PincodeDialogPage {
        id: unlock
        objectName: "unlockDialog"
        anchors.fill: parent
        focus: true

        passcodeLength: passcodeHandler?.passcodeLength ?? 6
        minimumPincodeLength: passcodeHandler?.minimumPincodeLength ?? 6
        goBackButton: false
        title: qsTr("Enter passcode")
        warning: {
            if (retailSettings?.enabled) {
                return qsTr("Incorrect passcode. Try again or contact Support.");
            }
            return qsTr("Wrong passcode. Try again.");
        }

        onGoBack: root.cancel()
        onAttempt: (attempt) => {
            if (retailSettings?.enabled && retailSettings?.verifyCurrentPasscode(attempt)) {
                unlock.accepted();
                return;
            }
            if (root.passcodeHandler?.verifyCurrentPasscode(attempt)) {
                unlock.accepted();
            } else {
                showPasscodeWarning = true;
            }
        }

        function accepted() {
            unlock.clear();
            root.passcodeHandler?.resetEntry();
            root.passcodeVerified();
        }
    }
}
