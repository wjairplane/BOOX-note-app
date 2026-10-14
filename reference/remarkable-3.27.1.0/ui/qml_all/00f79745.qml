import QtQuick

import xofm.libs.settings

QuickSettingsToggle {
    id: root
    required property var screenShare
    selected: screenShare.serverActive
    iconSource: "qrc:/ark/icons/screen_share"
    onClicked: {
        if(screenShare.serverActive) {
            screenShare.stopServer();
        } else {
            root.windowNavigator.open("screenshare/window/onboarding");
        }
        root.windowNavigator.close("settings/window/quicksettings");
    }
}
