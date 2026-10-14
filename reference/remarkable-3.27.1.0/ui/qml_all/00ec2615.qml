import xofm.modules.userfrontend
import xofm.libs.user
OneTimeCodeSetupPage {
    required property AuthTelemetry metrics
    onVisibleChanged: {
        if (visible) {
            metrics.pairingInitiatedFrom(AuthTelemetry.Setup);
        }
    }
}
