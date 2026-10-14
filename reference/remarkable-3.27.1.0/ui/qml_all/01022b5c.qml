import QtQuick
import xofm.libs.qtgui
import xofm.libs.homescreen

Action {
    id: root
    objectName: "search-action"
    required property WindowNavigator windowNavigator

    supportedViews: ["myfiles", "filter", "notebook-filter"]
    iconSource: "qrc:/ark/icons/lens"

    onActionClicked: {
        root.windowNavigator.open("legacydevice/window/main", { showSearch: true });
    }

    Shortcut {
        enabled: root.visible && supportedViews.includes(root.currentView)
        objectName: "global-search-shortcut"
        sequence: "Ctrl+F"
        onActivated: root.actionClicked()
    }
}
