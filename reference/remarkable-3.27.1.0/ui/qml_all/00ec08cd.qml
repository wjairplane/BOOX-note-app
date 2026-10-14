import QtQuick
import QtQuick.Layouts
import ark.tokens as ArkTokens
import ark.controls as ArkControls

import xofm.libs.user

ArkControls.InfoMessage {
    id: root

    required property AuthWrapper auth

    type: ArkTokens.InfoMessage.primary
    Layout.fillWidth: true
    iconSource: "qrc:/ark/icons/information_circle"
    visible: auth.loginState !== AuthWrapper.Ok

    Component.onCompleted: auth.updateLoginStatus()

    message: {
        switch (auth.loginState) {
        case AuthWrapper.NoUser: // not paired
            return qsTr("Pair your paper tablet to sync content to the cloud and use basic features.");
        case AuthWrapper.LacksEmailVerification:
            return qsTr("Verify your account by email. Open the verification link we sent you.");
        case AuthWrapper.Verbatim:
            return auth.verbatimErrorInfo.title === "" ? qsTr("Manage your account") : auth.verbatimErrorInfo.title
        case AuthWrapper.Expired:
            return qsTr("Pair your paper tablet to sync content to the cloud and use basic features.");
        case AuthWrapper.Ok: // Should not be visible
            return "";
        }
    }
}
