import QtQuick

import xofm.libs.qtgui
import xofm.libs.onboarding


BaseView {
    id: root

    OnboardingStateProp.group: OnboardingManager.Group.Dialogs
    OnboardingStateProp.domain: ""
    OnboardingStateProp.key: "CalendarIntegrationsOnboarding"

    onOpened: () => {
        if (root.OnboardingStateProp.completed) {
            root.close();
        }
    }

    function close() {
        root.windowNavigator.close();
    }

    contentItem: OnboardingDialogue {
        id: dialog

        initialModel: [{
            "image": "qrc:/onboarding/illustrations/meeting_note",
            "title": qsTr("Create meeting note is ready to use:"),
            "points": [
                qsTr("Tap a meeting from the list to create a meeting note"),
                qsTr("Meeting notes are added in a new, dedicated meeting notes folder"),
                qsTr("Meeting notebooks can be moved into any other folder"),
                qsTr("Notes for recurring meetings are added in the same notebook"),
            ]
        }]

        rightButtonText: qsTr("Show meetings")
        closeOption: true
        onFinished: {
            root.OnboardingStateProp.completed = true;
            root.close();
        }
    }
}
