import QtQuick

import com.remarkable // import for NavigationManager
import common

import device.ui.controls
import device.ui.text
import device.view.navigator

import xofm.libs.explorer // ViewManager, EntitySortedListModel
import xofm.libs.orientation
import xofm.libs.settings

import ark.controls as ArkControls

DeviceKeyboardNavigationHandler {
    id: headerItem
    navigationModel: [sortDropdown]

    signal open(var id)

    property int activeView
    property var breadcrumbModel
    property bool isIntegrations
    // Enum: EntitySortedListModel.SortType
    property alias sortType: sortDropdown.sortType
    // Enum: ThumbnailSettings.ThumbnailSize
    required property int thumbnailSize
    required property bool ascending
    property bool sortDropDownVisible: true
    property var activeMapping: myfilesMapping
    property alias isSortDropdownOpen: sortDropdown.isOpen
    property Orientation orientation

    signal updateAscending(bool ascending)
    signal updateThumbnailSize(int thumbnailSize)

    // SortDropdown Model
    // for UX reasons, we sort Alphabetical as A-Z when the sort order is descending
    readonly property string alphabetical: headerItem.ascending
                                           //: Recommended character limit for translation: 20
                                           ? QT_TR_NOOP("Alphabetical (Z-A)")
                                           //: Recommended character limit for translation: 20
                                           : QT_TR_NOOP("Alphabetical (A-Z)")
    readonly property string lastModified: headerItem.activeView === ViewManager.View.Trash ? QT_TR_NOOP("Date removed") : QT_TR_NOOP("Last modified")

    readonly property var integrationMapping: [
        { key: EntitySortedListModel.SortType.Date,             name: lastModified},
        { key: EntitySortedListModel.SortType.Alphabetically,   name: alphabetical },
        { key: EntitySortedListModel.SortType.Size,             name: QT_TR_NOOP("File size") },
        { key: EntitySortedListModel.SortType.FileType,         name: QT_TR_NOOP("File type") },
    ]

    readonly property var myfilesMapping: [
        { key: EntitySortedListModel.SortType.Date,             name: lastModified },
        { key: EntitySortedListModel.SortType.LastOpened,       name: QT_TR_NOOP("Last opened") },
        { key: EntitySortedListModel.SortType.DateCreated,      name: QT_TR_NOOP("Date created")},
        { key: EntitySortedListModel.SortType.Alphabetically,   name: alphabetical },
        { key: EntitySortedListModel.SortType.Size,             name: QT_TR_NOOP("File size") },
        { key: EntitySortedListModel.SortType.PageCount,        name: QT_TR_NOOP("Page count") },
    ]

    Connections {
        target: ViewManager
        function onActiveViewChanged() {
            updateSortMap();
        }
    }

    anchors {
        left: parent.left
        right: parent.right
        rightMargin: -Values.designGridMargin
    }
    onActivated: current?.toggleOpen()
    onFocusChanged: {
        // if we navigate away from the breadcrumb or the dropdown,
        // make sure we close the dropdown so it's not stuck open.
        if (!focus && !sortDropdown.focus) {
            sortDropdown.hide();
        }
    }

    onWillNavigate: (direction) => {
        // Update the previous chained handler depending on which toolbar is visible.
        // This allows us to navigate up to the toolbar using cursor keys too.
        if (direction === KeyboardNavigationHandler.Direction.Up) {
            if (actionHeader.visible) {
               headerItem.previousNavigationHandler = actionHeader;
               actionHeader.nextNavigationHandler = headerItem;
            } else if (contentHeader.visible && headerItem.previousNavigationHandler !== contentHeader) {
                headerItem.previousNavigationHandler = contentHeader;
                contentHeader.nextNavigationHandler = headerItem;
            }
        }
    }

    function updateSortMap() {
        if (isIntegrations) {
            headerItem.activeMapping = integrationMapping;
        } else if (!isIntegrations) {
            headerItem.activeMapping = myfilesMapping;
        }
    }

    Background {
        anchors.fill: parent
        color: Values.colorWhite
    }

    function navigationTitle(view) {
        switch (view) {
            case ViewManager.View.Notebooks:
                return qsTr("Notebooks");
            case ViewManager.View.Pdfs:
                return qsTr("PDFs");
            case ViewManager.View.Ebooks:
                return qsTr("Ebooks");
            case ViewManager.View.Favorites:
                return qsTr("Favorites");
            case ViewManager.View.Tags:
                return qsTr("Tags");
            case ViewManager.View.Trash:
                return qsTr("Trash");
            default:
                return null;
        }
    }

    ListModel {
        id: titleModel
    }

    ExplorerBreadcrumb {
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
        width: headerItem.width  - sortDropdown.width - Values.navigatorMargin
        height: headerItem.height
        onOpen: (id) => { headerItem.open(id); }
        breadcrumbModel: {
            const title = navigationTitle(headerItem.activeView);
            if (title) {
                // You cannot create a model with [ {name: navigationTitle()} ] because when you
                // use the model in a ListView delegate you only get the property "modelData" and not the
                // property "model" which both QAbstractListModel and ListModel provide instead.
                titleModel.clear();
                titleModel.append({id: "", name: title});
                return titleModel;
            }
            return headerItem.breadcrumbModel;

        }
    }

    SortDropdown {
        // Qt Properties
        id: sortDropdown
        name: "explorerDropdown"
        anchors {
            right: parent.right
            rightMargin: Values.designGridVerticalSpacing
            verticalCenter: parent.verticalCenter
        }

        // SortDropdown Properties
        visible: headerItem.sortDropDownVisible
        navigationHandler: headerItem
        previousNavigationHandler: parent
        sortType: isIntegrations ? Settings.thirdPartySortOrder : Settings.homeSortOrder
        ascending: headerItem.ascending
        thumbnailSize: headerItem.thumbnailSize
        model: headerItem.activeMapping
        overlayRoot: navigator
        orientation: headerItem.orientation

        // Slots
        onUpdateSortType: (sortType) => {
            if (isIntegrations) {
                Settings.thirdPartySortOrder = sortType;
            } else {
                Settings.homeSortOrder = sortType;
            }
            updateSortMap();
        }
        onUpdateAscending: (ascending) => {
            headerItem.updateAscending(ascending);
            updateSortMap();
        }
        onUpdateThumbnailSize: (thumbnailSize) => {
            headerItem.updateThumbnailSize(thumbnailSize);
        }
    }
}
