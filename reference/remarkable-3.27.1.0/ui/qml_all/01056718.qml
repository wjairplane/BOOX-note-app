import QtQuick

import xofm.libs.controls
import xofm.libs.qtgui
import xofm.libs.batterymanager
import xofm.modules.password

import ark.tokens as ArkTokens
import ark.controls as ArkControls

FocusScope {
    id: root

    required property Password password
    required property WindowNavigator windowNavigator
    required property ShutdownCommand shutdownCommand
    property string recoveryCodeAttempt
    property int pukLength

    property int _state: ChallengePassword.States.EnterPassword
    property int _attempsCount: 0
    property string title: qsTr("Enter password")
    property bool _resetPassword: false
    property string _recoverySubDescription: ""
    property bool _wrongPuk: false

    enum States { EnterPassword, NotifyRecovery, EnterRecoveryCode, InitializePassword }

    Connections {
        target: loader.item
        ignoreUnknownSignals: true

        function onFailed() {
            if (root._state === ChallengePassword.States.EnterPassword) {
                if (++root._attempsCount >= 3) { // max number of attempts
                    loader.item.suggestPasswordReset = true;
                }
            } else if(root._state === ChallengePassword.States.InitializePassword) {
                _recoverySubDescription = qsTr("Wrong recovery code entered");
                _wrongPuk = true;
                root._state = ChallengePassword.States.EnterRecoveryCode;
            }
        }

        function onResetPassword() {
            root._state = ChallengePassword.States.NotifyRecovery;
        }

        function onEnterRecovery() {
            root._state = ChallengePassword.States.EnterRecoveryCode;
        }

        function onFactoryReset() {
            shutdownCommand.execute(ShutdownCommand.Reason.FactoryReset, "Factory reset from password recovery");
        }

        function onAttempRecoveryCode(code) {
            recoveryCodeAttempt = code;
        }

        function onSetNewPassword() {
            _resetPassword = true;
            root._state = ChallengePassword.States.InitializePassword;
        }

        function onDone() {
            if (root._state === ChallengePassword.States.InitializePassword) {
                root._attempsCount = 0;
                root._wrongPuk = false;
                root.windowNavigator.open("password/window/update-notification", {notification: qsTr("Your password has been updated")});
                root.windowNavigator.open("password/window/unlock", {title: qsTr("Enter password")});
                return;
            }

            if (root._state === ChallengePassword.States.EnterPassword) {
                root.windowNavigator.close("password/window/unlock");
            }
        }

        function onGoBack() {
            if (root._state === ChallengePassword.States.EnterRecoveryCode)
                root._state = ChallengePassword.States.NotifyRecovery;
        }
    }

    Loader {
        id: loader

        focus: true // allows the loaded item to be given the focus
        anchors.fill: parent
        source: {
            switch (root._state) {
            case ChallengePassword.States.EnterPassword:
                return Qt.resolvedUrl("./EnterPassword.qml");
            case ChallengePassword.States.NotifyRecovery:
                return Qt.resolvedUrl("./NotifyRecovery.qml");
            case ChallengePassword.States.EnterRecoveryCode:
                return Qt.resolvedUrl("./EnterRecoveryCode.qml");
            case ChallengePassword.States.InitializePassword:
                return Qt.resolvedUrl("./SetupInitializePassword.qml");
            default:
                return "";
            }
        }

        Binding {
            target: loader.item
            property: "title"
            when: _state === ChallengePassword.States.EnterPassword
            value: title
        }

        onLoaded: {
            item.focus = true; // the loaded challenge is given the focus
            if (_state === ChallengePassword.States.EnterRecoveryCode) {
                item.pukLength = root.pukLength;
                loader.item.dialogSubDescription = root._recoverySubDescription;
                return;
            }

            if (_state === ChallengePassword.States.EnterPassword ||
                    _state === ChallengePassword.States.InitializePassword) {
                item.password = root.password;

                if (_state === ChallengePassword.States.InitializePassword) {
                    item.resetPassword = root._resetPassword;
                    item.wrongPuk = root._wrongPuk;
                    item.recoveryCodeAttempt = root.recoveryCodeAttempt;
                }
            }
        }
    }
}
