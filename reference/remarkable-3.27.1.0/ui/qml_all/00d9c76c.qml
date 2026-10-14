import QtQuick
import com.remarkable
import common
import device.ui.text
import xofm.libs.epub

import ark.controls as ArkControls

Item {
    id: alignmentContainer

    required property EpubProperties epub

    ArkControls.Label {
        id: justificationTitle
        x: Values.documentViewFormatTitleMargin
        y: Values.documentViewFormatTitleMargin
        text: qsTr("Justification")
    }
    Row {
        id: justificationRow
        anchors {
            top: justificationTitle.bottom
            topMargin: Values.documentViewFormatGridMargin
            left: parent.left
            leftMargin: Values.documentViewFormatGridMargin
            right: parent.right
            rightMargin: Values.documentViewFormatGridMargin
            bottom: parent.bottom
            bottomMargin: Values.documentViewFormatGridMargin
        }

        Repeater {
            id: repeater
            model: [
                {
                    illustration: "qrc:/ark/illustrations/epub/paragraph_left_aligned",
                    selectedIllustration: "qrc:/ark/illustrations/epub/paragraph_left_aligned_inverted",
                    alignment: Qt.AlignLeft,
                    objectName: "align-left"
                },
                {
                    illustration: "qrc:/ark/illustrations/epub/paragraph_justified",
                    selectedIllustration: "qrc:/ark/illustrations/epub/paragraph_justified_inverted",
                    alignment: Qt.AlignJustify,
                    objectName: "align-justify"
                }
            ]

            delegate: Item {
                required property var modelData
                objectName: modelData.objectName
                property bool selected: alignmentContainer.epub.textAlignment === modelData.alignment

                height: Values.documentViewFormatIconSize
                width: Math.floor(justificationRow.width / repeater.count)
                anchors.verticalCenter: justificationRow.verticalCenter

                ArkControls.Illustration {
                    anchors.centerIn: parent
                    size: Values.documentViewFormatIconSize
                    scale: Math.min(1, parent.width / size)
                    source: parent.selected ? modelData.selectedIllustration : modelData.illustration
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        confirmLayoutChange(() => { alignmentContainer.epub.setTextAlignment(modelData.alignment); });
                    }
                }
            }
        }
    }
}
