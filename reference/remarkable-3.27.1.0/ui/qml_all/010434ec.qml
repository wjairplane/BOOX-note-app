import QtQuick
import QtQuick.Layouts

import common // Values
import xofm.libs.explorer // EntitySort
import device.ui.controls // CloseShortcut. ScrollContainter
import device.view.navigator // SortDropdown

import xofm.libs.controls
import xofm.libs.orientation
import xofm.libs.settings // ThumbnailSettings

import ark.controls as ArkControls
import ark.tokens as ArkTokens

InputBlocker {
    id: root

    required property Orientation orientation
    property list<string> model: []
    property list<string> selectedTags: []

    readonly property int _nbColumns: 3
    readonly property int _rowHeight: 65
    property int _currentPageIndex: 0

    signal close
    signal tagClicked(string tag)

    onModelChanged: {
        updateModel();
    }

    function open() {
        updateModel();
    }

    function updateModel() {
        sortProperties._sortedModel = sortProperties.sortModel(model, sortProperties.ascending);
    }

    QtObject {
        id: sortProperties
        objectName: "sortProperties"

        property int sortType: EntitySortedListModel.SortType.Alphabetically
        property bool ascending: false
        // for UX reasons, we sort Alphabetical as A-Z when the sort order is descending
        readonly property string alphabetical: sortProperties.ascending
                                               //: Recommended character limit for translation: 20
                                               ? qsTr("Alphabetical (Z-A)")
                                               //: Recommended character limit for translation: 20
                                               : qsTr("Alphabetical (A-Z)")
        readonly property var sortOptions: [
            { key: EntitySortedListModel.SortType.Alphabetically,   name: alphabetical }
        ]
        property var _sortedModel

        function sortModel(arr, isAscending) {
            return [...arr].sort((a, b) => {
                const result = sortProperties.compareBase(a, b, Qt.locale("en_EN").name);
                return isAscending ? -result : result;
            });
        }

        function compareBase(a, b, locale) {
            // note: In QML/JavaScript, localeCompare is available, but the level of support for the options parameter (such as { sensitivity: "base" }) seems not
            // hence the normalization (toLowerCase)
            return a.toLowerCase().localeCompare(b.toLowerCase(), locale);
        }
    }

    CloseShortcut {
        onActivated: root.close();
    }

    ArkControls.NavigationBar {
        id: navigationBar
        type: ArkTokens.NavigationBar.secondary
        width: parent.width
        visible: true
        title: qsTr("Tags")
        borderPosition: ArkControls.NavigationBar.Border.Bottom

        ArkControls.NavigationBar.Button {
            text: qsTr("Back")
            iconSource: "qrc:/ark/icons/chevron_left"
            onClicked: root.close()
        }

        Item {
            Layout.fillWidth: true
        }
    }

    Rectangle {
        id: spacer
        height: 24
        anchors {
            top: navigationBar.bottom
            left: parent.left
            right: parent.right
        }
    }

    ScrollContainer {
        id: scrollingArea
        objectName: "scrollingArea"

        readonly property int tagsPerPage: {
            const rowsPerPage = Math.floor(myTagsContent.height / myTagsContent.cellHeight)
            return rowsPerPage * root._nbColumns
        }

        anchors {
            top: sortHeader.bottom
            bottom: pageIndicators.top
            bottomMargin: root._rowHeight
            left: parent.left
            right: parent.right
        }
        leftMargin: Values.navigatorMargin
        rightMargin: Values.navigatorMargin
        topMargin: Values.navigatorMargin
        orientation: Qt.Horizontal
        horizontalStepSize: myTagsContent.width
        scrollPastMaximum: true

        view: GridView {
            id: myTagsContent
            objectName: "myTagsContent"

            cellWidth: myTagsContent.width / root._nbColumns
            cellHeight: root._rowHeight
            flow: GridView.FlowTopToBottom
            interactive: false
            reuseItems: true
            clip: true
            model: sortProperties._sortedModel
            delegate: Item {
                id: pill

                required property string modelData
                required property int index

                width: myTagsContent.cellWidth
                height: myTagsContent.cellHeight

                function isTagSelected(tagName) {
                    return root.selectedTags?.indexOf(tagName) !== -1;
                }

                TagPill {
                    objectName: "delegatePill" + pill.index

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    maxWidth: myTagsContent.cellWidth - stdPadding - 16 // 16 is the minimum horizontal gap between 2 tags
                    text: pill.modelData
                    selected: root.selectedTags.indexOf(pill.modelData) !== -1
                    onClicked: {
                        root.tagClicked(pill.modelData);
                    }
                }
            }
            onContentXChanged: root._currentPageIndex = Math.floor(myTagsContent.contentX / myTagsContent.width)
        }

    }

    Item {
        id: sortHeader
        height: 72
        anchors {
            top: spacer.bottom
            left: parent.left
            right: parent.right
        }

        ArkControls.Title {
            id: title
            type: ArkControls.Title.Large
            height: parent.height
            text: qsTr("All")
            color: "black"
            elide: Text.ElideMiddle
            anchors {
                left: parent.left
                leftMargin: Values.navigatorMargin
                verticalCenter: sortHeader.verticalCenter
            }
        }

        SortDropdown {
            // Qt Properties
            id: tagSortDropdown
            name: "tagSortDropdown"
            overlayRoot: root
            anchors {
                right: parent.right
                rightMargin: 22
                verticalCenter: parent.verticalCenter
            }
            // SortDropdown Properties
            model: sortProperties.sortOptions
            ascending: sortProperties.ascending
            sortType: sortProperties.sortType
            thumbnailSize: ThumbnailSettings.List
            showThumbnailOptions: false
            orientation: root.orientation

            // Slots
            onUpdateAscending: (ascending) => {
                sortProperties.ascending = ascending;
                root.updateModel();
            }
        }
    }

    Item {
        id: pageIndicators
        objectName: "indicators"

        anchors.bottom: parent.bottom
        width: parent.width
        height: 80
        visible: root.model.length > scrollingArea.tagsPerPage

        Row {
            id: bulletsRow
            height: 20
            width: childrenRect.width
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 24

            Repeater {
                objectName: "indicatorsRepeater"
                model: Math.ceil(root.model.length / scrollingArea.tagsPerPage)
                delegate: Rectangle {
                    id: bullet

                    required property int index
                    width: height
                    height: parent.height
                    radius: width / 2
                    border {
                        color: "black"
                        width: 2
                    }
                    color: root._currentPageIndex === index ? "black" : "white"

                    MouseArea {
                        width: parent.width + bulletsRow.spacing
                        height: width * 2
                        anchors {
                            top: parent.top
                            topMargin: -width / 2
                            left: parent.left
                            leftMargin: -bulletsRow.spacing / 2
                        }
                        onClicked: myTagsContent.contentX = bullet.index * scrollingArea.horizontalStepSize
                    }
                }
            }
        }
    }
}
