import xofm.libs.batterymanager
import xofm.libs.system

MinimalBatteryIndicator {
    id: root
    required property var batteryManager

    lowBatteryWarning: batteryManager.battery.percentage <= 10
    batteryLevel: batteryManager.battery.percentage
    charging: batteryManager.battery.chargerState === Battery.Charging
    showBatteryText: root.lowBatteryWarning
}
