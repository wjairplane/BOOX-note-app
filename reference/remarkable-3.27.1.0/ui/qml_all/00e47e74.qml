import QtQuick

import xofm.libs.controls

import ark.tokens as ArkTokens
import ark.controls as ArkControls

InputBlocker {
    id: root
    property alias model: gridView.model
    property alias selectedIndex: gridView.selectedIndex
    property int formatMenuHeight: 0
    color: "black"
    property var display: (text) => { return text; }

    // Used for tests
    property alias view: gridView

    signal selected(var selection)
    signal closed()

    KeyboardButton {
        id: closeButton
        anchors {
            right: parent.right
            rightMargin: 12
            top: parent.top
            topMargin: 8
        }
        text: qsTr("Close")
        onClicked: root.closed()
    }

    GridView {
        id: gridView

        property int selectedIndex

        anchors.fill: parent
        topMargin: root.formatMenuHeight + ArkControls.Values.spacing.small
        bottomMargin: ArkControls.Values.spacing.small
        leftMargin: ArkControls.Values.margin.horizontal.xlarge
        rightMargin: ArkControls.Values.margin.horizontal.xlarge

        flow: GridView.FlowTopToBottom
        cellWidth: width / 5
        interactive: false
        cacheBuffer: 0
        cellHeight: 47
        delegate: Item {
            id: item
            height: gridView.cellHeight
            width: gridView.cellWidth
            readonly property bool selected: gridView.selectedIndex === index

            Rectangle {
                id: selection
                anchors.fill: parent
                color: item.selected ? "white" : "black"
                Text {
                    id: method
                    font.pixelSize: 28
                    text: qsTranslate("LanguageAndKeyboard", display(modelData))
                    font.capitalization: Font.Capitalize
                    color: selected ? "black" : "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 28
                    elide: Text.ElideLeft
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        gridView.selectedIndex = index;
                        root.selected(modelData);
                    }
                }
            }
        }
    }
}
