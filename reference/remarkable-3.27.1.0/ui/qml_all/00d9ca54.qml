import QtQuick
import com.remarkable
import common
import device.ui.headers

Loader {
    id: root
    active: convertMode || moveMode || duplicateMode || deleteMode

    signal requestResetFlags

    sourceComponent: Component {
        ActionBar {
            id: headerActions
            visible: true
            rejectText: qsTr("Cancel")
            onRejected: cancel()
            text: choseText()

            function choseText() {
                if (convertMode) {
                    return qsTr("You can only convert note pages to text");
                } else if (moveMode) {
                    return qsTr("You can only move note pages");
                } else if (duplicateMode) {
                    return qsTr("You can only duplicate note pages");
                } else if (deleteMode) {
                    return qsTr("You can only delete note pages");
                }
                return "";
            }

            function _resetFlags() {
            }

            function cancel() {
                root.requestResetFlags();
            }

            actions: ActionBar.ActionButton {
                text: {
                    if (convertMode) {
                        return qsTr("Convert")
                    } else if (moveMode) {
                        return qsTr("Move")
                    } else if (duplicateMode) {
                        return qsTr("Duplicate")
                    } else if (deleteMode) {
                        return qsTr("Delete")
                    } else {
                        return ""
                    }
                }
                iconSource: {
                    if (convertMode) {
                        return "qrc:/ark/icons/hwc"
                    } else if (moveMode) {
                        return "qrc:/ark/icons/move"
                    } else if (duplicateMode) {
                        return "qrc:/ark/icons/duplicate"
                    } else if (deleteMode) {
                        return "qrc:/ark/icons/trashcan"
                    } else {
                        return ""
                    }
                }
                onClicked: {
                    if (convertMode) {
                        pageActions.convertPagesAction();
                    } else if (moveMode) {
                        pageActions.movePagesAction();
                    } else if (duplicateMode) {
                        pageActions.duplicatePagesAction();
                    } else if (deleteMode) {
                        pageActions.deletePagesAction();
                    }
                    root.requestResetFlags();
                }
            }
        }
    }
}
