import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls

ArkControls.ActionBar {
    property list<ArkControls.ActionBar.ActionButton> actionButtons
    property list<Item> fixedButtons: [
        ArkControls.ActionBar.Button {
            text: qsTr("Cancel")
            onClicked: cancelClicked()
        },
        Item {
            Layout.fillWidth: true
        }
    ]

    signal cancelClicked

    function findAction(text) {
        for (const btn of actionButtons) {
            if (btn.text === text) {
                return btn;
            }
        }
        return null;
    }

    contentData: fixedButtons.concat(actionButtons)
}
