import QtQuick
import com.remarkable
import com.remarkable.hwctelemetry
import common
import device.ui.text
import xofm.libs.devicescreen

Item {
    id: root

    property Entry document
    readonly property bool processing: handwritingBar.recognitionJob && handwritingBar.recognitionJob.status === RecognitionJob.Status.Processing
    property bool _doApplyFormattedText: false
    implicitHeight: handwritingBar.visible ? handwritingBar.height : 0

    signal requestOpenPage(int pageIndex, var scrollPosition)

    function close() {
        handwritingBar.close();
        root.visible = false;
    }

    function createConvertedDocument() {
        DocumentController.addPageWithTemplateAndPageSize(document, handwritingBar.recognitionJob.newPage, Strings.defaultTemplateName, DeviceScreenInfo.paperSize, () => {
            _doApplyFormattedText = true;
            root.requestOpenPage(handwritingBar.recognitionJob.newPage, undefined);
        });
    }

    Connections {
        target: sceneView
        enabled: _doApplyFormattedText
        function onStatusChanged() {
            // As the reconitionJob using the worker to apply text, we need to make sure it
            // is not used by the sceneView as it may be null or invalid.
            // Thus, we wait for the sceneView to be ready before applying text.
            if (sceneView.status === SceneView.Active) {
                handwritingBar.recognitionJob.applyFormattedText(sceneController.worker);
                _doApplyFormattedText = false;
            }
        }
    }

    function convert(pages) {
        root.visible = true;
        Recognizer.startRecognitionJob(document.id, pages, Settings.handwritingConversionLanguage);
    }

    Timer {
        id: closeTimer
        interval: 8000
        repeat: false
        onTriggered: {
            root.close();
        }
        running: handwritingBar.finished && root.visible
    }

    HwcNotificationBar {
        id: handwritingBar
        recognitionJob: Recognizer.recognitionJob
        finishedModel: {
            "textBlock": {
                "text": qsTr("Converted text added as new page"),
                "icon": "qrc:/ark/icons/hwc",
                "visible": true
            },
            "actionButton": {
                "text": qsTr("Undo"),
                "visible": true
            }
        }
        onUndo: {
            HwcTelemetry.undo(true);
            DocumentController.deletePages(document, [recognitionJob.newPage], () => {
                root.requestOpenPage(recognitionJob.newPage - 1, DocumentView.ScrollPosition.Restore);
                root.close();
                exitTextMode();
            });
        }
        onCancel: root.close()

        onFinishedChanged: {
            if (!finished) {
                return;
            }

            if (recognitionJob.status === RecognitionJob.Status.Done) {
                createConvertedDocument();
            }
        }
    }
}
