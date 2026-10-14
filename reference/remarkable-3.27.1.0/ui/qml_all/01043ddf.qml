import QtQuick
import QtQuick.Layouts
import device.ui.controls
import device.ui.headers
import common
import xofm.libs.qtgui

import ark.controls as ArkControls
import ark.tokens as ArkTokens

FocusScope {
    id: root

    required property WindowNavigator windowNavigator
    required property var tagModel
    property list<string> selectedTags: []

    property alias maxTagRows: tagsContent.maxTagRows
    property bool accessibilityMode: false
    property bool showCreateTagButton: false
    property var headerContainer

    signal tagAdded(string tag)
    signal createTagClicked()

    height: header.implicitHeight

    function toggleTagSelection(newTag) {
        selectedTags = TagUtils.toggledInList(selectedTags, newTag);
    }

    function isFiltered(tag) {
        return selectedTags.indexOf(tag) !== -1;
    }

    Column {
        id: header
        width: parent.width
        spacing: ArkControls.Values.spacing.x3small

        RowLayout {
            width: parent.width

            ArkControls.Label {
                id: tagsLabel
                text: qsTr("Tags")
                type: ArkControls.Label.LargeSubtle
            }

            Item {
                Layout.fillWidth: true
            }

            IconButton {
                id: viewAll
                title: qsTr("View all")
                visible: root.tagModel.length > 0
                height: 50
                iconSource: "qrc:/ark/icons/chevron_small_right"
                layoutDirection: Qt.RightToLeft
                antialiasing: false
                onClicked: activate()
                padding: 0
                navigationHandler: root
                function activate() {
                    TagUtils.openAllTagsWindow(root.windowNavigator,
                        () => root.selectedTags,
                        () => root.tagModel,
                        (tag) => {
                            root.toggleTagSelection(tag);
                        });
                }
            }
        }

        Item {
            id: tagsContent
            property int maxTagRows: 3
            width: parent.width
            height: tagFlow.height
            Layout.fillHeight: true

            Flow {
                id: tagFlow
                objectName: "tagFlow"

                property int _maxExpandedHeight
                property int extra: root.accessibilityMode ? 20 : 0

                spacing: 20
                width: parent.width
                height: Math.min(implicitHeight, _maxExpandedHeight)
                clip: true

                function calculateMaxHeight() {
                    const firstChild = children[0];
                    if (!firstChild) {
                        _maxExpandedHeight = 0;
                        return;
                    }
                    return (tagsContent.maxTagRows * (firstChild.height + spacing)) + extra;
                }

                Component.onCompleted: {
                    _maxExpandedHeight = calculateMaxHeight();
                }

                Repeater {
                    id: tagFlowRepeater

                    readonly property var sortedModel: {
                        const tagsArr = Array.from(root.tagModel);
                        const selectedArr = tagsArr.filter(tag => root.selectedTags.includes(tag));
                        const unselectedArr = tagsArr.filter(tag => !root.selectedTags.includes(tag));
                        return selectedArr.concat(unselectedArr);
                    }

                    // Using a cardinal model for performance reasons
                    model: root.tagModel.length
                    delegate: TagPill {
                        required property int index
                        text: tagFlowRepeater.sortedModel[index]
                        selected: root.selectedTags.indexOf(text) !== -1
                        editing: false
                        navigationHandler: root
                        onClicked: activate()
                        onPressAndHold: activate()
                        function activate() {
                            root.toggleTagSelection(text);
                        }
                    }
                }
            }
        }
    }
    ArkControls.Button {
        id: createTagButton
        objectName: "createTagButton"
        type: ArkTokens.Button.secondary
        iconSource: "qrc:/ark/icons/plus_circle"
        text: qsTr("New tag")
        textPosition: ArkControls.Button.TextPosition.Right
        onClicked: activate()
        anchors.top: header.bottom
        anchors.topMargin: 20 // same as spacing between the tags
        visible: root.showCreateTagButton

        function activate() {
            createTagClicked();
        }
    }
}
