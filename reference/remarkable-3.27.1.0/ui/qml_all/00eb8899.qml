import QtQuick
import QtQuick.Layouts
import com.remarkable
import common
import xofm.modules.releasechannel
import xofm.libs.user
import xofm.libs.dialogs

import ark.tokens as ArkTokens
import ark.controls as ArkControls


Background {
    id: root
    required property ReleaseChannelWrapper releaseChannel
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

    DialogScreen {
        anchors.fill: parent
        //: Title shown on the dialog where the user needs to confirm whether or not to unenroll from the beta program.
        text: qsTr("Unenrolling from the reMarkable&#160;beta&#160;program")
        iconSource: "qrc:/ark/icons/warning_circle"
        gobackButton: false
        //: Informative message about what will happen when you unenroll from the beta program. Shown when user is about to unenroll, pending confirmation. Located below the "Unenrolling from the reMarkable beta program" title.
        description: qsTr("When you're not part of the&#160;reMarkable&#160;beta&#160;program, you'll stay on your current version until the next official release is public and available for download.")
        buttons: [
            {
                //: CTA to cancel unenrolling and close dialog
                text: qsTr("Cancel"),
                highlight: false,
                action: function() {
                    root.close();
                }
            },
            {
                //: CTA to confirm unenrolling
                text: qsTr("Unenroll"),
                highlight: true,
                action: function() {
                    if (!LinkProvider.isOnline || !Authentication.loggedIn) {
                        return;
                    }
                    loader.sourceComponent = unenrolling;
                    releaseChannel.enroll(ReleaseChannelWrapper.Channels.Default);
                }
            }
        ]
    }

    ArkControls.NotificationBar {
        id: errorNotification

        visible: errorNotification.state !== "noError"
        type: ArkTokens.NotificationBar.primary
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        state: {
            if (!LinkProvider.isOnline) {
                return "onlineError";
            }
            if (!Authentication.loggedIn) {
                return "authenticationError";
            }

            return "noError";
        }

        states: [
            State {
                name: "onlineError"
                PropertyChanges {
                    target: notificationMessage
                    text: qsTr("Please connect to Wi-Fi to unenroll")
                    iconSource: "qrc:/ark/icons/wifi_x"
                }
                PropertyChanges {
                    target: notificationButton
                    text:  qsTr("Manage network")
                    onClicked: {
                        windowNavigator.open("wifi/window/network-select");
                    }
                }
            },
            State {
                name: "authenticationError"
                PropertyChanges {
                    target: notificationMessage
                    text: qsTr("Unenrolling from the beta program requires a paired device")
                    iconSource: "qrc:/ark/icons/cloud_x"
                }
                PropertyChanges {
                    target: notificationButton
                    text: qsTr("Manage account")
                    onClicked: {
                        windowNavigator.open("userfrontend/window/account-settings");
                    }
                }
            }
        ]

        ArkControls.NotificationBar.Message {
            id: notificationMessage
            type: errorNotification.type
            iconSource: ""
            text: ""
            Layout.fillWidth: true
            Layout.rightMargin: ArkControls.Values.padding.large
            Layout.leftMargin: ArkControls.Values.padding.large
        }

        ArkControls.NotificationBar.Divider {
            type: errorNotification.type
        }

        ArkControls.NotificationBar.Button {
            id: notificationButton
            type: errorNotification.type
        }
    }

    Connections {
        target: releaseChannel
        function onEnrollError() {
            loader.sourceComponent = error
        }
        function onChannelUpdated() {
            loader.sourceComponent = unenrolled;
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
    }

    Component {
        id: unenrolling
        DialogScreen {
            anchors.fill: parent
            text: qsTr("Unenrolling")
            iconSource: "qrc:/ark/icons/cloud_upload"
            gobackButton: false
        }
    }

    Component {
        id: unenrolled
        DialogScreen {
            anchors.fill: parent
            //: Shown when user has unenrolled. Located below the "Unenrolling from the reMarkable beta program" title.
            text: qsTr("Unenrolled from the reMarkable&#160;beta&#160;program")
            iconSource: "qrc:/ark/icons/checkmark"
            onGoBack: root.close()
            description: qsTr("You can reenroll at any time through <b>Settings > General > Software.</b>")
            buttons: [
                {
                    //: CTA to finish the unenrolling flow.
                    text: qsTr("Complete"),
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
