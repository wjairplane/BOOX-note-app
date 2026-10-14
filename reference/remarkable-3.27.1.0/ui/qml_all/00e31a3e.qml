import com.remarkable

import xofm.libs.settings // CellItemWrapper

CellItemWrapper {
    id: root

    function activate() {
        root.windowNavigator.open("settings/window/battery");
    }

    text: qsTr("Battery")
    status: qsTr("%1 \%").arg(BatteryManager.battery.percentage)
    onClicked: root.activate();
}
