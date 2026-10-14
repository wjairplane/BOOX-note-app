import QtQuick
import xofm.libs.qtgui
import xofm.libs.onboarding
import xofm.libs.user
import device.view.experimental
import com.remarkable
import xofm.modules.userfrontend

BaseView {
    id: root

    required property AuthWrapper auth
    required property AuthHelper authHelper
    required property AuthTelemetry metrics
    required property LinkProvider linkProvider

    function openPairingFlow() {
        if (root.linkProvider.isOnline) {
            root.windowNavigator.open("userfrontend/window/pairing-setup");
        } else {
            root.windowNavigator.open(
                "wifi/window/network-select",
                { onFinish: ( navigator ) => navigator.open("userfrontend/window/pairing-setup") }
            );
        }
        root.metrics.pairingInitiatedFrom(AuthTelemetry.CloudFeaturePopup);
        root.windowNavigator.close(root.objectName);
    }

    onOpened: {
        if (auth.loginState === AuthWrapper.Ok) {
            console.warn("This window should not been opened with this login state.")
            root.windowNavigator.close(root.objectName);
        }
    }

    contentItem: OnboardingDialogue {
        id: dialog
        readonly property bool showButton: (auth.loginState !== AuthWrapper.Verbatim) && (auth.loginState !== AuthWrapper.LacksEmailVerification)
        readonly property string title: {
            if (auth.loginState === AuthWrapper.NoUser) {
                return qsTr("Pairing required");
            }
            switch (auth.loginState) {
            case AuthWrapper.LacksEmailVerification:
                return qsTr("Verify your account by email");
            case AuthWrapper.Verbatim:
                return auth.verbatimErrorInfo.title ?? qsTr("Verify your account");
            case AuthWrapper.Expired:
                return qsTr("Verify by pairing");
            default:
                return "";
            }
        }
        readonly property string description: {
            if (auth.loginState === AuthWrapper.NoUser) {
                return qsTr("To send content by email, use Screen Share, and convert notes to text, your paper tablet must be paired with a reMarkable account.");
            }
            switch (auth.loginState) {
            case AuthWrapper.LacksEmailVerification:
                return qsTr("Your account, %1, was created, but not verified. Find a verification link in an email we sent you, to sync content to the reMarkable cloud and use basic features.\n\nOnce resolved, the paper tablet may take up to 15 seconds to detect the change.").arg(UserInfo.email);
            case AuthWrapper.Verbatim:
                return qsTr("%1\n\nOnce resolved, the paper tablet may take up to 15 seconds to detect the change.").arg(auth.verbatimErrorInfo.body)
            case AuthWrapper.Expired:
                return  qsTr("Pair your account %1 to the paper tablet, again. This safety verification is required to sync content to the reMarkable cloud and use basic features.").arg(UserInfo.email);
            default:
                return "";
            }
        }
        readonly property string illustration: {
            switch (auth.loginState) {
            case AuthWrapper.LacksEmailVerification:
                return "qrc:/onboarding/illustrations/verify_by_email"
            case AuthWrapper.Verbatim:
                return "qrc:/onboarding/illustrations/pairing_required";
            case AuthWrapper.Expired:
                return "qrc:/onboarding/illustrations/verify_account";
            default:
                return "qrc:/onboarding/illustrations/verify_account";
            }
        }

        initialModel: [
            {
                "image": dialog.illustration,
                "title":  dialog.title,
                "body": [
                    { "description": dialog.description },
                ],
            }
        ]
        rightButtonText: dialog.showButton ? qsTr("Pair your device") : ""
        closeOption: true
        onQuitButtonClicked: root.windowNavigator.close(root.objectName)
        onRightButtonClicked: root.openPairingFlow()
    }
}
