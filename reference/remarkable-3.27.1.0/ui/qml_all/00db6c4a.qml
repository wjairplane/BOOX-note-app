import QtQuick
import QtQuick.Layouts

import com.remarkable
import common

import device.ui.controls

import ark.controls as ArkControls

FoldoutOverlay {
    id: root

    // MIME type constants
    readonly property string mimeTypePdf: "application/pdf"
    readonly property string mimeTypeEpub: "application/epub+zip"
    readonly property string mimeTypeRmdoc: "application/vnd.remarkable.rmdoc+zip"
    property list<string> possibleImportFileTypes: []
    property list<string> restrictedFileTypes: []
    property var getRestrictedFileTypeReasonCallback: () => {}

    signal fileTypeSelected(string fileType, bool isRestricted)
    signal cancelled

    function getDisplayName(fileType) {
        switch (fileType) {
            case mimeTypePdf:
                return qsTr("PDF");
            case mimeTypeRmdoc:
                return qsTr("Convert to Notebook");
            case mimeTypeEpub:
                return qsTr("Ebook");
            default:
                return fileType;
        }
    }

    function getIconSource(fileType) {
        switch (fileType) {
            case mimeTypePdf:
                return "qrc:/ark/icons/file_pdf";
            case mimeTypeEpub:
                return "qrc:/ark/icons/ebook";
            case mimeTypeRmdoc:
                return "qrc:/ark/icons/notebook_sparkles";
            default:
                return "qrc:/ark/icons/file";
        }
    }

    function getButtonDescription(fileType) {
        const reason = getRestrictedFileTypeReasonCallback(fileType);

        if (reason === "connectRequired") {
            //: Caption indicates that this functionality is only available for users with Connect subscription
            return qsTr("Connect feature");
        }

        return "";
    }

    function isFileTypeRestricted(fileType) {
        return restrictedFileTypes.includes(fileType);
    }

    contentItem: ColumnLayout {
        spacing: 0

        Repeater {
            model: root.possibleImportFileTypes

            ArkControls.FoldoutItem {
                required property string modelData
                required property int index

                Layout.fillWidth: true
                topDivider: index > 0
                label: root.getDisplayName(modelData)
                description: root.getButtonDescription(modelData)
                iconSource: root.getIconSource(modelData)
                selected: false
                onClicked: root.fileTypeSelected(modelData, isFileTypeRestricted(modelData))
            }
        }
    }

    onOverlayClicked: root.cancelled()
}
