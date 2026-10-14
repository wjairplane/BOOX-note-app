import QtQuick

import device.ui.controls
import device.ui.text
import device.ui.headers
import com.remarkable
import common

import xofm.libs.controls

import ark.controls as ArkControls

FocusScope {
    id: root

    required property Document document
    property bool invalidPassword: false
    property var acceptAction

    signal closeDialog

    function acceptInput(text) {
        if(!LibraryController.unlockWithPassword(document.id, text)) {
            invalidPassword = true;
        }
    }

    Connections {
        target: document
        function onInvalidPassword() {
            if (visible && passwordInput.text.length >= 0) {
                invalidPassword = true;
            }
        }
        function onLoadingSucceeded() {
            if (acceptAction) {
                acceptAction(passwordInput.text);
            }
            root.closeDialog();
        }
    }

    Background {
        width: root.width
        height: root.height
    }

    Header {
        id: inputHeader
        visible: true
        width: parent.width
        blackOnWhite: false
        acceptEnabled: passwordInput.text.length > 0
        acceptText: qsTr("Open")
        text: qsTr("Password protected PDF")
        onRejected: root.closeDialog()
        onAccepted: root.acceptInput(passwordInput.text)
    }

    Column {
        id: content
        anchors {
            fill: parent
            leftMargin: ArkControls.Values.margin.horizontal.xlarge
            rightMargin: ArkControls.Values.margin.horizontal.xlarge
            topMargin: 250
            bottomMargin: 375
        }
        spacing: 50

        ArkControls.Title {
            type: ArkControls.Title.Large
            anchors {
                left: parent.left
                right: parent.right
            }
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Enter password to open")
        }

        Item { height: 70 ; width: 1 }

        PasswordInputField {
            id: passwordInput
            objectName: "PasswordInput"
            focus: true
            label: qsTr("Incorrect password. Please try again.")
            labelVisible: invalidPassword
            fontSize: Values.fontSizeH1
            titleFontSize: Values.fontSizeH3
            onVisibleChanged: passwordInput.showPassword = false
            onShowWarning: invalidPassword = false
            onCancel: root.closeDialog()
            onAccepted: root.acceptInput(passwordInput.text)
       }
    }
}
