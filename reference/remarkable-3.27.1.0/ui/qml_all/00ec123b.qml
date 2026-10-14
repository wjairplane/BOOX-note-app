import QtQuick
import com.remarkable
import ark.controls as ArkControls

import xofm.libs.setup
import xofm.libs.user

SetupBasePage {
    id: root

    required property AuthWrapper auth
    required property AuthHelper authHelper
    property alias initialTitle: oAuthAccount.initialTitle
    property string skipTitle: qsTr("Pair your device later")
    property alias errorTitle: oAuthAccount.errorTitle
    property alias verifyEmailTitle: oAuthAccount.verifyEmailTitle
    property bool showSuccessScreen: true

    stateName: "OAuthPairing"
    pageReady: LinkProvider.isOnline && authHelper.oAuthEnabled
    includeInProgressCount: authHelper.oAuthEnabled
    showBackButton: true
    showSkipButton: !auth || !auth.loggedIn

    function handleBack() {
        if (skipPageLoader.active) {
            skipPageLoader.active = false;
            return true;
        }
        if (!oAuthAccount.inInitialState && auth.loginState === AuthWrapper.NoUser) {
            oAuthAccount.startPairing();
            return true;
        }
        return false;
    }

    function handleSkip() {
        if (skipPageLoader.active) {
            forward();
        } else {
            skipPageLoader.active = true;
        }
        return true;
    }

    onVisibleChanged: {
        if (visible) {
            // Only fetch the OAuth code if the user is not already fully or partially paired.
            if (auth.loginState === AuthWrapper.NoUser) {
                oAuthAccount.startPairing();
            }
        } else {
            // Abort any uncompleted login.
            if (auth.loginState === AuthWrapper.NoUser || auth.loginState === AuthWrapper.Expired) {
                oAuthAccount.abortLogin();
            }
        }
    }

    OAuthAccount {
        id: oAuthAccount
        auth: root.auth
        visible: !skipPageLoader.active
        successButtonText: qsTr("Next")
        showSuccessScreen: root.showSuccessScreen
        onClose: root.forward();
    }

    Loader {
        id: skipPageLoader
        anchors.fill: parent
        active: false
        sourceComponent: Component {
            PairingSkipPage {
                skipTitle: root.skipTitle
                onSkipCanceled: {
                    skipPageLoader.active = false;
                }
            }
        }
    }
}
