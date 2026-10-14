import QtQuick

import com.remarkable
import common

import xofm.libs.explorer // EntitySortedListModel
import xofm.libs.gestures
import xofm.libs.navigation // Entity, ISelectiveSync

ListView {
    id: listView
    objectName: "ContentListView"
    anchors.fill: parent
    clip: true
    highlightFollowsCurrentItem: false
    onVerticalOvershootChanged: {
        if (verticalOvershoot < 0) {
            listView.positionViewAtBeginning();
        }
    }

    required property var currentModel
    required property bool rmCloudExplorer
    required property bool canSelect
    required property bool isSelecting

    property bool isMoving: false
    onIsMovingChanged: {
        if (isMoving) {
            listView.positionViewAtBeginning();
        }
    }
    property int sortOrder
    property var sortType
    property var navigationHandler
    readonly property int listItemHeight: listView.currentItem?.height ?? 0

    // We need to reposition the view when header height changes
    readonly property int folderColumnHeight: listView.headerItem ? listView.headerItem.height : 0
    onFolderColumnHeightChanged: listView.positionViewAtBeginning()

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
            objectName: "explorer-list-swipe-right"
            direction: Qt.point(1, 0)
            area: Qt.rect(0, 0, parent.width, parent.height)
            onTriggered: {
                listView.navigateUp();
            }
        }
        z: -1 // ensure it is stacked behind the list items, so we can still interract with them
    }

    header: ListView {
        id: folderList
        width: parent.width
        height: contentHeight
        interactive: false
        clip: true

        model: EntitySortedListModel {
            typeFilter: EntitySortedListModel.Filter.Folder
            sortType: EntitySortedListModel.SortType.Alphabetically
            currentSortOrder: Qt.DescendingOrder
            model: listView.currentModel
        }

        Connections {
            target: folderList.model
            function onRowsInserted() {
                if (navigationHandler) {
                    // Model has changed for the grid we track, reset selection.
                    navigationHandler.resetFocusIndex();
                }
            }
        }

        delegate: ContentListFolderItem {
            id: folderItem
            required property var model
            height: Values.navigatorContentListCollectionHeight
            width: listView.width

            onAdd: listView.add(model.id)
            onOpen: activate()
            onRemove: listView.remove(model.id)
            onAbortExport: listView.abortExport(model.id)
            onRetrySync: listView.retrySync(model.id)

            moving: listView.isMoving
            isSelecting: listView.isSelecting
            isSelectable: listView.rmCloudExplorer && listView.canSelect
            selected: listView.isSelecting ? explorerView.isSelected(model.id) : false

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
            navigationHandler: listView.navigationHandler

            function activate() {
                listView.open(model.id, model.type);
            }
        }
    }

    model: EntitySortedListModel {
        id: filesModel
        typeFilter: EntitySortedListModel.Filter.AllNonFolders
        model: listView.currentModel
        sortType: listView.sortType
        currentSortOrder: listView.sortOrder
        onSortTypeChanged: listView.positionViewAtBeginning()
    }

    delegate: ContentListItem {
        id: listItem
        required property var model

        onAdd: listView.add(model.id)
        onOpen: activate()
        onRemove: listView.remove(model.id)
        onAbortExport: listView.abortExport(model.id)
        onRetrySync: listView.retrySync(model.id)

        width: listView.width
        moving: listView.isMoving
        inactiveWarningVisible: model.locality === ISelectiveSync.Locality.Inactive
        archivedWarningVisible: model.locality === ISelectiveSync.Locality.RemoteOnly
        isSelecting: listView.isSelecting
        isSelectable: listView.canSelect
        showMetadata: listView.rmCloudExplorer
        selected: listView.isSelecting ? explorerView.isSelected(model.id) : false
        onSelectedChanged: {
            if (Settings.showInactiveWarning && inactiveWarningVisible && selected) {
                listView.inactiveItemSelected();
            }
        }

        entityId: model.id
        author: model.author
        isFavorite: model.isFavorite
        childIndex: model.childIndex
        childCount: model.childCount
        passwordProtected: model.isPasswordProtected
        progress: model.progress
        publicationDate: model.publicationDate
        publisher: model.publisher
        size: StringUtils.formatSizeInBytes(model.size)
        supported: model.filetype !== Entity.FileType.Unsupported
        syncStatus: model.syncStatus
        tags: model.tags
        thumbnail: model.thumbnail
        asynchronousThumbnail: model.asynchronousThumbnail
        title: model.name
        navigationHandler: listView.navigationHandler
        filetype: model.filetype
        type: model.type
        isNew: model.isNew

        function activate() {
            listView.open(model.id, model.type);
        }
    }
}
