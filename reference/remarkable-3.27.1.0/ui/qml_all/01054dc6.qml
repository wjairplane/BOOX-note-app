import QtQuick
import QtQuick.Layouts

import xofm.libs.controls
import xofm.libs.setup

import xofm.modules.password

import ark.controls as ArkControls

Item {
    id: root

    property Password password
    property bool wrongPuk: false
    property string recoveryCodeAttempt
    property bool resetPassword: false
    property int _state: SetupPasswordInput.States.NewPassword
    property bool _mismatch: false
    property string _newPass

    // test purpose
    property alias page: _page
    property alias textInput: textInput

    enum States { NewPassword, VerifyPassword }

    signal failed()
    signal next(string puk)

    // handle "back" button's behavior
    function handleBack() {
        if (_state === SetupPasswordInput.States.NewPassword) {
            return false; // let Setup.qml deal with "back"
        }
        // pressing "back" resets to States.NewPassword
        _state = SetupPasswordInput.States.NewPassword;
        return true;
    }

    function processResult(result, puk) {
        if (result === true) {
            textInput.label = "";
            root.next(puk);
        }
        else {
            textInput.label = qsTr("Unable to change password");
            root.failed();
        }
    }

    Connections {
        target: root.password
        function onInitializeResult(result, puk) {
            processResult(result, puk);
        }
        function onResetPasswordResult(result, puk) {
            processResult(result, puk);
        }
    }

    ArkControls.SetupPage {
        id: _page
        anchors.fill: parent
        title: {
            if (_state === SetupPasswordInput.States.NewPassword) {
                return root.wrongPuk ? qsTr("Set a new password") : qsTr("Set a password");
            }
            return qsTr("Verify your password");
        }
        description: {
            if (_state === SetupPasswordInput.States.NewPassword) {
                return qsTr("Secure your data with minimum 8 characters, to power on your encrypted device. Include both upper and lower case letters.");
            }
            return "";
        }
    }

    SecuredPasswordInput {
        id: textInput
        objectName: "SecuredPasswordInput"
        anchors {
            top: _page.top
            topMargin: _page.contentPosition.topMargin + ArkControls.Values.spacing.x2large
            left: _page.left
            leftMargin: _page.contentPosition.leftMargin
            right: _page.right
            rightMargin: _page.contentPosition.rightMargin
        }
        // activeFocusOnPress: even if SecuredPasswordInput doesn't have the focus, we want to prevent it from
        // getting the focus when it's pressed, as long as the password is busy
        activeFocusOnPress: !root.password.busy
        focus: !root.password.busy
        mismatch: root._mismatch
        challengeSecurity: _state === SetupPasswordInput.States.NewPassword
        onToggleMismatch: root._mismatch = !root._mismatch
        onAccepted: {
            if (_state === SetupPasswordInput.States.NewPassword) {
                root._newPass = textInput.text;
                _state = SetupPasswordInput.States.VerifyPassword;
                textInput.text = "";
                textInput.label = "";
                return;
            }

            if (_state === SetupPasswordInput.States.VerifyPassword) {
                if (root._newPass === textInput.text) {
                    if (root.resetPassword) {
                        root.password.resetPassword(root.recoveryCodeAttempt, textInput.text);
                    } else {
                        root.password.initialize(textInput.text);
                    }
                    return;
                }
                _state = SetupPasswordInput.States.NewPassword;
                textInput.text = "";
                root._mismatch = true;
                textInput.label = qsTr("Incorrect password. Please try again.");
            }
        }
    }

    Progress {
        id: progress
        busy: root.password.busy
        maxExpectedDuration: 30000
        value: 0
        label: qsTr("Setting password...")
    }
}
