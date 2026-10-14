import QtQuick

import com.remarkable
import common

import ark.controls as ArkControls
import QtQuick.Layouts
import xofm.modules.virtualkeyboard
import xofm.libs.epaper as Epaper
import xofm.libs.models

Rectangle {
    id: root

    // Input
    required property SceneController sceneController
    required property var selectedParagraphStyle
    required property var formattingOptions

    // Output
    readonly property int buttonSize: 80

    // Internal
    readonly property int topMargin: 2
    readonly property int leftMargin: 12
    readonly property int undoLeftMargin: 48
    readonly property int minimumFormatAreaLeftMargin: 120
    property bool canUndo: !!sceneController?.undoAvailable
    property bool canRedo: !!sceneController?.redoAvailable

    // Only display all formatting options if there is enough space, and it wouldn't look cramped
    // minimumFormatAreaLeftMargin is used as the value to determine what "cramped" is
    readonly property bool useCompactTextStyles: formatArea.width < root.minimumFormatAreaLeftMargin + root.formattingOptions.length * root.buttonSize

    readonly property var currentTextStyle: {
        if (root.selectedParagraphStyle) {
            for (const opt of root.formattingOptions) {
                if (opt.text && TextFormattingUtils.isFormattingButtonSelected(opt.style, root.selectedParagraphStyle)) {
                    return opt;
                }
            }
        }
        return null;
    }

    readonly property var firstTextStyle: root.formattingOptions.find(opt => !!opt.text)

    property bool textStyleFoldoutOpen: false

    onVisibleChanged: {
        if (!visible) {
            textStyleFoldoutOpen = false;
        }
    }

    height: buttonSize + topMargin
    color: "black"

    KeyboardButton {
        id: tabButton
        anchors {
            left: parent.left
            leftMargin: root.leftMargin
            bottom: parent.bottom
        }
        width: root.buttonSize
        iconSource: "qrc:/ark/icons/tab"
        onClicked: root.sceneController.indentParagraph()
    }

    KeyboardButton {
        id: undoButton
        objectName: "undoButton"
        anchors {
            left: tabButton.right
            leftMargin: undoLeftMargin
            bottom: parent.bottom
        }
        width: root.buttonSize
        enabled: root.canUndo
        iconSource: root.canUndo ? "qrc:/ark/icons/undo" : "qrc:/ark/icons/undo_disabled"
        onClicked: root.sceneController.undo()
    }

    KeyboardButton {
        id: redoButton
        objectName: "redoButton"
        anchors {
            left: undoButton.right
            bottom: parent.bottom
        }
        width: root.buttonSize
        enabled: root.canRedo
        iconSource: root.canRedo ? "qrc:/ark/icons/redo" : "qrc:/ark/icons/redo_disabled"
        onClicked: root.sceneController.redo()
    }

    Item {
        id: formatArea
        height: root.buttonSize

        anchors {
            left: redoButton.right
            right: closeButton.left
            bottom: parent.bottom
        }

        Row {
            id: menuRow
            anchors.centerIn: parent
            spacing: 0

            FormatMenuButton {
                id: textStyleButton
                visible: root.useCompactTextStyles
                inverted: !textStyleFoldout.visible || textStyleButton.selected
                buttonSize: root.buttonSize
                selectedStyle: root.currentTextStyle ? root.selectedParagraphStyle : null
                iconSource: (root.currentTextStyle ?? root.firstTextStyle).iconSource
                style: (root.currentTextStyle ?? root.firstTextStyle).style
                onClicked: {
                    root.textStyleFoldoutOpen = !root.textStyleFoldoutOpen;
                }
            }

            Repeater {
                model: ArrayModel {
                    array: root.formattingOptions.filter(opt => !opt.text || !root.useCompactTextStyles)
                    roles: ["iconSource", "style"]
                    identity: ["iconSource"]
                }
                FormatMenuButton {
                    inverted: true
                    buttonSize: root.buttonSize
                    selectedStyle: (textStyleFoldout.visible && root.currentTextStyle) ? null : root.selectedParagraphStyle
                    onClicked: (style) => {
                        root.sceneController.cycleParagraphStyle(style);
                        root.textStyleFoldoutOpen = false;
                    }
                }
            }
        }
    }

    MouseArea {
        id: foldoutOverlay
        parent: root.parent
        visible: root.textStyleFoldoutOpen && root.useCompactTextStyles
        anchors.fill: parent
        onClicked: root.textStyleFoldoutOpen = false

        ArkControls.Foldout {
            id: textStyleFoldout
            x: Math.max(0, formatArea.x + formatArea.width / 2 - menuRow.width / 2 - (textStyleFoldout.background?.border.width ?? 0))
            y: root.y - textStyleFoldout.height

            contentItem: ColumnLayout {
                spacing: 0

                Repeater {
                    model: root.formattingOptions.filter(opt => !!opt.text)
                    ArkControls.FoldoutItem {
                        required property var modelData

                        Layout.fillWidth: true
                        focusPolicy: Qt.NoFocus
                        label: modelData.text
                        iconSource: modelData.iconSource
                        selected: TextFormattingUtils.isFormattingButtonSelected(modelData.style, root.selectedParagraphStyle)
                        onClicked: {
                            root.sceneController.cycleParagraphStyle(modelData.style);
                            root.textStyleFoldoutOpen = false;
                        }
                    }
                }
            }
        }
    }

    KeyboardButton {
        id: closeButton
        // Delay allows the pressed state to complete
        // which helps with ghosting
        activationDelay: 50
        anchors {
            right: parent.right
            rightMargin: 12
            bottom: parent.bottom
        }
        iconSource: "qrc:/ark/icons/keyboard_hide"
        onActivated: Qt.inputMethod.hide()
    }

    Epaper.ScreenModeItem {
        id: screenMode
        anchors.fill: parent
        mode: Epaper.ScreenModeItem.Animation
        objectName: "vkb-format-menu"
    }
}
