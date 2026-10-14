import xofm.libs.settings // CellItemWrapper

CellItemWrapper {
    id: root

    required property var retailSettings

    function activate() {
        root.windowNavigator.open("retail/window/download");
    }

    text: qsTr("Download new library")
    onClicked: activate()
}
