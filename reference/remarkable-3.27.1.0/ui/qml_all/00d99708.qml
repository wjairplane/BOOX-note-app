import QtQuick
import com.remarkable
import common
import device.ui.controls

IconButton {
    id: button

    property int targetIndex: -1

    width: parent.width
    height: visible ? Values.navigatorSidebarItemHeight : 0
    invertOnClick: true

    // Fit as much text on one line as possible in accessibility mode without losing too much padding
    leftPadding: Values.designGridVerticalGutter * (Values.accessibilityMode ? 0.75 : 1)
    rightPadding: Values.designGridVerticalGutter * (Values.accessibilityMode ? 0.5 : 1)
}
