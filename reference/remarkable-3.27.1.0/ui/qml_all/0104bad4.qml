import QtQuick

import xofm.libs.qtgui
import xofm.modules.pincode.qsettings

BaseView {
    id: root
    required property var passcodeResetHandler
    required property var wifiWidget

    contentItem: ForgotPasscodeScreen {
        passcodeResetHandler: root.passcodeResetHandler
        windowNavigator: root.windowNavigator
        wifiWidget: root.wifiWidget

        onPasscodeReset: {
            root.windowNavigator.open("security-pincode/window/passcode-reset");
            root.windowNavigator.close(root.objectName);
        }
    }
}
