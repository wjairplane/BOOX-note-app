import QtQuick
import QtQuick.Layouts

import xofm.libs.qtgui
import xofm.libs.analytics.ui
import xofm.libs.devicescreen
import xofm.libs.notificationbar
import xofm.libs.devicescreen

import com.remarkable

BaseView {
    id: root
    required property var library
    required property NotificationQueue notificationQueue
    required property var movePageSelection
    required property Analytics analytics

    property var currentFolderId: null

    property var onCreated: null
    onOpened: (args) => {
        const { currentFolderId, onCreated } = args || {};

        if (!SystemMonitor.enoughFreeSpaceForCreating) {
            root.notificationQueue.enqueue({
                "text": qsTr("Not enough free space to create document")
            });
            root.windowNavigator.close();
            return;
        }

        if(!currentFolderId) {
            console.error("create-notebook window opened without currentFolderId");
            root.windowNavigator.close();
            return;
        }
        root.onCreated = onCreated || null;
        root.currentFolderId = currentFolderId;
    }

    function createNotebook(documentName, template, coverPage) {
            const appliedTemplate = template.filename
            const portrait = !template.landscape;

            // TODO: Inject LibraryController here
            const id = LibraryController.createDocument(root.currentFolderId, documentName);

            const document = root.library.entryForId(id);
            LibraryController.setOrientation(document.id, portrait ? Qt.Vertical : Qt.Horizontal);
            DocumentController.setTemplateForPage(document, document.lastOpenedPage, appliedTemplate, DeviceScreenInfo.paperSize);
            LibraryController.setCoverPageNumber(document.id, coverPage);
            Templates.setRecentTemplate(template);

            root.analytics.sendEvent("Notebook Created", {
                document_id: id,
                trigger: "create menu",
                parent_id: root.currentFolderId,
                template: template.name,
                cover_page: coverPage === 0 ? "first page" : "last page"
            });
            return id;
    }
    function createNotebookFromExistingPages(name, coverPage) {

            const id = LibraryController.createDocumentFromExisting(root.currentFolderId.toString(), name, root.movePageSelection.documentId, root.movePageSelection.pages);
            let document = Library.entryForId(id);

            LibraryController.setCoverPageNumber(document.id, coverPage);
            root.analytics.sendEvent("Notebook Created", {
                document_id: id,
                trigger: "move page",
                parent_id: root.currentFolderId,
            });
            return document.id;
    }

    contentItem: CreateNotebook {
        windowNavigator: root.windowNavigator
        showTemplateSelector: root.movePageSelection.isEmpty
        documentName: root.library.uniqueVisibleName(qsTr("Notebook"))
        onCreate: (name, template, coverPage) => {

            const id = root.movePageSelection.isEmpty ?
                createNotebook(name, template, coverPage) :
                createNotebookFromExistingPages(name, coverPage);

            root.onCreated?.(id);
            root.windowNavigator.close();

        }
        onReject: root.windowNavigator.close();
    }
}
