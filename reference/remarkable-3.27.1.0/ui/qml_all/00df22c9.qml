import QtQuick
import QtQuick.Layouts

import com.remarkable
import common
import device.ui.controls
import device.ui.text

import xofm.libs.controls

import ark.controls as ArkControls
import ark.tokens as ArkTokens

InputBlocker {
    id: root
    required property var entry
    property alias newName: nameInput.inputText

    signal accept()
    signal reject()

    ArkControls.NavigationBar {
        id: header
        type: ArkTokens.NavigationBar.secondary
        width: root.width
        title: qsTr("Rename", "Rename folder or notebook")
        borderPosition: ArkControls.NavigationBar.Border.Bottom

        ArkControls.NavigationBar.Button {
            text: qsTr("Cancel", "Cancel renaming of folder or notebook")
            focusPolicy: Qt.NoFocus
            onClicked: root.reject()
        }

        Item {
            Layout.fillWidth: true
        }

        ArkControls.NavigationBar.Button {
            text: qsTr("Save", "Save renamed folder or notebook")
            visible: nameInput.inputText.length > 0
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
        spacing: ArkControls.Values.margin.vertical.small

        TitleTextInputComponent {
            id: nameInput

            height: Values.navigatorSidebarItemHeight
            focus: true
            autoSelectOnFocus: true
            KeyboardSettings.actionPanelEnabled: true

            //: Name of the entity to rename.
            title: qsTr("Name")
            inputText: root.entry?.visibleName ?? ""
            textColor: Values.colorBlack
            wrapMode: TextInput.NoWrap

            Layout.fillWidth: true

            onAccepted: root.accept()
            onCancel: reject()
        }

        Column {
            id: detailsColumn
            Layout.fillWidth: true
            spacing: ArkControls.Values.spacing.small

            TextHeaderRegular {
                text: qsTr("Details")
            }

            TextParagraph {
                visible: !!root.entry?.lastModifiedText
                width: parent.width
                text: qsTr("Last modified %1").arg(root.entry?.lastModifiedText)
            }

            TextParagraph {
                visible: !!root.entry?.createdText
                width: parent.width
                text: qsTr("Created %1").arg(root.entry?.createdText)
            }
            TextParagraph {
                width: parent.width
                text: qsTr("ID: %1").arg(root.entry?.id.split("-")[0])
            }

            TextParagraph {
                width: parent.width
                visible: !!text
                text:  {
                    if (root.entry?.status === Entry.SyncError) {
                        return qsTr("Syncing error: %1").arg(root.entry?.statusAdditionalText);
                    }

                    if (root.entry?.status === Entry.ExcludedFromSync) {
                        return qsTr("Not syncing. Cloud limit reached.");
                    }
                    return "";
                }
            }
        }
    }
}
