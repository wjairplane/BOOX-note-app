import QtQuick

import ark.controls as ArkControls

Rectangle {
    id: root

    property bool busy: false
    property int maxExpectedDuration: 3000 // milliseconds
    property double value: 0
    property alias label: progressText.text

    visible: root.busy
    color: "black"
    height: 72
    anchors {
        bottom: parent.bottom
        right: parent.right
        left: parent.left
    }

    ArkControls.Icon {
        id: loadIcon
        anchors {
            verticalCenter: parent.verticalCenter
            right: progressText.left
            rightMargin: 15
        }
        size: ArkControls.Values.iconSize.small
        color: "white"
        source: "qrc:/ark/icons/padlock"
    }

    ArkControls.Body {
        id: progressText
        type: ArkControls.Body.Medium
        anchors {
            right: progressBar.left
            rightMargin: 15
            verticalCenter: parent.verticalCenter
        }
        color: "white"
    }

    Rectangle {
        id: progressBar
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 30
        }
        width: 160
        height: 10
        radius: height/2

        Rectangle {
            height: 10
            width: parent.width
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            color: "black"
            radius: height/2
            border.width: 1
            border.color: "white"

            Rectangle {
                anchors.left: parent.left
                width: {
                    if (value > 1)
                        return 1;
                    if (value < 0)
                        return 0;
                    return Math.round(parent.width * root.value)
                }
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                radius: height/2
            }
        }
    }

    Timer {
        id: timer
        interval: 250
        running: root.visible
        repeat: true
        onTriggered: {
            root.value += 1/(root.maxExpectedDuration/timer.interval);
        }
    }
}
