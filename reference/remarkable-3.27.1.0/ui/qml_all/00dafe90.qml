import QtQuick
import com.remarkable
import common
import device.ui.text
import xofm.libs.epub

import ark.controls as ArkControls

Item {
    id: lineSpacingContainer

    required property EpubProperties epub

    ArkControls.Label {
        id: lineSpacingTitle
        x: Values.documentViewFormatTitleMargin
        y: Values.documentViewFormatTitleMargin
        text: qsTr("Line spacing")
    }

    Row {
        id: lineSpacingRow
        anchors {
            top: lineSpacingTitle.bottom
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
                    illustration: "qrc:/ark/illustrations/epub/line_spacing_minimum",
                    selectedIllustration: "qrc:/ark/illustrations/epub/line_spacing_minimum_inverted",
                    lineHeight: 100,
                    objectName: "line-height-minimum"
                },
                {
                    illustration: "qrc:/ark/illustrations/epub/line_spacing_medium",
                    selectedIllustration: "qrc:/ark/illustrations/epub/line_spacing_medium_inverted",
                    lineHeight: 150,
                    objectName: "line-height-medium"
                },
                {
                    illustration: "qrc:/ark/illustrations/epub/line_spacing_maximum",
                    selectedIllustration: "qrc:/ark/illustrations/epub/line_spacing_maximum_inverted",
                    lineHeight: 200,
                    objectName: "line-height-maximum"
                }
            ]

            delegate: Item {
                required property var modelData
                objectName: modelData.objectName
                property bool selected: lineSpacingContainer.epub.lineHeight === modelData.lineHeight

                height: Values.documentViewFormatIconSize
                width: Math.floor(lineSpacingRow.width / repeater.count)
                anchors.verticalCenter: lineSpacingRow.verticalCenter

                ArkControls.Illustration {
                    anchors.centerIn: parent
                    size: Values.documentViewFormatIconSize
                    scale: Math.min(1, parent.width / size)
                    source: parent.selected ? modelData.selectedIllustration : modelData.illustration
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        confirmLayoutChange(() => { lineSpacingContainer.epub.setLineHeight(modelData.lineHeight); });
                    }
                }
            }
        }
    }
}
