import QtQuick
import QtQuick.Layouts
import common
import ark.controls as ArkControls

ArkControls.OnboardingDialog.Content {
    id: root

    property var body: []
    property var points: []
    property var additionalItems: []

    spacing: Values.isPortraitOrientation ? ArkControls.Values.spacing.large : ArkControls.Values.spacing.medium

    contentItem: ColumnLayout {
        spacing: ArkControls.Values.spacing.medium

        Repeater {
            model: root.body
            delegate: ArkControls.Body {
                required property var modelData
                text: modelData.description
                type: ArkControls.Body.Large
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }

        ArkControls.List {
            id: bodyList
            type: ArkControls.List.Type.Large
            model: root.points
            spacing: Values.isPortraitOrientation ? ArkControls.Values.spacing.medium : ArkControls.Values.spacing.small
        }

        Column {
            Layout.fillWidth: parent
            Repeater {
                model: root.additionalItems
            }
        }
    }
}
