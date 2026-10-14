import QtQuick

import xofm.libs.qtgui

BaseView {
    id: root
    required property var passcodeHandler

    contentItem: TimedOutDialog {
        passcodeHandler: root.passcodeHandler
        onResetPasscodeClicked: {
            root.windowNavigator.open(root.passcodeHandler.resetUrl);
        }
        onClose: {
            root.windowNavigator.close();
        }
    }

    Connections {
        target: passcodeHandler
        // We need to close the window on successful resets
        function onUnlocked() {
            root.windowNavigator.close();
        }
    }
}
