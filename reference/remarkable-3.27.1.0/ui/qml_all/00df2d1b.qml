import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.controls
import xofm.libs.tags
import xofm.libs.qtgui

import common
import com.remarkable // KeyboardSettings
import device.ui.controls // TitleTextInputComponent
import device.ui.headers // HeaderInput

InputBlocker {
    id: root
    required property WindowNavigator windowNavigator

    property list<string> tagModel
    property alias collectionName: collectionNameInput.inputText
    readonly property alias selectedTags: tagsSelector.selectedTags

    signal accept()
    signal reject()

    ArkControls.NavigationBar {
        id: header
        type: ArkTokens.NavigationBar.secondary
        width: root.width
        title: qsTr("New folder")
        borderPosition: ArkControls.NavigationBar.Border.Bottom

        ArkControls.NavigationBar.Button {
            text: qsTr("Cancel", "top bar")
            focusPolicy: Qt.NoFocus
            onClicked: root.reject()
        }

        Item {
            Layout.fillWidth: true
        }

        ArkControls.NavigationBar.Button {
            text: qsTr("Create", "Notebook creator")
            visible: collectionNameInput.inputText.length > 0
            focusPolicy: Qt.NoFocus
            onClicked: root.accept()
        }
    }
    ColumnLayout {
        id: layout

        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            topMargin: ArkControls.Values.margin.vertical.small
            leftMargin: ArkControls.Values.margin.horizontal.small
            rightMargin: ArkControls.Values.margin.horizontal.small
        }

        TitleTextInputComponent {
            id: collectionNameInput

            Layout.fillWidth: true
            height: Values.navigatorSidebarItemHeight
            focus: true
            autoSelectOnFocus: true
            KeyboardSettings.actionPanelEnabled: true
            //: Name of the collection (or folder) to create.
            title: qsTr("Name")
            textColor: Values.colorBlack
            wrapMode: TextInput.NoWrap
            onAccepted: root.accept()
            onCancel: reject()
        }

        TagsSelector {
            id: tagsSelector
            Layout.fillWidth: true

            tagModel: root.tagModel
            windowNavigator: root.windowNavigator
            accessibilityMode: false
            showCreateTagButton: true
            headerContainer: root

            onCreateTagClicked: {
                addTagInput.visible = true;
                addTagInput.focus = true;
            }
        }
        HeaderInput {
            id: addTagInput

            placeholder: qsTr("Enter tag name")
            blackOnWhite: false
            inputField.selectedTextColor: Values.colorBlack
            inputField.selectionColor: Values.colorWhite
            inputField.maximumLength: 20
            inputField.inputMethodHints: Qt.ImhNoAutoUppercase
            focus: true
            visible: false
            confirmText: qsTr("Create")
            parent: root

            onAccepted: (tag) => {
                addTagInput.visible = false;
                addTagInput.text = "";

                if (!tag?.length) {
                    return;
                }
                if(root.tagModel.indexOf(tag) < 0) {
                    root.tagModel.push(tag);
                    tagsSelector.toggleTagSelection(tag);
                    return;
                }

                if (!tagsSelector.isFiltered(tag)) {
                    tagsSelector.toggleTagSelection(tag);
                }
            }
            onRejected: {
                addTagInput.visible = false;
                addTagInput.text = "";
            }
        }
    }

}
