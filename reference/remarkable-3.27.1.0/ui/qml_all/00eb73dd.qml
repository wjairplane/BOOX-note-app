import QtQuick

import xofm.libs.qtgui
import xofm.libs.pincode

BaseView {
    id: root

    required property var passcodeHandler

    onOpened: (args) => {
        const { remove } = args;
        setPasscode.removePasscode = remove ?? false;
    }

    contentItem: SetPasscode {
        id: setPasscode
        passcodeHandler: root.passcodeHandler
        onRemove: {
            root.windowNavigator.open("security-pincode/window/passcode-update-notification", {notification: qsTr("Your passcode is turned off")});
            root.windowNavigator.close("security-pincode/window/passcode-update");
        }

        onEnablePasscode: {
            root.windowNavigator.open("security-pincode/window/passcode-update-notification", {notification: qsTr("Your passcode has been updated")});
            root.windowNavigator.close("security-pincode/window/passcode-update");
        }

        onCancel: {
            root.windowNavigator.close("security-pincode/window/passcode-update");
        }
    }
}
