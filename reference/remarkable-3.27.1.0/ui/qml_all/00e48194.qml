import QtQuick

import ark.controls as ArkControls

MouseArea {
    id: root

    // text takes presedence over icon, there should only be one
    property string iconSource
    property string text
    property int activationDelay: 0
    signal activated() // Emitted when activationDelay > 0

    implicitHeight: 80
    implicitWidth: Math.max(icon.width, caption.implicitWidth) + 32 * 2

    // Use outline for pressed state to reduce ghosting
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        color: "black"
        border.color: "white"
        border.width: root.containsPress ? 3 : 0
    }

    Timer {
        id: delayTimer
        interval: root.activationDelay
        onTriggered: root.activated()
    }

    onClicked: {
        if (root.activationDelay > 0) {
            delayTimer.start();
        }
    }

    ArkControls.Icon {
        id: icon
        color: "white"
        anchors.centerIn: parent
        source: root.iconSource
        visible: !caption.visible
        antialiasing: false
    }

    ArkControls.Label {
        id: caption
        type: ArkControls.Label.Medium
        color: "white"
        anchors.centerIn: parent
        text: root.text
        visible: !!text
        antialiasing: false
        accessibility: false
    }
}
