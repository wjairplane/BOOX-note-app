import QtQuick
import com.remarkable
import common
import device.ui.text
import xofm.libs.epub

import ark.controls as ArkControls

Item {
    id: fontContainer

    required property EpubProperties epub
    readonly property bool useLargeLayout: fontContainer.width > 600

    ArkControls.Label {
        id: fontTitle
        x: Values.documentViewFormatTitleMargin
        y: Values.documentViewFormatTitleMargin
        text: qsTr("Font")
    }

    Grid {
        id: fontGrid
        anchors {
            top: fontTitle.bottom
            topMargin: Values.documentViewFormatGridMargin
            left: parent.left
            leftMargin: Values.documentViewFormatTitleMargin
            right: parent.right
            rightMargin: Values.documentViewFormatTitleMargin
            bottom: parent.bottom
            bottomMargin: Values.documentViewFormatTitleMargin
        }

        rows: 2
        columns: 2
        columnSpacing: useLargeLayout ? 0 : 40

        Repeater {
            model: ["EB Garamond", "Noto Sans", "Noto Mono", "Noto Serif"]
            delegate: Item {
                height: fontGrid.height / fontGrid.rows
                width: fontGrid.width / fontGrid.columns
                objectName: modelData

                Rectangle {
                    id: fontIndicator
                    anchors.verticalCenter: fontSample.verticalCenter
                    height: Values.navigatorContentListItemMargin
                    width: height
                    radius: height / 2
                    border.width: Values.outlineSize
                    border.color: Values.colorBlack
                    color: (fontContainer.epub.fontName === modelData) ? Values.colorBlack : "transparent"
                }

                Text {
                    id: fontSample
                    anchors {
                        baseline: parent.verticalCenter
                        left: fontIndicator.right
                        leftMargin: useLargeLayout ? Values.designGridVerticalSpacing : Values.designGridVerticalSpacing / 2
                    }
                    color: Values.colorBlack
                    text: modelData
                    font.family: modelData
                    font.pixelSize: useLargeLayout ? Values.fontSizeH1 : Values.fontSizeH1 * 3 / 4

                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var action = function () {
                            fontContainer.epub.setFontName(modelData);
                        }
                        confirmLayoutChange(action);
                    }
                }
            }
        }
    }
}
