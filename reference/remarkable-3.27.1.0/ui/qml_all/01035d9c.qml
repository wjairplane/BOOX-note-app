import QtQuick
import com.remarkable
import common
import device.ui.controls
import xofm.libs.setup
import xofm.libs.user
import ark.controls as ArkControls

Item {
    id: root

    required property AuthWrapper auth
    readonly property bool inInitialState: state === "pairingShowCode"
    property string initialTitle: qsTr("Pair your device")
    property string errorTitle: qsTr("Unable to complete pairing")
    property string verifyEmailTitle: qsTr("Verify email to pair")
    property string successButtonText: qsTr("Close")
    property string errorMessage
    property bool showSuccessScreen: true
    readonly property string userEmail: UserInfo.email ? qsTr(", %1").arg(UserInfo.email) : ""

    signal close

    function startPairing() {
        errorMessage = "";
        codeDisplay.reset();
        auth.login();
        state = "pairingShowCode";
    }

    function abortLogin() {
        if (state === "pairingShowCode" && !codeDisplay.codeTimedOut && !auth.loggedIn) {
            auth.abortLogin();
        }
    }

    width: parent.width
    height: parent.height

    state: "pairingShowCode"
    states: [
        State {
            name: "pairingShowCode"
            PropertyChanges {
                target: _page
                title: root.initialTitle
                description: qsTr("Visit the link to enter the verification code. Make the paper tablet your own by pairing it to a&#160;reMarkable&#160;account.")
            }
            PropertyChanges {
                target: codeDisplay
                visible: !delayedLogin.running
            }
            PropertyChanges {
                target: _page
                secondaryOption: codeDisplay.userCode.length && !delayedLogin.running
                secondaryButtonText: qsTr("Get new code")
                onSecondaryClicked: {
                    // Abort any uncompleted login.
                    root.abortLogin();

                    // Delay the login call, else oauth is not in the right state to start a new
                    // login. See RMS-920.
                    delayedLogin.start()
                }
            }
        },
        State {
            name: "emailNotVerified"
            PropertyChanges {
                target: _page
                title: root.verifyEmailTitle
                description: qsTr("To use cloud storage and sync, open the link we sent to your email%1." ).arg(root.userEmail)
                secondaryButtonText: qsTr("Verify later")
                onSecondaryClicked: root.close()
            }
            PropertyChanges {
                target: image
                source: "qrc:userfrontend/qml/images/pairing_incomplete_" + (Values.isPortraitOrientation ? "portrait" : "landscape")
            }
        },
        State {
            name: "pairingError"
            PropertyChanges {
                target: _page
                title: root.errorTitle
                description: root.errorMessage || qsTr("Please retry and we'll do our best to solve the problem.")
                primaryButtonText: qsTr("Try again")
                onPrimaryClicked: root.startPairing()
            }
            PropertyChanges {
                target: image
                source: "qrc:setup/qml/images/error_" + (Values.isPortraitOrientation ? "portrait" : "landscape")
            }
        },
        State {
            name: "verbatimError"
            PropertyChanges {
                target: _page
                title: auth.verbatimErrorInfo.title ?? qsTr("Something went wrong")
                description: auth.verbatimErrorInfo.body ?? qsTr("We are unable to pair your device. Please try again.")
                primaryButtonText: qsTr("Next")
                onPrimaryClicked: root.close()
            }
            PropertyChanges {
                target: image
                source: "qrc:setup/qml/images/error_" + (Values.isPortraitOrientation ? "portrait" : "landscape")
            }
        },
        State {
            name: "pairingSuccess"
            PropertyChanges {
                target: _page
                title: UserInfo.isSubscribed ? qsTr("Pairing completed") : qsTr("Activate Connect")

                description: UserInfo.isSubscribed
                             //: Recommended character limit for translation: 100.
                             ? qsTr("You've successfully paired your device. To manage your account, visit my.remarkable.com.")
                             //: Recommended character limit for translation: 160 – upsell the user to the benefits of the subscription. Preserve double line break (`<br><br>`) before prompting the user to claim the free trial.
                             : qsTr("Pairing successful, time to try Connect. Get unlimited cloud storage, handwriting search, exclusive templates, and more.<br><br>Claim your free trial on <b>my.remarkable.com.</b>")
                primaryButtonText: root.successButtonText
                onPrimaryClicked: root.close()
            }
            PropertyChanges {
                target: image
                source: "qrc:userfrontend/qml/images/pairing_complete_" + (Values.isPortraitOrientation ? "portrait" : "landscape")
            }
        }
    ]

    ArkControls.SetupPage {
        id: _page
        anchors.fill: parent
    }

    Image {
        id: image
        anchors.centerIn: parent
    }

    OAuthCodeDisplay {
        id: codeDisplay

        anchors.centerIn: parent
        width: parent.width
        visible: false
    }

    Loading {
        id: loadingIndicator
        anchors.centerIn: parent
        visible: root.state === "pairingShowCode" && !codeDisplay.visible && !delayedLogin.running
    }

    Timer {
        id: delayedLogin
        interval: 1
        onTriggered: startPairing()
    }

    Connections {
        target: auth

        Component.onCompleted: onLoginStateChanged()

        function onLoginStateChanged() {
            switch (auth.loginState) {
            case AuthWrapper.NoUser:
                // Nothing to do. The state is already "pairingShowCode", or the page is waiting
                // for action from the user.
                break;
            case AuthWrapper.LacksEmailVerification:
                root.state = "emailNotVerified";
                break;
            case AuthWrapper.Expired:
                // Want to re-authenticate when expired
                startPairing();
                break;
            case AuthWrapper.Verbatim:
                root.state = "verbatimError"
                break;
            case AuthWrapper.Ok:
                if (root.showSuccessScreen) {
                    root.state = "pairingSuccess";
                } else {
                    root.close();
                }

                break;
            }
        }

        function onAuthorizeGeneralError(message) {
            if (root.state === "pairingShowCode" && !delayedLogin.running) {
                root.errorMessage = message ?? "";
                root.state = "pairingError";
            }
        }

        function onAuthorizeCodeReceived(userCode, verificationURI, expiresIn) {
            if (root.state === "pairingShowCode") {
                codeDisplay.show(userCode, verificationURI, expiresIn);
            }
        }

        function onAuthorizeExpiredUserCode() {
            if (root.state === "pairingShowCode") {
                codeDisplay.authTimeout();
            }
        }

        function onAuthorizeReauthenticateAccountMismatch() {
            if (root.state === "pairingShowCode") {
                root.errorMessage = qsTr("Pair your paper tablet with %1, or unpair to use a different account").arg(UserInfo.email ?? "your original reMarkable account");
                root.state = "pairingError";
            }
        }
    }
}
