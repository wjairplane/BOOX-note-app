import QtQuick
import QtQuick.Layouts

import xofm.libs.controls

import ark.controls as ArkControls
import ark.tokens as ArkTokens

InputBlocker {
    id: root

    required property var documentSync

    readonly property string syncingStatusText: qsTr("Syncing")
    readonly property string syncCompleteStatusText: qsTr("Sync completed")
    property bool shouldShowProgress: {
        /*
         * Do NOT omit this constant. QML seems to cache something
         * internally, and unless we explicitly declare an association
         * with the signalled (from C++) tmp object, some state
         * transitions are skipped.
         */
        const progressCounts = root.documentSync.progressCounts;
        return root.documentSync.isSyncing
            && ((progressValue() > 0) || progressCounts.state !== "")
            && !root.documentSync.hasFailure
            && !syncMessageDelayTimer.running;
    }

    function progressValue() {
        return root.documentSync.progressCounts.progress;
    }

    function makeTransferCountLabel() {
        const counts = root.documentSync.progressCounts;
        if (counts.state === "") {
            return root.syncingStatusText;
        }
        if (counts.scheduled <= 1) {
            return root.syncingStatusText;
        }
        return qsTr("Syncing (%1 of %2)").arg(counts.transferred).arg(counts.scheduled);
    }

    height: progressInfo.implicitHeight
    visible: false
    states: [
        State {
            name: "showProgress"
            when: root.shouldShowProgress
            PropertyChanges {
                target: root
                visible: true
            }
            PropertyChanges {
                target: progressInfo
                messageText: root.makeTransferCountLabel()
                messageIcon: "qrc:/ark/icons/rotate"
                shouldProgressBarShow: true
            }
        },

        State {
            name: "showCompleteMessage"
            when: root.progressValue() > 0
                && syncCompleteMessageTimer.running
                && !root.documentSync.hasFailure
                && root.documentSync.hasService
            PropertyChanges {
                target: root
                visible: true
            }
            PropertyChanges {
                target: progressInfo
                messageText: root.syncCompleteStatusText
                messageIcon: "qrc:/ark/icons/checkmark"
                shouldProgressBarShow: false
            }
        }
    ]

    ArkControls.NotificationBar {
        id: progressInfo

        property string messageText: ""
        property string messageIcon: ""
        property bool shouldProgressBarShow: false

        type: ArkTokens.NotificationBar.primary
        anchors {
            bottom: parent.botton
            left: parent.left
            right: parent.right
        }

        ArkControls.NotificationBar.Message {
            id: message
            objectName: "message"
            Layout.fillWidth: true
            Layout.rightMargin: ArkControls.Values.padding.large
            Layout.leftMargin: ArkControls.Values.padding.large

            text: progressInfo.messageText
            iconSource: progressInfo.messageIcon
        }

        ArkControls.ProgressBar {
            id: progressBar
            objectName: "progressBar"
            type: ArkTokens.ProgressBar.primary_inverted
            value: root.progressValue()
            width: 160 // Values.syncProgressBarWidth - left on purpose to find back Values later on.
            Layout.rightMargin: ArkControls.Values.padding.large
            visible: progressInfo.shouldProgressBarShow
        }
    }

    Connections {
        target: root.documentSync
        function onIsSyncingChanged() {
            if (root.documentSync.isSyncing) {
                syncCompleteMessageTimer.stop();
                syncMessageDelayTimer.start();
            } else if (!syncMessageDelayTimer.running) {
                syncCompleteMessageTimer.start();
            }
        }
    }

    Timer {
        id: syncMessageDelayTimer
        objectName: "syncMessageDelayTimer"
        interval: 20000
        repeat: false
    }

    Timer {
        id: syncCompleteMessageTimer
        objectName: "syncCompleteMessageTimer"
        interval: 3000
        repeat: false
    }
}
