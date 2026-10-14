import QtQuick
import QtQuick.Layouts
import xofm.libs.homescreen
import xofm.libs.qtgui
import xofm.libs.explorer // TreeExplorer, ViewManager
import xofm.libs.devicescreen
import xofm.libs.analytics.ui
import common
import device.ui.controls
import ark.controls as ArkControls
import com.remarkable

Action {
    id: root
    objectName: "library-action"
    property TreeExplorer explorer: NavigationManager.treeExplorerForNavigation
    required property Analytics analytics
    required property WindowNavigator windowNavigator

    property bool createNotebook: root.visible && (currentView === "myfiles" || currentView === "notebook-filter")
    property bool createCollection: root.visible && currentView === "myfiles"
    property bool createQuicksheet: root.visible

    onLongPress: quickSheetsClicked("long press on create menu");

    iconSource: popupActive ? "qrc:/ark/icons/x_medium" : "qrc:/ark/icons/plus"
    supportedViews: ["myfiles", "filter", "notebook-filter"]

    Shortcut {
        enabled: root.createQuicksheet
        objectName: "new-quicksheet-shortcut"
        sequence: "Ctrl+O"
        onActivated: quickSheetsClicked("keyboard")
    }

    Shortcut {
        enabled: root.createCollection
        objectName: "new-folder-shortcut"
        sequence: "Ctrl+Shift+N"
        onActivated: collectionClicked("keyboard")
    }

    Shortcut {
        enabled: root.createNotebook
        objectName: "new-document-shortcut"
        sequence: "Ctrl+N"
        onActivated: notebookClicked()
    }

    function notebookClicked() {
        root.hidePopup();
        windowNavigator.open("library-ui/window/create-notebook", {
            currentFolderId: explorer.currentFolderId,
            onCreated: (id) => {
                root.windowNavigator.open("legacydevice/window/main", {
                    documentId: id,
                });
            }
        });
    }

    function quickSheetsClicked(trigger) {
        root.hidePopup();
        if (!SystemMonitor.enoughFreeSpaceForCreating) {
            root.notificationQueue.enqueue({
                "text": qsTr("Not enough free space to create quick sheet"),
                "id": "quickSheetCreateErrorMessage",
            });
            return;
        }
        const document = LibraryController.quickSheets();
        if (!document || document.type !== Entry.Document) {
            return;
        }

        if (document.isExporting) {
            root.notificationQueue.enqueue({
                "text": qsTr("Unable to add page while file is being exported"),
            });
            return;
        }

        if (document.isDownloading) {
            root.notificationQueue.enqueue({
                "text": qsTr("Unable to add page while file is being downloaded"),
            });
            return;
        }

        const openLastQuickSheet = (trigger, document) => {

            if (!document || document.type !== Entry.Document) {
                return;
            }
            root.analytics.sendEvent("Quick Sheet Added", {
                trigger: trigger,
            });
            LibraryController.setLastOpenedPage(document.id, document.pageCount);
            root.windowNavigator.open("legacydevice/window/main", {
                documentId: document.id,
                page: document.pageCount - 1,
            });
        }

        const paperSize = DeviceScreenInfo.paperSize;
        const pageIndex = document.pageCount - 1;
        const isQuickSheetsFirstPage = pageIndex === 0;

        if (document.hasContentsOnPage(pageIndex)) {
            DocumentController.addPageWithTemplateAndPageSize(document, -1, "Blank", paperSize, () => {
                openLastQuickSheet(trigger, document)
            });
        } else if (isQuickSheetsFirstPage) {
            // Only set paper size on the first page, given it's empty.
            DocumentController.setPaperSizeForQuickSheetPage(document, paperSize, () => {
                openLastQuickSheet(trigger, document);
            });
        } else {
            openLastQuickSheet(trigger, document);
        }
    }

    function collectionClicked(trigger) {
        root.hidePopup();
        root.windowNavigator.open("library-ui/window/create-collection", {
            parentFolderId: explorer.currentFolderId,
            trigger: trigger,
        });
    }

    popup: Background {

        objectName: "create-menu-popup"
        readonly property int _horizontalPadding: 40
        readonly property int _verticalPadding: 40

        width: createLayout.width + _horizontalPadding * 2
        height: createLayout.height + _verticalPadding * 2
        border {
            width: Values.outlineSize
            color: "black"
        }

        ColumnLayout {
            id: createLayout
            anchors.centerIn: parent
            spacing: 0

            ArkControls.Label {
                type: ArkControls.Label.Medium
                text: qsTr("Create new")
            }
            CreateActionButton {
                visible: root.createNotebook
                iconSource: "qrc:/ark/icons/notebook"
                title: qsTr("Notebook")
                caption: qsTr("Record ideas, write, and sketch")
                onClicked: root.notebookClicked()
            }
            CreateActionButton {
                visible: root.createCollection
                iconSource: "qrc:/ark/icons/folder"
                title: qsTr("Folder")
                caption: qsTr("Organize your content")
                onClicked: root.collectionClicked("create menu button")
            }
            CreateActionButton {
                visible: root.createQuicksheet
                iconSource: "qrc:/ark/icons/quick_sheet"
                title: qsTr("Quick sheet")
                caption: qsTr("Jot down your thoughts")
                onClicked: root.quickSheetsClicked("popup")
            }
        }
    }
}
