import QtQuick

// import com.remarkable // LinkProvider

import xofm.libs.qtgui
import xofm.libs.linkprovider
import xofm.libs.onboarding
import xofm.modules.integrations.calendar

import ark.controls as ArkControls

BaseView {
    id: root

    required property LinkProviderWrapper linkProvider
    required property CalendarSettings calendarSettings

    function openPairingFlow() {
        const pairingSetupRoute = (windowNavigator) => {
            windowNavigator.open("userfrontend/window/pairing-setup");
        }

        if (root.linkProvider.isOnline) {
            pairingSetupRoute(root.windowNavigator);
        } else {
            root.windowNavigator.open(
                "wifi/window/network-select",
                { onFinish: pairingSetupRoute }
            );
        }

        // We don't want to hide the button in this case, so calling close() explicitly
        root.close();
    }

    function closeAndCheckHideButton() {
        if (hideButtonCheckBox.checked) {
            root.calendarSettings.buttonVisible = false;
        }

        root.close();
    }

    function close() {
        root.windowNavigator.close();
    }

    contentItem: OnboardingDialogue {
        id: dialog

        initialModel: [{
            "image": "qrc:/onboarding/illustrations/meeting_note",
            "title": qsTr("Create meeting note"),
            "body": [
                { "description": qsTr("Start focused, stay engaged, and get organized with create meeting note.") },
                { "description": qsTr("You'll need a paired account and a Connect subscription to use this feature.") },
            ],
            "additionalItems": checkboxModel
        }]

        rightButtonText: qsTr("Pair your device")
        leftButtonText: qsTr("Close")
        closeOption: true
        onRightButtonClicked: root.openPairingFlow()
        onLeftButtonClicked: root.closeAndCheckHideButton()
        onFinished: root.closeAndCheckHideButton()
    }

    ObjectModel {
        id: checkboxModel
        ArkControls.CheckBox {
            id: hideButtonCheckBox

            width: parent?.width ?? 0
            checked: !root.calendarSettings.buttonVisible
            text: qsTr("Hide create meeting note button")
        }
    }
}
