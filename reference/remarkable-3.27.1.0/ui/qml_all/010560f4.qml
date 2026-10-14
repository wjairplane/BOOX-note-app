import QtQuick

import xofm.libs.controls
import xofm.modules.password

import ark.tokens as ArkTokens
import ark.controls as ArkControls

FocusScope {
    id: root

    property Password password
    property alias inputText: passwordTextInput.text
    property alias inputLabel: passwordTextInput.label
    property alias textInput: passwordTextInput
    property bool suggestPasswordReset: false
    property alias title: titleItem.text

    signal failed()
    signal resetPassword()
    signal done()

    Connections {
        target: root.password
        function onLoginResult(result) {
            if (result === true) {
                passwordTextInput.label = "";
                root.done();
            }
            else {
                passwordTextInput.label = qsTr("Incorrect password. Please try again.");
                progress.value = 0;
                passwordTextInput.text = "";
                root.failed();
            }
        }
        function onBusyChanged() {
            // note: we can't use a binding between passwordTextInput.label and root.password.busy
            // because the label can be changed from within PasswordInputField
            if (root.password.busy) {
                passwordTextInput.label = qsTr("Checking password");
            }
        }
    }

    ArkControls.Title {
        id: titleItem
        type: ArkControls.Title.X2Large
        text: qsTr("Enter password")
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: 351
        }
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
    }

    PasswordInputField {
        id: passwordTextInput
        anchors {
            top: titleItem.bottom
            topMargin: ArkControls.Values.spacing.x2large
            left: parent.left
            leftMargin: 120
            right: parent.right
            rightMargin: 120
        }
        titleText: qsTr("Password")
        labelVisible: label.length > 0
        focus: !root.password.busy
        onShowWarning: {
            if (text.length > 0) {
                passwordTextInput.label = "";
            }
        }
        onAccepted: password.attemptLogin(passwordTextInput.text);
    }

    Item {
        anchors {
            left: parent.left
            right: parent.right
            top: passwordTextInput.bottom
            bottom: parent.bottom
            bottomMargin: 540 + 40 // cf. virtual-keyboard.qml
        }

        ArkControls.Button {
            type: ArkTokens.Button.secondary
            text: qsTr("Reset password")
            width: 340
            anchors.centerIn: parent
            visible: suggestPasswordReset
            onClicked: root.resetPassword()
        }
    }
}
