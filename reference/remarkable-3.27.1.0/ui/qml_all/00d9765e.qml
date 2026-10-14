import QtQuick
import com.remarkable
import common
import device.ui.text

Item {
    id: settingsCheckBoxItem

    property bool selected: false
    property alias title: titleText.text
    property alias fontsize: titleText.font.pixelSize
    property alias description: descriptionText.text
    property string textColor: Values.colorWhite
    property int leftMargin: Values.navigatorHeaderTitleMargin
    signal clicked

    width: parent.width
    height: textsColumn.height + Values.fontSizeH2

    Column {
        id: textsColumn
        anchors {
            left: parent.left
            leftMargin: settingsCheckBoxItem.leftMargin
            verticalCenter: parent.verticalCenter
            right: switchText.left
        }

        TextHeaderRegular {
            id: titleText
            lineHeight: Values.lineHeight
            width: textsColumn.width
            color: settingsCheckBoxItem.textColor
        }

        TextParagraph {
            id: descriptionText
            lineHeight: Values.lineHeight
            color: settingsCheckBoxItem.textColor
            width: textsColumn.width
            wrapMode: Text.Wrap
        }
    }

    Rectangle {
        id: enabledSwitch
        readonly property real size: Values.fontSizeH2 * Values.lineHeight

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: Values.navigatorHeaderTitleMargin
        }

        height: size
        width: size * 2
        border.width: 4
        border.color: settingsCheckBoxItem.textColor
        color: "transparent"

        Rectangle {
            x: settingsCheckBoxItem.selected ? 0 : parent.height
            width: parent.size
            height: parent.size
            color: settingsCheckBoxItem.textColor
        }
    }

    TextParagraph {
        id: switchText
        text: settingsCheckBoxItem.selected ? qsTr("On") : qsTr("Off")
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: enabledSwitch.left
        anchors.rightMargin: Values.navigatorHeaderTitleMargin
        color: settingsCheckBoxItem.textColor
    }

    MouseArea {
        id: switchMouseArea
        anchors.fill: parent
        onPressed: settingsCheckBoxItem.clicked()
    }
}
