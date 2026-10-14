import QtQuick
import common

import device.ui.controls

import xofm.libs.controls
import xofm.libs.settings

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.modules.wifi
import xofm.libs.form

Background {
    id: root

    focus: true

    required property NetworkEditor editor

    signal close
    signal accept

    enum View {
        Form,
        Selection
    }

    QtObject {
        id: detail

        property int currentView: NetworkEditorForm.View.Form
        property FormField currentField: null

        function focusBestField() {
            var index = editor.fieldModel.nextSelectableIndex();
            if (index < 0) return;
            listView.currentIndex = index;

            var item = listView.currentItem;
            if (item?.item?.focusInput) {
                item.item.focusInput();
            }
        }

        function openSelection(field) {
            currentField = field;
            currentView = NetworkEditorForm.View.Selection;
        }

        function closeSelection(selectedOption) {
            if (selectedOption && currentField !== null) {
                currentField.value = selectedOption;
            }
            currentField = null;
            currentView = NetworkEditorForm.View.Form;
            focusBestField();
        }
    }

    Connections {
        target: root.editor
        function onExitEditor() {
            root.accept();
        }
    }

    ArkControls.NavigationBar {
        id: navBar
        type: ArkTokens.NavigationBar.secondary

        ArkControls.NavigationBar.Button {
            text: qsTr("Back")
            textPosition: ArkControls.Button.TextPosition.Right
            iconSource: "qrc:/ark/icons/chevron_left"
            onClicked: root.close()
        }
    }

    ScrollArea {
        id: flickable
        anchors {
            top: navBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        contentWidth: width
        contentHeight: bottomMarker.y + (Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0)

        enableScrollbar: true
        permanentScrollbar: true

        Column {
            id: headerColumn
            width: parent.width
            spacing: ArkControls.Values.spacing.medium
            anchors {
                top: parent.top
                topMargin: ArkControls.Values.margin.vertical.large - navBar.height
            }

            ArkControls.Title {
                width: parent.width
                type: ArkControls.Title.XLarge
                text: qsTr("Connect to Wi-Fi");
                textFormat: Text.StyledText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                horizontalAlignment: Text.AlignHCenter
            }

            ArkControls.Body {
                width: parent.width
                type: ArkControls.Body.Large
                text: {
                    switch (root.editor.mode) {
                    case EditorTypes.ConfigureMode.Manual:
                        return qsTr("Enter details for other network");
                    case EditorTypes.ConfigureMode.Edit:
                    case EditorTypes.ConfigureMode.FromNetwork:
                        if (root.editor.passwordOnlyView) {
                            //: %1 is substitute for the SSID name
                            //: Retain non-breaking space `&#160;` so that "Enter password for" or its translation always appear together on the same line
                            return qsTr("Enter password for %1").arg(root.editor.ssid);
                        }
                        //: %1 is substitute for the SSID name
                        //: Retain non-breaking space `&#160;` so that "Enter details for" or its translation always appear together on the same line
                        return qsTr("Enter&#160;details&#160;for %1").arg(root.editor.ssid);
                    }
                }

                textFormat: Text.StyledText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Column {
            id: formColumn
            anchors {
                top: headerColumn.bottom
                // UX reason, we are pushing the password field slightly more into the center of the screen when it is the only field
                topMargin: root.editor.passwordOnlyView ? ArkControls.Values.margin.vertical.large : ArkControls.Values.margin.vertical.small
                horizontalCenter: parent.horizontalCenter
            }
            width: Values.fixedWidthInputField
            spacing: ArkControls.Values.spacing.xlarge

            readonly property int fieldHeight: 120

            ListView {
                id: listView
                width: formColumn.width
                height: contentHeight
                interactive: false
                spacing: ArkControls.Values.spacing.large
                model: root.editor.fieldModel

                onCountChanged: detail.focusBestField()

                delegate: Component {
                    Loader {
                        required property FormField field
                        required property int index

                        id: fieldDelegate
                        width: formColumn.width

                        sourceComponent: {
                            if (!field) return null;
                            switch (field.type) {
                            case FormField.Type.Text:
                                return textFieldComponent;
                            case FormField.Type.Password:
                                return passwordFieldComponent;
                            case FormField.Type.Selection:
                                return selectionFieldComponent;
                            default:
                                return textFieldComponent;
                            }
                        }
                    }
                }
            }

            ArkControls.Button {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 432
                visible: root.editor.fieldModel.allFieldsValid
                text: qsTr("Connect")
                type: ArkTokens.Button.primary
                onClicked: root.editor.connect()
            }
        }

        Item {
            id: bottomMarker
            anchors.top: formColumn.bottom
            anchors.topMargin: ArkControls.Values.margin.vertical.xlarge
        }
    }

    Component {
        id: textFieldComponent
        Column {
            width: formColumn.width

            function focusInput() {
                textInput.forceActiveFocus();
            }

            ArkControls.Label {
                id: textLabel
                type: ArkControls.Label.Medium
                text: field?.label ?? ""
            }

            ArkControls.InputField {
                id: textInput
                width: parent.width
                text: field?.value ?? ""
                inputMethodHints: Qt.ImhNoAutoUppercase
                onTextChanged: if (field) field.value = text
                onAccepted: root.editor.connect()
            }

            ArkControls.Label {
                width: parent.width
                text: field && !field.passesValidation && field.errorHint && root.editor.showErrorHints ? field.errorHint : " "
            }
        }
    }

    Component {
        id: passwordFieldComponent
        Column {
            width: formColumn.width

            function focusInput() {
                passwordInput.forceFocus();
            }

            PasswordInputField {
                id: passwordInput
                width: parent.width

                titleText: field?.label ?? ""
                text: field?.value ?? ""
                showPassword: false
                onTextChanged: if (field) field.value = text
                onAccepted: root.editor.connect()
                label: field?.errorHint
                labelVisible: field && !field.passesValidation && field.errorHint && root.editor.showErrorHints
            }
        }
    }

    Component {
        id: selectionFieldComponent
        Column {
            width: formColumn.width

            ArkControls.Cell {
                width: formColumn.width
                ArkControls.CellItem {
                    text: field?.label ?? ""
                    status: field?.value ? field.value : qsTr("Select option")
                    onClicked: if (field) detail.openSelection(field)
                }
            }

            ArkControls.InfoMessage {
                width: parent.width
                visible: field && !field.passesValidation && field.errorHint && root.editor.showErrorHints
                type: ArkTokens.InfoMessage.primary
                iconSource: "qrc:/ark/icons/information_circle"
                message: field?.errorHint ?? ""
            }
        }
    }

    Loader {
        id: selectionOverlay
        anchors.fill: parent
        active: detail.currentView === NetworkEditorForm.View.Selection
        sourceComponent: SelectionComponent {
            title: detail.currentField?.label ?? ""
            selectedIndex: detail.currentField?.options.indexOf(detail.currentField?.value) ?? -1
            model: detail.currentField?.options ?? []
            onSelected: (option) => detail.closeSelection(option)
            onRejected: detail.closeSelection()
        }
    }
}
