import QtQuick
import QtQuick.Layouts
import com.remarkable
import common
import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.setup

FocusScope {
    id: root

    property int expiresIn
    property bool codeTimedOut
    property string userCode
    property string uri

    readonly property int borderWidth: 2

    function show(usercode, uri, expiresin) {
        root.userCode = usercode;
        timer.minutesPassed = 0;
        timer.restart();
        root.expiresIn = Math.floor(expiresin / 60);
        root.uri = uri;

        const fullURI =`${root.uri}?user_code=${root.userCode}`
        // Remove scheme from the displayed uri.
        const url = new URL(root.uri);
        urlField.text = `${url.hostname}${url.pathname}`;
        userCodeField.text = root.userCode;

        root.codeTimedOut = false;
        root.visible = true;
    }

    function reset() {
        root.visible = false;
        root.userCode = "";
        root.codeTimedOut = false;
        timer.minutesPassed = 0;
    }

    function authTimeout() {
        root.codeTimedOut = true;
    }

    height: content.height

    Timer {
        id: timer
        interval: 60000
        property int minutesPassed: 0
        onTriggered: {
            minutesPassed++;
            if (minutesPassed < root.expiresIn) {
                timer.restart();
            }
        }
    }

    Rectangle {
        id: border
        anchors.fill: content
        border.color: Values.colorBlack
        border.width: root.borderWidth
    }

    ColumnLayout {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: ArkControls.Values.platform.spacing.x2large

        ColumnLayout {
            Layout.topMargin: ArkControls.Values.padding.xlarge
            spacing: ArkControls.Values.spacing.large

            ArkControls.Body {
                id: urlField
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                type: ArkControls.Body.Type.Large
            }

            Rectangle {
                id: seperator
                Layout.fillWidth: true
                border.color: Values.colorBlack
                height: root.borderWidth
            }
        }

        ColumnLayout {
            spacing: ArkControls.Values.spacing.medium
            Layout.leftMargin: ArkControls.Values.padding.xlarge_alt // Figma: padding.x2large, 64px (not implemented yet)
            Layout.rightMargin: ArkControls.Values.padding.xlarge_alt
            Layout.bottomMargin: content.spacing

            ArkControls.Label {
                id: userCodeField
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 80
                font.letterSpacing: 32
                font.weight: Font.Normal
                Layout.rightMargin: -userCodeField.font.letterSpacing

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - userCodeField.font.letterSpacing
                    height: 5
                    color: Values.colorBlack
                    visible: root.codeTimedOut
                }
            }

            ArkControls.Body {
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.codeTimedOut ? qsTr("Your code timed out") : qsTr("The code is valid for %1 minutes").arg(root.expiresIn - timer.minutesPassed)
                type: ArkControls.Body.Type.Large
            }
        }
    }
}
