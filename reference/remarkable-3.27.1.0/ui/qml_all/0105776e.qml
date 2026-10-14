import QtQuick

import common

import xofm.libs.qtgui
import xofm.libs.controls

import xofm.modules.password

import ark.tokens as ArkTokens
import ark.controls as ArkControls

BaseView {
    id: root

    required property Password password
    property int _state: ChangePasswordWindow.States.OldPassword
    property bool _mismatch: false
    property string _oldPassword
    property string _newPassword

    signal success()

    enum States { OldPassword, NewPassword, VerifyPassword }

    Connections {
        target: root.password
        function onLoginResult(result) {
            if (result === true) {
                passwordTextInput.label = "";
                _state = ChangePasswordWindow.States.NewPassword;
                passwordTextInput.text = "";
                progress.value = 0;
            }
            else {
                _oldPassword = "";
                passwordTextInput.label = qsTr("Incorrect password. Please try again.");
                passwordTextInput.text = "";
            }
        }

        function onChangePasswordResult(result) {
            if (result === true) {
                root.windowNavigator.close("password/window/change-password");
            }
            else {
                // the password could not be changed, go back to the first step
                _state = ChangePasswordWindow.States.OldPassword;
                _oldPassword = "";
                passwordTextInput.label = qsTr("Unable to change password. Try again.");
                passwordTextInput.text = "";
            }
        }

        function onBusyChanged() {
            // note: we can't use a binding between passwordTextInput.label and root.password.busy
            // because the label can be changed from within PasswordInputField
            if (root.password.busy) {
                if (root._state === ChangePasswordWindow.States.OldPassword)
                    passwordTextInput.label = qsTr("Checking password");
                else
                    passwordTextInput.label = "";
            }
        }
    }

    contentItem: Background {
        ArkControls.NavigationBar {
            id: navigationBar
            type: ArkTokens.NavigationBar.secondary
            width: parent.width
            visible: !root.password.busy

            ArkControls.NavigationBar.Button {
                text: qsTr("Back")
                textPosition: ArkControls.Button.TextPosition.Right
                iconSource: "qrc:/ark/icons/chevron_left"
                onClicked: {
                    if (_state !== ChangePasswordWindow.States.OldPassword) {
                        passwordTextInput.text = "";
                        passwordTextInput.label = "";
                        _state = ChangePasswordWindow.States.OldPassword;
                        return;
                    }
                    root.windowNavigator.close("password/window/change-password");
                }
            }
        }

        ArkControls.Title {
            id: titleItem
            type: ArkControls.Title.X2Large
            text: {
                switch (_state) {
                case ChangePasswordWindow.States.OldPassword:
                    return qsTr("Enter password");
                case ChangePasswordWindow.States.NewPassword:
                    return qsTr("Enter your new password");
                case ChangePasswordWindow.States.VerifyPassword:
                    return qsTr("Verify your new password");
                }
            }
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: 351
            }
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }

        SecuredPasswordInput {
            id: passwordTextInput
            anchors {
                top: titleItem.bottom
                topMargin: ArkControls.Values.spacing.x2large
                left: parent.left
                leftMargin: 120
                right: parent.right
                rightMargin: 120
            }
            focus: !root.password.busy
            mismatch: root._mismatch
            challengeSecurity: _state === ChangePasswordWindow.States.NewPassword
            onToggleMismatch: root._mismatch = !root._mismatch
            validator: RegularExpressionValidator {
                regularExpression: _state === ChangePasswordWindow.States.OldPassword ? /^.{1,}+$/ : /^.{8,}+$/
            }
            onAccepted: {
                progress.value = 0;
                if (_state === ChangePasswordWindow.States.OldPassword) {
                    _oldPassword = passwordTextInput.text;
                    root.password.attemptLogin(passwordTextInput.text);
                    return;
                }

                if (_state === ChangePasswordWindow.States.NewPassword) {
                    _newPassword = passwordTextInput.text;
                    _state = ChangePasswordWindow.States.VerifyPassword;
                    passwordTextInput.text = "";
                    return;
                }

                if (_state === ChangePasswordWindow.States.VerifyPassword) {
                    if (_newPassword === passwordTextInput.text) {
                        root.password.changePassword(_oldPassword, _newPassword);
                        root.success();
                    }
                    else {
                        _state = ChangePasswordWindow.States.NewPassword;
                        passwordTextInput.text = "";
                        root._mismatch = true;
                        passwordTextInput.label = qsTr("Incorrect password. Please try again.");
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.password.busy
                propagateComposedEvents: false // Prevent propagation of events to other areas
            }
        }

        Progress {
            id: progress
            busy: root._state !== ChangePasswordWindow.States.OldPassword && root.password.busy
            maxExpectedDuration: 30000
            value: 0
            label: qsTr("Setting...")
        }
    }
}
