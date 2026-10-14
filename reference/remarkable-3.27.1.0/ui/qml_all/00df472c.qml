import QtQuick
import xofm.libs.qtgui
import xofm.libs.onboarding

BaseView {
    id: root

    required property var metrics

    onOpened: (args) => {
        metrics.opened();
    }

    contentItem: GestureCheatSheet {
        visible:true
        onBack: {
            metrics.closed();
            windowNavigator.close(root.objectName);
        }
    }
}
