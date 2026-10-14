import QtQuick
import common
import com.remarkable

KeyboardNavigationHandler {
    id: handler
    horizontalListViewNavigation: DeviceInfo.deviceType === DeviceInfo.RM100

    // This used to have the code below, but it caused issues deep in
    // qtdeclarative ... qqmlconnections.cpp where the function was
    // mapped to a null pointer. Replacing Connections with a binding avoids the crash.
    // Reported upstream: https://qt-project.atlassian.net/browse/QTBUG-143361
    //
    // Connections {
    //     target: KeyboardInfo
    //     function onKeyboardConnectedChanged() {
    //         if (!KeyboardInfo.keyboardConnected) {
    //             handler.resetFocusIndex();
    //         }
    //     }
    // }

    readonly property bool keyboardConnected: KeyboardInfo.keyboardConnected
    onKeyboardConnectedChanged: {
        if (!keyboardConnected) {
            // Invalidate all selections if the keyboard is
            // disconnected. We do nothing when a keyboard is
            // connected as the navigation is initiated with
            // cursor key input anyway.
            handler.resetFocusIndex();
        }
    }
}
