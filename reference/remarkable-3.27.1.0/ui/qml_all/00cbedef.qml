import QtQuick
import xofm.libs.qtgui
import xofm.libs.gestures
import xofm.libs.devicescreen

import ark.controls as ArkControls

BaseView {
    id: root
    required property TouchArea touchArea
    readonly property real pixelsPerCm: DeviceScreenInfo.pixelsPerCm

    contentItem: Item {
        id: globalGestures
        property int quickSettingsGestureAreaWidth: Math.min(400, root.width / 3);
        property int quickSettingsGestureAreaHeight: dummyActionBar.height

        ArkControls.ActionBar {
            id: dummyActionBar
            visible: false
            enabled: false
        }

        Binding {
            target: root.touchArea
            property: "parent"
            value: root
        }
        TouchAreaSwipeFilter {
            objectName: "global-swipe-from-top"
            touchArea: root.touchArea
            distance: 0.3 * root.pixelsPerCm
            direction: Qt.point(0, 1)
            area: Qt.rect(0, 0, root.width - globalGestures.quickSettingsGestureAreaWidth, globalGestures.quickSettingsGestureAreaHeight)
            onTriggered: {
                // Not in use?
            }
        }

        TouchAreaSwipeFilter {
            objectName: "open-drawer"
            touchArea: root.touchArea
            distance: 0.3 * root.pixelsPerCm
            direction: Qt.point(0, 1)
            area: Qt.rect(0, 0, root.width, 200)
            fingers: 2
            onTriggered: {
                root.windowNavigator.open("documentdrawer/window/main");
            }
        }

        TouchAreaSwipeFilter {
            touchArea: root.touchArea
            objectName: "open-quick-settings"
            distance: 0.3 * root.pixelsPerCm
            direction: Qt.point(0, 1)
            area: Qt.rect(root.width - globalGestures.quickSettingsGestureAreaWidth, 0, globalGestures.quickSettingsGestureAreaWidth, globalGestures.quickSettingsGestureAreaHeight)
            onTriggered: {
                root.windowNavigator.open("settings/window/quicksettings");
            }
        }
    }
}
