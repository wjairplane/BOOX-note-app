import QtQuick

import common
import device.ui.text

SidebarItem {
    id: root

    property bool showBorder: true
    property string errorText: ""
    property string description: ""
    readonly property bool hasError: root.errorText !== ""
    readonly property bool hasDescription: root.description !== ""

    releasable: false
    caption: {
        if (root.hasError) {
            return root.errorText;
        }
        if (root.hasDescription) {
            return root.description;
        }
        return "";
    }
    font.pixelSize: Values.fontSizeH3
    width: Values.navigatorSidebarWidth

    Rectangle {
        visible: showBorder
        width: parent.width
        height: Values.outlineSize
        color: Values.colorBlack
        anchors.bottom: parent.bottom
    }
}
