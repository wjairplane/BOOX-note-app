import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtQuickControls
import com.remarkable
import common
import device.ui.controls
import device.system
import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.setup
import xofm.libs.pincode

SetupBasePage {
    id: root

    required property var passcodeHandler
    property string verifyText: qsTr("Verify passcode")
    property string initialText: qsTr("Enter passcode")

    stateName: "PasscodePage"
    showSkipButton: passcodeHandler.minimumPincodeLength === 0
    showBackButton: true
    notificationMessage: qsTr("You can set a passcode in Security settings at any time.")
    onNotificationConfirmed: root.forward();

    onVisibleChanged: {
        // we need to be sensible when someone presses back in setup
        if (root.visible) {
            setPasscode.clear();
            setPasscode.currentAttempt = "";
        }
    }

    PincodeDialog {
        id: setPasscode
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: ArkControls.Values.margin.horizontal.large
            rightMargin: ArkControls.Values.margin.horizontal.large
            verticalCenter: parent.verticalCenter
        }
        focus: true
        passcodeLength: passcodeHandler.passcodeLength
        minimumPincodeLength: passcodeHandler.minimumPincodeLength
        warning: qsTr("Incorrect passcode. Try again.")

        property string currentAttempt

        onAttempt: (attempt) => {
            setPasscode.clear();
            if (!currentAttempt) {
                currentAttempt = attempt;
            } else if (attempt === currentAttempt) {
                // We assume we don't have a passcode during the setup flow,
                // reboot should factory reset and navigating back here should be an error.
                // Since it currently ISN'T, this behaviour is buggy.
                // TODO: fix it. Jira: SPT-6054
                if (!passcodeHandler.setNewPasscode("", attempt)) {
                     setPasscode.showPasscodeWarning = true;
                }
                root.forward();
            } else {
                setPasscode.showPasscodeWarning = true;
            }
        }
    }

    ArkControls.SetupPage {
        id: _page
        anchors.fill: parent
        title: !!setPasscode.currentAttempt ? root.verifyText : root.initialText
        description: !!setPasscode.currentAttempt
                ? qsTr("Re-enter the passcode to confirm it.")
                : qsTr("Set a passcode to keep your paper&#160;tablet&#160;secure.")
    }
}
