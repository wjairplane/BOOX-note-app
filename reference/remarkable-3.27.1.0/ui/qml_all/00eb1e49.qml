import com.remarkable // DeviceApp

import xofm.libs.qtgui // BaseView
import xofm.libs.pincode // UnlockScreen

BaseView {
    id: root

    required property var retailSettings
    required property ShutdownCommand shutdownCommand
    required property var passcodeHandler

    contentItem: UnlockScreen {
        passcodeHandler: root.passcodeHandler
        retailSettings: root.retailSettings
        headerText: qsTr("Exit retail mode")
        passcodeText: qsTr("Enter passcode to confirm")
        description: qsTr("To exit retail mode and restore the device to its original settings, a factory reset is required.")
        showBackButton: true
        onCancel: root.windowNavigator.close()
        onPasscodeVerified: {
            DeviceApp.factoryReset();
            root.windowNavigator.close();
        }
    }
}
