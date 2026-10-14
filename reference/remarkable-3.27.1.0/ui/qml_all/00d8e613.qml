import QtQuick

import com.remarkable
import common

import xofm.libs.explorer // EntityListModel, EntitySortedListModel
import xofm.libs.navigation // ISelectiveSync
import xofm.libs.gestures
import xofm.libs.settings

GridView {
    id: gridView
    objectName: "ContentGridView"
    anchors.fill: parent
    clip: true
    highlightFollowsCurrentItem: true

    Component.onCompleted: {
        console.assert(reuseItems === false, "reuseItems is not compatible with ContentGridView");
    }

    // Enum: ThumbnaSettings.ThumbnailSize
    required property int thumbnailSize
    required property var currentModel
    required property bool rmCloudExplorer
    required property bool canSelect
    required property bool isSelecting

    property bool isMoving: false
    onIsMovingChanged: {
        if (isMoving) {
            gridView.positionViewAtBeginning();
        }
    }

    property int sortOrder
    property var sortType
    property var navigationHandler

    // We need to reposition the view when header height changes
    readonly property int folderGridHeight: gridView.headerItem ? gridView.headerItem.height : 0
    onFolderGridHeightChanged: {
        gridView.forceLayout(); // needed in order to include the header
        gridView.positionViewAtBeginning();
    }

    signal open(var id, var type)
    signal add(var id)
    signal remove(var id)
    signal abortExport(var id)
    signal retrySync(var id)
    signal inactiveItemSelected
    signal navigateUp

    TouchArea {
        anchors.fill: parent

        property TouchAreaSwipeFilter swipeRightGesture: TouchAreaSwipeFilter {
            id: swipeRight
            objectName: "explorer-grid-swipe-right"
            direction: Qt.point(1, 0)
            area: Qt.rect(0, 0, parent.width, parent.height)
            onTriggered: {
                gridView.navigateUp();
            }
        }
        z: -1 // ensure it is stacked behind the grid items, so we can still interract with them
    }

    ThumbnailGridSize {
        id: thumbnailGridSize
        thumbnailSize: gridView.thumbnailSize
        width: parent.width
    }

    header: GridView {
        id: folderGrid

        cellWidth: thumbnailGridSize.gridItemWidth
        cellHeight: Values.navigatorContentCollectionHeight
        interactive: false

        clip: true
        width: parent.width
        height: folderGrid.contentHeight

        model: EntitySortedListModel {
            typeFilter: EntitySortedListModel.Filter.Folder
            sortType: EntitySortedListModel.SortType.Alphabetically
            currentSortOrder: Qt.DescendingOrder
            model: gridView.currentModel
        }

        Connections {
            target: folderGrid.model
            function onRowsInserted() {
                if (navigationHandler) {
                    // Model has changed for the grid we track, reset selection.
                    navigationHandler.resetFocusIndex();
                }
            }
        }

        delegate: ContentGridFolderItem {
            id: folderItem
            width: folderGrid.cellWidth
            height: folderGrid.cellHeight

            onOpen: activate()
            onAdd: gridView.add(model.id)
            onRemove: gridView.remove(model.id)
            onAbortExport: gridView.abortExport(model.id)
            onRetrySync: gridView.retrySync(model.id)

            moving: gridView.isMoving
            isSelecting: gridView.isSelecting
            isSelectable: gridView.rmCloudExplorer && gridView.canSelect
            selected: gridView.isSelecting ? explorerView.isSelected(model.id) : false

            childCount: model.childCount
            isFavorite: model.isFavorite
            isShared: model.shared
            progress: model.progress
            syncStatus: model.syncStatus
            tags: model.tags
            title: model.name
            entityId: model.id
            filetype: model.filetype
            type: model.type
            navigationHandler: gridView.navigationHandler

            function activate() {
                gridView.open(model.id, model.type);
            }
        }
    }

    model: EntitySortedListModel {
        typeFilter: EntitySortedListModel.Filter.AllNonFolders
        model: gridView.currentModel
        sortType: gridView.sortType
        onSortTypeChanged: gridView.positionViewAtBeginning()
        currentSortOrder: gridView.sortOrder
    }
    cellWidth: thumbnailGridSize.gridItemWidth
    cellHeight: thumbnailGridSize.gridItemHeight

    property var usedDelegates: [] // Cache for recycled delegate instances

    // Define the actual delegate component
    property Component gridItemComponent: ContentGridItem {
        property var model // Define the model property here

        // Properties will be bound in the delegate Item's onCompleted
        width: gridView.cellWidth
        height: gridView.cellHeight
        cellMargin: thumbnailGridSize.thumbnailMargin
        thumbnailSize: gridView.thumbnailSize

        onAdd: gridView.add(model.id)
        onOpen: activate()
        onRemove: gridView.remove(model.id)
        onAbortExport: gridView.abortExport(model.id)
        onRetrySync: gridView.retrySync(model.id)

        // Static or gridView-dependent properties
        moving: gridView.isMoving
        isSelectable: gridView.canSelect
        showMetadata: gridView.rmCloudExplorer

        // onSelectedChanged remains, but relies on properties bound in onCompleted
        onSelectedChanged: {
            if (Settings.showInactiveWarning && inactiveWarningVisible && selected) {
                gridView.inactiveItemSelected();
            }
        }

        navigationHandler: gridView.navigationHandler

        function activate() {
            gridView.open(model.id, model.type);
        }
    }

    // Wrapper delegate for object pooling
    delegate: Item {
        id: gridItemContainer
        required property var model // Ensure model is available here
        required property int index

        // To avoid recreating items from scratch we keep a cache of used instances
        property Item instance

        width: gridView.cellWidth // Set container size
        height: gridView.cellHeight

        function activate() {
            if (instance) {
                instance.activate();
            } else {
                console.warn("No instance available to activate!");
            }
        }

        Component.onDestruction: {
            if (instance) { // Place back in cache and prepare for recycle
                instance.visible = false;
                // Reset any internal state before recycling
                if (typeof instance.reset === "function") {
                    instance.reset();
                }
                instance.parent = null; // Detach from visual tree
                gridView.usedDelegates.push(instance); // Return to cache
                instance = null; // Clear reference
            }
        }

        Component.onCompleted: {
            // Retrieve from cache or create on demand
            if (usedDelegates.length > 0) {
                instance = usedDelegates.pop();
            } else {
                instance = gridItemComponent.createObject();
            }

            if (!instance) {
                console.error("Failed to get or create grid item instance!");
                return; // Exit if instance is null
            }

            // Ensure the instance is parented correctly and visible
            instance.parent = gridItemContainer;

            // Bind model-dependent properties with null checks only if instance is valid
            instance.model = Qt.binding(() => gridItemContainer.model ?? null);
            instance.entityId = Qt.binding(() => model?.id ?? "");
            instance.author = Qt.binding(() => model?.author ?? "");
            instance.isFavorite = Qt.binding(() => model?.isFavorite ?? false);
            instance.childIndex = Qt.binding(() => model?.childIndex ?? 0);
            instance.childCount = Qt.binding(() => model?.childCount ?? 0);
            instance.passwordProtected = Qt.binding(() => model?.isPasswordProtected ?? false);
            instance.progress = Qt.binding(() => model?.progress ?? 0.0);
            instance.publicationDate = Qt.binding(() => model?.publicationDate ?? "");
            instance.publisher = Qt.binding(() => model?.publisher ?? "");
            instance.syncStatus = Qt.binding(() => model?.syncStatus ?? EntityListModel.Status.Idle);
            instance.tags = Qt.binding(() => model?.tags ?? []);
            instance.thumbnail = Qt.binding(() => model?.thumbnail ?? "");
            instance.asynchronousThumbnail = Qt.binding(() => model?.asynchronousThumbnail ?? false);
            instance.title = Qt.binding(() => model?.name ?? "");
            instance.type = Qt.binding(() => model?.type ?? Entity.Type.File);
            instance.filetype = Qt.binding(() => model?.filetype ?? Entity.FileType.Unsupported);
            instance.isNew = Qt.binding(() => model?.isNew ?? false);

            // Bind properties that depend on explorerView and model *after* model is set, with null checks
            instance.isSelecting = Qt.binding(() => gridView.isSelecting ?? false);
            instance.archivedWarningVisible = Qt.binding(() => model?.locality === ISelectiveSync.Locality.RemoteOnly);
            instance.inactiveWarningVisible = Qt.binding(() => model?.locality === ISelectiveSync.Locality.Inactive);

            instance.selected = Qt.binding(() => (explorerView && model && model.id) ? explorerView.isSelected(model.id) : false);
            instance.drawFocus = Qt.binding(() => !!navigationHandler && navigationHandler.current === gridItemContainer);

            // Make the instance visible after setup
            instance.visible = true;
        }
    }
}
