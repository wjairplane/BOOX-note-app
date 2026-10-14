import QtQuick
import com.remarkable

import xofm.libs.qtgui
import xofm.libs.settings
import xofm.libs.user

CellItemWrapper {
    id: root

    required property AuthWrapper auth
    required property AuthHelper authHelper

    readonly property bool loggedIn: auth.loginState !== AuthWrapper.NoUser // Consider any partially-paired state to mean "logged in"

    function activate() {
        if(RetailDemo.enabled){
            root.windowNavigator.open("userfrontend/window/retail-account-settings");
            return;
        }
        root.windowNavigator.open("userfrontend/window/account-settings");
    }

    text: qsTr("Account")
    status: {
        if (!root.loggedIn){
            return qsTr("Pair with the reMarkable cloud");
        }
        if (UserInfo.accountType !== UserInfo.Undefined) {
            return qsTr("%1 via a %2 account").arg(UserInfo.email).arg(UserInfo.getAccountTypeString());
        }
        return qsTr("%1").arg(UserInfo.email);
    }
    onClicked: activate()
}
