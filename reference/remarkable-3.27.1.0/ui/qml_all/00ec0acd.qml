import QtQuick
import com.remarkable
import xofm.libs.qtgui
import xofm.libs.onboarding
import xofm.libs.user
import xofm.modules.userfrontend

BaseView {
    id: root

    required property AuthHelper authHelper
    required property AuthTelemetry metrics

    function close() {
        root.authHelper.nudgeReauth = true;
        root.windowNavigator.close(root.objectName);
    }

    contentItem: OnboardingDialogue {
        contentItem: OnboardingPage {
            illustrationSource: "qrc:/onboarding/illustrations/verify_account"
            title: qsTr("Verify your account")
            body: [
                { "description": qsTr("As a security measure, we need you to pair your account and paper tablet again. This is required to continue syncing content to the cloud and using basic features on your device and apps.") }
            ]
        }
        rightButtonText: qsTr("Pair your device")
        closeOption: true
        onQuitButtonClicked: root.close()
        onFinished: {
            root.metrics.pairingInitiatedFrom(AuthTelemetry.ExpiredPopup);
            root.windowNavigator.open("userfrontend/window/pairing-reauth");
            root.close();
        }
    }
}
