import QtQuick
import xofm.libs.qtgui
import xofm.libs.onboarding
import com.remarkable
import device.ui.controls

import xofm.libs.settings

BaseView {
    id: root

    required property var metrics
    property var callback

    readonly property var selectLanguage: ObjectModel {
        InputComponent {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent ? parent.width : 0
            title: qsTr("Handwriting conversion language")
            loader: handwritingLoader
            selectedText: HandwritingLanguageModel.language(Settings.handwritingConversionLanguage)
            onSelected: handwritingLoader.active = true
        }
    }

    OnboardingStateProp.group: OnboardingManager.Group.Dialogs
    OnboardingStateProp.domain: ""
    OnboardingStateProp.key: "ConversionLanguage"

    onOpened: (args) => {
        const { onFinished } = args;
        root.callback = onFinished;

        if (OnboardingStateProp.completed) {
            root.callback?.();
            root.windowNavigator.close();
        }
    }


    contentItem: OnboardingDialogue {
        id: onboarding
        initialModel:[
            {
                image: "qrc:/onboarding/illustrations/hwc",
                title: qsTr("Handwriting language"),
                body: [
                    { "description": qsTr("Convert your notes into text in the language you use most often (in addition to English). Change it in Settings at any time.")}
                ],
                additionalItems: root.selectLanguage
            } ]
        leftButtonText: qsTr("Cancel")
        rightButtonText: qsTr("Confirm")
        onFinished: {
            root.OnboardingStateProp.completed = true;
            root.callback?.();
            root.windowNavigator.close(root.objectName);
        }
        onQuit: {
            root.windowNavigator.close(root.objectName);
        }
    }

    Loader {
        id: handwritingLoader
        anchors.fill: parent
        active: false
        sourceComponent: SelectionComponent {
            title: qsTr("Handwriting conversion language")
            model: HandwritingLanguageModel.languageNames()
            selectedIndex: HandwritingLanguageModel.getLanguageNameIndex(HandwritingLanguageModel.language(Settings.handwritingConversionLanguage))
            onSelected: (selection) => {
                Settings.handwritingConversionLanguage = HandwritingLanguageModel.languageCode(selection);
                root.metrics.hwcLanguageChanged(Settings.handwritingConversionLanguage);
                handwritingLoader.active = false
            }
            onRejected: handwritingLoader.active = false
        }
    }
}
