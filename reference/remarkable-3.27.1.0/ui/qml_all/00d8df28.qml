import QtQuick

import com.remarkable
import common
import device.global
import device.ui.controls

import xofm.libs.onboarding
import xofm.libs.orientation
import xofm.libs.settings
import xofm.libs.navigation // Entity
import xofm.libs.explorer // ViewManager, TreeExplorer, EntitySelection

Item {
    id: treeExplorerView

    required property TreeExplorer explorer
    required property EntitySelection selection

    property var currentModel: isSearchView ? explorer.searchModel : explorer.entityListModel
    readonly property bool emptyView: !!currentModel?.isEmpty

    property bool movingEntities: false
    property bool loadingEntities: false
    readonly property bool isIntegrations: ViewManager.activeView === ViewManager.View.Integrations

    property alias activeView: explorerHeader.activeView

    property Orientation orientation

    signal navigateUp

    onNavigateUp: explorerView.navigateUp()

    ThumbnailSettings {
        id: thumbnailSettings
        settingsKey: ThumbnailSettings.Explorer
    }

    Item {
        anchors {
            top: explorerHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        ExplorerView {
            id: explorerView
            visible: !treeExplorerView.loadingEntities
            explorer: treeExplorerView.explorer
            currentModel: treeExplorerView.currentModel
            selection: treeExplorerView.selection
            orientation: treeExplorerView.orientation
            previousNavigationHandler: explorerHeader
            sortType: explorerHeader.sortType
            ascending: explorerHeader.ascending
            movingEntities: treeExplorerView.movingEntities
            thumbnailSize: thumbnailSettings.thumbnailSize
            isIntegrations: treeExplorerView.isIntegrations
            anchors.fill: parent

            onNavigateUp: {
                if (explorer.isInRoot()) {
                    return;
                }
                const parentId = explorer.parentForEntity(explorer.currentFolderId);
                explorerView.openId(parentId, Entity.Type.Folder);
            }
        }

        Loading {
            visible: delayedLoading.currentValue
            anchors.centerIn: parent
            DelayedValue {
                id: delayedLoading
                timeout: 500
                eventualValue: treeExplorerView.loadingEntities
                onEventualValueChanged: {
                    // Change to 'false' immediately, we only want to delay changes to 'true'.
                    if (!delayedLoading.eventualValue) {
                        delayedLoading.changeValueImmediately(false);
                    }
                }
            }
        }
    }

    ExplorerHeader {
        id: explorerHeader
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: Values.viewHorizontalMargin
            right: parent.right
        }
        height: Values.navigationEntriesHeaderHeight

        nextNavigationHandler: explorerView

        sortDropDownVisible: !treeExplorerView.emptyView
        activeView: ViewManager.activeView
        breadcrumbModel: treeExplorerView.explorer.breadcrumbModel
        isIntegrations: treeExplorerView.isIntegrations
        thumbnailSize: thumbnailSettings.thumbnailSize
        ascending: Settings.ascendingOrder
        orientation: treeExplorerView.orientation

        onOpen: (id) => { explorerView.openId(id, Entity.Type.Folder); }
        onTabCycle: Global.keyboardNavigationController.focusOtherHandler(explorerHeader)
        onUpdateThumbnailSize: (thumbnailSize) => {
            thumbnailSettings.thumbnailSize = thumbnailSize;
        }
        onUpdateAscending: (ascending) => {
            Settings.ascendingOrder = ascending;
        }
    }

    // If we are in a filter view (pdf, favorites, trash...), isSearchView returns true
    readonly property bool isSearchView: {
        if (ViewManager.activeView === ViewManager.View.MyFiles ||
            ViewManager.activeView === ViewManager.View.Integrations) {
            return false;
        } else {
            return true;
        }
    }
}
