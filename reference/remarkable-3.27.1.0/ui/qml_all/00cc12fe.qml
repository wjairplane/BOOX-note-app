import QtQuick
import QtQuick.Controls

import xofm.libs.qtgui
import xofm.libs.controls

BaseView {
    id: root

    contentItem: InputBlocker {

        SoftwareUpdateDialog {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            onCancelClicked: {
                root.windowNavigator.close();
            }

            onCheckForUpdatesClicked: {
                root.windowNavigator.open("softwareupdate/window/settings");
            }
        }
    }
}
