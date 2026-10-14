import QtQuick
import QtQuick.Layouts
import ark.controls as ArkControls
import ark.tokens as ArkTokens

ArkControls.NotificationBar {
    id: root

    property bool inverted: false
    property alias text: statusText.text
    property alias progress: progressIndicator.value

    type: root.inverted ? ArkTokens.NotificationBar.primary : ArkTokens.NotificationBar.secondary

    Item {
        Layout.fillWidth: true
    }

    ArkControls.NotificationBar.Message {
        id: statusText
        type: root.type
        Layout.rightMargin: ArkControls.Values.padding.large
    }

    ArkControls.ProgressBar {
        id: progressIndicator
        visible: !!value
        type: root.inverted ? ArkTokens.ProgressBar.primary_inverted : ArkTokens.ProgressBar.primary
        Layout.rightMargin: ArkControls.Values.padding.large
        width: 144
    }
}
