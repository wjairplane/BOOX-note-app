import QtQuick
import QtQuick.Layouts

import xofm.libs.qtgui
import xofm.libs.analytics.ui
import com.remarkable // NavigationManager

BaseView {
    id: root
    required property var library
    required property Analytics analytics

    property var currentFolderId: null
    property var trigger: null
    property var onCreated: null

    onOpened: (args) => {
        const { parentFolderId, onCreated, trigger} = args || {};
        if (!parentFolderId) {
            console.error("create-collection-window opened without parentFolderId");
            root.windowNavigator.close();
            return;
        }
        if(!trigger) {
            console.error("create-collection-window opened without trigger");
            root.windowNavigator.close();
            return;
        }
        root.trigger = trigger;
        root.currentFolderId = parentFolderId;
        root.onCreated = onCreated;
    }

    contentItem: CreateCollection {
        id: createCollection
        collectionName: root.library.uniqueVisibleName(qsTr("Folder"))
        // Todo: Inject treeExplorer here (Or some other tags model)
        tagModel: NavigationManager.treeExplorerForNavigation.tags
        windowNavigator: root.windowNavigator

        onAccept: () => {
            const newFolderId = root.library.createCollectionWrapper(
                root.currentFolderId,
                createCollection.collectionName);

            if (createCollection.selectedTags.length > 0) {
                LibraryController.setEntryTags(newFolderId, createCollection.selectedTags, []);
            }
            root.analytics.sendEvent("Folder Created", {
                trigger: root.trigger,
                folder_id: newFolderId,
                parent_id: root.currentFolderId,
            });

            root.onCreated?.(newFolderId);
            root.windowNavigator.close();
        }
        onReject: () => {
            root.windowNavigator.close();
        }
    }
}
