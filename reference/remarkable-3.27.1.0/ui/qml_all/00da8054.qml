import QtQuick
import common

Item {
    id: root
    property int borderWidth: 7

    // ScreenShare border sections.
    // Draw as separate sections to avoid filling screen and hijacking input.
    Rectangle {
        id: leftBorder
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: borderWidth
        color: Values.colorBlack
        antialiasing: false
    }

    Rectangle {
        id: rightBorder
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: borderWidth
        color: Values.colorBlack
        antialiasing: false
    }
    Rectangle {
        id: topBorder
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: borderWidth
        color: Values.colorBlack
        antialiasing: false
    }
    Rectangle {
        id: bottomBorder
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: borderWidth
        color: Values.colorBlack
        antialiasing: false
    }
}
