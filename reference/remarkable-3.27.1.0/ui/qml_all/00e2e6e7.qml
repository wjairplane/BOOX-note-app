import QtQuick

import xofm.libs.qtgui
import xofm.libs.settings

CellItemWrapper {
    id: root

    required property string currentVersion

    function activate() {
        root.windowNavigator.open("softwareupdate/window/settings");
    }

    text: qsTr("Software")
    status: qsTr("Version %1").arg(currentVersion)
    onClicked: activate()
}
