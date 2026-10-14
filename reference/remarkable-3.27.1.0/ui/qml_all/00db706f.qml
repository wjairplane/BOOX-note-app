import QtQuick
import com.remarkable
import common
import device.ui.headers

import xofm.libs.explorer // ViewManager
import xofm.libs.notificationbar

Loader {
    id: root

    required property Item documentView
    required property NotificationQueue notificationQueue
    property bool _isMovingPages: false
    property bool _isMovingToExternalDocument: false
    required property PageSelection movePageSelection
    property bool moreFoldoutShown: false


    signal requestSelectionLock
    signal requestSelectionUnlock

    active: !root.movePageSelection.isEmpty || root._isMovingPages
    sourceComponent: Component {
        ActionBar {
            id: moveHeaderActions

            readonly property string moveOutPagesWarning: qsTr("You can only move out note pages")
            // We have a page we can place before/after
            // We do not want this to show while a move out is in progress
            readonly property bool placeActions: !pages.canMoveOut && !pageSelection.isEmpty && !root._isMovingToExternalDocument

            readonly property Entry sourceDocument: visible && !placeActions && !root._isMovingToExternalDocument
                                                    ? Library.entryForId(root.movePageSelection.documentId)
                                                    : null
            readonly property Entry targetDocument: visible && !placeActions && !root._isMovingToExternalDocument
                                                    ? Library.entryForId(root.movePageSelection.documentId)
                                                    : null

            readonly property bool targetDocumentIsExternal: root._isMovingToExternalDocument
                                                             || (targetDocument && sourceDocument && root.movePageSelection.documentId !== pageSelection.documentId)

            function movePagesOutAction() {
                // Hide the view and let the user navigate to new destination.
                root.documentView.document = null;

                ViewManager.activeView = ViewManager.View.MyFiles;

                // Reset canMoveOut and unlock page picker
                pages.canMoveOut = false;
                root.requestSelectionUnlock();
            }

            function movePagesOutBeforeAction() {
                // Selects only note pages for move out
                if (pageActions.isNotebook() || !root.movePageSelection.containsOriginalPages) {
                    // Should behave as normal. We don't need to display warning message.
                    movePagesOutAction();
                    return;
                }

                root.movePageSelection.pages = root.movePageSelection.notePages;
                pageSelection.pages = root.movePageSelection.pages;
                text = moveOutPagesWarning;
                pages.canMoveOut = true;
                // In this state, page selection must be locked
                // as we don't want the user to select new pages.
                root.requestSelectionLock();
            }

            function movePagesAction(offset) {
                // Select only note pages to move internally for Ebooks only (no warning)
                if (pageActions.isEbook()) {
                    movePageSelection.pages = root.movePageSelection.notePages;
                    movePages(offset);
                } else {
                    movePages(offset);
                }
            }

            function movePages(offset) {
                if (typeof (offset) === 'undefined') {
                    offset = 0;
                }
                var insertIndex = pageSelection.pages[0] + offset;
                movePagesTo(document, insertIndex);
            }

            function movePagesTo(targetDocument, insertIndex) {

                if (root._isMovingPages) {
                    return;
                }

                const sourceDocument = Library.entryForId(root.movePageSelection.documentId);
                root._isMovingPages = true;
                root._isMovingToExternalDocument = (targetDocument && sourceDocument && root.movePageSelection.documentId !== targetDocument.id);
                if (!DocumentController.movePages(sourceDocument, root.movePageSelection.pages, targetDocument, insertIndex, () => {
                                                      root._isMovingPages = false;
                                                      root._isMovingToExternalDocument = false;
                                                  })) {
                    // We have to hide the view to be able to show the notification. We are still in "move" state though,
                    // so the user can try again from the original document if possible.
                    // Note that we have earlier checks that should mean we almost never end up here.
                    cancelMove();
                    notificationQueue.enqueue({
                        text: pageSelection.count == 1 ? qsTr("Failed to move pages") : qsTr("Unable to move pages"),
                    });
                }
            }

            function cancelMove() {
                root.moreFoldoutShown = false;
                root._isMovingPages = false;
                root._isMovingToExternalDocument = false;
                pages.canMoveOut = false;
                root.requestSelectionUnlock();
                pages.cancelMove();
            }

            visible: true
            enabled: !root._isMovingPages
            //: Page overview / Folder – regressive button in action bar
            rejectText: qsTr("Cancel")
            onRejected: {
                cancelMove();
            }
            text: moveHeaderActions.placeActions
                  //: Recommended character limit for translation: 26
                  ? qsTr("Choose a placement")
                  //: Recommended character limit for translation: 34
                  : qsTr("Select a page for placement")
            actions: [
                ActionBar.ActionButton {
                    //: Page overview / Folder – progressive button in action bar
                    text: qsTr("Place before")
                    iconSource: "qrc:/ark/icons/place_before"
                    onClicked: moveHeaderActions.movePagesAction()
                    visible: moveHeaderActions.placeActions
                },
                ActionBar.ActionButton {
                    //: Page overview / Folder – progressive button in action bar
                    text: qsTr("Place after")
                    iconSource: "qrc:/ark/icons/place_after"
                    onClicked: moveHeaderActions.movePagesAction(1)
                    visible: moveHeaderActions.placeActions
                },
                // Implicitly move to the end of the notebook if it's not the same as the source notebook
                ActionBar.ActionButton {
                    //: Page overview / Folder – progressive button in action bar
                    text: qsTr("Move here")
                    iconSource: "qrc:/ark/icons/move_here"
                    onClicked: moveHeaderActions.movePagesTo(document, -1)
                    visible: !moveHeaderActions.placeActions && moveHeaderActions.targetDocumentIsExternal
                },
                // We are currently in the same document as the selection - and don't have a page for before/after
                // Therefore we can move out of the document, or if pages are from a pdf/ebook, we do not allow moving.
                ActionBar.ActionButton {
                    text: qsTr("More")
                    iconSource: "qrc:/ark/icons/three_dots_vertical"
                    onClicked: root.moreFoldoutShown = !root.moreFoldoutShown
                    visible: {
                        if (moveHeaderActions.placeActions
                            || moveHeaderActions.targetDocumentIsExternal
                            || !targetDocument
                            || !sourceDocument
                            || root.movePageSelection.documentId !== pageSelection.documentId) {
                            return false;
                        } else {
                            return pageActions.isNotebook() || root.movePageSelection.notePageCount > 0;
                        }
                    }
                    selected: root.moreFoldoutShown

                    Loader {
                        id: moreFoldoutLoader
                        objectName: "moreFoldoutLoader"
                        anchors {
                            top: parent.bottom
                            topMargin: -moreFoldoutLoader.item?.background?.border.width
                            right: parent.right
                        }
                        active: root.moreFoldoutShown
                        sourceComponent: moveOutFoldout
                    }
                }

                // If we end up here we either lost the source document while moving to a new doc,
                // or we have not successfully loaded the target document yet.
                // We have no good alternatives to present to the user, so the only valid option is cancel
                // Cancel will either send the user back to the original document, or exit the document if we cannot
                // resolve where the user came from.
                // Note that we almost never end up here, and if we do it can be temporary
            ]

            Component {
                id: moveOutFoldout
                MoveOutFoldout {
                    onMoveOutClicked: moveHeaderActions.movePagesOutBeforeAction()
                }
            }
        }
    }
}
