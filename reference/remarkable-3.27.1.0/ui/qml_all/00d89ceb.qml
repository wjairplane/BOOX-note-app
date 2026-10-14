import QtQuick
import QtQuick.Layouts

import com.remarkable
import common
import device.ui.text
import device.ui.controls

import ark.tokens as ArkTokens
import ark.controls as ArkControls

/// ActionBar with (reject)button on the left, action buttons on the right and optional text in the center
DeviceKeyboardNavigationHandler {
    id: root
    objectName: "ActionBar"

    /// Label text will be shown in the center of the bar
    property string text

    /// Text of the left button
    property string rejectText: qsTr("Close")

    /*! List of components that will be shown on the right side of the bar.
        Use the ActionButton component to create a new action button.
    */
    property list<ActionButton> actions: []

    /// List of all navigation items
    readonly property alias navigationChildren: _actionbar.contentChildren

    /// Left button was clicked
    signal rejected()

    navigationModel: [_rejectButton]
    height: _actionbar.implicitHeight

    function findAction(text) {
        const buttons = _actionbar.contentChildren;
        for (let i in buttons) {
            let button = buttons[i];
            if (button.text === text) {
                return button;
            }
        }
        return null;
    }

    function findActionIndex(text) {
        const buttons = _actionbar.contentChildren;
        for (let i in buttons) {
            const button = buttons[i];
            if (button.text === text) {
                return i;
            }
        }
        return 0;
    }

    ArkControls.ActionBar {
        id: _actionbar
        width: parent.width
        title: root.text

        contentChildren: [...fixedContent, ...root.actions]

        property list<Item> fixedContent: [
            ArkControls.ActionBar.Button {
                id: _rejectButton
                text: rejectText
                property var navigationHandler: root
                onClicked: root.rejected()
            },
            Item {
                Layout.fillWidth: true
            }
        ]
        contentItem: RowLayout {
            property alias actionbar: root
            spacing: 0
            Repeater {
                model: root.contentModel
            }
        }
    }

    component ActionButton: ArkControls.ActionBar.ActionButton {
        readonly property ActionBar actionbar: parent?.actionbar
        property var navigationHandler: actionbar
    }
}
