import QtQuick

import xofm.libs.qtgui
import xofm.libs.onboarding

import xofm.modules.sharebyurl

import ark.controls as ArkControls

BaseView {
    id: root

    property var config
    required property ShareByUrlWrapper shareByUrlWrapper

    OnboardingStateProp.group: OnboardingManager.Group.Dialogs
    OnboardingStateProp.domain: ""
    OnboardingStateProp.key: "ShareByUrlOnboarding2"

    onOpened: (config) => {
        root.config = config;
        if (OnboardingStateProp.completed) {
            complete();
        }
    }

    function complete() {
        //TODO: do the thing
        shareByUrlWrapper.exportAndSend(root.config);
        root.windowNavigator.close();
    }

    contentItem: OnboardingDialogue {
        leftButtonText: qsTr("Cancel")
        rightButtonText: qsTr("Convert")
        onLeftButtonClicked: {
            root.windowNavigator.close();
        }
        onRightButtonClicked: {
            root.OnboardingStateProp.completed = true;
            root.complete();
        }
        initialModel: [
            {
                "image": "qrc:/onboarding/illustrations/convert_and_share",
                //: title in the onboarding dialogue
                "title": qsTr("Convert and share"),
                "body": [
                    //: the description of the feature in the onboarding dialogue - should mention the use of ai
                    { "description": qsTr("Convert and share uses AI to turn your notes into typed text, and sorts your annotated "
                                        + "documents into highlights and next steps. Your converted page is delivered to your email "
                                        + "inbox as a shareable link, and can be edited from any browser.") },
                ]
            }
        ]
    }
}
