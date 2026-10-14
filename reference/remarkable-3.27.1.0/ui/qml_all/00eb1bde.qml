import xofm.libs.qtgui // BaseView
import xofm.libs.onboarding // OnboardingDialogue

BaseView {
    id: root

    onOpened: (args) => {
        const { imageUrl, title, bodyList } = args;

        dialogue.initialModel = [{
            "image": imageUrl ?? "",
            "title": title ?? "",
            "body": bodyList?.map(item => ({ "description": item })) ?? [],
        }];
    }

    contentItem: OnboardingDialogue {
        id: dialogue
        onQuit: root.windowNavigator.close();
        onFinished: root.windowNavigator.close();
        initialModel: []
    }
}
