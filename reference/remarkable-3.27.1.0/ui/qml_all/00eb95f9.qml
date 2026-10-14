import QtQuick
import QtQuick.Layouts
import com.remarkable
import common
import xofm.modules.releasechannel
import xofm.libs.qtgui
import xofm.libs.user
import xofm.libs.dialogs

import ark.tokens as ArkTokens
import ark.controls as ArkControls


Background {
    id: root
    required property ReleaseChannelWrapper releaseChannel
    required property WindowNavigator windowNavigator
    required property AuthWrapper auth

    signal close

    ArkControls.NavigationBar {
        id: navigationBar
        type: ArkTokens.NavigationBar.secondary
        width: parent.width
        anchors.left: parent.left

        ArkControls.NavigationBar.Button {
            text: qsTr("Back")
            textPosition: ArkControls.Button.TextPosition.Right
            iconSource: "qrc:/ark/icons/chevron_left"
            onClicked: root.close()
        }
    }

    readonly property var betaEnrollPoints: [
        qsTr("Beta releases may contain bugs or inaccuracies, as they are being developed. Since it's not commercially released software, data loss may occur."),
        qsTr("Participation is voluntary and free of charge."),
        qsTr("You can unenroll whenever you want."),
    ]

    InformationDialog {
        anchors.fill: parent
        title: qsTr("reMarkable beta program")
        subtitle: qsTr("Access the latest developments by enrolling to the beta program.")
        onGoBack: root.close()
        body: betaEnrollPoints
        optionalFooterComponent: ArkControls.Body {
            type: ArkControls.Body.Type.Medium
            text: qsTr("By enrolling, you agree to the <a href='link'>End user agreement</a>.")
            // Force the link to be the same color as the text
            linkColor: color
            onLinkActivated: windowNavigator.open("releasechannel/window/betalicense")
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
        buttons: [
            {
                text: qsTr("Enroll"),
                highlight: false,
                action: function() {
                    if (!LinkProvider.isOnline || !Authentication.loggedIn) {
                        return;
                    }
                    loader.sourceComponent = enrolling;
                    releaseChannel.enroll(ReleaseChannelWrapper.Channels.Beta);
                }
            }
        ]
    }

    ArkControls.NotificationBar {
        visible: !Authentication.loggedIn || !LinkProvider.isOnline
        type: ArkTokens.NotificationBar.primary
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        ArkControls.NotificationBar.Message {
            type: ArkTokens.NotificationBar.primary
            iconSource: "qrc:/ark/icons/wifi_x"
            text: !Authentication.loggedIn ? qsTr("Pair your device in Account settings to enroll") : qsTr("Connect to Wi-Fi to enroll.")
            Layout.fillWidth: true
            Layout.rightMargin: ArkControls.Values.padding.large
            Layout.leftMargin: ArkControls.Values.padding.large
        }
    }

    Connections {
        target: releaseChannel
        function onEnrollError() {
            loader.sourceComponent = error;

        }
        function onChannelUpdated() {
            loader.sourceComponent = enrolled;
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
    }

    Component {
        id: enrolling
        DialogScreen {
            anchors.fill: parent
            text: qsTr("Enrolling")
            iconSource: "qrc:/ark/icons/cloud_upload"
            gobackButton: false
        }
    }
    Component {
        id: enrolled
        DialogScreen {
            anchors.fill: parent
            text: qsTr("Enrolled in the reMarkable beta&#160;program")
            iconSource: "qrc:/ark/icons/checkmark"
            onGoBack: root.close()
            description: qsTr("If a beta release is available, you will get it shortly. Manage your enrollment in <b>Settings > General > Software</b>")
            buttons: [
                {
                    text: qsTr("Close"),
                    highlight: false,
                    action: function() {
                        root.close();
                    }
                }
            ]
        }
    }

    Component {
        id: error
        DialogScreen {
            anchors.fill: parent
            text: qsTr("Something went wrong")
            description: qsTr("Please try again later. If the problem persists, visit our support pages at support.reMarkable.com.")
            iconSource: "qrc:/ark/icons/cloud_x"
            gobackButton: false
            buttons: [
                 {
                     text: qsTr("Back"),
                     highlight: false,
                     action: function() {
                        root.close();
                     }
                 }
            ]
        }
    }
}
