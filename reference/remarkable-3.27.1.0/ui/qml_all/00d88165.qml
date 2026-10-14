import QtQuick
import common

Rectangle {
    id: progressBar

    property real progress
    property color backgroundColor: Values.colorBlack
    property color foregroundColor: Values.colorWhite

    width: 160
    height: 10
    radius: height / 2

    Rectangle {
        anchors.fill: parent
        color: progressBar.backgroundColor
        radius: height / 2
        border.width: 1
        border.color: progressBar.foregroundColor

        Rectangle {
            anchors.left: parent.left
            width: parent.width * progressBar.progress
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            color: progressBar.foregroundColor
            radius: height / 2
        }
    }
}
