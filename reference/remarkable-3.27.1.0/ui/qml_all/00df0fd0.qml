import QtQuick
import QtQuick.Layouts

import xofm.libs.tags
import xofm.libs.analytics.ui
import xofm.libs.controls

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import common
import com.remarkable
import device.ui.controls
import device.ui.text
import device.ui.headers
import device.view.documentview

InputBlocker {
    id: root

    required property var windowNavigator
    required property bool showTemplateSelector
    required property Analytics analytics

    property alias documentName: documentNameInput.inputText
    property int coverPageNumber: -1
    property int recentCount: Math.floor(templatesView.width / templatesView.cellWidth) * 2
    property var recentTemplates: Templates.recentTemplates(recentCount)
    property var appliedTemplate: recentTemplates.length > 0 ? recentTemplates[0] : null
    property var newTemplates: []

    signal create(string name, var template, int coverPageNumber)
    signal reject

    function accept() {
        root.create(root.documentName, root.appliedTemplate, root.coverPageNumber);
        Templates.clearNewflag(newTemplates);
    }

    function addRecentTemplate(aTemplate) {
        // temporary storage of recents during this session
        // remove duplicate
        if (!aTemplate) {
            return;
        }
        if(typeof(aTemplate) === 'undefined') {
            return;
        }

        recentTemplates = recentTemplates.filter(function (item) {
            return item.filename !== aTemplate.filename;
        });
        // move the new in front
        recentTemplates.unshift(aTemplate);
        // correctly indicate current
        // only show limited amount
        recentTemplates = recentTemplates.slice(0, recentCount);
        root.appliedTemplate = aTemplate;
    }

    ArkControls.NavigationBar {
        id: header
        type: ArkTokens.NavigationBar.secondary
        width: root.width
        title: qsTr("New notebook", "Creates notebook")
        borderPosition: ArkControls.NavigationBar.Border.Bottom

        ArkControls.NavigationBar.Button {
            text: qsTr("Cancel", "top bar")
            focusPolicy: Qt.NoFocus
            onClicked: {
                root.reject()
                Templates.clearNewflag(newTemplates);
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ArkControls.NavigationBar.Button {
            text: qsTr("Create", "Notebook creator")
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

            Layout.fillWidth: true
            height: Values.navigatorSidebarItemHeight
            focus: true
            KeyboardSettings.actionPanelEnabled: true
            //: Name of the notebook to create.
            title: qsTr("Name")
            autoSelectOnFocus: true
            textColor: Values.colorBlack
            wrapMode: TextInput.NoWrap
            onAccepted: root.accept()
            onCancel: reject()
    }

    Column {
        id: coverPageSetting
        Layout.fillWidth: true
        spacing: ArkControls.Values.spacing.small
        TextHeaderRegular {
            text: qsTr("Notebook cover")
            }
        }

        ArkControls.ContextualMenu {
            ArkControls.ContextualMenu.Button {
                checked: root.coverPageNumber === -1;
                text: qsTr("Last visited page")
                type: ArkTokens.ContextualMenu.secondary
                onClicked: {
                    root.coverPageNumber = -1
                    Qt.inputMethod.hide()
                }
                focusPolicy: Qt.NoFocus
            }
            ArkControls.ContextualMenu.Button {
                checked: root.coverPageNumber === 0
                text: qsTr("First page")
                type: ArkTokens.ContextualMenu.secondary
                onClicked:{
                    root.coverPageNumber = 0
                    Qt.inputMethod.hide()
                }
                focusPolicy: Qt.NoFocus
            }
        }

    Column {
        Layout.fillWidth: true
        visible: root.showTemplateSelector
        spacing: ArkControls.Values.spacing.medium

        RowLayout {
            width: parent.width

            ArkControls.Title {
                text: qsTr("Templates", "template chooser")
                type: ArkControls.Title.MediumAlt
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            IconButton {
                id: viewAllTemplatesButton
                title: qsTr("View all", "template chooser")
                iconSource: "qrc:/ark/icons/chevron_small_right"
                elideTitle: Text.ElideNone
                layoutDirection: Qt.RightToLeft
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                onClicked: {
                    root.windowNavigator.open("document/window/template-selector", {
                        currentTemplate: root.appliedTemplate,
                        onApplied: (aTemplate, templateApplied, addToRecent) => {
                            if (templateApplied && addToRecent) {
                                root.addRecentTemplate(aTemplate);
                            }
                        }
                    });
                }
            }
        }

        GridView {
            id: templatesView

            // This size is based on the TemplateDelegate size
            cellHeight: 340
            cellWidth: width / Math.ceil(width / cellHeight)
            width: parent.width
            // 2 rows
            height: cellHeight * 2
            clip: true
            interactive: false
            model: recentTemplates

            delegate: TemplateDelegate {
                width: templatesView.cellWidth
                height: templatesView.cellHeight
                isCurrent: root.appliedTemplate === modelData
                onClicked: (aTemplate) => {
                    Qt.inputMethod.hide();
                    root.appliedTemplate = aTemplate;
                }
                Component.onCompleted: {
                    if (modelData.isNew) {
                        root.newTemplates.push(modelData.customTemplateId);
                    }
                }
            }
        }
    }
    }

}
