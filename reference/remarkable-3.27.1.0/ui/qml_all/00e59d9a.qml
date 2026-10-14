import QtQuick

import xofm.libs.qtgui
import xofm.libs.wifi

import xofm.modules.wifi

BaseView {
    id: root

    required property NetworkEditor networkEditor

    onOpened: (args) => {
        networkEditor.clear();

        if (args.ssid) {
            networkEditor.loadNetwork(args.ssid);
        } else {
            networkEditor.startHidden();
        }
    }

    contentItem: NetworkEditorForm {
            editor: root.networkEditor
            onClose: root.windowNavigator.close()
            onAccept: root.windowNavigator.close()
    }

}
