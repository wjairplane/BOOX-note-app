import QtQuick
import device.global
import device.ui.controls
import device.ui.headers
import com.remarkable
import common
import device.view.documentview

Popup {
    id: root

    implicitHeight: addTagInput.implicitHeight

    tapOutsideBehavior: Popup.TapOutside.RejectAndHide
    outsidePenInputBlocked: true

    property TagSelectionPopup originPopup
    property bool renameMode: false

    signal rename
    signal modifyTag(string tag)

    function open(origin) {
        addTagInput.text = "";
        root.originPopup = origin;
        showPopup();
        addTagInput.focus = true;
    }

    onVisibleChanged: {
        if (!visible) {
            reset();
        }
    }

    HeaderInput {
        id: addTagInput

        //: My files - Action bar - Tag - New tag - Enter tag name
        placeholder: qsTr("Enter tag name")
        blackOnWhite: false
        inputField.selectedTextColor: Values.colorBlack
        inputField.selectionColor: Values.colorWhite
        inputField.maximumLength: 20
        inputField.inputMethodHints: Qt.ImhNoAutoUppercase
        focus: true
        visible: true
        //: My files - Action bar - Tag - New tag - Enter tag name - Tertiary button
        confirmText: renameMode ? qsTr("Save") : qsTr("Create")

        onAccepted: (text) => {
            const newTag = text;
            if (text.length && root.renameMode) {
                rename();
                renameTagTimer.tag = newTag;
                renameTagTimer.start();
                root.renameMode = false;
            } else if (text.length) {
                let selectedTags = originPopup.selectedTags.splice(0);
                if (selectedTags.indexOf(newTag) === -1) {
                    selectedTags = selectedTags.concat(newTag);
                }
                // We do not call show here since that would
                // overwrite selected tags and kill the one we added
                originPopup.selectedTags = selectedTags;
                originPopup.sortVisibleTags();
                originPopup.modified = true;
            }
            root.hidePopup();
            root.accepted();
        }
        onRejected: {
            root.hidePopup()
            root.rejected();
        }
    }

    function renameTag(oldTag) {
        addTagInput.text = oldTag;
        renameMode = true;
        showPopup();
    }

    function reset() {
        addTagInput.text = "";
        renameMode = false;
    }

    function reject() {
        root.hidePopup();
        root.rejected();
    }

    Timer {
        id: renameTagTimer
        interval: 100
        running: false
        property string tag
        onTriggered: root.modifyTag(tag)
    }
}
