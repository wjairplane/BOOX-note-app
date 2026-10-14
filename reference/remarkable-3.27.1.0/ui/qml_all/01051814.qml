import QtQuick
import QtQuick.Controls

import device.ui.controls

import ark.controls as ArkControls

Control {
    id: root

    required property string title
    required property string description
    required property string confirmButtonText
    required property string rejectButtonText
    property var acceptedAction

    signal accepted
    signal rejected

    CloseShortcut {
        objectName: "confirm-change-close"
        onActivated: root.rejected()
    }

    bottomPadding: root.height - dialog.implicitHeight

    background: MouseArea {
        onClicked: {
            root.rejected()
        }
    }

    contentItem: ConfirmDialog {
        id: dialog

        horizontalPadding: ArkControls.Values.margin.horizontal.xlarge
        verticalPadding: ArkControls.Values.spacing.xlarge + ArkControls.Values.spacing.large

        title: root.title
        description: root.description
        confirmButtonText: root.confirmButtonText
        rejectButtonText: root.rejectButtonText

        onAccepted: {
            acceptedAction?.();
            root.accepted();
        }
        onRejected: root.rejected()
    }
}
