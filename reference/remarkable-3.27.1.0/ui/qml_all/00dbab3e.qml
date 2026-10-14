import QtQuick

import common

import ark.controls as ArkControls

Rectangle {
    id: retailDemoIndicator

    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right

    color: Values.colorWhite

    ArkControls.Title {
        type: ArkControls.Title.Medium
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Retail demo")
    }
}
