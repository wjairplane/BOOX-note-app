import QtQuick

import xofm.libs.qtgui
import xofm.libs.batterymanager
import xofm.modules.password

BaseView {
    id: root

    required property Password password
    required property int pukLength
    required property ShutdownCommand shutdownCommand

    onOpened: (args) => {
                  const { title } = args;
                  if (title) {
                      challenge.title = title;
                  }
              }

    contentItem: ChallengePassword {
        id: challenge
        password: root.password
        windowNavigator: root.windowNavigator
        pukLength: root.pukLength
        shutdownCommand: root.shutdownCommand
    }
}
