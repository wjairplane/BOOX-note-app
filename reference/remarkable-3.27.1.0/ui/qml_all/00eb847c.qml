import QtQuick

import xofm.libs.qtgui
import xofm.libs.pincode

BaseView {
    id: root
    required property var passcodeHandler

    contentItem: SetPasscode {
        id: setPasscode
        passcodeHandler: root.passcodeHandler
        headerText: qsTr("Success!")
        onEnablePasscode: root.windowNavigator.close()
        onCancel: root.windowNavigator.close()
        onAction: root.windowNavigator.close()
    }
}
