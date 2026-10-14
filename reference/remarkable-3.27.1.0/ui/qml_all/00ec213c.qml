import xofm.modules.userfrontend

OAuthSetupPage {
    required property AuthTelemetry metrics
    onVisibleChanged: {
        if (visible) {
            metrics.pairingInitiatedFrom(AuthTelemetry.Setup);
        }
    }
}
