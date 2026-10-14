import QtQuick
import QtQuick.Controls

import xofm.libs.qtgui
import xofm.libs.settings

import device.ui.controls
import device.ui.text
import com.remarkable

import device.view.navigator
import common

Column {
    id: root

    // injected from the module
    required property var library
    required property WindowNavigator windowNavigator
    property var ignoreIds: []

    property alias currentIndex: tabControl.currentIndex
    readonly property int currentTab: tabModel[currentIndex].type
    readonly property string currentTitle: tabModel[currentIndex].title

    property var tabModel: {
        return [
            //: List of recent documents
            {type: RecentMenu.Tab.Recent, title: qsTr("Recent")},
            {type: RecentMenu.Tab.Favorites, title: qsTr("Favorites")}
        ];
    }

    function openDocument(controlItem) {
        root.windowNavigator.open("legacydevice/window/main", {
            openedFrom: "document drawer",
            documentId: controlItem.modelData,
            analyticsDetails: { "document_drawer_details": root.currentTitle }
        });
        documentGrid.currentIndex = 0;
        root.windowNavigator.close();
    }

    enum Tab {
        Recent,
        Favorites
    }

    width: parent.width

    LibrarySearch {
        id: recentDocuments
        filter: LibraryView.Documents
        currentDirectoryId: ""
        sortOrder: LibraryView.RecentlyOpenedDate
        library: root.library
        showRecentsIfTermEmpty: false
        maximumResults: 12

        // there's an internal timer. make sure we have data for our first frame.
        Component.onCompleted: updateNow()
    }

    LibraryNavigator {
        id: entryModel
        library: root.library
        sortOrder: LibraryView.RecentlyOpenedDate
        filter: (LibraryView.Documents | LibraryView.Pinned)
        ignoreParent: true
    }

    Timer {
        id: ctrlTabShortcut
        interval: 50
        running: false
        repeat: false
        // Due to the previous timer we need another one for activating the Ctrl + Tab shortcut
        // This triggers the item that currently has the focus
        onTriggered: openDocument(documentGrid.currentItem);
    }

    TabControl {
        id: tabControl
        width: parent.width
        model: root.tabModel
        valueFunction: (index, model) => model[index].title
    }

    Item {
        height: 20
        width: parent.width
    }

    Rectangle {
        id: relevantDocsGridView
        height: scroll.itemHeight + 2 * Values.navigatorContentGridItemMargin
        width: parent.width

        TextHeaderRegular {
            id: infoText
            width: 700
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            lineHeight: 1.5
            anchors.centerIn: parent
            font.bold: false
            visible: documentGrid.model.length === 0
            text: root.currentTab === RecentMenu.Tab.Recent ? qsTr("No recent documents") : qsTr("No favorited documents")
        }

        ThumbnailGridSize {
            id: thumbnailGridSize
            thumbnailSize: ThumbnailSettings.Medium
            width: scroll.view.width
        }

        ScrollContainer {
            id: scroll

            // We want to show X thumbnails + a bit of a thumbnail on each side
            readonly property double croppedThumbnailSize: 0.4
            readonly property int visibleItems: Math.ceil((parent.width - thumbnailGridSize.gridItemWidth * croppedThumbnailSize * 1.2) / thumbnailGridSize.gridItemWidth)

            readonly property double proportion: thumbnailGridSize.gridItemHeight/ thumbnailGridSize.gridItemWidth
            readonly property double itemWidth: parent.width / (visibleItems + croppedThumbnailSize)
            readonly property double itemHeight: scroll.itemWidth * scroll.proportion

            anchors.fill: parent
            orientation: Qt.Horizontal
            horizontalStepSize: documentGrid.width
            focus: true

            leftMargin: scroll.itemWidth * croppedThumbnailSize / 2
            rightMargin: scroll.itemWidth * croppedThumbnailSize / 2
            topMargin: Values.navigatorContentGridItemMargin
            bottomMargin: Values.navigatorContentGridItemMargin

            Keys.onReleased: (event) => {
                if (event.key === Qt.Key_Control || event.key === Qt.Key_Alt) {
                    event.accepted = true;
                    ctrlTabShortcut.start();
                }
            }
            // This is similar to onPressed (Tab) but when you are pressing CTRL as well
            Keys.onShortcutOverride: (event) => {
                if (event.key === Qt.Key_Tab) {
                    event.accepted = true;
                    documentGrid.currentIndex = (documentGrid.currentIndex + 1) % documentGrid.count;
                    documentGrid.currentItem.focusReason = Qt.TabFocusReason;
                }
            }
            Keys.onPressed: (event) => {
                // Any key that is not a Ctrl up or Tab down should close the drawer
                // The event shall not be accepted either so the DocumentView can catch the typing
                if (event.key === Qt.Key_Tab) {
                    return;
                }
                root.windowNavigator.close();
            }

            view: ListView {
                id: documentGrid
                interactive: false
                orientation: ListView.Horizontal
                layoutDirection: GridView.FlowLeftToRight
                // Allow the view to create items outside the ListView container
                displayMarginBeginning: scroll.itemWidth
                displayMarginEnd: scroll.itemWidth
                model: {
                    if (root.currentTab === RecentMenu.Tab.Recent) {
                        return recentDocuments.entryIds.filter(id => !root.ignoreIds.includes(id));
                    } else if (root.currentTab === RecentMenu.Tab.Favorites) {
                        return entryModel.entryIds;
                    }
                }
                reuseItems: true
                highlightMoveDuration: 0
                clip: false // Make sure thumbnails that are not part of the "List" still show on the sides

                delegate: Control {
                    id: control
                    required property var modelData
                    required property int index
                    width:  scroll.itemWidth
                    height: scroll.itemHeight
                    focusPolicy: Qt.StrongFocus

                    contentItem: ContentEntriesGridItem {
                        anchors.fill: parent
                        entry: Library.entryForId(control.modelData)
                        selected: false
                        drawFocus: control.visualFocus

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.openDocument(control)
                        }
                    }
                }
            }
        }
    }
}
