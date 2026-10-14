import QtQuick

import com.remarkable // Templates

import device.ui.headers

import xofm.libs.dialogs


ActionBar {
    id: root

    required property var templateForActions

    rejectText: qsTr("Cancel")

    signal deleteTemplate(var templateToDelete)

    actions: [
        ActionBar.ActionButton {
            text: qsTr("Delete")
            iconSource: "qrc:/ark/icons/trashcan"
            onClicked: root.deleteTemplateAction()
            visible: true
        }
    ]

    ConfirmChangeDialog {
        id: confirmDelete
        visible: false
        anchors.fill: parent

        rejectButtonText: qsTr("Cancel", "cancel delete")
        title: qsTr("Delete template %1?").arg(templateForActions?.name ?? "")
        description: qsTr("If you delete this template it will be removed from the documents using it") // TODO: needs copy
        confirmButtonText: qsTr("Delete")

        onRejected: {
            confirmDelete.visible = false;
        }
        onAccepted: {
            root.deleteTemplate(templateForActions);
            confirmDelete.visible = false;
        }

    }

    function deleteTemplateAction() {
        confirmDelete.visible = true;
    }
}
