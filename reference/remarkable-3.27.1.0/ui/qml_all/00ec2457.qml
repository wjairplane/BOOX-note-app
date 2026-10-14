import QtQuick
import xofm.libs.qtgui
import xofm.libs.setup
import xofm.libs.user
import xofm.modules.userfrontend

BaseView {
    id: root

    required property AuthWrapper auth
    required property AuthHelper authHelper

    contentItem: Setup {
        initialPages: [ authHelper.oAuthEnabled ? oauthPairingComponent.createObject(root) : otcPairingComponent.createObject(root) ]
        showBackButton: true
        showSkipButton: false

        onSetupFinished: {
            root.windowNavigator.close(root.objectName);
        }
    }

    Component {
        id: oauthPairingComponent
        OAuthSetupPage {
            auth: root.auth
            authHelper: root.authHelper

            // Since this page is being shown outside of the full setup flow, force it to be visible.
            pageReady: true
        }
    }

    Component {
        id: otcPairingComponent
        OneTimeCodeSetupPage {
            // Since this page is being shown outside of the full setup flow, force it to be visible.
            pageReady: true
            showSuccessScreen: false
            authHelper: root.authHelper
        }
    }
}
