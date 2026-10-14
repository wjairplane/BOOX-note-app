import com.remarkable // SystemMonitor

import xofm.libs.settings // CellItemWrapper

CellItemWrapper {
    id: root

    readonly property int _gb: 1024 * 1024 * 1024
    property real _usedGB: SystemMonitor.storageUsed / _gb
    property real _totalGB: SystemMonitor.storageTotal / _gb

    function activate() {
        root.windowNavigator.open("settings/window/storage");
    }

    text: qsTr("Storage")
    status: qsTr("%1 GB of %2 GB").arg(_usedGB.toFixed(2)).arg(_totalGB.toFixed(2))
    onClicked: root.activate()
}
