import QtQuick

import xofm.libs.qtgui
import xofm.libs.pincode

BaseView {
    id: root
    required property PasscodeHandler passcodeHandler
    required property var batteryManager
    required property var pincodeWidgets

    Connections {
        target: root.batteryManager
        function onDisplayStateChanged(previous, next) {
            // We don't actually care which transition it is, might as well clear it when going to sleep or when waking up
            unlock.clear();
        }
    }

    Connections {
        target: passcodeHandler
        // When resetting the passcode, we don't expect this window to remain open.
        // Currently, if you skip setting a passcode, you'd be stuck on the unlock screen until reboot.
        // This will be problematic once the unlock window is the startup window...
        function onHasPasscodeChanged(hasPasscode) {
            if (!hasPasscode) {
                root.windowNavigator.close(root.objectName);
            }
        }
    }

    onOpened: {
        if (passcodeHandler.lockTime > 0) {
            root.windowNavigator.open("security-pincode/window/timed-out");
        }
    }
    contentItem: PincodeDialogPage {
        id: unlock
        passcodeLength: passcodeHandler.passcodeLength
        minimumPincodeLength: passcodeHandler.minimumPincodeLength
        pincodeWidgets: root.pincodeWidgets
        goBackButton: false
        title: qsTr("Enter passcode")
        warning: {
            if(passcodeHandler.pinLockedState === PasscodeHandler.LOCKED) {
                //: The user is fully locked out
                return qsTr("A reset is required to unlock your device.");
            }
            if(passcodeHandler.pinLockedState === PasscodeHandler.FINAL_TRY) {
                return qsTr("Final attempt before you need to reset");
            }
            //: We don't know, or there is no limit
            return qsTr("Incorrect passcode. Try again.");
        }

        buttonText: {
            if(passcodeHandler.pinLockedState === PasscodeHandler.LOCKED) {
                return qsTr("Reset passcode");
            }
            return "";
        }
        onAction: {
            root.windowNavigator.open(root.passcodeHandler.resetUrl);
        }

        onAttempt: (attempt) => {
            if (root.passcodeHandler.verifyCurrentPasscode(attempt)) {
                unlock.accepted();
            } else {
                unlock.showPasscodeWarning = true;
            }
        }

        function accepted() {
            unlock.clear();
            root.passcodeHandler.resetEntry();
            root.windowNavigator.close("security-pincode/window/unlock");
        }
    }
}
