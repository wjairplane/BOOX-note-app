import QtQuick
import com.remarkable
import common
import device.ui.controls

/**
    An button with icon in the Sidebar.
*/
IconButton {
    id: root

    property bool selected: false

    height: visible ? Values.navigatorSidebarItemHeight : 0
    invertOnClick: true

    focusFrame.z: parent.z + 1
    font.weight: Font.Medium
}
