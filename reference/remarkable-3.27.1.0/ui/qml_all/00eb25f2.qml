import xofm.libs.settings // CellItemWrapper

CellItemWrapper {
    id: root

    required property var retailSettings

    function activate() {
        if (root.retailSettings.enabled) {
            root.windowNavigator.open("retail/window/exit");
            return;
        }
        root.windowNavigator.open("retail/window/enter");
    }

    text: qsTr("Retail mode")
    onClicked: activate();
}
