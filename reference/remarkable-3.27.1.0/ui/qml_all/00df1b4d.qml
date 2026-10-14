import QtQuick

import xofm.libs.qtgui
import xofm.libs.dialogs

BaseView {
    id: root

    property var onAccepted
    property var onRejected

    onOpened: (args) => {
        const { onAccepted, onRejected } = args;

        if (typeof onAccepted !== "function") {
            console.error("handleAccepted is not a function!" + typeof onAccepted);
        }
        if (onRejected && typeof onRejected !== "function") {
            console.error("handleRejected is not a function!" + typeof onRejected);
        }

        root.onAccepted = onAccepted;
        root.onRejected = onRejected;
    }

    contentItem: Item {
        ConfirmChangeDialog {
            id: confirmDialog

            anchors.fill: parent

            title: qsTr("Delete permanently?")
            description: qsTr("If you delete the items, you won't be able to get them back.")
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
