import QtQuick
import QtQuick.Layouts

import common
import com.remarkable
import com.remarkable.devicetelemetry
import com.remarkable.telemetry as Telemetry

import device.ui.text
import device.ui.controls

import xofm.libs.qtgui

import ark.tokens as ArkTokens
import ark.controls as ArkControls

DeviceKeyboardNavigationHandler {
    id: root
    objectName: "Cloud"

    required property var cloudPanels

    property bool showheader: true
    property bool fullscreen: false

    signal wifiClicked

    function overrideNavigation(event) {
        // Handle going to the sidebar
        if (event.key === Qt.Key_Left) {
            root.resetFocusIndex();
            root.focus = false;
            settings.navigate();
            return true;
        }
        return false;
    }

    navigationModel: []
    canAcceptTabActivation: true
    keyOverrideHandler: overrideNavigation.bind(this)

    onVisibleChanged: syncPanel.syncCheckResultVisible = false

    onActivated: (element) => {
        if (element) {
            element.activate();
        }
    }

    ScrollArea {
        id: flickable

        anchors {
            fill: parent
        }
        contentWidth: width
        contentHeight: itemWrapper.implicitHeight + Values.navigatorSettingsItemMargin
        enableScrollbar: true
        permanentScrollbar: true

        Item {
            id: itemWrapper
            implicitHeight: itemWrapper.childrenRect.height
            implicitWidth: flickable.width

            ArkControls.PlaceholderBar {
                id: placeholder
                width: parent.width
            }

            ArkControls.Title {
                id: header
                type: ArkControls.Title.Large
                anchors {
                    top: placeholder.bottom
                    left: parent.left
                    leftMargin: ArkControls.Values.margin.horizontal.large
                }
                visible: root.showheader
                text: qsTr("Cloud settings")
            }

            ColumnLayout {
                anchors {
                    left: parent.left
                    leftMargin: ArkControls.Values.margin.horizontal.large
                    right: parent.right
                    rightMargin: ArkControls.Values.margin.horizontal.large
                    top: header.bottom
                    topMargin: ArkControls.Values.platform.spacing.x2large
                }
                spacing: ArkControls.Values.platform.spacing.x2large

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: ArkControls.Values.platform.spacing.large
                    visible: RetailDemo.enabled

                    ArkControls.Body {
                        text: qsTr("The reMarkable cloud is a service you can use to store your files and sync them to other devices. Unlimited cloud storage is included in the monthly price of a Connect subscription.")
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                    ArkControls.Body {
                        text: qsTr("For more information, go to <b>https://support.remarkable.com/s/article/Pair-your-reMarkable-with-the-cloud</b>")
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.preferredHeight: 300
                        Layout.preferredWidth: height
                        Layout.alignment: Qt.AlignLeft

                        QRCodeProvider {
                            id: provider
                            text: "https://support.remarkable.com/s/article/Pair-your-reMarkable-with-the-cloud?utm_source=rm_device&utm_medium=qr_code&utm_campaign=retail"
                        }

                        Image {
                            id: qrcode
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            source: provider.imageUrl
                        }
                    }
                }

                ArkControls.Panel {
                    id: syncPanel

                    property bool syncCheckResultVisible: false
                    property bool isSyncing: DocumentSync.isSyncing

                    function activate() {
                        if(DocumentSync.syncChecker.running) {
                            return;
                        }

                        // Find our top level collections ("My Files", and "trash")
                        // If status is sync error, handle sync error with retry
                        // This will try to re-resolve conflicting files, and remove .failure files
                        const topLevelIds = ["", "trash"];
                        for (const collectionId of topLevelIds) {
                            let topLevelCollection = Library.entryForId(collectionId);
                            if (topLevelCollection.status === Entry.SyncError) {
                                topLevelCollection.handleSyncError(Entry.Retry);
                            }
                        }

                        DocumentSync.syncChecker.startCheck();
                    }

                    visible: !RetailDemo.enabled
                    Layout.fillWidth: true
                    label: qsTr("Cloud connection")
                    showAttachment: syncPanel.syncCheckResultVisible
                                    || DocumentSync.syncChecker.running
                                    || DocumentSync.hasFailure
                    description: qsTr("Checks if your reMarkable is syncing.")
                    action: ArkControls.Button {
                        id: button
                        type: ArkTokens.Button.secondary
                        text: qsTr("Check sync")
                        showFocus: root.current === button
                        onClicked: syncPanel.activate()
                        Component.onCompleted: root.navigationModel[0] = button
                    }
                    attachment: ArkControls.InfoMessage {
                        type: ArkTokens.InfoMessage.primary
                        message: DocumentSync.hasFailure
                                 ? qsTr("There was an issue with your last sync")
                                 : qsTranslate("xofm::libs::syncinterface::Checker", DocumentSync.syncChecker.statusText)
                        description: DocumentSync.hasFailure ? DocumentSync.lastFailure : null
                        iconSource: DocumentSync.syncChecker.statusIcon
                        width: syncPanel.width

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if(!LinkProvider.isOnline) {
                                    root.wifiClicked();
                                }
                            }
                        }
                    }

                    Connections {
                        target: DocumentSync.syncChecker
                        function onStatusTextChanged() {
                            syncPanel.syncCheckResultVisible = true;
                        }
                    }
                }

                ArkControls.InfoMessage {
                    id: subscriptionPlanInfoMessage
                    type: ArkTokens.InfoMessage.secondary
                    title: qsTr("Sync without Connect")
                    iconSource: "qrc:/ark/icons/information_circle"
                    visible: DocumentSync.hasLimitedSync
                    message: qsTr("Without Connect, only files used and synced online in the last 50 days will continue to be stored in the cloud and updated in our apps.")
                    description: qsTr("Log in to manage your subscription at %1.", "Subscription settings info message").arg(NetworkClient.loginUrl)
                    Layout.fillWidth: true
                }

                Repeater {
                    model: root.cloudPanels
                    delegate: WidgetLoader {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
