import QtQuick

import device.view.experimental

import xofm.libs.qtgui
import xofm.libs.setup
import xofm.libs.user
import xofm.libs.dialogs
import xofm.modules.userfrontend
import com.remarkable

import ark.controls as ArkControls

BaseView {
    id: root

    required property AuthWrapper auth
    readonly property string userEmail: UserInfo.email ? qsTr(", %1").arg(UserInfo.email) : ""
    required property var logoutPolicy

    onOpened: {
        if (auth.loginState !== AuthWrapper.Expired) {
            console.warn("This window should not been opened with this login state.")
            root.windowNavigator.close(root.objectName);
        }
    }

    contentItem: ReauthDialog {
        email: userEmail
        logoutPolicy: root.logoutPolicy

        onUnpairClicked: {
            root.windowNavigator.open("userfrontend/window/unpairing-dialog");
            root.windowNavigator.close(root.objectName);
        }
        onPairClicked: {
            root.windowNavigator.open("userfrontend/window/pairing-setup");
            root.windowNavigator.close(root.objectName);
        }
        onClose: root.windowNavigator.close(root.objectName)
    }
}
