import QtQuick
import xofm.libs.qtgui

import com.remarkable

BaseView {
    id: root
    required property var library
    property var _entry: null

    onOpened: (args) => {
        const { id } = args || {};
        if (!id) {
            console.error("rename-entity-window opened without parentFolder or folderId");
            root.windowNavigator.close();
            return;
        }
        root._entry = root.library.entryForId(id);

    }

    contentItem: RenameEntity {
        id: settings

        entry: root._entry

        onAccept: {
            LibraryController.setVisibleName(root._entry.id, settings.newName);
            root.windowNavigator.close();
        }
        onReject: () => {
            root.windowNavigator.close();
        }
    }
}
