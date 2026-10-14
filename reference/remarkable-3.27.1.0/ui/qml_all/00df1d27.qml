import QtQuick
import QtQuick.Layouts

import xofm.libs.tags
import xofm.libs.controls

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import common
import com.remarkable
import device.ui.text
import device.ui.controls
import device.ui.headers
import device.view.documentview

InputBlocker {
    id: root
    required property var entry
    property int coverPageNumber: root.entry?.coverPageNumber ?? -1
    property alias documentName: documentNameInput.inputText

    signal accept
    signal reject

    ArkControls.NavigationBar {
        id: header
        type: ArkTokens.NavigationBar.secondary
        width: root.width
        title: {
            switch (root.entry?.fileType) {
                case Document.Notebook:
                    //: Settings of this specific notebook, not general settings
                    //~ unfinished
                    return qsTr("Notebook settings");
                case Document.Pdf:
                    //: Settings of this specific PDF, not general settings
                    //~ unfinished
                    return qsTr("PDF settings");
                case Document.Ebook:
                    //: Settings of this specific Ebook, not general settings
                    //~ unfinished
                    return qsTr("Ebook settings");
                default:
                    //: Settings of this specific document, not general settings
                    //~ unfinished
                    return "Settings";

                }
            }
        borderPosition: ArkControls.NavigationBar.Border.Bottom

        ArkControls.NavigationBar.Button {
            text: qsTr("Cancel", "top bar")
            focusPolicy: Qt.NoFocus
            onClicked: {
                root.reject();
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ArkControls.NavigationBar.Button {
            text: qsTr("Save", "Entry creator/editor modal")
            visible: documentName.length > 0
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
            id: documentNameInput

            height: Values.navigatorSidebarItemHeight
            focus: true
            autoSelectOnFocus: true
            KeyboardSettings.actionPanelEnabled: true

            //: Name of the document to edit.
            title: qsTr("Name")
            inputText: root.entry?.visibleName ?? ""
            textColor: Values.colorBlack
            wrapMode: TextInput.NoWrap

            Layout.fillWidth: true

            onAccepted: root.accept()
            onCancel: reject()
    }

        Column {
            id: coverPageSetting
            Layout.fillWidth: true
            spacing: ArkControls.Values.spacing.small

            TextHeaderRegular {
                visible: !root.entry?.lockedByPassword
                text: {
                    switch (root.entry?.type) {
                    case Document.Pdf:
                        return qsTr("PDF cover");
                    case Document.Ebook:
                        return qsTr("Ebook cover");
                    default:
                        return qsTr("Notebook cover");
                    }
                }
            }

            ArkControls.ContextualMenu {
                visible: !root.entry?.lockedByPassword
                ArkControls.ContextualMenu.Button {
                    checked: root.coverPageNumber === -1;
                    text: qsTr("Last visited page")
                    type: ArkTokens.ContextualMenu.secondary
                    onClicked: root.coverPageNumber = -1
                    focusPolicy: Qt.NoFocus
                }
                ArkControls.ContextualMenu.Button {
                    checked: root.coverPageNumber === 0
                    text: qsTr("First page")
                    type: ArkTokens.ContextualMenu.secondary
                    onClicked: root.coverPageNumber = 0
                    focusPolicy: Qt.NoFocus
                }
            }
        }

        Column {
            id: detailsColumn
            Layout.fillWidth: true
            spacing: ArkControls.Values.spacing.small

            TextHeaderRegular {
                text: qsTr("Details")
            }

            TextParagraph {
                visible: root.entry?.pageCount > 0
                width: parent.width
                //: Requires plural form
                text: qsTr("%n page(s)", "", root.entry?.pageCount ?? 0)
            }

            TextParagraph {
                visible: !!root.entry?.lastModifiedText
                width: parent.width
                //: Date of last modification -> Last modified 6 months ago
                //~ unfinished
                text: qsTr("Last modified %1").arg(root.entry?.lastModifiedText)
            }

            TextParagraph {
                visible: !!root.entry?.createdText
                width: parent.width
                //: Date of creation -> Created 1 year ago
                //~ unfinished
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
