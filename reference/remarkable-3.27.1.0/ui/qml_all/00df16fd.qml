import QtQuick
import QtQuick.Layouts

import xofm.libs.qtgui

import com.remarkable

BaseView {
    id: root
    property var _entry: null
    required property var library

    onOpened: (args) => {
        const { documentId } = args;
        if(!documentId) {
            console.error("notebook-settings opened without documentId");
            root.windowNavigator.close();
            return;
        }
        root._entry = root.library.entryForId(documentId);
        if (!root._entry) {
            console.error("notebook-settings opened with invalid documentId", documentId);
            root.windowNavigator.close();
            return;
        }
    }

    contentItem: EditDocument {
        id: settings
        entry: root._entry
        onAccept: {
            root.windowNavigator.close();
            //TODO: Inject LibraryController here
            LibraryController.setVisibleName(root._entry.id, settings.documentName);
            LibraryController.setCoverPageNumber(root._entry.id, settings.coverPageNumber);
        }
        onReject: () => {
            root.windowNavigator.close();
        }
    }
}
