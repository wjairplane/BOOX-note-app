import QtQuick
import common
import com.remarkable

import xofm.libs.qtgui
import xofm.libs.setup

import ark.controls as ArkControls

BaseView {
    id: root

    required property var settings
    required property var insecureSettings
    required property var passcodeHandler

    visible: !settings.seabirdSetup && KeyboardInfo.keyboardConnected
             && !passcodeHandler.userLocked

    contentItem: Item {
        anchors.fill: parent

        Setup {
            anchors.fill: parent
            initialPages: [ seabirdIntroPage, seabirdSuccessPage ]
            showBackButton: seabirdIntroPage.state !== "seabirdIntro" && !seabirdIntroPage.showingCustomBackButton

            onSetupFinished: {
                if (KeyboardInfo.keyboardConnected) {
                    settings.seabirdSetup = true;
                }
                if (root.visible) {
                    root.windowNavigator.close(root.objectName);
                }
            }
        }
    }

    onVisibleChanged: {
        if (!visible) {
            root.windowNavigator.close(root.objectName);
        }
    }

    Connections {
        target: KeyboardInfo
        enabled: root.windowLayout.ready
        function onKeyboardConnectedChanged() {
            if (!KeyboardInfo.keyboardConnected) {
                root.windowNavigator.close(root.objectName);
            }
        }
    }

    SeabirdIntroPage {
        id: seabirdIntroPage
        insecureSettings: root.insecureSettings
    }

    SetupBasePage {
        id: seabirdSuccessPage

        stateName: "SeabirdSuccess"

        ArkControls.SetupPage {
            anchors.fill: parent
            title: qsTr("Start typing without distractions")
            description: qsTr("Now you can bring focused typing and editing powers to your notes. Combine digital text with handwritten elements and capture new ideas using our mobile and desktop apps.")
            primaryButtonText: qsTr("Get started")
            onPrimaryClicked: seabirdSuccessPage.forward()
        }
    }
}
