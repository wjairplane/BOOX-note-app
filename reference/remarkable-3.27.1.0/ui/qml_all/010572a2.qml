import QtQuick

import com.remarkable

import ark.tokens as ArkTokens
import ark.controls as ArkControls

import xofm.libs.qtgui

BaseView {
    id: root

    onOpened: (args) => {
                  const { notification } = args;
                  if (!notification){
                      console.warning("notification argument was not sent to window 'password/window/update-notification'");
                      rootWindow.windowNavigator.close("password/window/update-notification");
                      return;
                  }
                  changedPasswordModal.text = notification;
              }

    contentItem: Item {
        ArkControls.PlaceholderBar {
            id: placeholder
            visible: true
        }

        Rectangle {
            height: placeholder.height
            width: root.width
            color: "black"

            ArkControls.Body {
                id: changedPasswordModal
                anchors.fill: parent
                color: "white"
                type: ArkControls.Body.Large
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Timer {
            id: timeoutTimer
            interval: 3000
            repeat: false
            running: true
            onTriggered: {
                root.windowNavigator.close("password/window/update-notification")
            }
        }
    }
}
