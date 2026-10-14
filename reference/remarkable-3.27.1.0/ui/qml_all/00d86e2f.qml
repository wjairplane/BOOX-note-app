import QtQuick
import com.remarkable
import device.ui.text
import device.ui.controls
import xofm.libs.qtgui  // WindowNavigator
import common

KeyboardNavigationHandler {
    id: root

    required property WindowNavigator windowNavigator
    property var _tagMap: ({})
    property var tags: []
    property list<string> selectedTags: []
    property bool filtering: selectedTags.length === 0

    readonly property int maxButtonWidth: 300
    readonly property int updateDelay: 300
    property alias maxTagRows: tagsContent.maxTagRows
    property int maxVisibleRows: 0

    signal newTagsSelection(var selection)

    // return the provided list of tags, with the selected tags first
    function sortSelectedFirst(tagsList) {
        const tagsArray = Array.from(tagsList);
        const selectedArray = tagsArray.filter(tag => selectedTags.includes(tag));
        const unselectedArray = tagsArray.filter(tag => !selectedTags.includes(tag));
        return selectedArray.concat(unselectedArray);
    }

    function toggleTagSelection(tagName) {
        selectedTags = TagUtils.toggledInList(selectedTags, tagName);
        newTagsSelection(selectedTags);
    }

    function clearSelectedTags() {
        selectedTags = [];
    }

    navigationModel: {
        // convert from a qml basic type list (tagFlow.children) to array
        let navModel = [];
        for (let i = 0; i < tagFlow.children.length; i++) {
            navModel.push(tagFlow.children[i]);
        }
        if (viewAll.visible) {
            navModel.push(viewAll);
        }
        return navModel;
    }
    height: header.implicitHeight

    onActivated: {
        if (current) {
            current.activate();
        }
    }

    Column {
        id: header
        width: parent.width
        spacing: 20

        Item {
            id: tagsContent

            property int maxTagRows: 3
            property bool viewAllVisible: !!root.tags && (tagFlow.implicitHeight > tagFlow.height)

            width: parent.width
            height: tagFlow.height

            TagPill {
                // this dummy item is necessary to know which size to give to tagFlow
                // indeed, the flow's children's height might not be resolved right away..
                id: dummyTagPill
                visible: false
            }

            Flow {
                id: tagFlow
                spacing: 20
                padding: 10 // Add some extra margin to avoid clipping tags that are edited
                width: parent.width
                height: (root.tags.length > 0 ? dummyTagPill.height : 0) + spacing
                clip: true

                Repeater {
                    id: tagFlowRepeater
                    model: root.tags
                    delegate: TagPill {
                        required property string modelData
                        property bool overlaps: x + width > viewAll.x && y + height > viewAll.y; // Overlaps "view all" button

                        function activate() {
                            root.toggleTagSelection(modelData);
                        }

                        text: modelData
                        selected: selectedTags.indexOf(modelData) >= 0
                        opacity: overlaps ? 0 : 1
                        navigationHandler: root

                        onClicked: activate();
                    }
                }
            }

            IconButton {
                id: viewAll
                visible: tagsContent.viewAllVisible && (tagsContent.maxTagRows > 1 || root.maxVisibleRows > 0)
                title: qsTr("View all")
                height: 50
                iconSource: "qrc:/ark/icons/chevron_small_right"
                layoutDirection: Qt.RightToLeft
                anchors {
                    bottom: tagsContent.bottom
                    bottomMargin: 10
                    right: tagsContent.right
                }
                antialiasing: false
                padding: 0
                navigationHandler: root
                onClicked: activate()

                function activate() {
                    TagUtils.openAllTagsWindow(root.windowNavigator,
                        () => root.selectedTags,
                        () => root.tags,
                        (tag) => {
                            root.toggleTagSelection(tag);
                        }
                    );
                }
            }
        }

        Item { // Extra spacing between the tag filter and folder/docs/pages
            height: 4
            width: parent.width
        }
    }
}
