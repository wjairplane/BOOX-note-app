import QtQuick

import com.remarkable
import common

Item {
    id: root

    anchors.fill: parent

    // Input
    required property Item viewItem
    required property SceneTileManager tileManager
    required property SceneController sceneController

    // Output
    property alias defaultMenu: defaultMenu
    property alias vkbMenu: vkbMenu

    // Internal
    readonly property var selectedParagraphStyle: root.sceneController && root.sceneController.textDocumentId
                                                  ? root.sceneController.textParagraphStyle : null
    readonly property var formattingOptions: [
        { "iconSource": "qrc:/ark/icons/formatting_title",      "style": ParagraphStyle.Type.Title,             "text": qsTr("Title") },
        { "iconSource": "qrc:/ark/icons/text_t_heading",        "style": ParagraphStyle.Type.Subheading,        "text": qsTr("Subheading") + " 1" },
        { "iconSource": "qrc:/ark/icons/formatting_subtitle",   "style": ParagraphStyle.Type.Subheading2,       "text": qsTr("Subheading") + " 2" },
        { "iconSource": "qrc:/ark/icons/formatting_paragraph",  "style": ParagraphStyle.Type.Paragraph,         "text": qsTr("Body text") },
        { "iconSource": "qrc:/ark/icons/formatting_bulletlist", "style": ParagraphStyle.Type.Bulletpoint },
        { "iconSource": "qrc:/ark/icons/formatting_number",     "style": ParagraphStyle.Type.NumberedList },
        { "iconSource": "qrc:/ark/icons/formatting_checkbox",   "style": ParagraphStyle.Type.CheckboxUnchecked }
    ]

    FormatMenu {
        id: defaultMenu
        visible: false
        viewItem: root.viewItem
        tileManager: root.tileManager
        sceneController: root.sceneController
        selectedParagraphStyle: root.selectedParagraphStyle
        formattingOptions: root.formattingOptions
    }

    FormatMenuVirtualKeyboard {
        id: vkbMenu
        visible: false
        sceneController: root.sceneController
        selectedParagraphStyle: root.selectedParagraphStyle
        formattingOptions: root.formattingOptions
        width: root.viewItem.width
        y: root.viewItem.height - Qt.inputMethod.keyboardRectangle.height - vkbMenu.height
    }
}
