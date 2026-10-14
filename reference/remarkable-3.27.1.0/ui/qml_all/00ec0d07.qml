import QtQuick

import xofm.libs.qtgui
import xofm.libs.user
import xofm.libs.dialogs
import com.remarkable

import ark.controls as ArkControls

Item {
    id: root

    property bool isOnline: false
    required property bool logoutPolicy

    readonly property string userEmail: UserInfo.email ? qsTr(", %1").arg(UserInfo.email) : ""

    signal close

    /*
        States: confirmUnpair, lacksWifi, stillSyncing, syncFailed, forceUnpair, unpaired
    */
    state: "confirmUnpair"

    function logout() {
        if (!root.isOnline) {
            root.state = "lacksWifi";
        } else if (LogoutHandler.syncState === LogoutHandler.SyncState.Syncing) {
            root.state  = "stillSyncing";
        } else if (LogoutHandler.syncState === LogoutHandler.SyncState.Failed) {
            root.state  = "syncFailed";
        } else if (LogoutHandler.syncState === LogoutHandler.SyncState.Ok) {
            LogoutHandler.logout();
            root.close();
        }
    }

    function confirmUnpair() {
        root.state = "confirmUnpair"
    }

    function forceUnpair() {
        root.state = "forceUnpair";
    }

    function unpaired() {
        root.state = "unpaired";
    }

    Connections {
        target: LogoutHandler
        function onSyncStateChanged() {
            if (root.state === "stillSyncing") {
                if (LogoutHandler.syncState === LogoutHandler.SyncState.Ok) {
                    LogoutHandler.logout();
                    root.close();
                } else if (LogoutHandler.syncState === LogoutHandler.SyncState.Failed) {
                    root.state  = "syncFailed";
                }
            }
        }
    }

    states:  [
        State {
            name: "confirmUnpair"
            PropertyChanges {
                target: dialog
                text: qsTr("Unpairing from the cloud")
                description: qsTr("Changes will sync automatically before your reMarkable account is unpaired. No files will be deleted on your device.")
                subDescription: {
                    const archivedCount = Library.countArchivedDocuments();
                    if (0 === archivedCount) {
                        return "";
                    }

                    //: Retain non-breaking space `&#160;` so that "paper tablet" or its translation always appear together on the same line; requires plural form.
                    return  qsTr("%n document(s) are currently archived. You will not be able to retrieve or open them on your paper&#160;tablet once you unpair.", "", archivedCount);
                }
                iconSource: "qrc:/ark/icons/cloud_x"
                gobackButton: false
                buttons: [
                    {
                        text: qsTr("Cancel"),
                        highlight: false,
                        action: function() {
                            root.close();
                        }
                    },
                    {
                        text: qsTr("Confirm"),
                        highlight: true,
                        visible: !root.logoutPolicy,
                        action: function() {
                            root.logout();
                        }
                    }
                ]
            }
        },

        State {
            name: "lacksWifi"
            PropertyChanges {
                target: dialog
                text: qsTr("Unpairing stopped")
                iconSource: "qrc:/ark/icons/wifi_x"
                description: qsTr("Please connect to Wi-Fi and try again.")
                gobackButton: false
                buttons: [
                    {
                        text: qsTr("Cancel"),
                        highlight: false,
                        action: function() {
                            root.close();
                        }
                    },
                    {
                        text: qsTr("Force unpair"),
                        highlight: true,
                        action: function() {
                            root.forceUnpair();
                        }
                    }
                ]
            }
        },

        State {
            name: "stillSyncing"
            PropertyChanges {
                target: dialog
                text: qsTr("Syncing")
                iconSource: "qrc:/ark/icons/cloud_upload"
                gobackButton: false
                buttons: [
                    {
                        text: qsTr("Cancel"),
                        highlight: false,
                        action: function() {
                            root.confirmUnpair();
                        }
                    },
                    {
                        text: qsTr("Force unpair"),
                        highlight: true,
                        action: function() {
                            root.forceUnpair();
                        }
                    }
                ]
            }
        },

        State {
            name: "syncFailed"
            PropertyChanges {
                target: dialog
                text: qsTr("Unpairing stopped")
                iconSource: "qrc:/ark/icons/cloud_x"
                description: qsTr("Unable to sync. Please try again.")
                gobackButton: false
                buttons: [
                    {
                        text: qsTr("Cancel"),
                        highlight: false,
                        action: function() {
                            root.confirmUnpair();
                        }
                    },
                    {
                        text: qsTr("Force unpair"),
                        highlight: true,
                        action: function() {
                            root.forceUnpair();
                        }
                    }
                ]
            }
        },

        State {
            name: "forceUnpair"
            PropertyChanges {
                target: dialog
                text: qsTr("Forced unpairing without syncing")
                iconSource: "qrc:/ark/icons/warning_circle"
                description: qsTr("If your device is unpaired with the&#160;reMarkable&#160;cloud now, you risk losing unsynced files.")
                gobackButton: false
                buttons: [
                    {
                        text: qsTr("Cancel"),
                        highlight: false,
                        action: function() {
                            root.close();
                        }
                    },
                    {
                        text: qsTr("Confirm"),
                        visible: !root.logoutPolicy,
                        highlight: true,
                        action: function() {
                            LogoutHandler.logout();
                            root.close();
                        }
                    }
                ]
            }
        },

        State {
            name: "unpaired"
            PropertyChanges {
                target: dialog
                text: qsTr("Your device has been unpaired")
                description: qsTr("Any new changes made since your last sync are at risk of being lost.")
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
    ]

    DialogScreen {
        id: dialog
        anchors.fill: parent
    }
}
