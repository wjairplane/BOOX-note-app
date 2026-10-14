import QtQuick

import com.remarkable // LogoutHandler

import xofm.libs.qtgui // WindowNavigator
import xofm.libs.pincode // PasscodeHandler
import xofm.libs.dialogs
import xofm.libs.retail // RetailSettings

FocusScope {
    id: root
    objectName: "retailDemoDialog"

    required property WindowNavigator windowNavigator
    required property RetailSettings retailSettings
    required property bool policyEnabled
    required property var logoutHandler
    required property PasscodeHandler passcodeHandler

    readonly property var retailPoints: [
        qsTr("By entering this mode, you will lose all content currently on your device and no longer have access to files backed up to the cloud."),
        qsTr("A factory reset is required to exit retail mode. This will restore your device to its original settings."),
        qsTr("Entering requires passcode to be disabled, and setting a dedicated retail passcode."),
    ]

    signal close

    function goBack() {
        subpageLoader.active = false;
        root.visible = false;
        root.close();
    }

    function enterRetailMode() {
        root.windowNavigator.open("retail/window/retail-setup-language")
        root.close();
    }

    function tryEnterRetailMode() {
        if (!Authentication.loggedIn) {
            // Not logged in, no sync/wifi to care for, proceed
            enterRetailMode();
        } else if (root.logoutHandler.syncState === LogoutHandler.SyncState.Syncing) {
            subpageLoader.sourceComponent = syncingScreen;
        } else if (root.logoutHandler.syncState === LogoutHandler.SyncState.Failed) {
            subpageLoader.sourceComponent = syncFailedScreen;
        } else {
            // All ok
            enterRetailMode();
        }
    }

    visible: true
    focus: visible
    anchors.fill: parent

    Component.onCompleted: {
        root.logoutHandler.checkReadyForLogout();
        subpageLoader.active = true;
        root.visible = true;
        subpageLoader.sourceComponent = initialScreen;
    }

    Loader {
        id: subpageLoader
        anchors.fill: parent
        active: false
        focus: visible
        onActiveChanged: {
            if (subpageLoader.isActive) {
                root.logoutHandler.checkReadyForLogout();
            }
        }
    }

    Connections {
        target: root.logoutHandler

        function onSyncStateChanged() {
            if (!subpageLoader.active) {
                return;
            }

            if (subpageLoader.sourceComponent === syncingScreen) {
                if (root.logoutHandler.syncState === LogoutHandler.SyncState.Ok) {
                    enterRetailMode();
                } else if (root.logoutHandler.syncState === LogoutHandler.SyncState.Failed) {
                    subpageLoader.sourceComponent = syncFailedScreen;
                }
            }
        }
    }

    Component {
        id: initialScreen

        InformationDialog {
            objectName: "retailInfoDialog"
            anchors.fill: parent
            title: qsTr("Retail mode")
            subtitle: qsTr("Please be aware that retail mode is designed for demo purposes only and not recommended for any other use.")
            onGoBack: root.goBack();
            body: {
                let bodyText = retailPoints;
                if (root.policyEnabled) {
                    bodyText = bodyText.concat(qsTr("You cannot enter with an Enterprise account."));
                }
                return bodyText;
            }
            buttons: root.policyEnabled ? [] : [
                {
                    objectName: "enterRetailButton",
                    text: root.passcodeHandler?.hasPasscode ? qsTr("Remove passcode") : qsTr("Enter retail mode"),
                    highlight: false,
                    action: function() {
                        if (root.passcodeHandler?.hasPasscode) {
                            root.windowNavigator.open("security-pincode/window/passcode-update", {
                                "remove": true,
                            });
                        } else {
                            subpageLoader.sourceComponent = setRetailPasscode;
                        }
                    }
                }
            ]
        }
    }

    Component {
        id: setRetailPasscode

        SetRetailPasscode {
            passcodeLength: root.passcodeHandler.passcodeLength
            goBackButton: true
            onGoBack: {
                subpageLoader.sourceComponent = initialScreen;
            }
            onPasscodeChanged: (passcode) => {
                root.retailSettings.setRetailPasscode(passcode);

                if (LinkProvider.isOnline) {
                    tryEnterRetailMode();
                } else {
                    root.windowNavigator.open("wifi/window/network-select", { onFinish: tryEnterRetailMode });
                }
            }
        }
    }

    Component {
        id: syncingScreen

        DialogScreen {
            text: qsTr("Syncing...")
            iconSource: "qrc:/ark/icons/cloud_upload"
            onGoBack: {
                root.goBack();
            }
        }
    }

    Component {
        id: syncFailedScreen

        DialogScreen {
            text: qsTr("Unable to sync")
            iconSource: "qrc:/ark/icons/cloud_x"
            description: qsTr("Any unsynced changes will be erased from the device.")
            gobackButton: false
            buttons: [
                {
                    text: qsTr("Cancel"),
                    highlight: false,
                    action: function() {
                        root.goBack();
                    }
                },
                {
                    text: qsTr("Reset without syncing"),
                    highlight: true,
                    action: function() {
                        enterRetailMode();
                    }
                }
            ]
        }
    }
}
