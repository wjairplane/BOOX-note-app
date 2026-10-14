import QtQuick
import QtQuick.Layouts

import device.view.syncserviceexplorer
import com.remarkable
import common

import xofm.libs.search.ui
import xofm.libs.qtgui
import xofm.libs.orientation
import xofm.libs.onboarding
import xofm.libs.explorer // TreeExplorer, EntitySelection
import xofm.libs.navigation // Entity.Type, Entity.FileType

import ark.controls as ArkControls

BaseView {
    id: root

    required property SearchIndexStatus searchIndexStatus
    required property Orientation orientation
    required property var movePageSelection

    readonly property TreeExplorer explorer: NavigationManager.treeExplorerForNavigation
    readonly property EntitySelection selection: explorer.selection
    readonly property bool movingEntities: selection.size > 0

    function complete(view = ViewManager.previousView) {
        root.clearSearch();
        openExplorer(view);
        windowNavigator.close();
    }

    function clearSearch()
    {
        root.explorer.clearTagFilterSelection();
        root.explorer.clearTagSelection();
        root.explorer.resetContentSearchResults();
    }

    function navigateToFolder(id) {
        root.openExplorer(ViewManager.View.MyFiles);
        root.explorer.open(id);
        root.complete(ViewManager.View.MyFiles);
    }

    function openExplorer(filter, navigationId = Strings.libraryExplorerId) {
        NavigationManager.activeNavigationId = navigationId;
        ViewManager.activeView = filter;

        if (filter !== ViewManager.View.MyFiles && filter !== ViewManager.View.Integrations) {
            root.explorer.filterView(filter);
        }
    }

    function openDocument(id) {
        root.explorer.open(id);
        root.complete();
    }

    function clearDocumentSelections() {
        root.selection.clear();
    }

    onOpened: (args) => {
        const { filterName } = args;

        search.updateFiltersModel(movePageSelection.count > 0);
        search.populateInitialState(filterName);
    }

    contentItem: SearchView {
        id: search

        treeExplorer: root.explorer
        selection: root.selection
        orientation: root.orientation
        windowNavigator: root.windowNavigator
        searchIndexStatus: root.searchIndexStatus

        onHwsConnectTooltipCompleted: {
            OnboardingManager.setCompletedForKey(OnboardingManager.Group.Dialogs, "", "HWS_Connect_Popup", true);
        }
        onCancel: root.complete()

        onEntityClicked: (id, type) => {
            /*** Behaviour - OnClick
            *   No selection:
            *       Folder: navigate to folder
            *       Document: open document
            *   Entities Move state:
            *       Folder: navigate to folder, do not clear selection
            *       Document: do nothing
            *   Page move state:
            *       Folder: navigate to folder, do not clear
            *       Document: open document in page overview, do not clear
            */

            // When moving documents / folders, only navigating to folders is allowed
            if (root.movingEntities && type !== Entity.Type.Folder) {
                root.complete();
            }

            // BOTH No selection and page move state
            if (type === Entity.Type.Folder) {
                root.navigateToFolder(id);
            } else {
                root.openDocument(id);
            }
        }

        onEntityPressAndHold: (id, type) => {
            /*** Behaviour - OnPressedAndHold
            *   No selection:
            *       Folder: navigate to parent, select folder
            *       Document: navigate to parent, select document
            *   Entities Move state:
            *       Folder: navigate to folder, do not clear selection
            *       Document: do nothing
            *   Page move state:
            *       Folder: navigate to folder, do not clear selection
            *       Document: open document in page overview, do not clear
            */

            // When moving documents / folders, only navigating to folders is allowed
            if (root.movingEntities && type !== Entity.Type.Folder) {
                root.complete();
            }

            if (!root.movePageSelection.isEmpty) {
                if (type === Entity.Type.File) {
                    root.openDocument(id);
                } else if (type === Entity.Type.Folder) {
                    root.navigateToFolder(id);
                }
                root.complete();
            }

            if (type === Entity.Type.Page) {
                // TODO: This should go to page overview and select instead
                root.openDocument(id);
            } else {
                root.clearDocumentSelections();
                root.navigateToFolder(root.explorer.parentForEntity(id));
                root.selection.add(id);
            }
        }
    }
}
