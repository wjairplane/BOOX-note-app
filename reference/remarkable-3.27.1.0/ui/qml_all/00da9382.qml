import QtQuick
import common
import com.remarkable
import device.ui.controls

import ark.controls as ArkControls

ButtonBase {
    id: root

    // Special circular button used for
    // adding a page

    property alias border: background.border

    height: 120
    width: 120

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.foregroundColor
        radius: root.width
        antialiasing: root.antialiasing
    }

    ArkControls.Icon {
        id: _icon
        anchors.centerIn: parent
        source: "qrc:/ark/icons/page_add"
        size: ArkControls.Values.iconSize.medium
        color: root.backgroundColor
        antialiasing: root.antialiasing
    }
}
