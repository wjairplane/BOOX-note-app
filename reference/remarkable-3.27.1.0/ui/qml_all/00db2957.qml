import QtQuick
import common
import com.remarkable
import device.global
import device.ui.text
import device.ui.controls
import device.view.documentview
import device.view.experimental

import xofm.libs.settings
import xofm.libs.qtgui  // WindowNavigator

DeviceKeyboardNavigationHandler {
    id: root

    required property Item documentView
    required property int currentPage
    required property WindowNavigator windowNavigator
    required property var tags
    property Document document
    property bool goToPageEnabled: false
    property bool selecting: false
    property bool selectionLocked: false

    property PageSelection pageSelection
    property var model: TagUtils.getPagesFromSelectedTags(document, tagFilter.selectedTags, tags)

    function clearSelectedTags() {
        tagFilter.clearSelectedTags();
    }

    signal openPage(int page, int position)

    function showPage(pageNumber) {
        var realPageNumber = Math.min(pageNumber, document.pageCount - 1);
        if (pageOverviewThumbnail.listMode) {
            listView.positionViewAtIndex(realPageNumber, GridView.Center);
        } else {
            gridView.positionViewAtIndex(realPageNumber, GridView.Center);
        }
    }

    function showCurrentOrSelected() {
        if (!pageSelection.isEmpty) {
            showPage(pageSelection.pages[0]);
        } else if (document && currentPage >= 0) {
            showPage(currentPage);
        } else if (document) {
            showPage(document.lastOpenedPage);
        }
    }

    function scrollToTop() {
        (pageOverviewThumbnail.listMode ? listView : gridView).positionViewAtBeginning();
    }

    function updateTags(selection = []) {
        let tagsList = [];
        if (document) {
            tagsList = tagFilter.sortSelectedFirst(document.tagLabels(false, selection));
        }
        tagFilter.tags = tagsList;
    }

    navigationModel: [gridView, listView]
    onActivated: current?.activate()
    onSelected: element.select()
    onToggleSelected: element.toggle()

    onWidthChanged: contentDropdown.updateGeometry()
    onVisibleChanged: {
        if (visible && document) {
            showCurrentOrSelected();
            tagFilter.clearSelectedTags();
            forceActiveFocus();
        }
        contentDropdown.hide();
    }

    ThumbnailSettings {
        id: pageOverviewThumbnail
        settingsKey: ThumbnailSettings.PageOverview
        readonly property bool listMode: thumbnailSize === ThumbnailSettings.List
    }

    Rectangle {
        id: contentHeader
        height: Values.navigationEntriesHeaderHeight + (bottomColumn.visible ? bottomColumn.height + 20 : 0)
        width: parent.width
        color: Values.colorWhite
        z: 1

        IconButton {
            id: selectButton
            visible: root.selecting
            title: !!root.document && root.pageSelection.count === root.document.pageCount ? qsTr("Unselect all") : qsTr("Select all")
            anchors.left: parent.left
            onClicked: {
                if (root.pageSelection.count === root.document.pageCount) {
                    root.pageSelection.clear();
                } else {
                    root.pageSelection.clear();
                    var allPages = [];
                    for (var page = 0; page < root.document.pageCount; page++) {
                        allPages.push(page);
                    }
                    root.pageSelection.pages = allPages;
                }
            }
        }

        ContentDropdown {
            id: contentDropdown
            name: "pageOverviewDropdown"
            overlayRoot: root
            anchors {
                right: parent.right
                verticalCenter: toc_goToPageMouseArea.verticalCenter
                rightMargin: Values.designGridHorizontalGutter
            }
            thumbnailSize: pageOverviewThumbnail.thumbnailSize
            onUpdateThumbnailSize: (thumbnailSize) => {
                pageOverviewThumbnail.thumbnailSize = thumbnailSize;
            }
        }

        MouseArea {
            // to avoid click on hidden items
            anchors {
                right: contentDropdown.left
                left: toc_goToPageMouseArea.right
            }
            height: parent.height
        }

        IconButton {
            id: toc_goToPageMouseArea
            anchors.left: parent.left
            onClicked: {
                goToPageHeader.visible = true
                goToPageHeader.forceActiveFocus();
            }
            visible: !root.selecting
            iconSource: "qrc:/ark/icons/go_to_page"
            wrapMode: Text.NoWrap
            title: qsTr("Go to page")
        }

        Column {
            id: bottomColumn
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: 10
                margins: 30
            }
            spacing: 30
            visible: tagFilter.tags.length > 0

            TagFilter {
                id: tagFilter
                width: parent.width
                maxTagRows: 1
                maxVisibleRows: 1
                windowNavigator: root.windowNavigator
                onNewTagsSelection: (selection) => {
                    root.updateTags(selection);
                }
            }

            TextHeaderSmall {
                font.capitalization: Font.AllUppercase
                text: (tagFilter.selectedTags.length
                       ? qsTr("Tagged pages")
                       : qsTr("All pages"))
                      + qsTr(" (%0)").arg(root.model.length)
                width: parent.width

                TextHeaderSmall {
                    font.underline: true
                    visible: root.model.length > 0
                    text: !!root.pageSelection && root.pageSelection.isEmpty ? qsTr("Select all") : qsTr("Unselect all")
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -40
                        onClicked: {
                            if (root.pageSelection.isEmpty) {
                                root.pageSelection.setPageNumbers(root.model)
                            } else {
                                root.pageSelection.clear();
                            }
                        }
                    }
                }
            }
        }
    }

    ScrollContainer {
        id: scrollOverlay
        visible: !noTagsEmptyView.visible
        anchors {
            top: contentHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        leftMargin: Values.viewHorizontalMargin
        rightMargin: Values.viewHorizontalMargin
        enableScrollbar: true
        scrollbarRightMargin: Values.viewHorizontalMargin
        view: pageOverviewThumbnail.listMode ? listView : gridView
    }

    ThumbnailGridSize {
        id: thumbnailGridSize
        thumbnailSize: pageOverviewThumbnail.thumbnailSize
        width: scrollOverlay.view.width
    }

    GridView {
        id: gridView
        visible: !pageOverviewThumbnail.listMode
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: Experimental.smoothScroll.enabled
        cellHeight: thumbnailGridSize.gridItemHeight
        cellWidth: thumbnailGridSize.gridItemWidth
        model: visible ? root.model : 0
        onModelChanged: {
            // if we have a stash, the page was copied and will be positioned
            // elsewhere
            if (model) {
                showCurrentOrSelected();
            }
        }
        delegate: PagesGridItem {
            required property int modelData
            documentView: root.documentView
            cellMargin: thumbnailGridSize.thumbnailMargin
            document: root.document
            page: modelData
            enabled: !root.selectionLocked
            navigationHandler: root
            highlighted: !!root.highlightIndexes ? root.highlightIndexes.indexOf(page) !== -1 : false
            selecting: !root.pageSelection.isEmpty || root.selecting
            selected: !root.pageSelection.isEmpty && pageSelection.isSelected(page)

            function activate() {
                root.openPage(page, DocumentView.ScrollPosition.Restore);
            }

            function select() {
                root.pageSelection.add(page);
            }

            function toggle() {
                if (root.pageSelection.isSelected(page)) {
                    root.pageSelection.remove(page);
                } else {
                    root.pageSelection.add(page);
                }
            }
        }
    }

    ListView {
        id: listView
        visible: pageOverviewThumbnail.listMode
        clip: true
        model: visible ? root.model : 0
        onModelChanged: {
            // if we have a stash, the page was copied and will be positioned
            // elsewhere
            if (model) {
                showCurrentOrSelected();
            }
        }

        boundsBehavior: Flickable.StopAtBounds
        interactive: Experimental.smoothScroll.enabled
        delegate: PagesListItem {
            required property var modelData
            documentView: root.documentView
            document: root.document
            page: modelData
            width: listView.width
            navigationHandler: root
            highlighted: !!root.highlightIndexes ? root.highlightIndexes.indexOf(page) !== -1 : false
            selecting: !root.pageSelection.isEmpty || root.selecting
            selected: !root.pageSelection.isEmpty && root.pageSelection.isSelected(page)

            function activate() {
                root.openPage(page, DocumentView.ScrollPosition.Restore);
            }

            function select() {
                root.pageSelection.add(page);
            }

            function toggle() {
                if (root.pageSelection.isSelected(page)) {
                    root.pageSelection.remove(page);
                } else {
                    root.pageSelection.add(page);
                }
            }
        }
    }

    EmptyViewItem {
        id: noTagsEmptyView
        anchors {
            top: contentHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        topPadding: (root.height - contentHeader.height) * Values.emptyViewTopMarginRatio
        visible: Boolean(root.tags && root.model && root.tags.length > 0 && root.model.length === 0)
        emptyViewKey: "noTagsCombination"
    }
}
