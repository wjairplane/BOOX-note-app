import QtQuick
import com.remarkable
import common
import device.ui.text
import xofm.libs.epub

import ark.controls as ArkControls

Item {
    id: textSizeContainer

    required property EpubProperties epub

    ArkControls.Label {
        id: textSizeTitle
        x: Values.documentViewFormatTitleMargin
        y: Values.documentViewFormatTitleMargin
        text: qsTr("Font size")
    }

    Item {
        id: textSizeRow

        anchors {
            top: textSizeTitle.bottom
            topMargin: Values.documentViewFormatGridMargin
            left: parent.left
            leftMargin: Values.documentViewFormatGridMargin
            right: parent.right
            rightMargin: Values.documentViewFormatGridMargin
            bottom: parent.bottom
            bottomMargin: Values.documentViewFormatGridMargin
        }

        Row {
            anchors.centerIn: parent

            Repeater {
                model: [0.7, 0.8, 1.0, 1.2, 1.5, 2.0]

                delegate: Rectangle {
                    property bool selected: textSizeContainer.epub.textScale === fontScale
                    property real fontScale: modelData
                    objectName: "font-scale-" + fontScale
                    width: textSizeRow.width / 6
                    height: width
                    color: selected ? Values.colorBlack : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "A"
                        font.pixelSize: parent.fontScale * Values.iconSizeLarge / 2
                        color: selected ? Values.colorWhite : Values.colorBlack
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var action = function () {
                                textSizeContainer.epub.setTextScale(parent.fontScale);
                            }
                            confirmLayoutChange(action);
                        }
                    }
                }
            }
        }
    }
}
