import QtQuick
import com.remarkable
import device.ui.controls
import ark.tokens as ArkTokens

import xofm.libs.setup
import xofm.libs.settings

Item {
    id: root

    readonly property bool languageSelectionActive: seabirdLoader.active
    property real inputTopMargin

    InputComponent {
        anchors.horizontalCenter: parent.horizontalCenter
        y: inputTopMargin
        width: parent.width / 3
        title: ""
        loader: seabirdLoader
        selectedText: TypeFolioLanguageModel.language(Settings.inputLocale)
        onSelected: seabirdLoader.active = true
    }

    Loader {
        id: seabirdLoader
        anchors.fill: parent
        active: false
        sourceComponent: SelectionComponent {
            title: qsTr("Type Folio language")
            model: TypeFolioLanguageModel.languageNames()
            selectedIndex: TypeFolioLanguageModel.getLanguageNameIndex(TypeFolioLanguageModel.language(Settings.inputLocale))
            onSelected: (selection) => {
                Settings.inputLocale = TypeFolioLanguageModel.languageCode(selection);
                seabirdLoader.active = false
            }
            onRejected: seabirdLoader.active = false
        }
    }
}
