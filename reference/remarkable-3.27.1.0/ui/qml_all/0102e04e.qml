import QtQuick
import xofm.libs.qtgui
import common

import ark.tokens as ArkTokens
import ark.controls as ArkControls

BaseView {
    id: root
    required property var onboardingActive
    contentItem: Background {
        ArkControls.SetupPage {
            anchors.fill: parent
            title: qsTr("You're good to go")
            description: qsTr("The security of paper tablet has been strengthened. You can update your passcode from Security settings any time.")
            primaryButtonText: qsTr("Continue")
            onPrimaryClicked: {
                root.windowNavigator.close();
                root.onboardingActive.value = false;
            }
            Image {
                source: "qrc:/setup/qml/images/summary_portrait"
                anchors.centerIn: parent
            }
        }
    }
}
