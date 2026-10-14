import QtQuick

import com.remarkable
import common
import device.global
import device.ui.controls

import xofm.libs.qtgui  // WindowNavigator
import xofm.libs.explorer // ViewManager, TreeExplorer, EntitySelection
import xofm.libs.navigation // Entity
import xofm.libs.onboarding
import xofm.libs.orientation
import xofm.libs.settings

Item {
    id: root

    required property TreeExplorer explorer
    required property WindowNavigator windowNavigator
    required property EntitySelection selection

    property var currentModel: explorer.searchModel
    property bool tagSelected: explorer.selectedTags.length > 0

    property bool movingEntities: false

    readonly property int tagFilterCount: explorer.tagFilter.length
    onTagFilterCountChanged: requestSearchUpdate()
    property alias activeView: explorerHeader.activeView
    required property Orientation orientation

    property bool enabled: false

    signal openTreeExplorer(var id)

    onVisibleChanged: {
        if (visible) {
            requestSearchUpdate();
        }
    }

    function requestSearchUpdate() {
        tabControl.model[tabControl.currentIndex].action(); // calling the currently selected model action from tabControl
    }

    function searchWithArgument(types) {
        explorer.filterViewWithArguments(ViewManager.View.Tags, [], types, "", false);
    }

    ThumbnailSettings {
        id: thumbnailSettings
        settingsKey: ThumbnailSettings.Explorer
    }

    TabControl {
        id: tabControl
        anchors {
            top: explorerHeader.bottom
            left: parent.left
            leftMargin: Values.viewHorizontalMargin
            right: parent.right
            rightMargin: Values.viewHorizontalMargin
        }
        valueFunction: (index, model) => model[index].title
        model: [
            {width: 200, title: qsTr("All"),
                action: () => { root.explorer.filterView(ViewManager.View.Tags); }},
            {width: 230, title: qsTr("Pages"),
                action: () => { root.searchWithArgument([Entity.Type.Page ]); }},
            {width: 270, title: qsTr("Documents"),
                action: () => { root.searchWithArgument([Entity.Type.File]); }},
        ]
        onCurrentIndexChanged: {
            root.requestSearchUpdate();
        }
        nextNavigationHandler: tagsFilter
        previousNavigationHandler: explorerHeader
    }

    TagsFilter {
        id: tagsFilter
        explorer: root.explorer
        anchors {
            top: tabControl.bottom
            topMargin: 20
            left: parent.left
            leftMargin: Values.viewHorizontalMargin
            right: parent.right
            rightMargin: Values.viewHorizontalMargin
        }
        nextNavigationHandler: explorerView
        previousNavigationHandler: tabControl
        canAcceptTabActivation: true
        onTagSelected: {
            if (root.selection.hasSelection) {
                root.selection.clear();
            }
        }

        onViewAllTags: {
            TagUtils.openAllTagsWindow(root.windowNavigator,
                () => root.explorer.tagFilter,
                () => root.explorer.tagsInView,
                (tag) => {
                    if (root.explorer.tagFilterSelected(tag)) {
                        root.explorer.deselectTagFilter(tag);
                        return;
                    }
                    root.explorer.selectTagFilter(tag);
                }
            );
        }
    }

    ExplorerView {
        id: explorerView
        explorer: root.explorer
        currentModel: root.currentModel
        selection: root.selection
        orientation: root.orientation
        previousNavigationHandler: tagsFilter
        sortType: explorerHeader.sortType
        ascending: explorerHeader.ascending
        selectingEnabled: !root.tagSelected
        movingEntities: root.movingEntities
        thumbnailSize: thumbnailSettings.thumbnailSize
        onChangeExplorerAndOpenId: (id) => { root.openTreeExplorer(id); }
        anchors {
            top: tagsFilter.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
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

        nextNavigationHandler: tabControl

        sortDropDownVisible: !currentModel.isEmpty
        activeView: ViewManager.View.Tags
        breadcrumbModel: []
        isIntegrations: false
        thumbnailSize: thumbnailSettings.thumbnailSize
        ascending: Settings.ascendingOrder
        orientation: root.orientation

        onOpen: (id) => { explorerView.openId(id, Entity.Type.Folder); }
        onTabCycle: Global.keyboardNavigationController.focusOtherHandler(explorerHeader)
        onUpdateThumbnailSize: (thumbnailSize) => {
            thumbnailSettings.thumbnailSize = thumbnailSize;
        }
        onUpdateAscending: (ascending) => {
            Settings.ascendingOrder = ascending;
        }
    }
}
