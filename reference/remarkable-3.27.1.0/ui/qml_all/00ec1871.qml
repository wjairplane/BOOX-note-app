import QtQuick

import xofm.libs.qtgui
import xofm.libs.user
import xofm.modules.userfrontend
import com.remarkable

BaseView {
    id: root

    required property AuthWrapper auth
    required property AuthHelper authHelper
    required property LinkProvider linkProvider
    required property var logoutPolicy

    onOpened: {
        if (auth.loginState === AuthWrapper.NoUser) {
            console.warn("This window should not been opened with this login state.")
            root.windowNavigator.close(root.objectName);
        }
        LogoutHandler.checkReadyForLogout();
    }

    contentItem: UnpairingDialog {
        id: dialog
        isOnline: root.linkProvider.isOnline
        onClose: root.windowNavigator.close(root.objectName)
        logoutPolicy: root.logoutPolicy.value
    }
}
