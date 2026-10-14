import QtQuick
import QtQuick.Layouts
import com.remarkable
import common
import device.ui.controls
import device.ui.text
import device.view.documentview
import xofm.libs.gestures

import ark.tokens as ArkTokens
import ark.controls as ArkControls

Rectangle {
    id: root

    property int currentPage: Math.floor(scroll.contentY / scroll.height)
    readonly property int pageCount: Math.floor(scroll.contentHeight / scroll.height)
    signal close

    function nextPage() {
        if (currentPage < pageCount - 1) {
            currentPage++;
        }
    }
    function previousPage() {
        if (currentPage > 0) {
            currentPage--;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: ArkControls.Values.spacing.medium

        ArkControls.NavigationBar {
            id: navigationBar
            type: ArkTokens.NavigationBar.secondary
            width: parent.width
            Layout.fillWidth: true

            ArkControls.NavigationBar.Button {
                text: qsTr("Back")
                textPosition: ArkControls.Button.TextPosition.Right
                iconSource: "qrc:/ark/icons/chevron_left"
                onClicked: root.close()
            }
        }

        ArkControls.Title {
            type: ArkControls.Title.Large
            Layout.fillWidth: true
            Layout.leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
            Layout.rightMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
            text: qsTr("End user agreement reMarkable beta program")
            wrapMode: Text.WordWrap
        }

        ScrollArea {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
            Layout.rightMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
            Layout.bottomMargin: ArkControls.Values.margin.vertical.large
            Layout.topMargin: ArkControls.Values.spacing.large

            contentHeight: agreementText.height
            clip: true

            Text {
                id: agreementText
                width: parent.width
                text: markdownToHtml.html
                textFormat: Text.RichText
                font.pixelSize: 31
                color: Values.colorBlack
                wrapMode: Text.WordWrap

                MarkdownToHtml {
                    id: markdownToHtml
                    sourceFile: "qrc:/xofm/modules/releasechannel/agreement.md"
                    skipTitle: true
                    headerStyle: "font-family: 'Maison 'Neue'; text-align: center; margin-bottom: 80px"
                    unorderedListStyle: "margin-top: 35px"
                    orderedListStyle: "margin-top: 35px; margin-bottom: 40px"
                    paragraphStyle: "font-family: 'Maison Neue'; font-weight: 500; margin-top: 35px; font-size: %1px; line-height: 1.45".arg(Values.fontSizeBody1)
                    listElementStyle: "font-family: 'Maison Neue'; font-weight: 500; font-size: %1px; line-height: 1.45; margin-bottom: 10px".arg(Values.fontSizeBody1)
                }
            }
        }
    }
}
