import QtQuick
import xofm.libs.qtgui
import xofm.libs.onboarding
import xofm.libs.user
import xofm.modules.userfrontend
import com.remarkable

BaseView {
    id: root

    required property AuthHelper authHelper
    required property AuthTelemetry metrics
    required property LinkProvider linkProvider

    function openPairingFlow() {
        if (root.linkProvider.isOnline) {
            root.windowNavigator.open("userfrontend/window/pairing-setup");
        } else {
            root.windowNavigator.open(
                "wifi/window/network-select",
                { onFinish: (navigator) => navigator.open("userfrontend/window/pairing-setup") }
            );
        }
        root.authHelper.nudgeManualMigration = true;
        root.metrics.pairingInitiatedFrom(AuthTelemetry.MigrationPopup);
        root.windowNavigator.close(root.objectName);
    }

    contentItem: OnboardingDialogue {
        initialModel: [
            {
                "image": "qrc:/onboarding/illustrations/verify_account",
                "title":  qsTr("Verify your account"),
                "body": [
                    { "description": qsTr("We've increased the security for your reMarkable account. To sync your content, and use basic features, pair your paper tablet to the cloud. Make sure you log in with the same email.") },
                ],
            }
        ]
        rightButtonText: qsTr("Pair your device")
        closeOption: true
        onQuitButtonClicked: {
            root.windowNavigator.close();
            root.authHelper.nudgeManualMigration = true;
        }
        onRightButtonClicked: root.openPairingFlow()
    }
}
