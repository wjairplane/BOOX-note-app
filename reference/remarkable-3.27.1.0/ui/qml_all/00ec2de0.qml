import QtQuick

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ListView {
    id: root

    required property var languageSettings

    // The width you set for this component affects the visual center point of the delegates.
    // The width needs to be enough to counter-balance the checkmark icon.
    height: contentHeight
    interactive: false
    orientation: ListView.Vertical
    model: languageSettings.availableLanguageCodes
    delegate: ArkControls.SelectableItem {
        required property var modelData

        function activate() {
            root.languageSettings.languageCode = modelData;
        }

        type: ArkTokens.SelectableItem.secondary
        text: root.languageSettings.getLanguageDisplayName(modelData)
        checked: modelData === root.languageSettings.languageCode
        autoExclusive: true
        onClicked: activate()
    }
}
