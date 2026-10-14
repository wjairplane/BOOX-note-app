import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import com.remarkable
import common
import device.global
import device.ui.controls
import device.ui.headers
import device.ui.text
import com.remarkable.devicetelemetry
import device.view.experimental
import device.view.navigator

import xofm.libs.onboarding
import xofm.libs.orientation
import xofm.libs.controls
import xofm.libs.qtgui
import xofm.libs.dialogs
import xofm.libs.notificationbar

import ark.controls as ArkControls

Background {
    id: pages

    required property Item documentView
    required property Item addTagPopup
    required property NotificationQueue notificationQueue
    property Document document: null
    property real progress: pages.contentY / pages.height
    property real total: pages.contentHeight - pages.height
    property bool fromConvert: false
    property var highlightIndexes: []
    property var highlightIndexesTmp: []

    // Properties only used to trigger SelectedPagesWarningHeader
    property bool canMoveOut: false
    property bool convertMode: false
    property bool moveMode: false
    property bool duplicateMode: false
    property bool deleteMode: false
    property bool shouldRestrictMethods: false
    required property PageSelection pageSelection
    required property PageSelection movePageSelection
    required property Orientation orientation
    property WindowNavigator windowNavigator
    property int notificationBarHeight: 0

    property var tocModel
    property DocumentTelemetry documentTelemetry
    property alias popupOverlay: tagPagePopup.overlay

    clip: true
    color: Values.colorWhite

    onDocumentChanged: {
        // close ToC when document is closed
        if (!document) {
            tableOfContentsLoader.active = false;
        }
    }

    onVisibleChanged: {
        if (!visible) {
            closeAction();
            goToPageHeader.reject();
            fromConvert = false;
            tagPagePopup.hidePopup();
        } else {
            documentView.selectedButton = "";
        }
    }

    CloseShortcut {
        onActivated: {
            closeAction();
        }
    }

    function setSelected(selected) {
        pageSelection.clear();
        for (var i = 0; i < selected.length; ++i) {
            pageSelection.add(selected[i]);
        }
    }

    function closeAction() {
        // TODO: this should be folded into a reject() when modals are deduplicated
        var closedSomething = false;

        if (pages.canMoveOut) {
            return;
        }

        if (movePageHeader.active && movePageHeader.item && movePageHeader.item.visible) {
            movePageHeader.item.cancelMove();
            return;
        }

        if (pages.visible) {
            pages.visible = false;
            return;
        }

        if (cloudConnectionLost.visible) {
            cloudConnectionLost.dismiss();
            return;
        }

        if (connectivityNotifier.visible) {
            connectivityNotifier.dismiss();
            return;
        }

        if (pageActions.visible || goToPageHeader.visible) {
            pageActions.reject();
            goToPageHeader.reject();
            pageNumberInput.text = "";
            closedSomething = true;
        }

        if (!pageSelection.isEmpty) {
            pageSelection.clear();
            pages.movePageSelection.clear();
            closedSomething = true;
        }
    }

    function scrollToTop() {
        pagePickerPanel.scrollToTop();
    }

    function showPage(pageNumber) {
        pagePickerPanel.showPage(pageNumber);
    }

    function cancelMove() {
        if (pages.movePageSelection.isEmpty) {
            return;
        }

        let document = Library.entryForId(pages.movePageSelection.documentId);
        if (!document) {
            documentView.document = null;
            notificationQueue.enqueue({
                "text": qsTr("Unable to find original document.")
            });
            return;
        }

        // We are moving pages within the same document
        if (document === documentView.document) {
            pages.pageSelection.pages = pages.movePageSelection.pages;
            pages.movePageSelection.clear();
            return;
        }

        // We are moving pages to another document
        if (document !== documentView.document) {
            pages.windowNavigator.open("legacydevice/window/main", { folderId: Library.parentIdForId(document.id) });
            // Open the original document in Page Overview and restore the page selection
            documentView.document = document;
            pageSelection.pages = pages.movePageSelection.pages;
            for (const page of pageSelection.pages) {
                showPage(page);
            }
            pages.movePageSelection.clear();
            return;
        }
    }

    function reportPageAction(name) {
        pageActions.reportPageAction(name);
    }

    Connections {
        target: pages.movePageSelection

        function onMovePagesActionCancelled() {
            pages.cancelMove();
        }
    }

    Connections {
        target: document
        function onPageUpdated(pageIndex) {
            showPage(pageIndex);
            pages.highlightIndexesTmp.push(pageIndex);
            updateHighlightTimer.restart();
        }
    }

    Timer {
        // Using this intermediate time is required because changing the model
        // causes the highlight to be lost/obscured
        id: updateHighlightTimer
        interval: 100
        onTriggered: {
            pages.highlightIndexes = pages.highlightIndexesTmp;
            pages.highlightIndexesTmp = [];
            highlightTimer.restart();
        }
    }

    Timer {
        id: highlightTimer
        interval: 3000
        onTriggered: {
            pages.highlightIndexes = [];
        }
    }

    PagePicker {
        id: pagePickerPanel
        windowNavigator: pages.windowNavigator
        documentView: pages.documentView
        document: pages.document
        selecting: fromConvert
        selectionLocked: pageActions.selectionLocked
        pageSelection: documentView.pageSelection
        anchors {
            top: pageActions.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        tags: documentView.pageTagMap
        currentPage: documentView.currentPage
        onVisibleChanged: {
            if (visible) {
                pagePickerPanel.updateTags();
            }
        }
        onOpenPage: (page, position) => {
                        documentView.openPage(page, position);
                    }
    }

    ArkControls.NavigationBar {
        visible: !movePageHeader.active
        borderPosition: ArkControls.NavigationBar.Border.Bottom
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        ArkControls.NavigationBar.Button {
            id: backButton
            iconSource: "qrc:/ark/icons/chevron_left"
            text: qsTr("Back")
            onClicked: {
                closeAction();
                tagPagePopup.hidePopup();
            }
        }

        ArkControls.Title {
            id: documentTitle
            text: document ? Library.entryForId(document.id).visibleName : ""
            type: ArkControls.Title.Medium
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.leftMargin: ArkControls.Values.margin.horizontal.small
            Layout.rightMargin: ArkControls.Values.margin.horizontal.small
        }

        ArkControls.NavigationBar.Button {
            objectName: "tableOfContentsButton"
            iconSource: "qrc:/ark/icons/list"
            onClicked: {
                reportPageAction("Table of Content");
                tableOfContentsLoader.active = true;
            }
            visible: pageActions.editableDocument && documentView.tocModel.length
        }

        ArkControls.NavigationBar.Button {
            id: _tagAction
            iconSource: "qrc:/ark/icons/tag"
            onClicked: {
                _popupTagPage();
            }
        }

        ArkControls.NavigationBar.Button {
            iconSource: "qrc:/ark/icons/send"
            onClicked: {
                pageActions.sharePagesAction();
            }
        }
    }

    Item {
        id: pagesOverlay
        width: parent.width
        height: parent.height
    }

    PagesActions {
        id: pageActions
        closureOverlay: pagesOverlay
        visible: !pageSelection.isEmpty
        objectName: "pageActions"
        documentView: pages.documentView
        document: pages.document
        windowNavigator: pages.windowNavigator
        notificationQueue: pages.notificationQueue
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        pageSelection: pages.pageSelection
        movePageSelection: pages.movePageSelection
        shouldRestrictMethods: pages.shouldRestrictMethods
        tocModelLength: documentView.tocModel.length
        requestPage: PageAction {
            onTriggered: pagePickerPanel.showPage(page);
        }

        lockSelection: PageAction {
            onTriggered: pagePickerPanel.selectionLocked = true
        }

        reject: PageAction {
            onTriggered: {
                reportPageAction("Close");
                if (!pageSelection.isEmpty) {
                    pageSelection.clear();
                } else {
                    pages.closeAction();
                }
            }
        }

        share: PageAction {
            onTriggered: {
                _openShareEmailDialog();
                // nothing should be selected after we dismiss (either way)
                pageSelection.clear();
            }
        }

        hidePopup: PageAction {
            onTriggered: {
                tagPagePopup.setAllTags();
                tagPagePopup.hidePopup();
            }
        }

        Binding {
            target: popupOverlay
            property: "verticalOffset"
            value: pageActions.visible ? pageActions.height : 0
        }

        onTagClicked: (obj) => {
            _popupTagPage(obj);
        }

        onPageActionClicked: (name, isEmpty) => documentView.pageActionClicked(name, isEmpty)
        onReportManagedPdfAction: (name) => documentView.reportManagedPdfAction(name)
        onAddPage: (index) => documentView.addPage(pages.document, index)
        onConvertPages: (page) => {
            documentView.convertPages(page)
            pageSelection.clear();
        }
        onShowConfirmDeleteDialog: confirmDeleteLoader.active = true
    }

    Loader {
        id: confirmDeleteLoader

        active: false
        anchors.fill: parent

        sourceComponent: ConfirmChangeDialog {
            id: confirmDelete

            rejectButtonText: qsTr("Cancel", "cancel delete")
            onRejected: {
                confirmDeleteLoader.active = false;
            }
            title: qsTr("Delete %n page(s) permanently?", "", pageSelection.count);
            description: pages.pageSelection.count > 1
                ? qsTr("If you delete the pages, you won't be able to get them back.")
                : qsTr("If you delete the page, you won't be able to get it back.")
            confirmButtonText: qsTr("Delete")
            onAccepted: {
                if (pageActions.isEbook() && pages.pageSelection.containsOriginalPages) {
                    pages.pageSelection.pages = pages.pageSelection.notePages;
                    pageActions.lockSelection.trigger();
                    pages.deleteMode = true;
                    return;
                }
                DocumentController.deletePages(document, pageSelection.pages);
                confirmDeleteLoader.active = false;
            }
        }
    }


    Header {
        id: cloudConnectionLost
        hideOnDismiss: true
        blackOnWhite: false
        text: qsTr("Connect to Wi-Fi to convert text")
        //: Dismiss the "Connect to Wi-Fi" notification
        rejectText: qsTr("Dismiss")
        timeout: Values.popupTimeout
    }

    SelectedPagesWarningHeader {
        id: convertPagesHeader
        anchors.fill: pageActions

        onRequestResetFlags: {
            pages.convertMode = false;
            pages.moveMode = false;
            pages.duplicateMode = false;
            pages.deleteMode = false;
            pagePickerPanel.selectionLocked = false;
        }
    }

    ContentPagesMoveHeader {
        id: movePageHeader
        anchors.fill: pageActions
        movePageSelection: pages.movePageSelection
        notificationQueue: pages.notificationQueue
        documentView: pages.documentView

        onRequestSelectionLock: {
            pagePickerPanel.selectionLocked = true;
        }

        onRequestSelectionUnlock: {
            pagePickerPanel.selectionLocked = false;
        }
    }

    Loading {
        id: loadingIndicator
        anchors.centerIn: parent
        visible: LibraryController.isRunningTasks
    }

    Header {
        id: goToPageHeader
        blackOnWhite: false
        hideOnDismiss: true
        visible: false
        focus: visible

        function goToPage(page, onlyFocus) {
            reportPageAction("Goto Page");
            // while moving or after move, just focus the page instead of opening
            if (onlyFocus || !pages.movePageSelection.isEmpty) {
                var index = (page === -1 ? gridView.count - 1 : page);
                showPage(index);
                // if using goto while moving pages, select the page
                if (!pages.movePageSelection.isEmpty) {
                    pageSelection.clear();
                    pageSelection.add(index);
                }
            } else {
                documentView.openPage(page, DocumentView.ScrollPosition.Restore);
            }
        }

        rejectText: qsTr("Cancel")
        onRejected: {
            pageNumberInput.text = "";
        }

        //: In the "Go to page" flow, "Go" is the confirmation action to go to the selected page
        acceptText: qsTr("Go")
        acceptEnabled: {
            const numb = parseInt(pageNumberInput.text);
            return numb && numb > 0 && numb <= document.pageCount;
        }

        onAccepted: {
            goToPageHeader.goToPage(parseInt(pageNumberInput.text) - 1);
            pageNumberInput.text = "";
        }

        Row {
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Values.navigatorHeaderTitleMargin

            TextHeaderRegular {
                height: parent.height
                color: goToPageHeader.blackOnWhite ? Values.colorBlack : Values.colorWhite
                font.bold: false
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideMiddle
                text: qsTr("Page (%1 - %2)").arg(pageNumberInputValidator.bottom).arg(pageNumberInputValidator.top)
            }

            GeneralTextInput {
                id: pageNumberInput
                anchors.verticalCenter: parent.verticalCenter
                focus: true
                width: Values.navigatorSettingsItemSecondMargin
                font.pixelSize: Values.fontSizeBody1
                color: Values.colorWhite
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator {
                    id: pageNumberInputValidator
                    bottom: 1
                    top: document ? document.pageCount : 1
                }

                onAccepted: {
                    goToPageHeader.goToPage(parseInt(text) - 1);
                    goToPageHeader.dismiss();
                    pageNumberInput.text = "";
                }

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Home) {
                        closeAction();
                        event.accepted = true;
                    }
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Values.outlineSize
                    color: Values.colorWhite
                }
            }
        }
    }

    Loader {
        id: tableOfContentsLoader
        active: false
        anchors.fill: parent
        sourceComponent: TableOfContent {
            document: pages.document
            model: pages.tocModel
            currentPage: documentView.currentPage
            onRejected: tableOfContentsLoader.active = false
            onChapterClicked: (page) => {
                documentTelemetry.pageNavigated("Table of Contents");
                documentView.openPage(page, DocumentView.ScrollPosition.Restore);
                tableOfContentsLoader.active = false;
            }
        }
    }

    Connections {
        target: visible && document ? document : null
        function onPageTagsChanged() {
            pagePickerPanel.clearSelectedTags();
            pagePickerPanel.updateTags();
        }
    }

    TagSelectionPopup {
        id: tagPagePopup

        property var taggedPages: null

        function setAllTags() {
            if (modified) {
                // Tag the selected pages
                if (taggedPages) {
                    LibraryController.setPageTags(document.id, taggedPages, selectedTags, partiallySelectedTags);
                    pagePickerPanel.updateTags();
                    notifyTagsTelemetryForPage();
                } else {
                    // Tag the whole document
                    LibraryController.setEntryTags(document.id, selectedTags, partiallySelectedTags);
                    notifyTagsTelemetryForDocument();
                }
                pageSelection.clear();
                taggedPages = null;

                allTags = Library.tagLabels();
            }
            pageActions.dismiss();
        }

        documentTelemetry: _documentTelemetry
        layoutDirection: Values.accessibilityRightHanded ? Qt.LeftToRight : Qt.RightToLeft
        orientation: pages.orientation
        windowNavigator: pages.windowNavigator
        onEditClicked: addTagPopup.open(tagPagePopup);
        onAccepted: setAllTags();
    }

    NewPageButton {
        id: newPageButton
        anchors {
            right: parent.right
            rightMargin: Values.navigatorMargin
            bottom: parent.bottom
            bottomMargin: pages.notificationBarHeight + Values.navigatorMargin
        }
        visible: !pageActions.visible && !movePageHeader.active
        onClicked: {
            pageActions.addPageAction();
            documentView.reportPageAdded(document, "page overview", { "page_overview_details": "new page" })
        }
    }

    function _openShareEmailDialog() {
        pages.windowNavigator.open("sendmail/window/email-dialog", {
                                       documentView: pages.documentView,
                                       document: pages.document,
                                       pages: pageSelection.pages,
                                       password: documentView.password
                                   });
    }

    function _popupTagPage(obj) {
        let pages = pageSelection.pages
        if (pages.length) {
            // Tag the selected pages
            for (let page of pages) {
                tagPagePopup.addTagsForEntry(pageTagMap[page] ?? []);
            }
            tagPagePopup.taggedPages = pages;
        } else {
            // Tag the whole document
            tagPagePopup.addTagsForEntry(Library.entryForId(document.id).tags);
            tagPagePopup.taggedPages = null;
        }
        tagPagePopup.initialTagsModel = allTags;
        if (obj)
            tagPagePopup.pointTo = obj;
        else
            tagPagePopup.pointTo = pageActions.visible ?  pageActions.findAction(qsTr("Tag")) : _tagAction;
        tagPagePopup.show();
    }
}
