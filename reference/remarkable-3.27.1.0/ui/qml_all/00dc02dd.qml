import QtQuick
import QtQuick.Layouts
import com.remarkable
import common

import ark.controls as ArkControls
import ark.tokens as ArkTokens

Item {
    id: root
    visible: true

    property RecognitionJob recognitionJob
    property bool finished
    property var finishedModel
    property bool failed

    height: bar.height
    width: parent.width

    anchors.bottom: parent.bottom
    anchors.left: parent.left

    signal undo
    signal cancel

    states: [
        State {
            name: "processing"
            when: recognitionJob && recognitionJob.status === RecognitionJob.Status.Processing

            PropertyChanges {
                target: textBlock
                text: qsTr("Converting to text (%1)").arg(HandwritingLanguageModel.languageWithRegion(Settings.handwritingConversionLanguage))
                iconSource: ""
            }

            PropertyChanges {
                target: actionButton
                text: qsTr("Cancel")
                onClicked: cancel()
            }

            PropertyChanges {
                target: root
                finished: false
            }

            PropertyChanges{
                target: progressBar
                visible: true
            }

            PropertyChanges{
                target: root
                failed: false
            }
        },

        State {
            name: "done"
            when: recognitionJob && recognitionJob.status === RecognitionJob.Status.Done

            PropertyChanges {
                target: textBlock
                text: finishedModel.textBlock.text
                iconSource: finishedModel.textBlock.icon
                visible: finishedModel.textBlock.visible
            }

            PropertyChanges {
                target: actionButton
                text: finishedModel.actionButton.text
                visible: finishedModel.actionButton.visible
                onClicked: undo()
            }

            PropertyChanges {
                target: root
                finished: true
            }

            PropertyChanges{
                target: root
                failed: false
            }
        },

        State {
            name: "error"
            when: recognitionJob && recognitionJob.status === RecognitionJob.Status.Error

            PropertyChanges {
                target: textBlock
                text: errorMessage(recognitionJob.error)
            }

            PropertyChanges{
                target: progressBar
                visible: false
            }

            PropertyChanges {
                target: actionButton
                text: qsTr("Close")
                onClicked: cancel()
            }

            PropertyChanges {
                target: root
                finished: true
            }

            PropertyChanges{
                target: root
                failed: true
            }
        }
    ]

    function close() {
        barTimer.running = false;
        progressBar.visible = true;
        Recognizer.abortRecognitionJob();
    }

    function errorMessage(error) {
        if (error === RecognitionJob.ConvertError.NetworkError) {
            return qsTr("Unable to convert text. Please check your Wi-Fi connection.");
        } else if (error === RecognitionJob.ConvertError.ServerError) {
            return qsTr("Unable to convert that amount of notes");
        } else if (error === RecognitionJob.ConvertError.AuthenticationError) {
            return qsTr("Unable to convert text. Pair your device to an account.");
        } else if(error === RecognitionJob.ConvertError.NoTasks || error === RecognitionJob.ConvertError.NoText ) {
            return qsTr("Unable to convert notes");
        }

        return qsTr("Unknown error");
    }

    Item {
        Timer {
            id: barTimer
            interval: 15000
        }
        Timer {
            id: animationTimer
            interval: 500
            onTriggered: progressBar.visible = false
        }
    }
    Connections {
        target: recognitionJob
        function onFinished() {
            animationTimer.running = true;
            barTimer.running = true;
        }
    }

    ArkControls.NotificationBar {
        id: bar
        type: ArkTokens.NotificationBar.primary
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        ArkControls.NotificationBar.Message {
            id: textBlock
            type: bar.type
            Layout.leftMargin: ArkControls.Values.padding.large
            Layout.rightMargin: ArkControls.Values.padding.large
            Layout.fillWidth: true
        }

        ArkControls.ProgressBar {
            id: progressBar
            type: ArkTokens.ProgressBar.primary_inverted
            value: recognitionJob ? recognitionJob.progress : 0
            width: 124
            Layout.rightMargin: Values.isDevice ? ArkControls.Values.padding.large : ArkControls.Values.padding.medium
            visible: false
        }

        ArkControls.NotificationBar.Divider {
            type: bar.type
            visible: actionButton.visible
        }

        ArkControls.NotificationBar.Button {
            id: actionButton
            type: bar.type
            focusPolicy: Qt.NoFocus
        }
    }
}
