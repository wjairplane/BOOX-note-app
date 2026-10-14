import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import xofm.libs.controls   // InputBlocker

import ark.tokens as ArkTokens
import ark.controls as ArkControls

Control {
    id: root

    required property string title
    required property string description
    required property string confirmButtonText
    required property string rejectButtonText

    signal accepted
    signal rejected

    background: InputBlocker {
        color: "black"
    }

    contentItem: ColumnLayout {
        id: column

        spacing: ArkControls.Values.spacing.xlarge

        ColumnLayout {
            id: textColumn

            spacing: ArkControls.Values.spacing.medium

            ArkControls.Title {
                type: ArkControls.Title.Large
                text: root.title
                color: "white"
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            ArkControls.Body {
                type: ArkControls.Body.Medium
                text: root.description
                color: "white"
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }

        Row {
            id: buttonsRow
            spacing: ArkControls.Values.spacing.medium
            Layout.fillWidth: true

            ArkControls.Button {
                id: rejectButton
                type: ArkTokens.Button.primary_inverted
                text: root.rejectButtonText
                onClicked: root.rejected()
                width: 346
            }

            ArkControls.Button {
                id: confirmButton
                type: ArkTokens.Button.secondary_inverted
                text: root.confirmButtonText
                onClicked: root.accepted()
                width: 346
            }
        }
    }
}
