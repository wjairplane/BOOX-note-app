import QtQuick
import common
import com.remarkable
import device.ui.controls
import device.view.dialogs
import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.setup
import xofm.libs.user
import xofm.libs.controls
import xofm.modules.userfrontend

SetupBasePage {
    id: root

    required property AuthHelper authHelper
    readonly property string pairingUrl: NetworkClient.loginUrl + "/pair"

    readonly property string state_idle: ""
    readonly property string state_pairingSuccess: "pairingSuccess"
    readonly property string state_pairingError: "pairingError"
    readonly property string state_pairing: "pairing"
    readonly property string state_pairingCodeInput: "pairingCodeInput"
    readonly property string state_skipConfirmation: "skipConfirmation"

    property string initialTitle: qsTr("Pair your device")
    property string skipTitle: qsTr("Pair your device later")
    property string errorTitle: qsTr("Unable to complete pairing")
    property string errorMessage
    property bool showSuccessScreen: true

    stateName: "Pairing"
    pageReady: LinkProvider.isOnline && !authHelper.oAuthEnabled
    includeInProgressCount: !authHelper.oAuthEnabled
    showBackButton: true

    function handleBack() {
        if (state === root.state_pairing) {
            return false;
        }
        if (state !== root.state_pairingCodeInput) {
            root.state = root.state_pairingCodeInput;
            return true;
        }
        return false;
    }

    function handleSkip() {
        if (state === root.state_skipConfirmation) {
            root.forward();
        } else {
            state = root.state_skipConfirmation;
        }
        return true;
    }

    //We should probably use server error messages insted of generic one fits all in the future
    function getErrorMessage() {
        if (Authentication.loginResult === Authentication.LoginResult.DeviceAlreadyConnected) {
            return qsTr("Another reMarkable already connected. Go to %1 to connect your new device.").arg(NetworkClient.loginUrl);
        } else if (Authentication.loginResult === Authentication.LoginResult.InvalidOneTimeCode) {
            return qsTr("Please try a different code to log in with.");
        }  else if (Authentication.loginResult === Authentication.LoginResult.SslCertificateTimeError) {
            return qsTr("There might be an issue with the date/time information on your device. Please check System time and try logging in again. If you still experience problems, contact support@remarkable.com.");
        }  else if (Authentication.loginResult === Authentication.LoginResult.SslHandshakeError) {
            return qsTr("The connection to our servers is not secure. Please try again, or connect to a different Wi-Fi.");
        } else if (Authentication.loginResult === Authentication.LoginResult.NetworkError) {
            return qsTr("There's an issue with the server connection. Please try again, or connect to a different Wi-Fi.");
        } else {
            return qsTr(Authentication.loginErrorMessage);
        }
    }

    state: visible ? root.state_pairingCodeInput : root.state_idle
    onVisibleChanged: {
        // Reset the UI when returning to this page, if not already pairing/paired.
        if (visible && state !== root.state_pairing && !Authentication.loggedIn) {
            state = root.state_pairingCodeInput;
        }
    }

    states: [
        State {
            name: root.state_pairingCodeInput
            PropertyChanges {
                target: _page
                title: root.initialTitle
                //: Description below "Pair your device" title. The %1 placeholder is a URL.
                description: qsTr("Get a verification code at <b>%1</b><br>and enter it below.").arg(root.pairingUrl)
            }
            PropertyChanges {
                target: oneTimeCodeDisplay
                visible: true
                focus: true
            }
            PropertyChanges {
                target: root
                showSkipButton: true
            }
        },
        State {
            name: root.state_pairing
            PropertyChanges {
                target: _page
                title: qsTr("Pairing")
                ellipse: true
            }
            PropertyChanges {
                target: root

                // This shouldn't happen, but in case the pairing never gets to a success or
                // failure state, ensure the user can step back or skip.
                showBackButton: !pairingTimeout.running
                showSkipButton: !pairingTimeout.running
            }
            StateChangeScript {
                script: pairingTimeout.restart();
            }
        },
        State {
            name: root.state_pairingError
            PropertyChanges {
                target: _page
                title: root.errorTitle
                description: root.errorMessage || root.getErrorMessage() || qsTr("Please retry and we'll do our best to solve the problem.")
                primaryButtonText: qsTr("Try again")
                onPrimaryClicked: root.state = root.state_pairingCodeInput
            }
            PropertyChanges {
                target: image
                source: Values.isPortraitOrientation ? "qrc:setup/qml/images/error_portrait.png" : "qrc:setup/qml/images/error_landscape.png"
            }
            PropertyChanges {
                target: root
                showSkipButton: true
            }
        },
        State {
            name: root.state_pairingSuccess
            PropertyChanges {
                target: _page
                title: UserInfo.isSubscribed ? qsTr("Pairing completed") : qsTr("Activate Connect")

                description: UserInfo.isSubscribed
                             //: Recommended character limit for translation: 100.
                             ? qsTr("You've successfully paired your device. To manage your account, visit my.remarkable.com.")
                             //: Recommended character limit for translation: 160 – upsell the user to the benefits of the subscription. Preserve double line break (`<br><br>`) before prompting the user to claim the free trial.
                             : qsTr("Pairing successful, time to try Connect. Get unlimited cloud storage, handwriting search, exclusive templates, and more.<br><br>Claim your free trial on <b>my.remarkable.com.</b>")
                primaryButtonText: qsTr("Next")
                onPrimaryClicked: root.forward()
            }
            PropertyChanges {
                target: image
                source: Values.isPortraitOrientation ? "qrc:userfrontend/qml/images/pairing_complete_portrait" : "qrc:userfrontend/qml/images/pairing_complete_landscape"
            }
        },
        State {
            name: root.state_skipConfirmation
            PropertyChanges {
                target: root
                showSkipButton: true
            }
            PropertyChanges {
                target: skipPageLoader
                active: true
            }
        }
    ]

    Timer {
        id: pairingTimeout
        interval: 30000
    }

    ArkControls.SetupPage {
        id: _page
        anchors.fill: parent
    }

    OneTimeCodeDisplay {
        id: oneTimeCodeDisplay
        anchors {
            top: parent.top
            topMargin: ArkControls.Values.margin.vertical.x3large + ArkControls.Values.spacing.x2large
            horizontalCenter: parent.horizontalCenter
        }
        width: 716 // provided by Design System
        visible: false
        onCodeReceived: (code) => {
            root.state = root.state_pairing;
            Authentication.legacyLogin(code);
        }
    }

    Image {
        id: image
        anchors.centerIn: parent
    }

    Connections {
        target: Authentication
        function onLoggedInChanged() {
            if (!Authentication.loggedIn) {
                if (root.state === root.state_pairing) {
                    root.state = root.state_pairingError;
                }
            } else {
                if (root.showSuccessScreen) {
                    root.state = root.state_pairingSuccess;
                } else {
                    root.forward();
                }
            }
        }
        function loginErrorMessageChanged(message) {
            if (root.state === root.state_pairing) {
                root.errorMessage = message;
                root.state = root.state_pairingError;
                Authentication.abortLogin();
            }
        }
    }

    Loader {
        id: skipPageLoader
        anchors.fill: parent
        active: false
        sourceComponent: Component {
            PairingSkipPage {
                skipTitle: root.skipTitle
                onSkipCanceled: {
                    root.state = root.state_pairingCodeInput;
                }
            }
        }
    }
}
