import QtQuick
import QtQuick.Controls

import xofm.libs.qtgui
import xofm.libs.controls

BaseView {
    id: root

    contentItem: InputBlocker {
        InfoDialog {
            id: infoDialog
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            onCloseClicked: {
                root.windowNavigator.close();
            }
        }
    }
    onOpened: (args) => {
        const { reason } = args;
        if(!reason) {
            return;
        }
        infoDialog.infoText = reason;
    }
}
