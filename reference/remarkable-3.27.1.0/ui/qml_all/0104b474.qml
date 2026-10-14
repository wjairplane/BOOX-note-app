import QtQuick
import com.remarkable
import common
import device.ui.controls
import device.ui.text
import xofm.libs.dialogs
import xofm.libs.qtgui

FocusScope {
    id: root

    required property var passcodeResetHandler
    required property WindowNavigator windowNavigator
    required property var wifiWidget

    property QtObject linkProvider: LinkProvider
    property bool loggedIn: Authentication.loggedIn
    property int textWidth: width - 2 * Values.minimumButtonWidth

    signal passcodeReset
    Component.onCompleted: root.getNextScreen();

    function getNextScreen() {
        if (!root.loggedIn) {
            subpageLoader.sourceComponent = noCloudPage;
        } else if (root.linkProvider.isOnline) {
            subpageLoader.sourceComponent = confirmResetScreen;
            root.passcodeResetHandler.resetPasscode();
        } else {
            subpageLoader.sourceComponent = connectToWifiPage;
        }
        subpageLoader.active = true;
    }

    function reset() {
        subpageLoader.active = false;
    }

    Connections {
        target: root.passcodeResetHandler
        function onResetApproved() {
            root.passcodeReset();
            subpageLoader.active = false;
        }
        function onResetDenied() {
            subpageLoader.sourceComponent = resetDeniedScreen;
        }
        function onResetError() {
            subpageLoader.sourceComponent = resetErrorScreen;
        }
    }

    Loader {
        id: subpageLoader
        objectName: "subpageLoader"
        anchors.fill: parent
        active: false
    }

    Component {
        id: noCloudPage
        DialogScreen {
            text: qsTr("No cloud connection")
            iconSource: "qrc:/ark/icons/cloud_x"
            gobackButton: false
            description: qsTr("Unable to back up content before resetting. Your device is not paired with the cloud.");
            subDescription: qsTr("You can try the passcode again or reset your device.")
            buttons: [
                {
                    text: qsTr("Try again"),
                    highlight: false,
                    action: function() {
                        root.reset();
                    }
                },
                {
                    text: qsTr("Reset device"),
                    highlight: true,
                    action: function() {
                        subpageLoader.sourceComponent = confirmResetPage;
                    }
                }
            ]
        }
    }

    Component {
        id: resetErrorScreen
        DialogScreen {
            text: qsTr("Reset stopped")
            gobackButton: false
            description: qsTr("Something went wrong, please try again later. If the problem persists, visit our support page at support.remarkable.com.")
            iconSource: "qrc:/ark/icons/information_circle"
            buttons: [
                {
                    text: qsTr("Back"),
                    highlight: false,
                    action: function() {
                        root.reset();
                    }
                }
            ]
        }
    }

    Component {
        id: confirmResetPage
        DialogScreen {
            text: qsTr("Confirm reset")
            gobackButton: false
            iconSource: "qrc:/ark/icons/restore"
            description: qsTr("This action will delete all files on the device and restore your device settings to their original state.");
            buttons: [
                {
                    text: qsTr("Cancel"),
                    highlight: false,
                    action: function() {
                        root.reset();
                    }
                },
                {
                    text: qsTr("Confirm reset"),
                    highlight: true,
                    action: function() {
                        factoryResetTimer.start();
                    }
                }
            ]
        }
    }

    Timer {
        id: factoryResetTimer
        interval: 1000
        onTriggered: DeviceApp.factoryReset()
    }

    Connections {
        target: root.linkProvider
        function onIsOnlineChanged(isOnline) {
            if (root.linkProvider.isOnline && subpageLoader.sourceComponent == connectToWifiPage) {
                getNextScreen();
            }
        }
    }

    Component {
        id: resetDeniedScreen
        DialogScreen {
            gobackButton: false
            text: qsTr("Reset canceled")
            description: qsTr("The request to reset the passcode was canceled via %1.").arg(NetworkClient.loginUrl)
            subDescription: qsTr("If it was unintended, please go back and try again.")
            iconSource: "qrc:/ark/icons/information_circle"
            buttons: [
                {
                    text: qsTr("Back"),
                    highlight: false,
                    action: function() {
                        root.reset();
                    }
                }
            ]
        }
    }

    Component {
        id: confirmResetScreen
        DialogScreen {
            readonly property string accountString: UserInfo.accountType !== UserInfo.Undefined ? qsTr("%1 via %2").arg(UserInfo.email).arg(UserInfo.getAccountTypeString()) : qsTr(UserInfo.email)
            iconSource: "qrc:/ark/icons/padlock"
            text: qsTr("Confirm reset on %1").arg(NetworkClient.loginUrl)
            description: qsTr("Log in to %1 and confirm that you want to reset your passcode.").arg(NetworkClient.loginUrl)
            //: Email address
            subDescription: qsTr("You are currently logged in as: <b>%1</b>").arg(accountString)
            footerText: qsTr("Waiting for confirmation")
            onGoBack: {
                root.reset();
                root.passcodeResetHandler.abort();
            }
        }
    }

    Component {
        id: connectToWifiPage
        Item {
            id: wifiPage
            objectName: "connectToWifiPage"

            WidgetLoader {
                id: wifiLoader
                anchors.fill: parent
                widget: root.wifiWidget.count > 0 ? root.wifiWidget.get(0).widget : null
            }

            Binding {
                target: wifiLoader.item
                property: "titleText"
                value: qsTr("Connect to Wi-Fi")
                when: wifiLoader.status === Loader.Ready
            }

            IconButton {
                id: leftButton
                anchors.left: parent.left
                anchors.top: parent.top
                title: qsTr("Cancel")
                iconSource: "qrc:/ark/icons/angle_left"
                onClicked: root.reset();
            }
        }
    }
}
