import QtQuick

import com.remarkable   // TreeExplorer
import common   // StringUtils, Values
import device.ui.controls   // CloseShortcut
import device.ui.headers    // HeaderInput
import device.view.experimental
import device.view.syncserviceexplorer  // TagsFilter
import device.view.navigator    // dropdowns

import xofm.libs.qtgui  // WindowNavigator
import xofm.libs.orientation
import xofm.libs.search.ui  // SearchIndexStatus
import xofm.libs.controls
import xofm.libs.explorer  // EntitySortedListModel, ViewManager, EntitySelection
import xofm.libs.navigation // Entity.Type, Entity.FileType
import xofm.libs.settings   // ThumbnailSettings
import xofm.libs.onboarding

import com.remarkable.devicetelemetry
import com.remarkable.telemetry as Telemetry

import ark.controls as ArkControls

InputBlocker {
    id: root

    required property TreeExplorer treeExplorer
    required property EntitySelection selection
    required property WindowNavigator windowNavigator
    required property Orientation orientation
    required property SearchIndexStatus searchIndexStatus

    readonly property bool hwsAvailable: searchIndexStatus.status !== SearchIndexStatus.Status.Ineligible
    readonly property int tagFilterCount: treeExplorer?.tagFilter.length ?? 0

    signal cancel
    signal entityClicked(var id, var type)
    signal entityPressAndHold(var id, var type)
    signal hwsConnectTooltipCompleted

    // When opening the view from the navigator, we want some state to propegate to the search
    // I.e filters and perhaps tags later on
    function populateInitialState(filterName = _filterProps.strAll) {
        _filterProps.currentFilter = _filterProps.filterModel.find(filter => filter.label === filterName);
        searchFilterDropdown.currentFilter = _filterProps.currentFilter.label;

        // Ensure there's an update done right away, so the content is there before we are shown
        _internal.requestSearchUpdate();
    }

    // depending on whether the user is moving a page or not, update the filters model
    function updateFiltersModel(movingPage) {
        // when moving a page, "all" and "ebooks" are not visible
        if (movingPage) {
            _filterProps.hideFilterObject(_filterProps.strAll);
            _filterProps.hideFilterObject(_filterProps.strEbooks);
            searchFilterDropdown.filterModel = _filterProps.filterModel;
        }
    }

    onTagFilterCountChanged: {
        _internal.requestSearchUpdate();
    }

    CloseShortcut {
        objectName: "nav-search-close"
        onActivated: root.cancel()
    }

    QtObject {
        id: _internal

        function searchWithArguments(filetypes, types, onlyFavorites = false) {
            // only search if there is more than one letter, or tags selected
            if (inputHeader.text.length > 1 || root.tagFilterCount > 0) {
                root.treeExplorer.filterViewWithArguments(ViewManager.View.Search, filetypes, types, inputHeader.text, onlyFavorites);
                return;
            }
            // reset results if no search text or tags selected
            root.treeExplorer.clearSearchResults();
        }

        function requestSearchUpdate() {
            searchTimer.restart();
        }
    }

    QtObject {
        id: _filterProps

        readonly property string strAll: qsTr("All")
        readonly property string strEbooks: qsTr("Ebooks")
        readonly property string strHWS: qsTr("Handwriting")

        property var currentFilter: filterModel[0] // Default to "All"

        property var filterModel: [
            { label: _filterProps.strAll, icon: "qrc:/ark/icons/page_funnel",
              // Include all three types and all file types in result
              action: () => { _internal.searchWithArguments([], []); },
              visible: true
            },
            { label: qsTr(_filterProps.strHWS), icon: "qrc:/ark/icons/note",
              action: () => { _internal.searchWithArguments([], [Entity.Type.Content]); },
              visible: true
            },
            { label: qsTr("Notebooks"), icon: "qrc:/ark/icons/notebook",
              action: () => { _internal.searchWithArguments([Entity.FileType.RmDocument], []); },
              visible: true
            },
            { label: qsTr("Favorites"), icon: "qrc:/ark/icons/star",
              action: () => { _internal.searchWithArguments([], [], true); },
              visible: true
            },
            { label: qsTr("PDFs"), icon: "qrc:/ark/icons/document",
              action: () => { _internal.searchWithArguments([Entity.FileType.Pdf], []); },
              visible: true
            },
            { label: qsTr("Folders"), icon: "qrc:/ark/icons/folder",
              action: () => { _internal.searchWithArguments([], [Entity.Type.Folder]); },
              visible: true
            },
            { label: _filterProps.strEbooks, icon: "qrc:/ark/icons/ebook",
              action: () => { _internal.searchWithArguments([Entity.FileType.Epub], []); },
              visible: true
            }
        ]

        function findFilterIndex(filterName) {
            return filterModel.findIndex((filter) => filter.label === filterName);
        }

        function hideFilterObject(filterName) {
            let filterIndex = findFilterIndex(filterName);
            if (filterIndex !== -1) {
                filterModel[filterIndex].visible = false;
            }
        }
    }

    QtObject {
        id: _sortProps

        property int sortType: Experimental.relevanceSearch.enabled ? EntitySortedListModel.SortType.Relevance : EntitySortedListModel.SortType.Date
        property bool ascending: false // We want the LastModified / LastCreated item to be the first on the model
        // for UX reasons, we sort Alphabetical as A-Z when the sort order is descending
        readonly property string alphabetical: ascending
                                               //: Recommended character limit for translation: 20
                                               ? qsTr("Alphabetical (Z-A)")
                                               //: Recommended character limit for translation: 20
                                               : qsTr("Alphabetical (A-Z)")
        readonly property var sortOptions: {
            let sortOptions = [
                { key: EntitySortedListModel.SortType.Date,             name: qsTr("Last modified") },
                // Disabled until collections support it { key: EntitySortedListModel.SortType.LastOpened,       name: qsTr("Last opened") },
                { key: EntitySortedListModel.SortType.DateCreated,      name: qsTr("Date created")},
                { key: EntitySortedListModel.SortType.Alphabetically,   name: alphabetical },
                // Disabled until collections support it { key: EntitySortedListModel.SortType.Size,             name: qsTr("File size") },
            ];

            if (Experimental.relevanceSearch.enabled) {
                sortOptions = [{ key: EntitySortedListModel.SortType.Relevance, name: qsTr("Relevance") }, ...sortOptions];
            }

            return sortOptions;
        }
    }

    Timer {
        // We can request many searchs in a short amount of time, because of how we populate states in
        // search. So a timer is best to group all these updates together into only one search
        id: searchTimer
        interval: 5
        running: false
        onTriggered: _filterProps.currentFilter?.action()
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
        target: root.treeExplorer
        function onSearchTimeElapsed(elapsedMs) {
            searchExecutionTelemetry.lastSearchTime = elapsedMs;
            searchMeasurementGraceTimer.restart();
        }
    }

    HeaderInput {
        id: inputHeader

        visible: true
        blackOnWhite: false
        focus: true
        width: parent.width
        //: Closes search view
        rejectText: qsTr("Back")

        confirmText: !!inputHeader.text ? qsTr("Clear") : ""
        confirmItem.enabled: !!inputHeader.text
        iconSource: "qrc:/ark/icons/lens"
        placeholder: qsTr("Search")

        confirmItem.onClicked: {
            inputHeader.focus = true;
            inputHeader.inputField.clear();
        }
        onInputChanged: {
              _internal.requestSearchUpdate();
        }
        onRejected: {
            root.cancel();
        }

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
                if (!Qt.inputMethod.visible && inputHeader.focus) {
                    // remove selection and cursor
                    inputHeader.focus = false;
                } else {
                    inputHeader.focus = true;
                }
            }
        }
    }

    TagsFilter {
        id: tagFilter
        anchors {
            top: inputHeader.bottom
            topMargin: Values.navigatorMargin
            left: parent.left
            right: parent.right
            leftMargin: Values.designGridVerticalSpacing
            rightMargin: Values.designGridVerticalSpacing
        }
        explorer: root.treeExplorer
        canEdit: false
        onViewAllTags: {
            TagUtils.openAllTagsWindow(root.windowNavigator,
                () => root.treeExplorer.tagFilter,
                () => root.treeExplorer.tagsInView,
                (tag) => {
                    if (root.treeExplorer.tagFilterSelected(tag)) {
                        root.treeExplorer.deselectTagFilter(tag);
                        return;
                    }
                    root.treeExplorer.selectTagFilter(tag);
                }
            );
        }
    }

    property Component searchEntity: ContentListItem {
        id: searchListItem
        property var model

        width: searchListView.width

        onClicked: root.entityClicked(model.id, model.type)
        onPressAndHold: root.entityPressAndHold(model.id, model.type)
        navigationHandler: listViewHandler
    }

    DeviceKeyboardNavigationHandler {
        id: listViewHandler
        objectName: "SearchView"
        navigationModel: [searchListView]
        previousNavigationHandler: inputHeader

        onActivated: (element) => {
            element.instance.clicked(element.model.id, element.model.type);
        }
        onSelected: (element) => {
            element.instance.clicked(element.model.id, element.model.type);
        }
        onToggleSelected: (element) => {
            element.instance.pressAndHold(element.model.id, element.model.type);
        }

        anchors {
            top: listHeader.bottom
            bottom: parent.bottom
            left: parent.left
            leftMargin: Values.navigatorMargin
            rightMargin: Values.navigatorMargin
            right: parent.right
        }

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
                    model: root.treeExplorer?.searchModel ?? null
                    sortType: _sortProps.sortType
                    sortOrder: _sortProps.ascending ? Qt.AscendingOrder : Qt.DescendingOrder
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
                        instance.path = Qt.binding(() => root.treeExplorer.fullPath(model?.id));
                        instance.drawFocus = Qt.binding(() => listViewHandler.current === searchItemContainer);
                        instance.wordHits = Qt.binding(() => model?.wordHits ?? 0);

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
            visible: !root.hwsAvailable && _filterProps.currentFilter?.label === _filterProps.strHWS && false
        }
    }

    Item {
        id: listHeader
        height: sortDropdown.height
        anchors {
            top: tagFilter.hasTags ?  tagFilter.bottom : inputHeader.bottom
            topMargin: Values.navigatorMargin
            left: parent.left
            leftMargin: Values.navigatorMargin
            rightMargin: Values.navigatorMargin
            right: parent.right
        }

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
            overlayRoot: root
            anchors {
                right: sortDropdown.left
                rightMargin: root.orientation.isPortraitOrientation ? 0 : 24
                verticalCenter: parent.verticalCenter
            }
            height: Values.navigatorDropdownHeaderHeight
            visible: root.selection.size === 0
            filterModel: _filterProps.filterModel

            onUpdateFilter: (filter) => {
                _filterProps.currentFilter = _filterProps.filterModel[filter]
                _internal.requestSearchUpdate();
            }
            onFilterButtonClicked: {
                hwsConnectTooltip.OnboardingStateProp.completed = true;
                hwsNoConnectTooltip.OnboardingStateProp.completed = true;
            }
        }

        QtObject {
            id: tooltipHelpers

            // the area for the tooltip is all the space underneath the header
            readonly property int containerHeight: root.height - inputHeader.height - tagFilter.height - listHeader.height
            readonly property var pointTo: searchFilterDropdown
            readonly property var container: Qt.rect(0, 0, listViewHandler.width, tooltipHelpers.containerHeight)
        }

        ToolTip {
            id: hwsConnectTooltip

            readyToShow: root.searchIndexStatus.initialIndexCompleted
            caption: qsTr("Handwriting search")
            OnboardingStateProp.key: "HWS_Connect"
            pointTo: tooltipHelpers.pointTo
            container: tooltipHelpers.container

            OnboardingStateProp.onCompletedChanged: {
                if (hwsConnectTooltip.OnboardingStateProp.completed) {
                    root.searchIndexStatus.clearInitialIndexCompleted();
                    root.hwsConnectTooltipCompleted();
                }
            }
        }

        ToolTip {
            id: hwsNoConnectTooltip

            readyToShow: root.hwsAvailable
            caption: qsTr("Searchable content filter")
            OnboardingStateProp.key: "HWS_No_Connect"
            pointTo: tooltipHelpers.pointTo
            container: tooltipHelpers.container
        }

        SortDropdown {
            // Qt Properties
            id: sortDropdown
            name: "searchDropdown"
            overlayRoot: root
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            // SortDropdown Properties
            model: _sortProps.sortOptions
            ascending: _sortProps.ascending
            sortType: _sortProps.sortType
            thumbnailSize: ThumbnailSettings.List
            showThumbnailOptions: false
            orientation: root.orientation

            Connections {
                target: root.orientation
                function onOrientationChanged() {
                    sortDropdown.requestUpdateGeometry();
                }
            }

            // Slots
            onUpdateSortType: (sortType) => {
                _sortProps.sortType = sortType;
            }
            onUpdateAscending: (ascending) => {
                _sortProps.ascending = ascending;
            }
        }
    }
}
