import QtQuick
import com.remarkable
import common
import device.global
import device.ui.text
import device.ui.controls
import device.ui.headers
import device.view.experimental
import device.view.navigator

import xofm.libs.qtgui  // WindowNavigator
import xofm.libs.explorer // TreeExplorer, ViewManager, EntityListModel, EntitySortedListModel
import xofm.libs.navigation // Entity.Type, Entity.FileType
import xofm.libs.orientation
import xofm.libs.settings
import xofm.libs.onboarding // ToolTip

import xofm.libs.search.ui // SearchIndexStatus
import xofm.libs.system // SearchNotificationBar.qml

import com.remarkable.devicetelemetry
import com.remarkable.telemetry as Telemetry

import ark.controls as ArkControls

FocusScope {
    id: search

    onVisibleChanged: {
        if (visible) {
            search.focus = false;
            searchHeader.forceActiveFocus();
        }
    }

    readonly property string _strAll: qsTr("All")
    readonly property string _strEbooks: qsTr("Ebooks")
    readonly property string _strHWS: qsTr("Handwriting")

    required property TreeExplorer treeExplorer
    required property WindowNavigator windowNavigator
    property Orientation orientation
    readonly property int tagFilterCount: treeExplorer.tagFilter.length
    property bool showFilter: true
    onTagFilterCountChanged: requestSearchUpdate()
    focus: visible

    required property SearchIndexStatus searchIndexStatus
    readonly property bool hwsAvailable: searchIndexStatus.status !== SearchIndexStatus.Status.Ineligible

    signal entityClicked(var id, var type)
    signal entityPressAndHold(var id, var type)
    signal cancel
    signal hwsConnectTooltipCompleted

    Background {
        anchors.fill: parent
    }

    CloseShortcut {
        objectName: "nav-search-close"
        onActivated: cancel()
    }

    property var filterModel: [
        { label: search._strAll, icon: "qrc:/ark/icons/page_funnel",
          // Include all three types and all file types in result
          action: () => { searchWithArguments([], []); },
          visible: true
        },
        { label: qsTr(search._strHWS), icon: "qrc:/ark/icons/note",
          action: () => { searchWithArguments([], [Entity.Type.Content]); },
          visible: true
        },
        { label: qsTr("Notebooks"), icon: "qrc:/ark/icons/notebook",
          action: () => { searchWithArguments([Entity.FileType.RmDocument], []); },
          visible: true
        },
        { label: qsTr("Favorites"), icon: "qrc:/ark/icons/star",
          action: () => { searchWithArguments([], [], true); },
          visible: true
        },
        { label: qsTr("PDFs"), icon: "qrc:/ark/icons/document",
          action: () => { searchWithArguments([Entity.FileType.Pdf], []); },
          visible: true
        },
        { label: qsTr("Folders"), icon: "qrc:/ark/icons/folder",
          action: () => { searchWithArguments([], [Entity.Type.Folder]); },
          visible: true
        },
        { label: search._strEbooks, icon: "qrc:/ark/icons/ebook",
          action: () => { searchWithArguments([Entity.FileType.Epub], []); },
          visible: true
        }
    ]

    // SortDropdown Model
    // for UX reasons, we sort Alphabetical as A-Z when the sort order is descending
    readonly property string alphabetical: searchProperties.ascending
                                           //: Recommended character limit for translation: 20
                                           ? qsTr("Alphabetical (Z-A)")
                                           //: Recommended character limit for translation: 20
                                           : qsTr("Alphabetical (A-Z)")

    readonly property var sortOptions: Experimental.relevanceSearch.enabled ? [
        { key: EntitySortedListModel.SortType.Relevance,        name: qsTr("Relevance") },
        { key: EntitySortedListModel.SortType.Date,             name: qsTr("Last modified") },
        { key: EntitySortedListModel.SortType.DateCreated,      name: qsTr("Date created")},
        { key: EntitySortedListModel.SortType.Alphabetically,   name: alphabetical },
    ] : [
        { key: EntitySortedListModel.SortType.Date,             name: qsTr("Last modified") },
        // Disabled until collections support it { key: EntitySortedListModel.SortType.LastOpened,       name: qsTr("Last opened") },
        { key: EntitySortedListModel.SortType.DateCreated,      name: qsTr("Date created")},
        { key: EntitySortedListModel.SortType.Alphabetically,   name: alphabetical },
        // Disabled until collections support it { key: EntitySortedListModel.SortType.Size,             name: qsTr("File size") },
    ]

    function searchWithArguments(filetypes, types, onlyFavorites = false) {
        // only search if there is more than one letter, or tags selected
        if (searchHeader.text.length > 1 || tagFilterCount > 0) {
            treeExplorer.filterViewWithArguments(ViewManager.View.Search, filetypes, types, searchHeader.text, onlyFavorites);
            return;
        }
        // reset results if no search text or tags selected
        treeExplorer.clearSearchResults();
    }

    // When opening the view from the navigator, we want some state to propegate to the search
    // I.e filters and perhaps tags
    function populateInitialState(filterName = search._strAll) {
        searchProperties.filterObject = filterModel.find(filter => filter.label === filterName);
        searchFilterDropdown.currentFilter = searchProperties.filterObject.label;

        // Ensure there's an update done right away, so the content is there before we are shown.
        // Don't use requestSearchUpdate! That will delay, meaning our initial content may be wrong!
        searchProperties.filterObject?.action()
    }

    function requestSearchUpdate() {
        searchTimer.restart();
    }

    function findFilter(txt) {
        for (var i=0; i<search.filterModel.length; ++i) {
            if (search.filterModel[i].label === txt)
                return i;
        }
        return -1;
    }

    // depending on whether the user is moving a page or not, update the filters model
    function updateFiltersModel(movingPage) {
        // when moving a page, "all" and "ebooks" are not visible
        let change = false;
        let filt = findFilter(search._strAll);

        if (filt >= 0) {
            search.filterModel[filt].visible = !movingPage;
            change = true;
        }

        filt = findFilter(search._strEbooks);
        if (filt >= 0) {
            search.filterModel[filt].visible = !movingPage;
            change = true;
        }

        if (change) {
            // provide the updated model to searchFilterDropdown
            searchFilterDropdown.filterModel = search.filterModel;
        }
    }

    SearchExecutionTelemetry {
        id: searchExecutionTelemetry
        dispatcher: Telemetry.Dispatcher

        property int lastSearchTime: -1

        function reportIndexSearchTime() {
            if (lastSearchTime <= 0) {
                return;
            }
            searchExecutionTelemetry.indexSearchQueryExecuted(lastSearchTime);
            lastSearchTime = -1;
        }
    }

    Timer {
        id: searchMeasurementGraceTimer
        interval: 2500 // only measure when the user has stopped typing (a 'complete' search)
        repeat: false
        onTriggered: searchExecutionTelemetry.reportIndexSearchTime()
    }

    Connections {
        target: explorer
        function onSearchTimeElapsed(elapsedMs) {
            searchExecutionTelemetry.lastSearchTime = elapsedMs;
            searchMeasurementGraceTimer.restart();
        }
    }

    Timer {
        // We can request many searchs in a short amount of time, because of how we populate states in
        // search. So a timer is best to group all these updates together into only one search
        id: searchTimer
        interval: 5
        running: false
        onTriggered: searchProperties.filterObject?.action()
    }

    HeaderInput {
        id: searchHeader
        blackOnWhite: false
        visible: true
        focus: true
        z: 1
        width: parent.width
        //: Closes search view
        rejectText: qsTr("Back")
        onRejected: {
            search.cancel();
        }
        confirmText: !!text ? qsTr("Clear") : ""
        confirmItem.enabled: !!text
        confirmItem.onClicked: {
            searchHeader.focus = true;
            inputField.clear();
        }

        iconSource: "qrc:/ark/icons/lens"
        placeholder: qsTr("Search")
        onInputChanged: requestSearchUpdate()

        Keys.onPressed: (event) => {
            // We gotta eat the event when we want to
            // navigate out of the input field
            if (event.key === Qt.Key_Down){
                event.accepted = true;
                if (searchListView.count === 0) {
                    return;
                }

                listViewHandler.forceActiveFocus();
                listViewHandler.navigate();
            }
        }
        Connections {
            target: Qt.inputMethod
            enabled: !KeyboardInfo.keyboardConnected
            function onVisibleChanged() {
                if(!Qt.inputMethod.visible && searchHeader.focus) {
                    // remove selection and cursor
                    searchHeader.focus = false;
                } else {
                    searchHeader.focus = true;
                }
            }
        }
    }

    Item {
        id: searchProperties
        property var filterObject // from the model
        property int sortType: Experimental.relevanceSearch.enabled ? EntitySortedListModel.SortType.Relevance : EntitySortedListModel.SortType.Date
        property bool ascending: false // We want the LastModified / LastCreated item to be the first on the model
    }

    TagsFilter {
        id: tagFilter
        anchors {
            top: searchHeader.bottom
            topMargin: Values.navigatorMargin
            left: parent.left
            right: parent.right
            leftMargin: Values.designGridVerticalSpacing
            rightMargin: Values.designGridVerticalSpacing
        }
        explorer: search.treeExplorer
        canEdit: false
        onViewAllTags: {
            TagUtils.openAllTagsWindow(search.windowNavigator,
                () => search.treeExplorer.tagFilter,
                () => search.treeExplorer.tagsInView,
                (tag) => {
                    if (search.treeExplorer.tagFilterSelected(tag)) {
                        search.treeExplorer.deselectTagFilter(tag);
                        return;
                    }
                    search.treeExplorer.selectTagFilter(tag);
                }
            );
        }
    }

    property Component searchEntity: ContentListItem {
        id: searchListItem
        property var model

        width: searchListView.width

        onClicked: search.entityClicked(model.id, model.type)
        onPressAndHold: search.entityPressAndHold(model.id, model.type)
        navigationHandler: listViewHandler
    }

    DeviceKeyboardNavigationHandler {
        id: listViewHandler
        objectName: "SearchView"
        navigationModel: [searchListView]
        previousNavigationHandler: searchHeader

        onActivated: (element) => {
            element.instance.clicked(element.model.id, element.model.type);
        }
        onSelected: (element) => {
            element.instance.clicked(element.model.id, element.model.type);
        }
        onToggleSelected: (element) => {
            element.instance.pressAndHold(element.model.id, element.model.type);
        }

        anchors.top: listHeader.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: Values.navigatorMargin
        anchors.rightMargin: Values.navigatorMargin
        anchors.right: parent.right

        ScrollContainer {
            visible: !hwsEmptyState.visible
            anchors.fill: parent
            enableScrollbar: true

            view: ListView {
                id: searchListView

                interactive: Experimental.smoothScroll.enabled
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                onVerticalOvershootChanged: {
                    if (verticalOvershoot < 0) {
                        searchListView.positionViewAtBeginning();
                    }
                }

                model: EntitySortedListModel {
                    model: treeExplorer.searchModel
                    sortType: searchProperties.sortType
                    currentSortOrder: searchProperties.ascending ? Qt.AscendingOrder : Qt.DescendingOrder
                }

                property var usedDelegates: [] // Cache for recycled delegate instances

                delegate: Item {
                    id: searchItemContainer
                    required property var model

                    // To avoid recreating items from scratch we keep a cache of used instances
                    property Item instance

                    width: searchListView.width - Values.navigatorContentListItemMargin
                    height: Values.navigatorContentListItemHeight + Values.navigatorMargin

                    function activate() {
                        if (instance) {
                            instance.activate();
                        } else {
                            console.warn("No instance available to activate!");
                        }
                    }

                    Component.onDestruction: {
                        if (instance === null) {
                            return;
                        }
                        instance.visible = false;
                        // Reset any internal state before recycling
                        if (typeof instance.reset === "function") {
                            instance.reset();
                        }
                        instance.parent = null; // Detach from visual tree
                        searchListView.usedDelegates.push(instance);
                        instance = null;
                    }

                    Component.onCompleted: {
                        // Retrieve from cache or create on demand
                        if (searchListView.usedDelegates.length > 0) {
                            instance = searchListView.usedDelegates.pop();
                        } else {
                            instance = searchEntity.createObject();
                        }

                        if (!instance) {
                            console.error("Failed to get or create search item instance!");
                            return;
                        }

                        // Ensure the instance is parented correctly and visible
                        instance.parent = searchItemContainer;

                        // Bind model-dependent properties with null checks only if instance is valid
                        instance.model = Qt.binding(() => searchItemContainer.model ?? null);
                        instance.entityId = Qt.binding(() => model?.id ?? "");
                        instance.author = Qt.binding(() => model?.author ?? "");
                        instance.isFavorite = Qt.binding(() => model?.isFavorite ?? false);
                        instance.childCount = Qt.binding(() => model?.childCount ?? 0);
                        instance.childIndex = Qt.binding(() => model?.childIndex ?? 0);
                        instance.passwordProtected = Qt.binding(() => model?.isPasswordProtected ?? false);
                        instance.progress = Qt.binding(() => model?.progress ?? 0.0);
                        instance.publicationDate = Qt.binding(() => model?.publicationDate ?? "");
                        instance.publisher = Qt.binding(() => model?.publisher ?? "");
                        instance.size = Qt.binding(() => StringUtils.formatSizeInBytes(model.size ?? 0));
                        instance.syncStatus = Qt.binding(() => model?.syncStatus ?? EntityListModel.Status.Idle);
                        instance.tags = Qt.binding(() => model?.tags ?? []);
                        instance.thumbnail = Qt.binding(() => model?.thumbnail ?? "");
                        instance.asynchronousThumbnail = Qt.binding(() => model?.asynchronousThumbnail ?? false);
                        instance.title = Qt.binding(() => model?.name ?? "");
                        instance.type = Qt.binding(() => model?.type ?? Entity.Type.File);
                        instance.filetype = Qt.binding(() => model?.filetype ?? Entity.FileType.Unsupported);
                        instance.isNew = Qt.binding(() => model?.isNew ?? false);
                        instance.path = Qt.binding(() => treeExplorer.fullPath(model?.id));
                        instance.drawFocus = Qt.binding(() => listViewHandler.current === searchItemContainer);
                        instance.wordHits = Qt.binding(() => model?.wordHits ?? 0);
                        instance.documentWordHits = Qt.binding(() => model?.documentWordHits ?? 0);

                        // Make the instance visible after setup
                        instance.visible = true;
                    }
                }

                onMovingChanged: Qt.inputMethod.hide();
            }
            onStartedMoving: Qt.inputMethod.hide();
        }

        EmptyViewItem {
            id: hwsEmptyState
            anchors.fill: parent
            topPadding: parent.height * (Values.emptyViewTopMarginRatio / 2)
            emptyViewKey: "noConnectHWS"
            visible: !search.hwsAvailable && searchProperties.filterObject?.label === search._strHWS
        }
    }

    Item {
        id: listHeader
        height: sortDropdown.height
        anchors.top: tagFilter.hasTags ?  tagFilter.bottom : searchHeader.bottom
        anchors.topMargin: Values.navigatorMargin
        anchors.left: parent.left
        anchors.leftMargin: Values.navigatorMargin
        anchors.rightMargin: Values.navigatorMargin
        anchors.right: parent.right

        ArkControls.Title {
            objectName: "searchMatches"
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            type: ArkControls.Title.Large
            //: Requires plural form
            text: qsTr("%n matches", "", searchListView.count)
        }

        SearchFilterDropdown {
            id: searchFilterDropdown
            name: "searchFilterDropdown"
            overlayRoot: search
            anchors {
                right: sortDropdown.left
                rightMargin: orientation.isPortraitOrientation ? 0 : 24
                verticalCenter: parent.verticalCenter
            }
            height: Values.navigatorDropdownHeaderHeight
            visible: search.showFilter
            filterModel: search.filterModel

            onUpdateFilter: (filter) => {
                searchProperties.filterObject = search.filterModel[filter]
                requestSearchUpdate();
            }
            onFilterButtonClicked: {
                hwsConnectTooltip.OnboardingStateProp.completed = true;
                hwsNoConnectTooltip.OnboardingStateProp.completed = true;
            }
        }

        QtObject {
            id: tooltipHelpers

            // the area for te tooltip is all the space underneath the header
            readonly property int containerHeight: search.height - searchHeader.height - tagFilter.height - listHeader.height
            readonly property var pointTo: searchFilterDropdown
            readonly property var container: Qt.rect(0, 0, listViewHandler.width, tooltipHelpers.containerHeight)
        }

        ToolTip {
            id: hwsConnectTooltip

            readyToShow: search.searchIndexStatus.initialIndexCompleted
            caption: qsTr("Handwriting search")
            OnboardingStateProp.key: "HWS_Connect"
            pointTo: tooltipHelpers.pointTo
            container: tooltipHelpers.container

            OnboardingStateProp.onCompletedChanged: {
                if (hwsConnectTooltip.OnboardingStateProp.completed) {
                    search.searchIndexStatus.clearInitialIndexCompleted();
                    search.hwsConnectTooltipCompleted();
                }
            }
        }

        ToolTip {
            id: hwsNoConnectTooltip

            readyToShow: !search.hwsAvailable
            caption: qsTr("Searchable content filter")
            OnboardingStateProp.key: "HWS_No_Connect"
            pointTo: tooltipHelpers.pointTo
            container: tooltipHelpers.container
        }

        SortDropdown {
            // Qt Properties
            id: sortDropdown
            name: "searchDropdown"
            overlayRoot: search
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            // SortDropdown Properties
            model: sortOptions
            ascending: searchProperties.ascending
            sortType: searchProperties.sortType
            thumbnailSize: ThumbnailSettings.List
            showThumbnailOptions: false
            orientation: search.orientation

            Connections {
                target: search.orientation
                function onOrientationChanged() {
                    sortDropdown.requestUpdateGeometry();
                }
            }

            // Slots
            onUpdateSortType: (sortType) => {
                                  searchProperties.sortType = sortType;
                              }
            onUpdateAscending: (ascending) => {
                                   searchProperties.ascending = ascending;
                               }
        }
    }

    SearchNotificationBar {
        id: searchNotificationBar

        searchIndexStatus: search.searchIndexStatus
        anchors {
            left: parent.left
            right: parent.right
            bottom: listViewHandler.bottom
            bottomMargin: Qt.inputMethod.keyboardRectangle.height === 0 ? 0 : Qt.inputMethod.keyboardRectangle.height + 2
        }
    }
}
