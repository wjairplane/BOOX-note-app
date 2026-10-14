import xofm.libs.qtgui // BaseView
import xofm.libs.pincode // UnlockScreen

BaseView {
    id: root

    required property var retailSettings
    required property var passcodeHandler
    required property var downloader

    contentItem: UnlockScreen {
        passcodeHandler: root.passcodeHandler
        retailSettings: root.retailSettings
        headerText: qsTr("Download localized library")
        passcodeText: qsTr("Enter passcode to confirm")
        description: root.downloader.description
        showBackButton: true
        onCancel: root.windowNavigator.close()
        onPasscodeVerified: {
            root.downloader.download();
        }
    }
}
