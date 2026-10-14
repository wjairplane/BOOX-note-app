import QtQuick

import common
import com.remarkable

import xofm.libs.dialogs
import xofm.libs.pincode
import xofm.libs.retail
import xofm.libs.logout
import xofm.modules.security.pincode // PasscodeHandler

FocusScope {
    id: resetDialog

    signal close

    function resetDevice() {
        resetTimer.start();
        subpageLoader.sourceComponent = resettingScreen;
    }

    Background {
        anchors.fill: parent
    }

    Connections {
        target: LogoutHandler
        function onSyncStateChanged() {
            if (!subpageLoader.active) {
                return;
            }

            if (subpageLoader.sourceComponent === syncingScreen) {
                if (LogoutHandler.syncState === LogoutHandler.SyncState.Ok) {
                    subpageLoader.sourceComponent = confirmResetScreen;
                } else if (LogoutHandler.syncState === LogoutHandler.SyncState.Failed) {
                    subpageLoader.sourceComponent = syncFailedScreen;
                }
            }
        }
    }

    Component.onCompleted: {
        // Ensure that the reset dialog is not visible when the app starts
        if (PasscodeHandler.hasPasscode || RetailDemo.enabled) {
            subpageLoader.sourceComponent = unlock;
        } else {
            subpageLoader.sourceComponent = initialResetScreen;
        }
        subpageLoader.active = true;
    }


    Loader {
        id: subpageLoader
        anchors.fill: parent
        focus: visible
        onActiveChanged: {
            if (subpageLoader.active) {
                LogoutHandler.checkReadyForLogout();
            }
        }
    }

    Component {
        id: unlock
        UnlockScreen {
            passcodeHandler: PasscodeHandler
            retailSettings: RetailDemo.settings
            anchors.fill: parent
            focus: visible
            showBackButton: true
            onCancel: close()
            onPasscodeVerified: subpageLoader.sourceComponent = initialResetScreen
        }
    }

    Component {
        id: initialResetScreen
        DialogScreen {
            anchors.fill: parent
            text: qsTr("Factory reset")
            description: qsTr("Reset your device to factory settings. By doing this all files and settings on your reMarkable will be erased, and your device will be restored to its original state.")
            iconSource: "qrc:/ark/icons/restore"
            gobackButton: false
            buttons: [
                {
                    text: qsTr("Cancel"),
                    highlight: false,
                    action: function() {
                        close();
                    }
                },
                {
                    text: qsTr("Factory reset"),
                    highlight: true,
                    action: function() {
                        if (!Authentication.loggedIn) {
                            // Not logged in, no sync/wifi to care for, proceed
                            subpageLoader.sourceComponent = confirmResetScreen;
                        } else if (!LinkProvider.isOnline) {
                            subpageLoader.sourceComponent = lacksWifiScreen;
                        } else if (LogoutHandler.syncState === LogoutHandler.SyncState.Syncing) {
                            subpageLoader.sourceComponent = syncingScreen;
                        } else if (LogoutHandler.syncState === LogoutHandler.SyncState.Failed) {
                            subpageLoader.sourceComponent = syncFailedScreen;
                        } else {
                            // All ok
                            subpageLoader.sourceComponent = confirmResetScreen;
                        }
                    }
                }
            ]
        }
    }


    Component {
        id: confirmResetScreen
        DialogScreen {
            anchors.fill: parent
            text: qsTr("Confirm factory reset")
            description: qsTr("Are you sure you want to reset your\nreMarkable to its factory settings?")
            subDescription: qsTr("All of your data will be erased from the device.")
            iconSource: "qrc:/ark/icons/restore"
            gobackButton: false
            accidentalTouchPrevention: true
            buttons: [

                {
                    text: qsTr("Cancel"),
                    highlight: false,
                    action: function() {
                        close();
                    }
                },
                {
                    text: qsTr("Confirm"),
                    highlight: true,
                    action: function() {
                        resetDevice();
                    }
                }
            ]
        }
    }

    Component {
        id: syncingScreen
        DialogScreen {
            text: qsTr("Syncing")
            iconSource: "qrc:/ark/icons/cloud_upload"
            onGoBack: {
                close();
            }
            buttons: [
                {
                    text: qsTr("Cancel"),
                    highlight: false,
                    action: function() {
                        close();
                    }
                },
                {
                    text: qsTr("Force reset"),
                    highlight: true,
                    action: function() {
                        subpageLoader.sourceComponent = forceResetScreen;
                    }
                }
            ]
        }
    }

    Component {
        id: syncFailedScreen
        DialogScreen {
            text: qsTr("Reset stopped")
            iconSource: "qrc:/ark/icons/cloud_x"
            description: qsTr("Unable to sync. Please try again.")
            gobackButton: false
            buttons: [
                {
                    text: qsTr("Cancel"),
                    highlight: false,
                    action: function() {
                        close();
                    }
                },
                {
                    text: qsTr("Reset without syncing"),
                    highlight: true,
                    action: function() {
                        subpageLoader.sourceComponent = forceResetScreen;
                    }
                }
            ]
        }
    }

    Component {
        id: lacksWifiScreen
        DialogScreen {
            text: qsTr("Factory reset stopped")
            iconSource: "qrc:/ark/icons/wifi_x"
            description: qsTr("Please connect to Wi-Fi and try again.")
            gobackButton: false
            buttons: [
                {
                    text: qsTr("Cancel"),
                    highlight: false,
                    action: function() {
                        close();
                    }
                },
                {
                    text: qsTr("Reset without syncing"),
                    highlight: true,
                    action: function() {
                        subpageLoader.sourceComponent = forceResetScreen;
                    }
                }
            ]
        }
    }

    Component {
        id: forceResetScreen
        DialogScreen {
            text: qsTr("Are you sure you want to reset without\nsyncing your latest changes?")
            iconSource: "qrc:/ark/icons/warning_circle"
            description: qsTr("Any unsynced changes will be erased from the device.")
            gobackButton: false
            buttons: [
                {
                    text: qsTr("Cancel"),
                    highlight: false,
                    action: function() {
                        close();
                    }
                },
                {
                    text: qsTr("Confirm"),
                    highlight: true,
                    action: function() {
                        resetDevice();
                    }
                }
            ]
        }
    }

    Component {
        id: resettingScreen
        DialogScreen {
            text: qsTr("Resetting...")
            iconSource: "qrc:/ark/icons/restore"
            gobackButton: false
        }
    }

    Timer {
        id: resetTimer
        interval: 1000
        onTriggered: DeviceApp.factoryReset()
    }
}
