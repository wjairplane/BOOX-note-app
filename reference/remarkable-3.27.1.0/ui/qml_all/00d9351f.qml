import QtQuick

import com.remarkable
import common
import device.global
import device.ui.controls
import device.view.dialogs
import device.view.experimental

import xofm.libs.devicescreen
import xofm.libs.explorer // ViewManager, TreeExplorer, EntitySelection
import xofm.libs.navigation // Entity,ISelectiveSync
import xofm.libs.onboarding
import xofm.libs.settings
import xofm.libs.orientation

import ark.controls as ArkControls

DeviceKeyboardNavigationHandler {
    id: root
    objectName: "ExplorerView"

    required property TreeExplorer explorer
    required property var currentModel
    required property EntitySelection selection
    required property Orientation orientation
    // Enum: ThumbnaSettings.ThumbnailSize
    required property int thumbnailSize
    required property bool ascending
    required property int sortType

    property string newNavigationId
    property alias viewLoaderItem: _viewLoader.item
    property bool movingEntities: false
    property bool selectingEnabled: true
    property bool isIntegrations: false
    property int folderAreaHeight
    property int thumbnailHeight: 0
    property int thumbnailWidth: 0

    readonly property bool selecting: root.selection.hasSelection
    readonly property var currentFolder: explorer.currentFolderId

    signal layoutChanged(bool list)
    signal navigateUp
    signal changeExplorerAndOpenId(var id)

    function setLongPressTooltipAsCompleted() {
        OnboardingManager.setCompletedForKey(OnboardingManager.Group.Tooltips, "", "Long_Press_Entry", true);
    }

    // scroll the model so that the provided item is visible
    function scrollToEntity(id) {
        const proxyModel = _viewLoader.item.model;
        const proxyIndex = proxyModel.getProxyIndex(id);

        if (proxyIndex >= 0) {
            // Grid/ListView's positionViewAtIndex needs to be given the index of the proxified model
            _viewLoader.item.positionViewAtIndex(proxyIndex, root.thumbnailSize === ThumbnailSettings.List ? ListView.Visible : GridView.Visible);
        }
    }

    function openId(id, type) {
        if (ViewManager.activeView === ViewManager.View.Trash) {
            return; // don't open trashed files
        }
        if (ViewManager.activeView === ViewManager.View.Favorites && type === Entity.Type.Folder) {
            // Move to my files to open the folder
            ViewManager.activeView = ViewManager.View.MyFiles;
            explorer.open(id);
            return;
        }

        if (ViewManager.activeView === ViewManager.View.Tags && type === Entity.Type.Folder) {
            // Move to my files to open the folder
            changeExplorerAndOpenId(id);
            return;
        }

        if (!root.movingEntities) {
            root.selection.clear();
        }

        if (ViewManager.activeView !== ViewManager.View.Integrations && type === Entity.Type.File) {
            // we don't need to check for entity in folder unless the view is MyFiles, since it will not be used
            // when adding the measurement in navigatortelemetry.cpp
            const inMyFiles = ViewManager.activeView === ViewManager.View.MyFiles;
            const entityInFolder = inMyFiles ? !root.explorer.isInRoot() : false;
            navigator.navigatorTelemetry.documentOpened(entityInFolder);
        }

        if (!toolTipLongPress.OnboardingStateProp.completed) {
            toolTipLongPress.readyToShow = true;
        } else if (toolTipLongPress.visible) {
            root.setLongPressTooltipAsCompleted();
        }

        explorer.open(id);
    }

    function addId(id) {
        root.selection.add(id);
    }

    function removeId(id) {
        if (id === undefined) {
            // We can get a call to remove when resetting the delegate.
            // In that case, we'll get an undefined id, which will
            // make the call below emit a warning, so we can just eat it here.
            return;
        }
        root.selection.remove(id);
    }

    function resetExplorer() {
        root.selection.clear();
    }

    function isSelected(id) {
        // This check might look pointless, but it's necessary so the QML engine knows
        // to reevaluate bindings to this (isSelected) function when the selection
        // changes, since isSelected() is a Q_INVOKABLE, not a Q_PROPERTY.
        //
        // So don't delete it without some care.
        if (root.selection.size === 0) {
            return false;
        }

        if (!root.selecting) {
            return false;
        }

        root.setLongPressTooltipAsCompleted();
        return root.selection.isSelected(id);
    }

    function setFolderAreaHeight(height) {
        root.folderAreaHeight = height;
    }

    navigationModel: [_viewLoader.item.headerItem, _viewLoader.item]
    canAcceptTabActivation: true
    canTakeFirstNavigationFocus: true

    onExplorerChanged: {
        if (!explorer) {
            navigator.openExplorer(ViewManager.View.MyFiles);
            return;
        }
        explorer.clearTagFilterSelection();
        explorer.update();
    }

    onSelectingChanged: {
        if (selecting) {
            scrollToEntity(root.selection.selectedIds[0])
        }
    }

    onActivated: (element) => {
        if (element) {
            element.activate();
        }
    }
    onSelected: (element) => {
        if (!root.selection.isSelected(element.entityId)) {
            element.select();
        }
    }
    onToggleSelected: (element) => {
        if (root.selection.isSelected(element.entityId)) {
            element.deselect();
        } else {
            element.select();
        }
    }

    onTabCycle: {
        if (navigator.actionHeader.visible) {
            navigator.actionHeader.resetFocusIndex();
            navigator.actionHeader.forceActiveFocus();
            navigator.actionHeader.navigate(KeyboardNavigationHandler.Direction.None, false, 1);
        } else {
            Global.keyboardNavigationController.focusOtherHandler(root);
            root.resetFocusIndex();
        }
    }

    onThumbnailSizeChanged: {
        // Reset because we're switching grid in the navigation model
        root.resetFocusIndex();
    }

    Component.onCompleted: {
        if (Global.keyboardNavigationController) {
            Global.keyboardNavigationController.registerHandler(root);
        }
    }

    Component.onDestruction: {
        if (Global.keyboardNavigationController) {
            Global.keyboardNavigationController.unregisterHandler(root);
        }
        resetExplorer();
    }

    Connections {
        target: ViewManager
        function onActiveViewChanged() {
            root.resetFocusIndex();
            if (!toolTipLongPress.OnboardingStateProp.completed) {
                root.setLongPressTooltipAsCompleted();
            }
        }
    }

    Background {
        anchors.fill: parent
        color: Values.colorWhite
    }

    ScrollContainer {
        id: scrollContainer

        visible: !emptyViewPlaceholder.visible
        anchors {
            fill: parent
            leftMargin: Values.viewHorizontalMargin
            rightMargin: Values.viewHorizontalMargin
        }
        enableScrollbar: true

        view: Loader {
            id: _viewLoader
            sourceComponent: root.thumbnailSize === ThumbnailSettings.List ? listView : gridView
        }

        onStartedMoving: {
            toolTipLongPress.closed();
        }
    }

    Component {
        id: listView

        ContentListView {
            id: contentlistview

            interactive: Experimental.smoothScroll.enabled

            rebound: Transition {
                 NumberAnimation {
                     properties: "y"
                     easing.type: Easing.OutCubic
                     easing.amplitude: 1.5
                     duration: 700
                 }
            }

            reuseItems: true
            cacheBuffer: interactive ? DeviceScreenInfo.height * 2 : 5
            boundsBehavior: interactive ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

            currentModel: root.currentModel
            rmCloudExplorer: !root.isIntegrations
            canSelect: root.selectingEnabled
            isSelecting: root.selecting
            isMoving: root.movingEntities
            sortOrder: root.ascending ? Qt.AscendingOrder : Qt.DescendingOrder
            sortType: root.sortType

            onOpen: (id, type) => { root.openId(id, type); }
            onAdd: (id) => { root.addId(id); }
            onRemove: (id) => { root.removeId(id); }
            onAbortExport: (id) => { explorer.abortExport(id); }
            onRetrySync: (id) => { explorer.retrySync(id); }
            onNavigateUp: root.navigateUp()
            navigationHandler: root
            footer: Item { height: Values.createMenuHeight + Values.createMenuBottomMargin }
            onFolderColumnHeightChanged: root.setFolderAreaHeight(contentlistview.folderColumnHeight)
            onListItemHeightChanged: root.thumbnailHeight = listItemHeight
            onWidthChanged: root.thumbnailWidth = contentlistview.width / 3
        }
    }

    Component {
        id: gridView

        ContentGridView {
            id: contentgridview

            interactive: Experimental.smoothScroll.enabled

            rebound: Transition {
                 NumberAnimation {
                     properties: "y"
                     easing.type: Easing.OutCubic
                     easing.amplitude: 1.5
                     duration: 700
                 }
            }

            cacheBuffer: interactive ? DeviceScreenInfo.height * 2 : 0
            boundsBehavior: interactive ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

            thumbnailSize: root.thumbnailSize
            currentModel: root.currentModel
            rmCloudExplorer: !root.isIntegrations
            canSelect: root.selectingEnabled
            isSelecting: root.selecting
            isMoving: root.movingEntities
            sortOrder: root.ascending ? Qt.AscendingOrder : Qt.DescendingOrder
            sortType: root.sortType

            onOpen: (id, type) => { root.openId(id, type); }
            onAdd: (id) => { root.addId(id); }
            onRemove: (id) => { root.removeId(id); }
            onAbortExport: (id) => { explorer.abortExport(id); }
            onRetrySync: (id) => { explorer.retrySync(id); }
            onInactiveItemSelected: inactiveWarning.visible = true
            onNavigateUp: root.navigateUp()
            navigationHandler: root
            footer: Item { height: Values.createMenuHeight + Values.createMenuBottomMargin }
            onFolderGridHeightChanged: root.setFolderAreaHeight(contentgridview.folderGridHeight)
            onCellHeightChanged: root.thumbnailHeight = contentgridview.cellHeight
            onCellWidthChanged: root.thumbnailWidth = contentgridview.cellWidth
        }
    }

    EmptyViewItem {
        id: emptyViewPlaceholder

        anchors.fill: parent
        topPadding: root.height * Values.emptyViewTopMarginRatio
        emptyViewKey: {
            let key = ViewManager.activeView;
            if (ViewManager.View.Tags === ViewManager.activeView &&
                root.explorer.tagFilter.length > 0) {
                key = "noTagsCombination";
            }
            else if (ViewManager.View.MyFiles === ViewManager.activeView &&
                     root.currentFolder !== root.explorer.rootId()) {
                key = "emptyFolder";
            }

            return key;
        }
        // We do not have an empty view for Integration view
        visible: !!root.currentModel?.isEmpty && !isIntegrations && Library.isReady
    }

    InactiveWarning {
        id: inactiveWarning

        visible: false
        anchors {
            // Extend to above the explorerHeader and ActionHeader to align with the top of the
            // Navigator view.
            top: parent.top
            topMargin: -Values.navigationEntriesHeaderHeight - Values.navigatorSidebarItemHeight
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
    }

    ToolTip {
        id: toolTipLongPress

        // used to position the container from the start of the documents' area, if it's visible
        readonly property int marginY: root.height <= root.folderAreaHeight ? 0 : root.folderAreaHeight

        // limits the size of the container so the less space there is below the first row - the smaller the container will be,
        // resulting in the tooltip positioning itself to the right of the document or above it.
        readonly property int containerHeight: root.height - marginY  - root.thumbnailHeight * 0.5

        readyToShow: false
        /*: Recommended character limit for translation: 20.
        Long-pressing a document will show context actions such as copy, paste etc. */
        caption: qsTr("Long-press for actions")
        OnboardingStateProp.key: "Long_Press_Entry"
        pointTo: Qt.rect(scrollContainer.x, scrollContainer.y + marginY, root.thumbnailWidth, root.thumbnailHeight * 0.9) // 0.9 - so the tooltip doesn't point too low below the thumbnail
        positionHint: ArkControls.Tooltip.Position.Below
        container: {
            let yAdjustment = 0;
            // when the folders area takes up 2 thirds or more of the screen, that's when we want the tooltip to start pointing above the
            // document and not below or to the side, so it doesn't get cut.
            if (root.height * 0.6 <= toolTipLongPress.marginY) {
                yAdjustment = root.containerHeight;
            }

            return Qt.rect(
                scrollContainer.x,
                scrollContainer.y + marginY - yAdjustment,
                scrollContainer.width,
                containerHeight
            );
        }

        OnboardingStateProp.onCompletedChanged: {
            if (OnboardingStateProp.completed) {
                readyToShow = false;
            } else {
                readyToShow = true;
            }
        }
    }
}
