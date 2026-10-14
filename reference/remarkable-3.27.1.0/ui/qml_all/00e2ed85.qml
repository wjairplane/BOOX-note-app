import xofm.libs.qtgui
import xofm.libs.onboarding
import QtQuick
import QtQml.Models
import xofm.modules.softwareupdate
import ark.controls as ArkControls

BaseView {
    id: root

    required property var outdatedSoftware

    readonly property string blockedText: qsTr("You have an outdated version of the software. Enable updates in <b>Software settings &gt; Advanced</b> to continue syncing.")

    function close() {
        if (doNotShowAgainCheckBox.checked) {
            root.outdatedSoftware.disableWindowForCurrentVersion();
        }
        root.windowNavigator.close("softwareupdate/window/outdated-software");
    }

    ObjectModel {
        id: extraContentModel
        ArkControls.CheckBox {
            id: doNotShowAgainCheckBox
            width: parent?.width ?? undefined
            text: qsTr("Don't show this message again")
        }
    }

    contentItem: OnboardingDialogue {
        contentItem: OnboardingPage {
            illustrationSource: "qrc:/onboarding/illustrations/automatic_sync"
            //: Dialog title to prompt for updating the software. The dialog has limited width so translations should be short.
            title: qsTr("Get the latest software")
            body: [
                { "description": root.blockedText }
            ]
            additionalItems: extraContentModel
        }
        onQuit: {
            root.close()
        }
        onFinished: {
            root.close()
        }
    }
}
