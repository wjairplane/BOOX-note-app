import xofm.libs.qtgui
import xofm.libs.onboarding

BaseView {
    id: root

    property string service: "rm" // Default service, can be overridden

    OnboardingStateProp.group: OnboardingManager.Group.Dialogs
    OnboardingStateProp.domain: ""
    OnboardingStateProp.key: "Integrations"

    onOpened: (args) => {
        if(OnboardingStateProp.completed) {
            root.windowNavigator.close();
            return;
        }
        const { service } = args;

        if(!!service) {
            root.service = service;
            return;
        }
    }

    contentItem: OnboardingDialogue {
        initialModel: [{
            "image": "qrc:/onboarding/illustrations/integrations",
            "title": qsTr("Content from %1").arg(service !== "rm" ? service : qsTr("Integration")),
            "body": [
               { "description": qsTr("With this integrated service, you have access to all your documents in one place.") },
               { "description": qsTr("<b>Press and hold</b> an item for <b>2 seconds</b> and make a duplicate of any PDF and ebook, to download, browse, and edit in My files.") } ]
        }]
        onFinished: {
            root.OnboardingStateProp.completed = true;
            root.windowNavigator.close();
        }
    }

}
