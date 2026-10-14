import QtQuick

import com.remarkable

import device.ui.headers

import ark.tokens as ArkTokens
import ark.controls as ArkControls

import xofm.libs.qtgui

BaseView {
    id: root

    onOpened: (args) => {
        const { notification } = args;
        if (!notification){
            console.warning("notification argument was not sent to window 'security-pincode/window/passcode-update-notification'");
            rootWindow.windowNavigator.close("security-pincode/window/passcode-update-notification");
            return;
        }
        changedPasscodeModal.text = notification;
    }
    contentItem: Item {
        ArkControls.PlaceholderBar {
            id: placeholder
            visible: true
        }

        Header {
            id: changedPasscodeModal
            blackOnWhite: false
            height: placeholder.height
            hideOnDismiss: false
            visible: true
            width: root.width
            rejectEnabled: false
            timeout: 3000
            onTimedOut: root.windowNavigator.close("security-pincode/window/passcode-update-notification")
        }
    }
}
