import QtQuick

import com.remarkable
import common
import device.global
import device.ui.controls
import device.view.experimental

import xofm.libs.explorer // TreeExplorer

DeviceKeyboardNavigationHandler {
    id: root

    required property TreeExplorer explorer
    readonly property var tagModel: root.explorer.tagsInView
    readonly property bool hasTags: root.tagModel.length > 0
    readonly property bool selecting: root.explorer.selectedTags?.length > 0
    readonly property bool filtering: root.explorer.tagFilter.length > 0
    property bool canEdit: true
    property int maxVisibleRows: 0

    signal viewAllTags
    signal tagSelected

    function refreshNavigationModel() {
        let navModel = [];
        for (let i = 0; i < listView.contentItem.children.length; i++) {
            navModel.push(listView.contentItem.children[i]);
        }
        navModel.push(viewAll);
        return navModel;
    }

    function selectEditModeTag(tagName) {
        if (root.filtering) {
            root.explorer.clearTagFilterSelection();
        }

        if (root.explorer.tagSelected(tagName)) {
            root.explorer.deselectTag(tagName);
            return;
        }

        tagSelected();
        root.explorer.selectTag(tagName);
    }

    height: header.implicitHeight
    navigationModel: refreshNavigationModel()

    onActivated: (element) => {
        element.activate();
    }

    onToggleSelected: (element) => {
        if (element?.text) {
          root.selectEditModeTag(element.text);
        }
    }
    onTabCycle: Global.keyboardNavigationController.focusOtherHandler(root)

    Connections {
        target: root.explorer
        function onTagsChanged() {
            // Renaming a tag requires a invalidation of the navigation model
            navigationModel = refreshNavigationModel();
        }
    }

    Column {
        id: header
        width: parent.width
        spacing: 20

        Item {
            id: tagsContainer

            property bool viewAllVisible: false
            property var filterSelection: root.explorer.tagFilter
            property var tagSelection: root.canEdit ? root.explorer.selectedTags : []
            readonly property int padding: 10 // Add some extra margin to avoid clipping tags that are edited

            width: parent.width
            height: listView.count > 0 ? row.height + 2 * padding : 0
            visible: height > 0

            Row {
                id: row
                anchors {
                    left: parent.left
                    leftMargin: tagsContainer.padding
                    right: parent.right
                    rightMargin: tagsContainer.padding
                    verticalCenter: parent.verticalCenter
                }
                height: listView.height
                spacing: 24

                ListView {
                    id: listView

                    function updateViewAllVisible() {
                        // "view all" must be displayed if the size of the tags list exceeds the available space
                        const availableWidth = listView.width - viewAll.implicitWidth;
                        const contentWidth = listView.contentItem?.width ?? 0;
                        const allVisible = listView.count > 0 ? contentWidth >= availableWidth : false;
                        tagsContainer.viewAllVisible = allVisible;
                    }

                    height: currentItem?.height ?? 0
                    width: parent.width - viewAll.implicitWidth - row.spacing
                    currentIndex: count > 0 ? 0 : -1
                    interactive: false
                    spacing: 20
                    layoutDirection: Qt.LeftToRight
                    orientation: Qt.Horizontal
                    model: root.tagModel
                    delegate: TagPill {
                        required property string modelData
                        property bool _overlaps: (x + width) > (listView.x  + listView.width) // Overlaps "view all" button

                        function activate() {
                            if (selecting) {
                                // Do not filter when selecting
                                root.selectEditModeTag(modelData);
                                return;
                            }

                            if (root.explorer.tagFilterSelected(modelData)) {
                                root.explorer.deselectTagFilter(modelData);
                                return;
                            }
                            root.explorer.selectTagFilter(modelData);
                        }

                        text: modelData
                        selected: tagsContainer.filterSelection.indexOf(modelData) !== -1 || editing
                        editing: root.canEdit ? tagsContainer.tagSelection?.indexOf(modelData) !== -1 : false
                        visible: !_overlaps
                        navigationHandler: root
                        onClicked: activate()
                        onPressAndHold: root.canEdit ? root.selectEditModeTag(modelData) : activate()
                    }

                    onVisibleChanged: {
                        if (visible) {
                            listView.updateViewAllVisible();
                        }
                    }

                    onModelChanged: {
                        listView.updateViewAllVisible();
                    }
                }

                IconButton {
                    id: viewAll

                    function activate() {
                        root.viewAllTags();
                    }

                    visible: tagsContainer.viewAllVisible
                    title: qsTr("View all")
                    elideTitle: Text.ElideNone
                    height: 50
                    iconSource: "qrc:/ark/icons/chevron_small_right"
                    layoutDirection: Qt.RightToLeft
                    anchors.verticalCenter: parent.verticalCenter
                    antialiasing: false
                    padding: 0
                    navigationHandler: root
                    onClicked: activate()
                }
            }
        }

        Item { // Extra spacing between tagFilter and folder/docs/pages
            height: 4
            width: parent.width
        }
    }
}
