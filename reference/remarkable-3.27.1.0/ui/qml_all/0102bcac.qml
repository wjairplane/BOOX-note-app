import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl

import common
import device.ui.text

import ark.controls as ArkControls

Rectangle {
    id: root
    property int layoutAlignment: Qt.AlignLeft
    required property string key

    implicitWidth: Math.max(72, text.visible ? text.implicitWidth : icon.implicitWidth)
    height: 72
    color: "transparent"
    border.color: Values.colorBlack
    radius: 4

    function isIconChar(text) {
        return text.startsWith('qrc');
    }

    ArkControls.Body {
        id: text
        accessibility: false
        type: ArkControls.Body.Medium
        visible: !icon.visible
        anchors.centerIn: parent
        padding: 16
        text: root.key ?? ""
    }

    IconImage {
        id: icon
        sourceSize {
            width: ArkControls.Values.iconSize.medium
            height: ArkControls.Values.iconSize.medium
        }
        source: isIconChar(root.key) ? root.key : ""
        anchors.centerIn: parent
        visible: isIconChar(root.key)
    }
}
