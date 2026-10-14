import QtQuick
import QtQuick.Layouts
import com.remarkable
import common
import device.ui.controls
import device.ui.text
import device.view.dialogs
import ark.tokens as ArkTokens
import ark.controls as ArkControls
import xofm.libs.user
import xofm.libs.qtgui
import xofm.libs.dialogs
import xofm.libs.factoryreset
import xofm.libs.settings
import xofm.modules.userfrontend

Background {
    id: root

    required property WindowNavigator windowNavigator
    required property AuthWrapper auth
    required property AuthHelper authHelper
    required property var logoutPolicy
    required property AuthTelemetry metrics

    signal wifiClicked
    signal close

    function goBack() {
        root.close();
    }

    function goToPairingScreen() {
        root.metrics.pairingInitiatedFrom(AuthTelemetry.Settings);
        root.windowNavigator.open("userfrontend/window/pairing-setup");
    }
    function goToLogoutScreen() {
        root.windowNavigator.open("userfrontend/window/unpairing-dialog");
    }
    function goToReauthScreen() {
        root.windowNavigator.open("userfrontend/window/pairing-reauth");
    }

    Component.onCompleted: {
        if (visible && authHelper.oAuthEnabled) {
            // Need to manually start updating process to check if
            // half paired state is changed.
            auth.updateLoginStatus();
        }
    }

    ArkControls.NavigationBar {
        id: navigationBar
        type: ArkTokens.NavigationBar.secondary
        width: parent.width

        ArkControls.NavigationBar.Button {
            id: back
            //: Force disconnect was successful (button)
            text: qsTr("Back")
            textPosition: ArkControls.Button.TextPosition.Right
            iconSource: "qrc:/ark/icons/chevron_left"
            onClicked: root.close()
        }
    }

    ArkControls.Title {
        id: header
        type: ArkControls.Title.Large
        anchors.top: navigationBar.bottom
        anchors.left: parent.left
        anchors.leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
        //: Title of Account settings page
        text: qsTr("Account")
    }

    ColumnLayout {
        anchors.top: header.bottom
        anchors.topMargin: ArkControls.Values.platform.spacing.x2large
        anchors.left: parent.left
        anchors.leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
        anchors.right: parent.right
        anchors.rightMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
        spacing: ArkControls.Values.platform.spacing.x2large

        Profile {
            id: accountPanelButton

            auth: root.auth
            authHelper: root.authHelper
            canLogout: !root.logoutPolicy.value
            windowNavigator: root.windowNavigator
            Layout.fillWidth: true
            onOpenPairingSetupDialog: {
                root.goToPairingScreen();
            }
            onWifiClicked: root.wifiClicked()
            onOpenLogoutDeviceDialog: {
                if (auth.loginState === AuthWrapper.Expired) {
                    root.goToReauthScreen();
                } else {
                    LogoutHandler.checkReadyForLogout();
                    root.goToLogoutScreen();
                }
            }
        }

        ArkControls.InfoMessage {
            id: subscriptionPanel
            type: ArkTokens.InfoMessage.secondary
            Layout.fillWidth: true
            title: qsTr("%1 subscription", "Subscription info message").arg(UserInfo.subscriptionLevel);
            message:  qsTr("You have unlimited cloud storage, sync, and access to all note-taking features in the mobile and desktop apps.", "Cloud storage information message (connect)");
            iconSource: "qrc:/ark/icons/checkmark_circle"
            visible: Authentication.loggedIn && UserInfo.isSubscribed && !root.logoutPolicy.value
        }

        ArkControls.InfoMessage {
            id: mdmPanel
            type: ArkTokens.InfoMessage.secondary
            Layout.fillWidth: true
            title: qsTr("Enterprise", "Enterprise enrollment message");
            message: qsTr("Your workplace has set certain policies to strengthen the security on the device.", "Enterprise enrollment information message");
            iconSource: "qrc:/ark/icons/checkmark_circle"
            visible: Authentication.loggedIn && UserInfo.isSubscribed && root.logoutPolicy.value
            description: qsTr("Your Connect subscription is administered by your employer.")
        }

        ArkControls.InfoMessage {
            type: ArkTokens.InfoMessage.primary
            Layout.fillWidth: true
            title: qsTr("Not subscribed");
            message: qsTr("Subscribe to Connect, with unlimited cloud storage and sync, and access to all note-taking features in the mobile and desktop apps.", "Cloud storage information message (no connect)");
            description: qsTr("Log in to manage your subscription at %1.", "Subscription settings info message").arg(NetworkClient.loginUrl)
            iconSource: "qrc:/ark/icons/information_circle"
            visible: Authentication.loggedIn && !UserInfo.isSubscribed && !errorPanel.visible
        }

         ArkControls.InfoMessage {
            id: errorPanelOldAuth
            visible: !errorPanel.visible && !Authentication.loggedIn
            type: ArkTokens.InfoMessage.primary
            Layout.fillWidth: true
            title: qsTr("Pair your device")
            message: qsTr("Your paper tablet is not connected to the cloud, which is required to use basic features.")
            iconSource: "qrc:/ark/icons/information_circle"
       }

        ArkControls.InfoMessage {
            id: errorPanel
            type: ArkTokens.InfoMessage.primary
            Layout.fillWidth: true

            readonly property string userEmail: UserInfo.email ? qsTr(", %1,").arg(UserInfo.email) : ""

            states: [
                State {
                    name: "migration"
                    when: auth.loginState === AuthWrapper.NoUser && authHelper.nudgeManualMigration
                    PropertyChanges {
                        target: errorPanel
                        title: qsTr("Verify by pairing")
                        message: qsTr("Pair your account%1 to the paper tablet, again. This safety verification is required to sync content to the reMarkable cloud and use basic features.").arg(errorPanel.userEmail)
                    }
                },
                State {
                    name: "notPaired"
                    when: auth.loginState === AuthWrapper.NoUser
                    PropertyChanges {
                        target: errorPanel
                        title: qsTr("Pair your device")
                        message: qsTr("Your paper tablet is not connected to the cloud, which is required to use basic features.")
                    }
                },
                State {
                    name: "lacksEmailVerification"
                    when: auth.loginState === AuthWrapper.LacksEmailVerification
                    PropertyChanges {
                        target: errorPanel
                        title: qsTr("Verify your account by email")
                        message: qsTr("Your account%1 was created, but not verified. Find a verification link in an email we sent you, to sync content to the reMarkable cloud and use basic features.").arg(errorPanel.userEmail)
                        description: qsTr("Log in to %1 to request a new email from us.").arg(NetworkClient.loginUrl)
                    }
                },
                State {
                    name: "verbatim"
                    when: auth.loginState === AuthWrapper.Verbatim
                    PropertyChanges {
                        target: errorPanel
                        title: auth.verbatimErrorInfo.title ?? qsTr("Verify your device")
                        message: auth.verbatimErrorInfo.body ?? qsTr("Your paper tablet is not connected to the cloud, which is required to use basic features.")
                        description: ""
                    }
                },
                State {
                    name: "expired"
                    when: auth.loginState === AuthWrapper.Expired
                    PropertyChanges {
                        target: errorPanel
                        title: qsTr("Verify by pairing")
                        message: qsTr("Pair your account%1 to the paper tablet, again. This safety verification is required to sync content to the reMarkable cloud and use basic features.").arg(errorPanel.userEmail)
                    }
                }
            ]
            iconSource: "qrc:/ark/icons/information_circle"
            visible: authHelper.oAuthEnabled && auth.loginState !== AuthWrapper.Ok
        }

        ArkControls.Panel {
            id: factoryResetButton
            Layout.fillWidth: true
            //: Title of Factory reset on the Account page (under General)
            label: qsTr("Factory reset")
            description: qsTr("This will delete all files stored on your paper tablet and restore it to its original settings.", "Factory reset message")
            iconSource: "qrc:/ark/icons/restore"
            visible: !RetailDemo.enabled

            action: ArkControls.Button {
                type: ArkTokens.Button.secondary
                text: qsTr("Reset")
                onClicked: {
                    root.windowNavigator.open("settings/window/factory-reset");
                }
            }
        }
    }
}
