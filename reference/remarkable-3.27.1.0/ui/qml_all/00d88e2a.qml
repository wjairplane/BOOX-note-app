import QtQuick
import common
import device.ui.text

Item {
    id: root

    // Marks the button as the designated one
    property bool primary: false

    // Set this to true when background is black to draw with inverted colors
    // The default is inherit from any inverted property set on a parent item.
    property bool inverted: invertedState()

    // Search for any "inverted" property set in a parent item
    // such as in Settings. If none is found, resolve to false
    function invertedState() {
        let parent = root.parent;
        while (parent.parent && parent["inverted"] === undefined) {
            parent = parent.parent;
        }
        return parent.inverted ?? false;
    }

    property color textColor: (inverted ^ primary) ? Values.colorWhite :
                                                     Values.colorBlack
    readonly property color highlightColor: inverted ? Values.colorWhite :
                                                       Values.colorBlack
    readonly property bool pressed: interactionArea.pressed

    property alias text: text.text
    property alias font: text.font
    property alias border: borderRectangle.border
    property color color: primary ? highlightColor : "transparent"
    property alias containsPress: interactionArea.containsPress
    property int labelMargin: 60
    property int minimumWidth: Values.minimumButtonWidth
    property int contentWidth: text.width + labelMargin * 2
    implicitWidth: Math.max(contentWidth, minimumWidth)
    implicitHeight: Values.buttonHeight

    signal clicked

    MouseArea {
        id: interactionArea
        anchors.fill: parent
        onClicked: root.clicked()
    }

    Rectangle {
        id: borderRectangle
        anchors.fill: parent
        color: root.color
        border.color: root.highlightColor
        border.width: Values.outlineSize
        antialiasing: root.antialiasing
    }

    FontMetrics {
        id: fontMetrics
        font: text.font
    }

    TextMetrics {
        id: textMetrics
        font: text.font
        text: text.text
    }

    TextHeaderRegular {
        id: text
        anchors.centerIn: parent
        color: root.textColor
        antialiasing: root.antialiasing
    }
}
