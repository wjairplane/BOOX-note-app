import QtQuick
import com.remarkable
import common
import device.ui.text
import xofm.libs.onboarding

import ark.controls as ArkControls

Background {
    id: background
    color: "transparent"

    signal writeAnywayClicked

    function hide(){
    visible = false;
    }

    ObjectModel {
        id: extraContentModel
        ArkControls.CheckBox {
            id: warningCheckBox
            width: parent?.width ?? 0
            text: qsTr("Don't show this message again")
        }
    }

    ArkControls.OnboardingDialog {
        id: inactiveWarning
        anchors.fill: parent
        primaryButtonText: qsTr("Close")
        closeOption: false // we have one Close button, no need in another one

        contentItem: OnboardingPage {
            illustrationSource: "qrc:/onboarding/illustrations/cloud_limit_reached"
            title: qsTr("Cloud limit reached")
            body: [
                { description: qsTr("Without Connect, documents stop syncing after 50 days of inactivity. Reactivate cloud storage and sync documents across all devices by subscribing at my.remarkable.com.") }
            ]
            additionalItems: extraContentModel
        }

        onPrimaryClicked:{
            if (warningCheckBox.checked) {
                Settings.showInactiveWarning = false;
            }
            hide();
        }
    }
}
