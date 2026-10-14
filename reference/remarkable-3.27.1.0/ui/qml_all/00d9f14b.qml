import QtQuick
import com.remarkable
import com.remarkable.hwctelemetry
import common
import device.ui.text

Item {
    id: root
    visible: false

    // Properties
    required property Document document
    required property int currentPage
    readonly property int status: handwritingBar.recognitionJob ? handwritingBar.recognitionJob.status : -1
    readonly property alias failed: handwritingBar.failed
    readonly property bool processing: status === RecognitionJob.Status.Processing

    // Signals
    signal close
    signal conversionFinished
    signal conversionFailed
    signal closeAndUndo

    // Functions
    function convert(items) {
        Clipboard.items = undefined;
        HwcTelemetry.entryPoint("Selection Tool");
        Recognizer.startSelectionToolJob(items, Settings.handwritingConversionLanguage);
        root.visible = true;
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: (mouse) => {
            if (!processing) {
                mouse.accepted = false;
                root.close();
            }
        }
    }

    // UI
    HwcNotificationBar {
        id: handwritingBar
        visible: root.visible
        recognitionJob: Recognizer.selectionToolJob
        finishedModel: {
            "textBlock": {
                "text": qsTr("Converted text added to clipboard"),
                "icon": "qrc:/ark/icons/copy",
                "visible": true
            },
            "actionButton": {
                "text": qsTr("Undo"),
                "visible": document && document.isNotepage(root.currentPage)
            }
        }

        onUndo: root.closeAndUndo()

        onVisibleChanged: {
            if (visible && !Authentication.loggedIn) {
                // Show error message straight away when not logged in
                recognitionJob.status = RecognitionJob.Status.Error;
                recognitionJob.error = RecognitionJob.ConvertError.AuthenticationError;
            }
        }

        onCancel: {
            if (recognitionJob && recognitionJob.status === RecognitionJob.Status.Error) {
                root.close();
            } else {
                Recognizer.abortSelectionToolJob();
                // Since we remove the lines, we need to
                // both close and undo if the cancel button was clicked.
                root.closeAndUndo();
            }
        }

        onFinishedChanged: {
            if (!finished) {
                return;
            }
            Clipboard.text = recognitionJob.formattedTextToClipboardText();
            if (Clipboard.hasText) {
                conversionFinished();
            }
        }

        onFailedChanged: {
            if (failed) {
                conversionFailed();
            }
        }
    }
}
