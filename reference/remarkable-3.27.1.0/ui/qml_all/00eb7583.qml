import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.controls

InputBlocker {
    id: root
    required property var passcodeHandler

    signal resetPasscodeClicked
    signal close

    // only for spacing
    ArkControls.NavigationBar {
        id: navigationBar
        type: ArkTokens.NavigationBar.secondary
        width: parent.width
        anchors.left: parent.left
        anchors.top: parent.top
    }

    ColumnLayout {
        id: layout
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: ArkControls.Values.margin.vertical.x2large
            leftMargin: ArkControls.Values.margin.horizontal.xlarge
            rightMargin: ArkControls.Values.margin.horizontal.xlarge
            bottomMargin: ArkControls.Values.spacing.medium
        }
        spacing: ArkControls.Values.spacing.medium

        ArkControls.Icon {
            size: ArkControls.Values.iconSize.large
            Layout.alignment: Qt.AlignHCenter
            color: "black"
            source:  "qrc:/ark/icons/padlock"
        }

        ArkControls.Title {
            type: ArkControls.Title.Large
            text: qsTr("Too many attempts")
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        ArkControls.Body {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: {
                if (root.passcodeHandler.numberOfUnlockAttempts === 6 || Math.ceil(root.passcodeHandler.lockTime) === 1) {
                    return qsTr("Wait 1 minute to try again, or reset passcode.");
                } else {
                    return qsTr("Wait %1 minutes to try again, or reset passcode.").arg(Math.ceil(root.passcodeHandler.lockTime));
                }
            }
        }

        Item {
            id: spacer
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Rectangle {
        id: progressBar
        height: 10
        width: 300
        color: "transparent"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 100
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "black"
        }
        Rectangle {
            height: parent.height
            width: parent.width * root.passcodeHandler.lockTimePercentage
            color: "black"
        }
    }

    RowLayout {
        id: buttonRow
        visible: !accidentalSlider.visible
        anchors {
            bottom: parent.bottom
            bottomMargin: ArkControls.Values.margin.vertical.large
            horizontalCenter: parent.horizontalCenter
        }
        spacing: ArkControls.Values.spacing.large

        ArkControls.Button {
            id: tryAgainButton
            text: qsTr("Try again")
            type: ArkTokens.Button.secondary
            onClicked: root.close()
            visible: root.passcodeHandler.lockTime === 0
        }

        ArkControls.Button {
            id: resetButton
            text: qsTr("Reset passcode")
            type: ArkTokens.Button.secondary
            onClicked: root.resetPasscodeClicked()
        }
    }

    AccidentalTouchSlider {
        id: accidentalSlider
        visible: !accepted
        anchors.centerIn: buttonRow
    }
}
