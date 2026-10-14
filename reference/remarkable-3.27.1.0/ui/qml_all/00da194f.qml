import QtQuick
import com.remarkable
import common
import device.ui.text
import xofm.libs.epub

import ark.controls as ArkControls

Item {
    id: marginsContainer

    required property EpubProperties epub

    ArkControls.Label {
        id: marginsTitle
        x: Values.documentViewFormatTitleMargin
        y: Values.documentViewFormatTitleMargin
        text: qsTr("Page margins")
    }

    Row {
        id: marginsRow
        anchors {
            top: marginsTitle.bottom
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
                    illustration: "qrc:/ark/illustrations/epub/margin_minimum",
                    selectedIllustration: "qrc:/ark/illustrations/epub/margin_minimum_inverted",
                    margins: 50,
                    objectName: "margin-minimum"
                },
                {
                    illustration: "qrc:/ark/illustrations/epub/margin_medium",
                    selectedIllustration: "qrc:/ark/illustrations/epub/margin_medium_inverted",
                    margins: 125,
                    objectName: "margin-medium"
                },
                {
                    illustration: "qrc:/ark/illustrations/epub/margin_maximum",
                    selectedIllustration: "qrc:/ark/illustrations/epub/margin_maximum_inverted",
                    margins: 225,
                    objectName: "margin-maximum"
                }
            ]

            delegate: Item {
                required property var modelData
                objectName: modelData.objectName
                property bool selected: marginsContainer.epub.margins === modelData.margins

                height: Values.documentViewFormatIconSize
                width: Math.floor(marginsRow.width / repeater.count)
                anchors.verticalCenter: marginsRow.verticalCenter

                ArkControls.Illustration {
                    anchors.centerIn: parent
                    size: Values.documentViewFormatIconSize
                    scale: Math.min(1, parent.width / size)
                    source: parent.selected ? modelData.selectedIllustration : modelData.illustration
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        confirmLayoutChange(() => { marginsContainer.epub.setMargins(modelData.margins);});
                    }
                }
            }
        }
    }
}
