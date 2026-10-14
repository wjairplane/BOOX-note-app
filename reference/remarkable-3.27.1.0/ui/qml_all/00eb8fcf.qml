import QtQuick
import xofm.libs.settings

CellItemWrapper {
    id: root
    text: qsTr("reMarkable beta program")
    required property var uri
    onClicked: activate()
    function activate() {
        root.windowNavigator.open(uri);
    }
}
