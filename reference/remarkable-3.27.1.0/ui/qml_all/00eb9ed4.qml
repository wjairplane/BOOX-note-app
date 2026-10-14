import QtQuick
import QtQuick.Controls

import xofm.libs.qtgui
import xofm.libs.onboarding
import com.remarkable
import device.ui.controls
import device.global

BaseView {
    id: root

    required property var passcodeHandler

    onOpened: () => {
                cheatSheet.currentIndex = Global.documentViewLoader?.item?.document ? ShortcutCheatSheet.Tab.Editing : ShortcutCheatSheet.Tab.Navigation
              }

    Connections {
        target: passcodeHandler
        function onLockChanged(locked) {
            if(locked) {
                root.windowNavigator.close();
            }
        }
    }

    contentItem: FocusScope {

        CloseShortcut {
            onActivated: root.windowNavigator.close()
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.windowNavigator.close()
        }

        ShortcutCheatSheet {
            id: cheatSheet
            focus: true
            onClose: root.windowNavigator.close()
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }
    }
}
