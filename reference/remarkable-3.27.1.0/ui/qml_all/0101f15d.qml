import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.controls // InputBlocker
import xofm.libs.search.ui // SearchIndexStatus

InputBlocker {
    id: root

    required property SearchIndexStatus searchIndexStatus
    readonly property int status: searchIndexStatus?.status ?? 0

    visible: {
        switch (status) {
        case SearchIndexStatus.Status.InProgress:
            return true;
        case SearchIndexStatus.Status.Completed:
        case SearchIndexStatus.Status.NotEnoughDiskSpace:
        case SearchIndexStatus.Status.Error:
            return messageTimer.running;
        case SearchIndexStatus.Status.Ineligible:
        case SearchIndexStatus.Status.Eligible:
        case SearchIndexStatus.Status.UpToDate:
        default:
            return false;
        }
    }

    property int messageTimeoutMs: 5000

    Timer {
        id: messageTimer
        interval: root.messageTimeoutMs
        repeat: false
    }

    onStatusChanged: {
        switch (status) {
        case SearchIndexStatus.Status.Completed:
        case SearchIndexStatus.Status.NotEnoughDiskSpace:
        case SearchIndexStatus.Status.Error:
            messageTimer.restart();
        default:
        }
    }

    states: [
        State {
            name: "ineligible"
            when: status === SearchIndexStatus.Status.Ineligible
        },

        State {
            name: "eligible"
            when: status === SearchIndexStatus.Status.Eligible
        },

        State {
            name: "downloading"
            when: status === SearchIndexStatus.Status.InProgress

            PropertyChanges {
                target: textBlock
                //: Message appears in notification bar at the top or bottom edge of the screen.
                //: Keep it single-sentence if possible and don't use punctuation at the end.
                text: qsTr("Making handwriting searchable might take a while")
                iconSource: "qrc:/ark/icons/rotate"
            }

            PropertyChanges {
                target: progressBar
                visible: true
            }
        },

        State {
            name: "completed"
            when: status === SearchIndexStatus.Status.Completed

            PropertyChanges {
                target: textBlock
                //: Message appears in notification bar at the top or bottom edge of the screen.
                //: Keep it single-sentence if possible and don't use punctuation at the end.
                text: qsTr("All handwritten notes are now searchable")
                iconSource: "qrc:/ark/icons/checkmark"
            }

            PropertyChanges {
                target: messageTimer
                //: Make sure completed is only showed once per progress by forcing UpToDate state.
                onTriggered: searchIndexStatus.forceUpToDate();
            }
        },

        State {
            name: "upToDate"
            when: status === SearchIndexStatus.Status.UpToDate
        },

        State {
            name: "notEnoughDiskSpace"
            when: status === SearchIndexStatus.Status.NotEnoughDiskSpace

            PropertyChanges {
                target: textBlock
                text: qsTr("Disk is almost full. Free up disk space to make more handwritten notes searchable.")
                iconSource: "qrc:/ark/icons/warning_circle"
            }
        },

        State {
            name: "error"
            when: status === SearchIndexStatus.Status.Error

            PropertyChanges {
                target: textBlock
                //: Message appears in notification bar at the top or bottom edge of the screen.
                //: Keep it single-sentence if possible and don't use punctuation at the end.
                text: qsTr("Unable to make handwritten notes searchable")
                iconSource: "qrc:/ark/icons/warning_circle"
            }
        }
    ]

    ArkControls.NotificationBar {
        id: bar
        type: ArkTokens.NotificationBar.primary
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        ArkControls.NotificationBar.Message {
            id: textBlock
            type: bar.type
            Layout.rightMargin: ArkControls.Values.padding.large
            Layout.leftMargin: ArkControls.Values.padding.large
            Layout.fillWidth: true
            iconSource: ""
        }

        ArkControls.ProgressBar {
            id: progressBar
            objectName: "progressBar"
            type: ArkTokens.ProgressBar.primary_inverted
            value: (searchIndexStatus?.progress.percent / 100) ?? 0
            width: 192 // Values.syncProgressBarWidth
            Layout.rightMargin: ArkControls.Values.padding.large
            visible: false
        }

        ArkControls.NotificationBar.Divider {
            type: bar.type
            visible: actionButton.visible
        }

        ArkControls.NotificationBar.Button {
            id: actionButton
            objectName: "actionButton"
            type: bar.type
            focusPolicy: Qt.NoFocus
            visible: text !== ""
        }
    }
}
