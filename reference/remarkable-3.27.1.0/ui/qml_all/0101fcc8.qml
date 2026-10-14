import QtQuick
import QtQuick.Controls

import ark.controls as ArkControls

Control {
    id: root

    required property int batteryLevel
    required property bool charging
    property bool lowBatteryWarning: false
    property bool showBatteryText: false
    property int animationStep: 0

    property alias orientation: indicator.orientation

    onChargingChanged: {
        if (!root.charging) {
            root.animationStep = 0;
        }
    }

    Timer {
        id: timer
        interval: 1000
        running: root.charging
        repeat: root.animationStep < 5
        onTriggered: {
            if (root.charging) {
                indicator.showMaxBars(root.animationStep);
                root.animationStep++;
            }
        }
    }

    contentItem: ArkControls.BatteryIndicator {
        id: indicator
        showCharging: root.charging
        showWarning: false
        showValue: root.showBatteryText
        value: root.batteryLevel
        highlighted: root.lowBatteryWarning

    }
}
