import QtQuick
import QtQuick.Layouts
import common
import com.remarkable
import device.global
import device.ui.controls
import ark.controls as ArkControls

import xofm.libs.explorer // ViewManager

Item {
    id: root

    width: primaryContainer.width
    height: Values.createMenuHeight

    required property int activeView
    required property bool hideCreateMenu
    required property bool isEmptyView

    property PopupOverlay popupOverlay
    property int bottomMargin

    readonly property int sidePadding: more.visible ? 16 : 0
    readonly property bool moreButtonVisible: more.visible
    readonly property point moreButtonPos: Qt.point(more.x, more.y)

    signal searchClicked
    signal collectionClicked
    signal notebookClicked
    signal quicksheetClicked(var analyticsData)
    signal trashClicked
    signal menuVisible

    enum Actions {
        Collection,
        Notebook,
        Quicksheet,
        Trash,
        Search
    }

    property var actions: {
        if(hideCreateMenu) {
            return [];
        }
        switch (activeView) {
        case ViewManager.View.MyFiles:
            return [
                        CreateMenu.Actions.Collection,
                        CreateMenu.Actions.Notebook,
                        CreateMenu.Actions.Quicksheet,
                        CreateMenu.Actions.Search,
                   ];
        case ViewManager.View.Trash:
            return root.isEmptyView ? [] : [CreateMenu.Actions.Trash];
        case ViewManager.View.Tags:
        case ViewManager.View.Pdfs:
        case ViewManager.View.Ebooks:
        case ViewManager.View.Favorites:
            return [
                        CreateMenu.Actions.Quicksheet,
                        CreateMenu.Actions.Search,
                   ];
        case ViewManager.View.Notebooks:
            return [
                        CreateMenu.Actions.Notebook,
                        CreateMenu.Actions.Quicksheet,
                        CreateMenu.Actions.Search,
                   ];
        case ViewManager.View.Integrations:
            return [];
        }
        return [];
    }

    Shortcut {
        objectName: "global-search-shortcut"
        sequence: "Ctrl+F"
        enabled: root.visible && root.enabled && root.actions.includes(CreateMenu.Actions.Search)
        onActivated: searchClicked()
    }

    Shortcut {
        objectName: "new-document-shortcut"
        sequence: "Ctrl+N"
        enabled: root.visible && root.enabled && root.actions.includes(CreateMenu.Actions.Notebook)
        onActivated: notebookClicked()
    }

    Shortcut {
        objectName: "new-folder-shortcut"
        sequence: "Ctrl+Shift+N"
        enabled: root.visible && root.enabled && root.actions.includes(CreateMenu.Actions.Collection)
        onActivated: collectionClicked()
    }

    Shortcut {
        objectName: "new-quicksheet-shortcut"
        sequence: "Ctrl+O"
        enabled: root.visible && root.enabled && root.actions.includes(CreateMenu.Actions.Quicksheet)
        onActivated: quicksheetClicked({"trigger": "keyboard"})
    }

    Rectangle {
        id: primaryContainer
        width: primaryLayout.implicitWidth + root.sidePadding * 2
        height: parent.height
        radius: height / 2
        border {
            width: Values.outlineSize
            color: "black"
        }

        RowLayout {
            id: primaryLayout
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: root.sidePadding
            spacing: 0
            Action {
                id: search
                onClicked: root.searchClicked()
                visible: actions.includes(CreateMenu.Actions.Search)
                iconSource: "qrc:/ark/icons/lens"
            }

            Rectangle {
                visible: search.visible && more.visible
                height: 64
                width: 2
                color: "black"
            }

            Action {
                id: more
                visible: root.actions.some(option => option === CreateMenu.Actions.Notebook
                                           || option === CreateMenu.Actions.Collection
                                           || option === CreateMenu.Actions.Quicksheet);
                onClicked: {
                    popup.showPopup();
                    root.menuVisible();
                }

                onPressAndHold: {
                    if(root.actions.includes(CreateMenu.Actions.Quicksheet)) {
                        root.quicksheetClicked({"trigger": "long press on create menu"});
                    }
                }

                iconSource: popup.active ? "qrc:/ark/icons/x_medium" : "qrc:/ark/icons/plus"
            }
            Action {
                id: trash
                visible: actions.includes(CreateMenu.Actions.Trash)
                onClicked: root.trashClicked()
                iconSource: "qrc:/ark/icons/trashcan_delete"
            }
        }
    }

    Rectangle {
        id: externalBorder
        anchors.fill: primaryContainer
        color: "transparent"
        radius: height / 2
        anchors.margins: -border.width
        border {
            color: Values.colorWhite
            width: 4
        }
    }

    component Action: MouseArea {
        Layout.alignment: Qt.AlignHCenter
        Layout.minimumWidth: height
        Layout.fillHeight: true
        property alias iconSource: icon.source
        property alias caption: caption.text
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            ArkControls.Icon {
                id: icon
                Layout.alignment: Qt.AlignHCenter
                size: ArkControls.Values.iconSize.medium
                source: "qrc:/ark/icons/placeholder"
            }
            ArkControls.Caption {
                id: caption
                visible: !!text
            }
        }
    }

    Popup {
        id: popup
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24 + root.height + root.bottomMargin

        overlay: root.popupOverlay
        tapOutsideBehavior: Popup.TapOutside.RejectAndHide

        Background {
            anchors {
                bottom: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            border {
                width: Values.outlineSize
                color: "black"
            }

            readonly property int _horizontalPadding: 40
            readonly property int _verticalPadding: 40
            width: createLayout.width + _horizontalPadding * 2
            height: createLayout.height + _verticalPadding * 2

            component CreateAction: MouseArea {
                property alias iconSource: createIcon.source
                property alias title: createTitle.text
                property alias caption: createCaption.text
                implicitHeight: createTitle.height + createCaption.height
                implicitWidth: createIcon.width + createTitle.anchors.leftMargin + createCaption.width
                Layout.fillWidth: true
                Layout.topMargin: 40

                ArkControls.Icon {
                    id: createIcon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    size: ArkControls.Values.iconSize.medium
                    source: "qrc:/ark/icons/placeholder"
                }

                ArkControls.Label {
                    id: createTitle
                    anchors.left: createIcon.right
                    anchors.leftMargin: 20
                    type: ArkControls.Label.LargeStrong
                }

                ArkControls.Caption {
                    id: createCaption
                    anchors.top: createTitle.bottom
                    anchors.left: createTitle.left
                }
            }

            ColumnLayout {
                id: createLayout
                anchors.centerIn: parent

                spacing: 0

                ArkControls.Label {
                    type: ArkControls.Label.Medium
                    text: qsTr("Create new")
                }

                CreateAction {
                    iconSource: "qrc:/ark/icons/notebook"
                    title: qsTr("Notebook")
                    caption: qsTr("Record ideas, write, and sketch")
                    visible: root.actions.includes(CreateMenu.Actions.Notebook)
                    onClicked: {
                        root.notebookClicked();
                        popup.hidePopup();
                    }
                }

                CreateAction {
                    iconSource: "qrc:/ark/icons/folder"
                    title: qsTr("Folder")
                    caption: qsTr("Organize your content")
                    visible: root.actions.includes(CreateMenu.Actions.Collection)
                    onClicked: {
                        root.collectionClicked();
                        popup.hidePopup();
                    }
                }

                CreateAction {
                    iconSource: "qrc:/ark/icons/quick_sheet"
                    title: qsTr("Quick sheet")
                    caption: qsTr("Jot down your thoughts")
                    visible: root.actions.includes(CreateMenu.Actions.Quicksheet)
                    onClicked: {
                        root.quicksheetClicked({"trigger": "create menu button"});
                        popup.hidePopup();
                    }
                }
            }
        }
    }
}
