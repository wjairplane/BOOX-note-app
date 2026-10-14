import QtQuick
import common
import device.ui.text

Item {
    id: panel
    objectName: "Panel"

    property string header: ""
    property string text: ""
    property int rightInset: 0
    property int margin: Values.navigatorSettingsItemMargin
    property int padding: 0
    property alias column: column
    property var textModel: []
    property bool showFrame: false
    property bool indentText: false
    property alias elide: titleText.elide
    readonly property int leftIndentMargin: titleText.size + Values.designGridMargin + panel.margin

    height: Math.max(column.height + Values.navigatorMargin + padding, Values.navigatorSidebarItemHeight)
    width: parent.width

    states: State {
        when: panel.showFrame

        AnchorChanges {
            target: _textItem
            anchors.left: column.left
        }
    }

    Column {
        id: column
        spacing: showFrame ? 50 : 20
        width: parent.width
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            rightMargin: panel.margin + rightInset
            leftMargin: panel.indentText ? panel.leftIndentMargin : panel.margin
        }

        IconTitle {
            id: titleText
            title: panel.header
            rowSpacing: Values.designGridVerticalSpacing
            width: _textItem.visible ? (_textItem.width + Values.designGridVerticalSpacing) : implicitWidth
            visible: panel.header.length > 0
        }

        TextParagraphSmall {
            id: _textItem
            width: parent.width
            text: panel.text
            lineHeight: Values.lineHeight
            visible: panel.text.length > 0
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            anchors.leftMargin: showFrame ? 20 : titleText.iconSize + titleText.rowSpacing
        }

        Repeater {
            model: textModel
            TextParagraph {
                text: textModel[index].text
                width: parent.width
                lineHeight: Values.lineHeight
                visible: text.length > 0
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }
}
