import QtQuick
import common
import com.remarkable
import device.global

import xofm.libs.setup
import xofm.libs.qtgui
import xofm.libs.ghostbuster
import xofm.libs.onboarding

import ark.tokens as ArkTokens
import xofm.libs.epaper as Epaper

BaseView {
    id: root

    required property var setupPages
    required property var settings
    required property var insecureSettings
    required property var ghostBuster
    required property bool contentModeOnInputScreens

    function mapModelToArray() {
        var array = [];
        for (let i = 0; i < widgets.count; ++i) {
            array.push(widgets.objectAt(i).children[0]);
        }
        return array;
    }

    Instantiator {
        id: widgets
        model: setupPages

        delegate: WidgetLoader {
        }
    }

    contentItem: Setup {
            id: setup
            insecureSettings: root.insecureSettings
            focus: true
            anchors.centerIn: parent
            width: rotation % 180 === 0 ? parent.width: parent.height
            height: rotation % 180 === 0 ? parent.height : parent.width
            initialPages: root.mapModelToArray()
            windowLayout: root.windowLayout

            onSetupFinished: {
                settings.setupState = "Intro";
                Values.updateScreen = false;
                insecureSettings.setup = false;
                settings.setValue(settings.OnboardingUpdateScreen, Values.updateScreen);
                OnboardingManager.setCompletedForAllKeys(false);

                ghostBuster.viewChange(GhostBuster.SetupCompleted);
                root.windowNavigator.close(root.objectName);
            }
    }

    Epaper.ScreenModeItem {
        // Show onboarding with maximum quality and minimal ghosting
        anchors.fill: parent
        visible: {
            if (root.contentModeOnInputScreens) {
                return true;
            }
            return setup.currentPage !== "Pairing" && setup.currentPage !== "PasscodePage";
        }
        mode: Epaper.ScreenModeItem.Content
        objectName: "setupscreenmode"
        z: 1
    }
}
