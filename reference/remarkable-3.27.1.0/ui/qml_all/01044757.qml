import QtQuick

import xofm.libs.qtgui
import xofm.libs.dialogs

BaseView {
    id: root

    property var onAccepted
    property var onRejected
    property int numOfTags

    onOpened: (args) => {
        const { numOfTags, onAccepted, onRejected } = args;

        if (typeof onAccepted !== "function") {
            console.error("handleAccepted is not a function!" + typeof onAccepted);
        }
        if (onRejected && typeof onRejected !== "function") {
            console.error("handleRejected is not a function!" + typeof onRejected);
        }

        if (1 < numOfTags) {
            confirmDialog.description = qsTr("If you delete these tags, they'll be removed from all tagged content.");
        }

        root.numOfTags = numOfTags;
        root.onAccepted = onAccepted;
        root.onRejected = onRejected;
    }

    contentItem: Item {
        ConfirmChangeDialog {
            id: confirmDialog

            anchors.fill: parent

            title: qsTr("Delete %n tag(s)?", "", root.numOfTags)
            description: root.numOfTags > 1
                ? qsTr("If you delete these tags, they'll be removed from all tagged content.")
                : qsTr("If you delete this tag, it'll be removed from all tagged content.")
            confirmButtonText: qsTr("Delete", "confirm delete")
            rejectButtonText: qsTr("Cancel", "cancel delete")

            onAccepted: {
                root.onAccepted?.();
                root.windowNavigator.close();
            }

            onRejected: {
                root.onRejected?.();
                root.windowNavigator.close();
            }
        }
    }
}
