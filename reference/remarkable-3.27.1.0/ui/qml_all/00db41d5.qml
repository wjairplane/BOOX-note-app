import QtQuick
import QtQuick.Layouts

import com.remarkable
import common

import com.remarkable.devicetelemetry

import device.global
import device.ui.headers
import device.view.documentview
import device.view.experimental

import xofm.libs.explorer // TreeExplorer, ViewManager, NavigationSortedListModel, EntitySelection
import xofm.libs.onboarding
import xofm.libs.orientation
import xofm.libs.qtgui
import xofm.libs.notificationbar // NotificationQueue
import xofm.libs.settings // SettingsPage
import xofm.libs.navigation // ISelectiveSync

import ark.controls as ArkControls
import ark.tokens as ArkTokens

HeaderContainer {
    id: actionHeader

    required property TreeExplorer explorer
    required property var navigationManager
    required property bool retailSettingsEnabled
    required property WindowNavigator windowNavigator
    required property NotificationQueue notificationQueue
    navigationModel: updateNavigationModel()
    required property bool canArchive
    required property int activeView
    required property EntitySelection selection
    required property Item foldoutOverlay
    required property NavigatorTelemetry navigatorTelemetry

    onSelectionChanged: reloadActions()

    property string sourceFolder
    property int activeButton: ActionHeader.ActiveButton.None

    readonly property bool wideScreen: width > 1000
    readonly property bool canMove: sourceFolder !== currentFolder
    readonly property string currentFolder: explorer.currentFolderId
    property alias popupOverlay: addTagPopup.overlay
    required property Orientation orientation
    property bool _shouldRestrictMethodsContent: selection.hasMethodsContent && !UserInfo.isSubscribed
    property var activeButtonPos: Qt.point(0, 0)
    property bool _showSendEmail
    property bool _showArchive
    property bool _showRetrieve

    readonly property bool loadingEntities: importExportContext.isActive && importExportContext.loadingEntities

    enum ActiveButton { None, Move, Duplicate, More, FileTypeSelection }

    signal switchIntegration(var id)
    signal openMyFiles
    signal openExplorer(var filter, var id)
    signal openFolder(var folderId)
    signal createCollection
    signal showSearch
    signal exportSelection(EntitySelection selection, string fileType, string sourceId, string targetId)
    signal deleteTrashClicked
    signal deleteTags

    blackOnWhite: false
    height: actionBarLoader.implicitHeight
    rejectEnabled: true // the "cancel" button will be created from here

    objectName: "ActionHeader"

    anchors.left: parent.left
    anchors.right: parent.right

    onVisibleChanged: {
        if (!actionHeader.visible) {
            actionHeader.activeButton = ActionHeader.ActiveButton.None;
        }
    }
    onActivated: (element) => {
        if (element) {
            element.activate();
        }
    }
    onTabCycle: {
        Global.keyboardNavigationController.focusOtherHandler(actionHeader);
    }

    Connections {
        target: selection
        function onSelectionChanged() {
            reloadActions();
        }
    }

    Connections {
        target: explorer
        enabled: actionHeader.activeView === ViewManager.View.Tags
        function onSelectedTagsChanged() {
            reloadActions();
        }
    }

    QtObject {
        id: importExportContext

        readonly property bool isActive: actionHeader.state === "Exporting"
        property EntitySelection selection
        property string sourceId
        property string targetId
        property string targetType
        property string targetEntityId
        property bool isImport: false
        property bool loadingEntities: false

        function setup(targetFilter, targetNavigationId, targetFileType = "") {
            // Save source explorer details so we can use and restore them on completion
            selection = actionHeader.selection;
            sourceId = NavigationManager.activeNavigationId;
            // Save target navigation Id to control status messages actions
            targetId = targetNavigationId;
            targetType = targetFileType;
            // Prepare to export to origin folder if it exists
            targetEntityId = Strings.invalidId;
            // If the target filter is MyFiles, this is an import from integration
            isImport = targetFilter === ViewManager.View.MyFiles;
            // Switch to target explorer and enter Exporting state
            loadingEntities = false;
            actionHeader.openExplorer(targetFilter, targetNavigationId);
            actionHeader.state = "Exporting";

            if (!isImport) {
                // If all selected items have the same source in the target integration,
                // load its enity tree to offer to open its parent folder
                targetEntityId = selection.selectionSourceEntityId(targetNavigationId);
                if (targetEntityId != Strings.invalidId) {
                    loadingEntities = true;
                    explorer.loadTree(targetEntityId);
                }
            }
        }

        function cancel() {
            // Switch back to source explorer
            actionHeader.openExplorer(ViewManager.previousView, sourceId);
            actionHeader.cancel();
        }

        function execute() {
            // Export (or import) the source explorer selection to the current folder of the current explorer
            navigatorTelemetry.fileActionbarClicked(isImport ? "import" : "export");
            actionHeader.exportSelection(selection, targetType, sourceId, targetId);
            if (isImport) {
                // Stay in MyFiles (so imported doc can be opened and edited right away)
                actionHeader.cancel();
            } else {
                // Switch back to MyFiles after export
                actionHeader.openExplorer(ViewManager.previousView, sourceId);
                actionHeader.cancel();
            }
        }
    }

    Connections {
        target: explorer

        function onEntityTreeLoaded(navigationId, entityId, targetFolderId) {
            importExportContext.loadingEntities = false;
            if (!importExportContext.isActive || importExportContext.targetEntityId != entityId) {
                // Only respond if we're still in target folder selection mode
                // and the loaded tree is for the exported entity
                return;
            }
            actionHeader.notificationQueue.enqueue({
                "text": qsTr("Original folder found"),
                "style": Notification.Secondary,
            });
            actionHeader.openFolder(targetFolderId);
        }
    }

    function resetActiveButton () {
        actionHeader.activeButton = ActionHeader.ActiveButton.None;
    }

    function cancel() {
        actionHeader.state = "";
        resetActiveButton();
        actionHeader.rejected();
    }

    function updateNavigationModel() {
        let navModel = [];
        navModel.push(rejectItem);
        navModel = navModel.concat(actionBarLoader.item?.actionButtons);

        return navModel;
    }

    function pointToAction(title) {
        const buttons = actionBarLoader.item.actionButtons
        for (let i in buttons) {
            let button = buttons[i];
            if (button.title === title) {
                return button;
            }
        }
        return null;
    }

    function reloadActions() {
        resetActiveButton();
        tagPopup.hidePopup();
        currentActions();
        // bindings will not always trigger this, do it explicitly.
        navigationModel = updateNavigationModel();
    }

    function currentActions() {
        const selectedTags = explorer.selectedTags?.length
        const emptySelection = selection.size === 0;

        // Actions while in Trash view
        if (!emptySelection && actionHeader.activeView === ViewManager.View.Trash) {
            actionHeader.state = "TrashView";
            return;
        }

        if (actionHeader.state === "Exporting" && !importExportContext.isImport)
        {
            return;
        }

        if (!emptySelection && actionHeader.activeView === ViewManager.View.Integrations) {
            actionHeader.state = "IntegrationsView";
            return;
        }

        // Limit options when there isn't enough disk space
        if (!emptySelection && !SystemMonitor.enoughFreeSpaceForDownload) {
            actionHeader.state = "DiskFull";
            return;
        }

        if (actionHeader.state === "Exporting")
        {
            return;
        }

        if (!emptySelection && actionHeader.selection.hasPage) {
            actionHeader.state = "PageTag";
            return;
        }

        if ((actionHeader.activeView === ViewManager.View.Tags) && selectedTags) {
            actionHeader.state = selectedTags > 1 ? "DeleteTag" : "DeleteRenameTag";
            return;
        }

        const remoteOnlyCount = selection.selectionLocalityCount(ISelectiveSync.Locality.RemoteOnly);
        actionHeader._showSendEmail = actionHeader.selection.size === 1 && !actionHeader.selection.hasFolder && (remoteOnlyCount === 0);
        // Show archive action if we have no remoteonly items selected, and no folders
        actionHeader._showArchive = !actionHeader.selection.hasFolder && (remoteOnlyCount === 0) && actionHeader.canArchive;
        // Show retrieve if all selected items are remote only
        actionHeader._showRetrieve = remoteOnlyCount === actionHeader.selection.size;
        actionHeader.state = "";
    }

    // Selected entries
    function renameEntryAction() {
        if (explorer.selectedTags?.length > 0) {
            actionHeader.state = "RenamingTag";
            return;
        }
        selection.selectionRename();
    }

    function moveEntriesAction() {
        if (actionHeader.activeButton === ActionHeader.ActiveButton.Move) {
            resetActiveButton();
            return;
        }
        actionHeader.activeButton = ActionHeader.ActiveButton.Move;
        actionHeader.state = "Moving";
    }

    function integrationAction(name, id) {
        if (LinkProvider.availability === LinkProvider.Offline) {
            actionHeader.notificationQueue.enqueue({
                "text": qsTr("Connect to Wi-Fi to export documents"),
                "icon": "qrc:/ark/icons/wifi_x",
                "id": "actionHeaderNoWifiExport",
                "actionText": qsTr("Wi-Fi settings"),
                "onClicked": () => {
                    actionHeader.windowNavigator.open("settings/window/main", { index: SettingsPage.Wifi });
                    resetActiveButton();
                    actionHeader.state = "";
                },
            });
            return;
        }

        if (actionHeader._shouldRestrictMethodsContent) {
            windowNavigator.open("legacydevice/window/no-connect-workbook-action");
            return;
        }

        importExportContext.setup(ViewManager.View.Integrations, id);
     }

    function duplicateEntriesAction() {
        if (actionHeader._shouldRestrictMethodsContent) {
            windowNavigator.open("legacydevice/window/no-connect-workbook-action");
            return;
        }

        // if it's possible to clean, we need to show popup that lets users decide between a clean copy or a copy
        if (actionHeader.selection.canClean) {
            if (actionHeader.activeButton === ActionHeader.ActiveButton.Duplicate) {
                resetActiveButton();
                return;
            }

            /// copy from tags
            actionHeader.activeButton = ActionHeader.ActiveButton.Duplicate;
        }
        // if not, copy each document
        else {
            // Trigger one copy measurement per document
            addCopyTelemetry("copy");
            actionHeader.notificationQueue.enqueue({
                //: Requires plural form
                "text": qsTr("%n item(s) were duplicated", "", selection.size),
                "style": Notification.Secondary,
            });
            selection.selectionCopy(explorer.parentForEntity(actionHeader.selection.selectedId()));
        }
    }

    function addCopyTelemetry(copyActionName) {
        for (let i = 0; i < actionHeader.selection.size; ++i) {
            navigatorTelemetry.documentCreated(copyActionName);
        }
    }

    function sendEntriesAction() {
        if (actionHeader._shouldRestrictMethodsContent) {
            windowNavigator.open("legacydevice/window/no-connect-workbook-action");
            return;
        }

        selection.selectionMail();
        resetActiveButton();
    }

    function trashEntriesAction() {
        actionHeader.notificationQueue.enqueue({
            //: Requires plural form
            "text": qsTr("%n item(s) were moved to Trash", "", selection.size),
            "style": Notification.Secondary,
        });
        selection.selectionMoveToTrash();
    }

    function requestSelectionSynced() {
        selection.selectionRequestLocality(ISelectiveSync.Locality.Synced);
    }

    function requestSelectionRemoteOnly() {
        selection.selectionRequestLocality(ISelectiveSync.Locality.RemoteOnly);
    }

    function favoriteClicked() {
        navigatorTelemetry.fileActionbarClicked("favorite");
        selection.selectionToggleFavorite();
    }

    function moreEntriesAction() {
        if (actionHeader.activeButton === ActionHeader.ActiveButton.More) {
            resetActiveButton();
            return;
        }
        actionHeader.activeButton = ActionHeader.ActiveButton.More;
    }

    NavigationSortedListModel {
        id: navigationSortedModel
        list: navigationManager.navigationView
        filter: navigationManager.activeNavigationId
    }

    Component{
        id: duplicateFoldout
        DuplicateFoldout {
            overlayParent: foldoutOverlay
            onClicked: (action) => {
                actionHeader.notificationQueue.enqueue({
                    //: Requires plural form
                    "message": qsTr("%n item(s) were duplicated", "", selection.size),
                    "style": Notification.Secondary,
                });

                const measurementName = action === "copy" ? "copy" : "clean copy";
                addCopyTelemetry(measurementName);

                if (action === "clean") {
                    selection.selectionClean(explorer.parentForEntity(actionHeader.selection.selectedId()));
                } else if (action === "copy") {
                    selection.selectionCopy(explorer.parentForEntity(actionHeader.selection.selectedId()));
                }
                actionHeader.cancel();
            }
            onFoldoutOverlayClicked: resetActiveButton()
        }
    }

    Component {
        id: moreFoldout
        MyFilesMoreFoldout {
            favoriteIcon: actionHeader.selection.onlyFavorites ? "qrc:/ark/icons/star_inverted" : "qrc:/ark/icons/star"
            showFavorite: !actionHeader.selection.hasPage && !actionHeader.wideScreen
            showTag: !actionHeader.wideScreen
            showSendEmail: actionHeader._showSendEmail
            showArchive: actionHeader._showArchive
            showRetrieve: actionHeader._showRetrieve
            showIntegrations: !actionHeader.selection.hasFolder && selection.selectionLocalityCount(ISelectiveSync.Locality.RemoteOnly) === 0
            overlayParent: foldoutOverlay
            navigationModel: navigationSortedModel
            connectRequired: selection.hasMethodsContent && !UserInfo.isSubscribed
            pairingRequired: !Authentication.loggedIn

            onShowMoreIntegrationsClicked: actionHeader.state = "ShowMoreIntegrations"
            onIntegrationClicked: (name, id) => { actionHeader.integrationAction(name, id); }
            onFavoriteClicked: actionHeader.favoriteClicked()
            onTagClicked: {
                // An Entry (Document / Folder) has a different state from a Page
                actionHeader.state = "EntryTag";
                actionHeader.tagEntriesAction();
            }
            onSendByEmailClicked: {
                actionHeader.navigatorTelemetry.fileActionbarClicked("send");

                if (pairingRequired) {
                    windowNavigator.open("userfrontend/window/cloud-feature-popup");
                    return;
                }
                if (connectRequired) {
                    windowNavigator.open("legacydevice/window/no-connect-workbook-action");
                    return;
                }
                if (LinkProvider.availability === LinkProvider.Offline) {
                    connectivityNotifier.show();
                    return;
                }

                sendEntriesAction();
            }
            onArchiveClicked: {
                actionHeader.navigatorTelemetry.fileActionbarClicked("archive");
                actionHeader.requestSelectionRemoteOnly();
            }
            onRetrieveClicked: {
                actionHeader.navigatorTelemetry.fileActionbarClicked("unarchive");
                actionHeader.requestSelectionSynced();
            }
            onFoldoutOverlayClicked: actionHeader.cancel()
        }
    }

    Component {
        id: moveFoldout
        MoveFoldout {
            overlayParent: foldoutOverlay
            onNewFolderClicked: {
                actionHeader.createCollection();
                resetActiveButton();
            }
            onSearchClicked: {
                actionHeader.showSearch();
                resetActiveButton();
            }
            onFoldoutOverlayClicked: resetActiveButton()
        }
    }

    AddTagPopup {
        id: addTagPopup
        width: parent.width
    }

    TagSelectionPopup {
        id: tagPopup
        overlay: addTagPopup.overlay
        onEditClicked: addTagPopup.open(tagPopup)
        layoutDirection: Qt.LeftToRight
        orientation: actionHeader.orientation
        windowNavigator: actionHeader.windowNavigator
        onAccepted: {
            if (modified) {
                selection.selectionSetTags(selectedTags, partiallySelectedTags);
            }
            actionHeader.state = "";
        }
    }

    Component {
        id: fileTypeSelectionFoldout
        FileTypeSelectionFoldout {
            overlayParent: foldoutOverlay
            possibleImportFileTypes: actionHeader.selection.selectionPossibleImportFileTypes()
            restrictedFileTypes: actionHeader.selection.selectionRestrictedFileTypes()
            getRestrictedFileTypeReasonCallback: (fileType) => actionHeader.selection.getRestrictedFileTypeReason(fileType)

            onFileTypeSelected: (fileType, isRestricted) => {
                if (isRestricted) {
                    actionHeader.windowNavigator.open("integrations-storage/window/convert-to-notebook-connect-restriction-dialog");
                    return;
                }
                importExportContext.setup(ViewManager.View.MyFiles, Strings.libraryExplorerId, fileType);
            }
            onCancelled: {
                resetActiveButton();
            }
        }
    }

    function tagEntriesAction() {
        navigatorTelemetry.fileActionbarClicked("tag");
        tagPopup.pointTo = actionBarLoader;
        tagPopup.initialTagsModel = explorer.tags;
        tagPopup.addTagsAndEntries(selection.selectionTagMap());
    }

    Component {
        id: tagRenameHeader

        HeaderInput {
            id: renameHeader
            inputField.selectedTextColor: Values.colorBlack
            inputField.selectionColor: Values.colorWhite
            inputField.maximumLength: 20
            blackOnWhite: false
            visible: true
            Component.onCompleted: inputField.forceActiveFocus()
            text: explorer.selectedTags?.length > 0 ? explorer.selectedTags[0] : ""
            confirmText: qsTr("Save")
            onAccepted: text => {
                if (text.trim().length <= 0) {
                    return;
                }
                actionHeader.state = "";
                explorer.renameTag(text);
                explorer.clearTagSelection();
            }
            onRejected: {
                actionHeader.state = "";
                explorer.clearTagSelection();
            }
        }
    }

    Component {
        id: defaultActionBar

        ActionBarBase {
            objectName: "defaultActionBar"
            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    id: renameActionButton
                    property var navigationHandler: actionHeader

                    function activate() {
                        actionHeader.navigatorTelemetry.fileActionbarClicked("rename");
                        actionHeader.renameEntryAction();
                    }

                    showFocus: !!navigationHandler && navigationHandler.current === renameActionButton
                    text: qsTr("Rename")
                    iconSource: "qrc:/ark/icons/text_edit"
                    visible: actionHeader.selection.size === 1
                    onClicked: activate()
                },
                ArkControls.ActionBar.ActionButton {
                    id: favoriteActionButton
                    property var navigationHandler: actionHeader

                    function activate() {
                        actionHeader.favoriteClicked();
                    }

                    showFocus: !!navigationHandler && navigationHandler.current === favoriteActionButton
                    text: qsTr("Favorite")
                    iconSource: actionHeader.selection.onlyFavorites ? "qrc:/ark/icons/star_inverted" : "qrc:/ark/icons/star"
                    visible: !actionHeader.selection.hasPage && actionHeader.wideScreen
                    onClicked: activate()
                },
                ArkControls.ActionBar.ActionButton {
                    id: tagActionButton
                    property var navigationHandler: actionHeader

                    function activate() {
                        // An Entry (Document / Folder) has a different state from a Page
                        actionHeader.state = "EntryTag";
                        actionHeader.tagEntriesAction();
                    }

                    showFocus: !!navigationHandler && navigationHandler.current === tagActionButton
                    text: qsTr("Tag")
                    iconSource: "qrc:/ark/icons/tag"
                    visible: actionHeader.wideScreen
                    onClicked: activate()
                },
                ArkControls.ActionBar.ActionButton {
                    id: duplicateActionButton

                    property var navigationHandler: actionHeader

                    function activate() {
                        actionHeader.activeButtonPos = duplicateActionButton.mapToItem(navigator, 0, duplicateActionButton.y + duplicateActionButton.height);
                        actionHeader.navigatorTelemetry.fileActionbarClicked("duplicate");
                        actionHeader.duplicateEntriesAction();
                    }

                    showFocus: !!navigationHandler && navigationHandler.current === duplicateActionButton
                    text: qsTr("Duplicate")
                    iconSource: "qrc:/ark/icons/duplicate"
                    visible: !actionHeader.selection.hasFolder && (selection.selectionLocalityCount(ISelectiveSync.Locality.RemoteOnly) === 0)
                    selected: actionHeader.activeButton === ActionHeader.ActiveButton.Duplicate
                    onClicked: activate()

                    Loader {
                        id: duplicateFoldoutLoader
                        objectName: "foldoutLoader"
                        anchors {
                            top: parent.bottom
                            topMargin: -duplicateFoldoutLoader.item?.background?.border.width
                            right: parent.right
                        }
                        active: actionHeader.activeButton === ActionHeader.ActiveButton.Duplicate
                        sourceComponent: duplicateFoldout
                    }
                },
                ArkControls.ActionBar.ActionButton {
                    id: moveActionButton

                    property var navigationHandler: actionHeader

                    function activate() {
                        actionHeader.navigatorTelemetry.fileActionbarClicked("move");
                        actionHeader.moveEntriesAction();
                    }

                    showFocus: !!navigationHandler && navigationHandler.current === moveActionButton
                    text: qsTr("Move")
                    iconSource: "qrc:/ark/icons/move"
                    onClicked: activate()
                },
                ArkControls.ActionBar.ActionButton {
                    id: trashActionButton

                    property var navigationHandler: actionHeader

                    function activate() {
                        actionHeader.navigatorTelemetry.fileActionbarClicked("trash");
                        actionHeader.trashEntriesAction();
                    }

                    showFocus: !!navigationHandler && navigationHandler.current === trashActionButton
                    text: qsTr("Delete")
                    iconSource: "qrc:/ark/icons/trashcan"
                    onClicked: activate()
                },
                ArkControls.ActionBar.ActionButton {
                    id: moreActionButton

                    property var navigationHandler: actionHeader

                    function activate() {
                        actionHeader.activeButtonPos = moreActionButton.mapToItem(navigator, 0, moreActionButton.y + moreActionButton.height);
                        actionHeader.moreEntriesAction();
                    }

                    showFocus: !!navigationHandler && navigationHandler.current === moreActionButton
                    text: qsTr("More")
                    iconSource: "qrc:/ark/icons/three_dots_vertical"
                    selected: actionHeader.activeButton === ActionHeader.ActiveButton.More
                    onClicked: activate()

                    Loader {
                        id: moreFoldoutLoader
                        objectName: "foldoutLoader"
                        anchors {
                            top: parent.bottom
                            topMargin: -moreFoldoutLoader.item?.background?.border.width
                            right: parent.right
                        }
                        active: actionHeader.activeButton === ActionHeader.ActiveButton.More
                        sourceComponent: moreFoldout
                    }
                }
            ]
            onCancelClicked: actionHeader.cancel()
        }
    }

    Component {
        id: deleteTagActionBar

        ActionBarBase {
            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    text: qsTr("Delete")
                    iconSource: "qrc:/ark/icons/trashcan"
                    onClicked: actionHeader.deleteTags()
                }
            ]
            onCancelClicked: actionHeader.cancel()
        }
    }

    Component {
        id: deleteRenameTagActionBar

        ActionBarBase {
            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    text: qsTr("Delete")
                    iconSource: "qrc:/ark/icons/trashcan"
                    onClicked: actionHeader.deleteTags()
                },
                ArkControls.ActionBar.ActionButton {
                    text: qsTr("Rename")
                    iconSource: "qrc:/ark/icons/text_edit"
                    onClicked: renameEntryAction()
                }
            ]
            onCancelClicked: actionHeader.cancel()
        }
    }

    Component {
        id: trashViewActionBar

        ActionBarBase {
            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    text: qsTr("Restore")
                    iconSource: "qrc:/ark/icons/restore"
                    onClicked: {
                        actionHeader.navigatorTelemetry.fileActionbarClicked("restore");
                        actionHeader.notificationQueue.enqueue({
                            //: Requires plural form
                            "message": qsTr("%n item(s) were restored to My files", "", selection.size),
                            "style": Notification.Secondary,
                        });
                        selection.selectionRestoreTrashed();
                        actionHeader.cancel();
                    }
                },
                ArkControls.ActionBar.ActionButton {
                    text: qsTr("Delete")
                    iconSource: "qrc:/ark/icons/trashcan"
                    onClicked: {
                        actionHeader.navigatorTelemetry.fileActionbarClicked("delete");
                        actionHeader.deleteTrashClicked();
                    }
                }
            ]
            onCancelClicked: actionHeader.cancel()
        }
    }

    Component {
        id: movingActionBar

        ActionBarBase {
            title: canMove ?
                       //: Recommended character limit for translation: 26
                       qsTr("Choose a placement", "Move document, moving allowed") :
                       (actionHeader.selection.size > 1 ?
                            //: Recommended character limit for translation: 30
                            qsTr("Select where to move the items", "Move multiple documents, moving NOT allowed") :
                            //: Recommended character limit for translation: 30
                            qsTr("Select where to move the item", "Move document, moving NOT allowed"))
            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    visible: canMove
                    text: qsTr("Move here")
                    iconSource: "qrc:/ark/icons/move_here"
                    onClicked: {
                        selection.selectionMove(explorer.currentFolderId);
                        actionHeader.state = "";
                    }
                },
                ArkControls.ActionBar.ActionButton {
                    text: qsTr("More")
                    iconSource: "qrc:/ark/icons/three_dots_vertical"
                    onClicked: actionHeader.moreEntriesAction()
                    selected: actionHeader.activeButton === ActionHeader.ActiveButton.More

                    Loader {
                        id: moveFoldoutLoader
                        objectName: "moveFoldoutLoader"
                        anchors {
                            top: parent.bottom
                            topMargin: -moveFoldoutLoader.item?.background?.border.width
                            right: parent.right
                        }
                        active: actionHeader.activeButton === ActionHeader.ActiveButton.More
                        sourceComponent: moveFoldout
                    }
                }
            ]
            onCancelClicked: actionHeader.cancel()
        }
    }

    Component {
        id: exportingActionBar

        ActionBarBase {
            readonly property bool isImport: importExportContext.isImport
            readonly property bool multipleItems: importExportContext.selection.size > 1

            readonly property string importLabel: multipleItems ?
                //: Select target folder for multiple files import
                //: Recommended character limit for translation: 30
                qsTr("Select where to save the files") :
                //: Select target folder for single file import
                //: Recommended character limit for translation: 30
                qsTr("Select where to save the file")

            //: Select target folder for document(s) export
            //: Recommended character limit for translation: 30
            readonly property string exportLabel: qsTr("Select destination")

            title: isImport ? importLabel : exportLabel

            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    visible: true
                    text: isImport ?
                        //: Import document to selected folder
                        qsTr("Import here") :
                        //: Export document to selected folder
                        qsTr("Export here")
                    iconSource: isImport ? "qrc:/ark/icons/cloud_download" :  "qrc:/ark/icons/cloud_upload"
                    onClicked: {
                        importExportContext.execute();
                    }
                },
                ArkControls.ActionBar.ActionButton {
                    //: Show 'Move foldout' with options to search or create new folder
                    text: qsTr("More")
                    iconSource: "qrc:/ark/icons/three_dots_vertical"
                    onClicked: actionHeader.moreEntriesAction()
                    selected: visible && actionHeader.activeButton === ActionHeader.ActiveButton.More
                    visible: isImport

                    Loader {
                        id: importFoldoutLoader
                        objectName: "importFoldoutLoader"
                        anchors {
                            top: parent.bottom
                            topMargin: -importFoldoutLoader.item?.background?.border.width
                            right: parent.right
                        }
                        active: actionHeader.activeButton === ActionHeader.ActiveButton.More
                        sourceComponent: moveFoldout
                    }
                }
            ]
            onCancelClicked: {
                importExportContext.cancel();
            }
        }
    }

    Component {
        id: integrationsActionBar

        ActionBarBase {
            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    id: importButton
                    iconSource: "qrc:/ark/icons/import"
                    //: Action bar on Desktop
                    text: qsTr("Import")
                    onClicked: {
                        importIntegrationsTooltip.OnboardingStateProp.completed = true;
                        if (LinkProvider.availability === LinkProvider.Offline) {
                            actionHeader.notificationQueue.enqueue({
                                "text": qsTr("Connect to Wi-Fi to import documents"),
                                "icon": "qrc:/ark/icons/wifi_x",
                                "id": "actionHeaderNoWifiImport",
                                "actionText": qsTr("Wi-Fi settings"),
                                "onClicked": () => {
                                    actionHeader.windowNavigator.open("settings/window/main", { index: SettingsPage.Wifi });
                                    actionHeader.cancel();
                                },
                            });
                            return;
                        }

                        if (actionHeader.activeButton === ActionHeader.ActiveButton.FileTypeSelection) {
                            resetActiveButton();
                            return;
                        }

                        const possibleFileTypes = actionHeader.selection.selectionPossibleImportFileTypes();
                        if (possibleFileTypes.length < 1) {
                            actionHeader.notificationQueue.enqueue({
                                //: Notification shown when the user is in their storage integration and has attempted to import two documents that cannot be imported/converted as the same type.
                                "text": qsTr("These files have different formats. Try importing them separately."),
                                "id": "integrationsImportNoCommonFileTypes",
                            });
                            return;
                        }
                        actionHeader.activeButton = ActionHeader.ActiveButton.FileTypeSelection;
                    }

                    ToolTip {
                        id: importIntegrationsTooltip
                        //: Recommended character limit for translation: 20
                        caption: qsTr("Import a duplicate")
                        //: Recommended character limit for translation: 120-140
                        description: qsTr("Work on your documents from My files. You can export them to %1 whenever you like.").arg(NavigationManager.navigationName(NavigationManager.activeNavigationId))
                        OnboardingStateProp.key: "IntegrationsMyFilesCopy"
                        readyToShow: true

                        parent: actionHeader
                        position: ArkControls.Tooltip.Position.Below

                        pointTo: actionHeader.mapToItem(actionHeader, importButton.x, importButton.y, importButton.width, importButton.height)
                        container: actionHeader.mapToItem(actionHeader, actionHeader.x, actionHeader.y, actionHeader.width - 32, window.height);
                    }

                    Loader {
                        id: fileTypeSelectionFoldoutLoader
                        parent: importButton
                        anchors {
                            right: importButton.right
                            top: importButton.bottom
                        }
                        active: actionHeader.activeButton === ActionHeader.ActiveButton.FileTypeSelection
                        sourceComponent: fileTypeSelectionFoldout
                    }
                }
            ]
            onCancelClicked: actionHeader.cancel()
        }
    }

    Component {
        id: diskFullActionBar

        ActionBarBase {
            title: SystemMonitor.enoughFreeSpaceForCreating ? qsTr("Disk is almost full") : qsTr("Disk is full")
            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    iconSource: "qrc:/ark/icons/storage_full"
                    text: qsTr("Storage settings")
                    onClicked: {
                        actionHeader.windowNavigator.open("settings/window/storage");
                        actionHeader.cancel();
                    }
                },
                ArkControls.ActionBar.ActionButton {
                    iconSource: "qrc:/ark/icons/archive"
                    text: qsTr("Archive")
                    visible: !actionHeader.selection.hasFolder
                        && selection.selectionLocalityCount(ISelectiveSync.Locality.RemoteOnly) === 0
                        && actionHeader.canArchive
                        && actionHeader.activeView !== ViewManager.View.Integrations
                    onClicked: {
                        actionHeader.navigatorTelemetry.fileActionbarClicked("archive");
                        actionHeader.requestSelectionRemoteOnly();
                        actionHeader.cancel();
                    }
                },
                ArkControls.ActionBar.ActionButton {
                    iconSource: "qrc:/ark/icons/trashcan"
                    text: qsTr("Delete")
                    onClicked: {
                        actionHeader.navigatorTelemetry.fileActionbarClicked("delete");
                        actionHeader.trashEntriesAction();
                        actionHeader.cancel();
                    }
                }
            ]
            onCancelClicked: actionHeader.cancel()
        }
    }

    Component {
        id: pageTagActionBar

        ActionBarBase {
            title: qsTr("Tag item")
            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    text: qsTr("Tag")
                    iconSource: "qrc:/ark/icons/tag"
                    onClicked: {
                        actionHeader.tagEntriesAction();
                    }
                }
            ]
            onCancelClicked: actionHeader.cancel()
        }
    }

    Component {
        id: entryTagActionBar

        ActionBarBase {
            title: qsTr("Tag item")
            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    text: qsTr("Back")
                    iconSource: "qrc:/ark/icons/chevron_left"
                    selected: true
                    onClicked: {
                        actionHeader.state = "";
                        actionHeader.activeButton = ActionHeader.ActiveButton.More;
                        if (tagPopup.modified) {
                            selection.selectionSetTags(tagPopup.selectedTags, tagPopup.partiallySelectedTags);
                        }
                        tagPopup.hidePopup();
                    }
                }
            ]
            onCancelClicked: actionHeader.cancel()
        }
    }

    Component {
        id: showMoreIntegrationsActionBar

        ActionBarBase {
            title: qsTr("Export to integration")
            onCancelClicked: actionHeader.cancel()
            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    id: backActionButton
                    text: qsTr("Back")
                    iconSource: "qrc:/ark/icons/chevron_left"
                    selected: true
                    onClicked: goBack()

                    function goBack() {
                        actionHeader.state = "";
                        actionHeader.activeButton = ActionHeader.ActiveButton.More;
                    }

                    FoldoutOverlay {
                        anchors {
                            top: parent.bottom
                            right: parent.right
                        }
                        overlayParent: foldoutOverlay
                        contentItem: ColumnLayout {
                            spacing: 0
                            IntegrationsFoldoutItem {
                                Layout.fillWidth: true
                                navigationModel: navigationSortedModel
                                connectRequired: actionHeader.selection.hasMethodsContent && !UserInfo.isSubscribed
                                onIntegrationClicked: (name, id) => { actionHeader.integrationAction(name, id); }
                            }
                        }
                        onOverlayClicked: backActionButton.goBack()
                    }
                }
            ]
        }
    }

    Loader {
        id: actionBarLoader
        objectName: "actionBarLoader"
        anchors.fill: parent
        sourceComponent: {
            // The sourceComponent should be an ArkControls.ActionBar
            switch (actionHeader.state) {
                case "Moving":
                    return movingActionBar;
                case "Exporting":
                    return exportingActionBar;
                case "IntegrationsView":
                    return integrationsActionBar;
                case "DiskFull":
                    return diskFullActionBar;
                case "ShowMoreIntegrations":
                    return showMoreIntegrationsActionBar;
                case "RenamingTag":
                    return tagRenameHeader;
                case "TrashView":
                    return trashViewActionBar;
                case "PageTag":
                     return pageTagActionBar;
                case "EntryTag":
                    return entryTagActionBar;
                case "DeleteTag":
                    return deleteTagActionBar;
                case "DeleteRenameTag":
                    return deleteRenameTagActionBar;
                default:
                    return defaultActionBar;
            }
        }
    }
}
