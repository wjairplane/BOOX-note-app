import QtQuick
import com.remarkable
import common

/**
    An item in the Sidebar, pre-configured to be highlighted when active.
*/
SidebarItem {
    id: sidebarItem

    active: false
    width: parent.width
    selected: active && enabled
    releasable: false
    delayedAntialiasing: false
}
