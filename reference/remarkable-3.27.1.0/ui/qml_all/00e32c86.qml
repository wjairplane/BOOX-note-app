import xofm.libs.settings // CellItemWrapper

CellItemWrapper {
    id: root

    function activate() {
        root.windowNavigator.open("settings/window/language");
    }

    text: qsTr("Language and keyboard")
    onClicked: root.activate()
}
