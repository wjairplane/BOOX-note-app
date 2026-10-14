import QtQuick

import device.ui.controls

import xofm.libs.qtgui
import xofm.libs.orientation
import xofm.libs.tags

BaseView {
    id: root

    required property Orientation orientation

    // callback for when a tag is selected/deselected. Expected to get a tag string as argument.
    property var onTagSelected
    // callback for additional tasks when the is closed
    property var onClose
    property list<string> selectedTags
    property list<string> tagsModel

    onOpened: (args) => {
        const { onTagSelected, onClose, selectedTags, tagsModel } = args;
        root.onTagSelected = onTagSelected;
        root.onClose = onClose;

        if (selectedTags !== undefined) {
            root.selectedTags = (typeof selectedTags === "function") ? Qt.binding(selectedTags) : selectedTags;
        } else {
            console.error("all-tags-view: missing selectedTags");
            return;
        }

        if (tagsModel !== undefined) {
            root.tagsModel = (typeof tagsModel === "function") ? Qt.binding(tagsModel) : tagsModel;
        } else {
            console.error("all-tags-view: missing tagsModel");
            return;
        }

        allTags.open();
    }

    function close() {
        root.windowNavigator.close();
        root.onClose?.();
    }

    contentItem: AllTagsView {
        id: allTags
        orientation: root.orientation
        selectedTags: root.selectedTags
        model: root.tagsModel

        onClose: root.close();
        onTagClicked: (tag) => {
            root.onTagSelected?.(tag);
        }
    }
}
