import QtQuick
import com.remarkable
import common
import device.ui.controls
import com.remarkable.devicetelemetry
import device.ui.text
import xofm.libs.onboarding
import device.global
import xofm.libs.orientation
import xofm.libs.qtgui

import ark.controls as ArkControls

// This is the popup used to select tags or partially
// selected tags from a list

Popup {
    id: tagPopup

    signal editClicked

    property var initialTagsModel
    property var selectedTags: []
    property var partiallySelectedTags: []
    property var tags: []
    readonly property var _slicedTagModel: tags.slice(0, maxTagsInPopup)

    readonly property int maxTagsInPopup: 20
    property var onboardingTags: ["Important", "Follow up"]
    property var tagCount: []
    property int maxTagRows: 3
    property int totalEntries: 0
    property bool topAligned: true
    property bool delayClose: true
    property Item pointTo: null
    property bool modified: false
    property bool isToolbarProxy: false
    property int fontSizeTagPopup: Values.fontSizeBody2
    required property var layoutDirection
    property alias border: background.border
    property Orientation orientation
    property WindowNavigator windowNavigator

    readonly property int tagItemHeight: 80
    readonly property bool viewAllVisible: !!tagPopup.initialTagsModel && tagFlow.implicitHeight > tagFlow.height

    tapOutsideBehavior: Popup.TapOutside.AcceptAndHide
    outsidePenInputBlocked: true

    onHeightChanged: updateGeometry()
    onPointToChanged: updateGeometry()

    onShown: {
        handler.forceActiveFocus();
    }

    onHidden: {
        handler.focus = false;
    }

    Connections {
        target: orientation
        function onOrientationChanged() {
            updateGeometry();
        }
    }

    Connections {
        target: pointTo
        function onVisibleChanged() {
            if (!pointTo.visible) {
                tagPopup.hidePopup();
            }
        }
    }

    width: 594 // Note: deselecting tags updates slower on the display if this is just a few pixels wider
    implicitHeight: tagsColumn.height

    property DocumentTelemetry documentTelemetry
    signal notifyTagsTelemetryForPage
    signal notifyTagsTelemetryForDocument

    onNotifyTagsTelemetryForPage: {
        documentTelemetry.taggedFile("Page");
    }
    onNotifyTagsTelemetryForDocument: {
        documentTelemetry.taggedFile("Document");
    }

    function notifyTagsTelemetry(documentSelection) {
        const includeDoc = documentSelection.includesDocuments;
        const includeFolder = documentSelection.includesFolders;
        if (includeDoc && includeFolder) {
            documentTelemetry.taggedFile("FolderAndDocument");
        } else if (includeDoc) {
            notifyTagsTelemetryForDocument();
        } else if (includeFolder) {
            documentTelemetry.taggedFile("Folder");
        }
    }

    function squish_selectedTags() { return JSON.stringify(tagPopup.selectedTags); }
    function squish_partiallySelectedTags() { return JSON.stringify(tagPopup.partiallySelectedTags); }

    function sortVisibleTags() {
        tagPopup.tags = TagUtils.sortVisibleTags(tagPopup.initialTagsModel, selectedTags, partiallySelectedTags);
        if (tagPopup.tags.length == 0) {
            tagPopup.tags = onboardingTags;
        }
    }

    function show() {
        updateSelectedTags();
        sortVisibleTags();
        tagFlow.forceLayout(); // To stabilize tests
        if (isToolbarProxy) {
            visible = true;
        } else {
            showPopup();
        }
        modified = false;
    }

    function handleAccept() {
        accepted();
        if (!isToolbarProxy) {
            hidePopup();
        }
    }

    function accept() {
        if (delayClose) {
            acceptTimer.restart();
        } else {
            handleAccept();
        }
    }

    function updateSelectedTags() {
        const usedTags = Object.keys(tagCount);
        let selected = []; // Fully selected tags
        let partial = []; // Grayed out partially selected tags
        for (let tag of usedTags) {
            if (tagCount[tag] < totalEntries) {
                partial.push(tag);
            } else {
                selected.push(tag);
            }
        }
        tagPopup.selectedTags = selected;
        tagPopup.partiallySelectedTags = partial;
        totalEntries = 0;
        tagCount = [];
    }

    function addTagsForEntry(tags) {
        for (let tagtext of tags) {
            tagCount[tagtext] = tagCount[tagtext] ? tagCount[tagtext] + 1 : 1;
        }
        totalEntries++;
    }

    function addTagsAndEntries(tags) {
        // temporary function to handle tags from the navigation merge
        tagPopup.partiallySelectedTags = tags["partial"];
        tagPopup.selectedTags = tags["shared"];
        sortVisibleTags();
        tagFlow.forceLayout(); // To stabilize tests
        showPopup();
        modified = false;
    }

    function updateGeometry() {
        if (pointTo) {
            const globalPos = pointTo.mapToItem(parent, 0, 0);
            const topOffset = globalPos.y;
            if (!tagPopup.parent) {
                return;
            }
            const target = tagPopup.parent.mapFromItem(parent, globalPos);
            topAligned = topOffset < tagPopup.height;
            y = topAligned ? target.y + pointTo.height - background.border.width : target.y - tagPopup.height;
            x = globalPos.x + pointTo.width - width;
        }
    }

    function toggleTagSelection(tagName) {
        if (tagPopup.partiallySelectedTags.indexOf(tagName) !== -1) {
            tagPopup.partiallySelectedTags = TagUtils.removedFromList(tagPopup.partiallySelectedTags, tagName);
        }
        tagPopup.selectedTags = TagUtils.toggledInList(tagPopup.selectedTags, tagName);
        modified = true;
    }

    Timer {
        id: acceptTimer
        // Close might trigger a time consuming operation
        // So we ensure the UX is repainted first
        interval: 100
        repeat: false
        running: false
        onTriggered: handleAccept()
    }

    Background {
        id: background

        width: tagPopup.width
        height: tagPopup.height

        border.color: Values.colorBlack
        border.width: 2
    }

    DeviceKeyboardNavigationHandler {
        id: handler
        width: parent.width
        navigationModel: {
            // convert from a qml basic type list (tagFlow.children) to array
            let navModel = [];
            for (let i = 0; i < tagFlow.children.length; i++) {
                navModel.push(tagFlow.children[i]);
            }
            navModel.push(viewAll);
            navModel.push(createTagButton);
            return navModel;
        }
        onActivated: current.activate()
        keyOverrideHandler: (event) => {
            if (event.key === Qt.Key_Up) {
                if (tagFlow.children.length > 0 && handler.current === tagFlow.children[0]) {
                    // If we're at the first tag, close the popup.
                    accept();
                    return true;
                }
            }
            return false;
        }

        CloseShortcut {
            onActivated: accept()
        }

        Column {
            id: tagsColumn
            width: parent.width

            Item { height: 30; width: 1 }

            Item {
                width: parent.width
                height: tagFlow.height + 30

                Flow {
                    id: tagFlow
                    clip: true
                    height: Math.min(implicitHeight, maxTagRows * ((children[0]?.height ?? 0) + spacing) - spacing)
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 30
                    spacing: 10

                    Repeater {
                        width: parent.width
                        model: tagPopup._slicedTagModel
                        height: implicitHeight + 30 // adds extra pixels between tags vertically
                        delegate: TagPill {
                            required property string modelData
                            text: modelData
                            selected: tagPopup.selectedTags.indexOf(modelData) !== -1
                            partiallySelected: tagPopup.partiallySelectedTags.indexOf(modelData) !== -1
                            onClicked: activate()
                            navigationHandler: handler
                            property bool hidden: y > tagFlow.height

                            function activate() {
                                toggleTagSelection(modelData);
                            }
                        }
                    }
                }

                IconButton {
                    id: viewAll
                    height: 50 // TODO: unify height here with other `TagFilter` components
                    title: qsTr("View all")
                    elideTitle: Text.ElideNone
                    iconSource: "qrc:/ark/icons/chevron_small_right"
                    layoutDirection: Qt.RightToLeft
                    anchors {
                        top: tagFlow.bottom
                        topMargin: 5
                        right: parent.right
                        rightMargin: 12
                    }
                    padding: 0
                    font.pixelSize: Values.fontSizeBody2
                    antialiasing: false
                    visible: viewAllVisible
                    navigationHandler: handler
                    onClicked: activate()

                    function activate() {
                        TagUtils.openAllTagsWindow(tagPopup.windowNavigator,
                            () => tagPopup.selectedTags,
                            () => tagPopup.tags,
                            (tag) => {
                                toggleTagSelection(tag);
                            }
                        );
                    }
                }
            }

            Item {
                visible: viewAll.visible
                height: 35
                width: 1
            }

            Rectangle {
                height: Values.outlineSize
                width: parent.width
                color: Values.colorBlack
            }

            ArkControls.FoldoutItem {
                id: createTagButton
                antialiasing: false
                iconSource: parent.enabled ? "qrc:/ark/icons/plus_circle" : ""
                label: qsTr("New tag")
                width: parent.width
                height: Values.documentViewToolButtonSize - Values.outlineSize
                anchors.left: parent.left
                anchors.leftMargin: parent.enabled ? 0 : Values.designGridVerticalWidth
                onClicked: activate()

                function activate() {
                    editClicked();
                }
            }
        }
    }
}
