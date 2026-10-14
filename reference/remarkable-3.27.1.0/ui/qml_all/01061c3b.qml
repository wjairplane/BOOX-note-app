import QtQuick
import com.remarkable
import common
import device.ui.controls
import device.ui.text
import xofm.libs.user
import xofm.libs.qtgui
import ark.tokens as ArkTokens
import ark.controls as ArkControls

Column {
    id: root

    signal openPairingSetupDialog
    signal openLogoutDeviceDialog
    signal wifiClicked

    required property AuthWrapper auth
    required property AuthHelper authHelper
    required property WindowNavigator windowNavigator
    required property bool canLogout

    readonly property bool loggedIn: auth.loginState !== AuthWrapper.NoUser // Consider any partially-paired state to mean "logged in"

    property bool hasConnectionError

    function testHasConnection() {
        root.hasConnectionError = false;
        if (!LinkProvider.isOnline) {
            root.hasConnectionError = true;
            return false;
        }
        return true;
    }

    function shouldEnablePairButton() {
        if (auth.loginState === AuthWrapper.Expired) {
            // allow the user to re-pair if token has expired
            return true;
        }
        return root.canLogout;
    }

    spacing: ArkControls.Values.platform.spacing.x2large

    Component {
        id: noConnectionComponent
        ArkControls.InfoMessage {
            message: qsTr("Pairing with the cloud requires a Wi-Fi connection.")
            iconSource: "qrc:/ark/icons/wifi_x"
            onClicked: root.wifiClicked()
        }
    }

    ArkControls.Panel {
        id: connectPanel
        width: parent.width
        visible: !root.loggedIn

        //: Shown when the user is not logged in yet on their device
        label: qsTr("No account")
        iconSource: "qrc:/ark/icons/user"
        description: qsTr("Pair your paper tablet with a&#160;reMarkable&#160;account.")
        action: ArkControls.Button {
            type: ArkTokens.Button.secondary
            //: When unpaired: Button sharing horizontal space with "No account" label + Settings menu.
            //: Recommended character limit for translation: 15.
            text: qsTr("Pair")
            onClicked: {
                if (root.testHasConnection()) {
                    root.openPairingSetupDialog();
                }
            }
        }
        showAttachment: root.hasConnectionError
        attachment: noConnectionComponent
    }

    ArkControls.Panel {
        id: logoutPanel
        visible: root.loggedIn
        width: parent.width
        label: {
            if (UserInfo.email) {
                return UserInfo.accountType !== UserInfo.Undefined
                        //: <b>john.doe@example.com</b> via a <b>Facebook account</b>
                        ? qsTr("<b>%1</b> via a <b>%2 account</b>").arg(UserInfo.email).arg(UserInfo.getAccountTypeString())
                        //: <b>john.doe@example.com</b>
                        : qsTr("<b>%1</b>").arg(UserInfo.email);
            } else {
                // It takes a moment for UserInfo.email to be updated after the pairing succeeds, so
                // so show some temporary loading text in the meantime.
                return qsTr("Loading...");
            }
        }
        description: qsTr("Your login details for your reMarkable account.")
        iconSource: "qrc:/ark/icons/user"

        action: ArkControls.Button {
            objectName: "pairButton"
            type: ArkTokens.Button.secondary
            visible: root.shouldEnablePairButton()
            text: auth && (auth.loginState === AuthWrapper.Expired)
                  //: When pairing failed: Button sharing horizontal space with user's email address + Settings menu.
                  //: Recommended character limit for translation: 15.
                  ? qsTr("Pair")
                  //: When paired: Button sharing horizontal space with user's email address + Settings menu.
                  //: Recommended character limit for translation: 15.
                  : qsTr("Unpair")
            onClicked: root.openLogoutDeviceDialog()
        }
    }
}
