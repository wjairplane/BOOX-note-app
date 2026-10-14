import QtQuick

import com.remarkable
import com.remarkable.hwctelemetry
import common
import device.view.navigator
import device.ui.headers
import device.view.dialogs
import device.view.experimental

import xofm.libs.onboarding
import xofm.libs.devicescreen
import xofm.libs.qtgui
import xofm.libs.notificationbar

import "ShareUtils.js" as ShareUtils
import ark.controls as ArkControls

Item {
    id: pageActions

    property bool selectionLocked: false
    property Item documentView: null
    property Document document: null
    required property PageSelection pageSelection
    property WindowNavigator windowNavigator
    required property PageSelection movePageSelection
    required property bool shouldRestrictMethods
    required property int tocModelLength
    required property NotificationQueue notificationQueue
    property bool selectionHasNativePages: pageSelection.containsOriginalPages
    // We do not have a "user has an account check" because we want to nudge the user to pair their device
    property Item closureOverlay

    QtObject {
        id: internal
        property bool showConvert: pageActions.editableDocument && !pageSelection.isEmpty && (RetailDemo.enabled || notebookPage)
        property bool showSendEmail: pageActions.editableDocument && (Authentication.loggedIn || RetailDemo.enabled)
        property bool showTag: pageActions.editableDocument
        property int moreButtonState: PagesActions.MoreButtonState.Default
    }

    enum MoreButtonState { Default, MoreFoldout, TagFoldout }
    enum AddPageAction { Before, After }

    // Note: all of the actions' visible properties will effectively return false if the containing item
    // is hidden, so the visible portion of the binding simply shortcuts evaluation of the rest of the
    // conditions.
    // Note:  pageActions is only visible when !pageSelection.isEmpty
    // Note: editableDocument returns true even when pageActions is not visible (see Pages.qml)
    readonly property bool editableDocument: SystemMonitor.enoughFreeSpaceForDownload
            && document
            && (document.isImported || document.fileType === Document.Notebook)
    readonly property bool notebookPage: editableDocument && pageSelection.notePageCount > 0
    readonly property bool editablePage: editableDocument
            && !pageSelection.isEmpty
            && (notebookPage || document.fileType === Document.Pdf)
    property string activeButton: ""
    property var activeButtonPos: Qt.point(0, 0)
    property var activeButtonObj

    required property PageAction lockSelection
    required property PageAction requestPage
    required property PageAction reject
    required property PageAction share
    required property PageAction hidePopup

    signal tagClicked(var obj)
    signal pageActionClicked(string name, bool isEmpty)
    signal reportManagedPdfAction(string name)
    signal addPage(int index)
    signal convertPages(list<int> page)
    signal showConfirmDeleteDialog

    height: dummyActionBar.implicitHeight
    state: ""

    onWidthChanged: updateGeometry(pageActions.activeButton)

    function dismiss() {
        internal.moreButtonState = PagesActions.MoreButtonState.Default;
    }

    function updateGeometry(button) {
        if (button === undefined)
            return;

        const buttonObj = findAction(button);
        if (buttonObj) {
            pageActions.activeButtonPos = buttonObj.mapToItem(pages, 0, pageActions.height);
            pageActions.activeButtonObj = buttonObj;
        }
    }

    function findAction(button) {
        return actionBarLoader.item?.findAction(button);
    }

    function changeActiveButton(button) {
        if (pageActions.activeButton === button) {
                pageActions.activeButton = "";
            return;
        }

        pageActions.activeButton = button;
        updateGeometry(button);
    }

    Connections {
        target: document
        function onPageAdded(pageIndex) {
            onPagesAdded([ pageIndex ]);
        }
        function onPagesAdded(pageIndexes) {
            if (!pageSelection.isEmpty) {
                pageSelection.pages = pageIndexes;
            }
            pageActions.requestPage.page = pageIndexes[0];
            pageActions.requestPage.trigger();
            pageActions.movePageSelection.clear();
        }

        function onPagesMoved(from, to) {
            pageSelection.clear();
            pageActions.movePageSelection.clear();
        }
        function onPagesRemoved(removedPages) {
            pageSelection.clear();
        }
    }

    ArkControls.ActionBar {
        id: dummyActionBar
    }

    function reportPageAction(name) {
        pageActions.pageActionClicked(name, !pageSelection.isEmpty);
    }

    function isNotebook() {
        return !!document ? document.fileType === Document.Notebook : false;
    }

    function isPdf() {
        return !!document ? document.fileType === Document.Pdf : false;
    }

    function isEbook() {
        return !!document ? document.fileType === Document.Ebook : false;
    }

    function notifyPageExportWarning() {
        notificationQueue.enqueue({
            text: qsTr("Unable to add page while file is being exported")
        });
    }

    function shouldShowMethodsLimitation() {
        if (pageActions.shouldRestrictMethods && pageActions.selectionHasNativePages) {
            windowNavigator.open("legacydevice/window/no-connect-workbook-action");
            return true;
        }
        return false;
    }

    function reportManagedPdfHelper(actionName) {
        const currentPageIsNote = document.redirectionPageMap[currentPage] === -1;
        const notePageCount = pageSelection.notePageCount;
        const containsOriginalPages = pageSelection.containsOriginalPages;
        if (notePageCount > 0 && containsOriginalPages) {
            // Mixed selection
            pageActions.reportManagedPdfAction(actionName + " Mixed");
        } else if (currentPageIsNote || notePageCount > 0 && !containsOriginalPages) {
            // Only note page(s) selected
            pageActions.reportManagedPdfAction(actionName + " Note");
        } else if (!currentPageIsNote || notePageCount <= 0 && containsOriginalPages) {
            // Only original page(s) selected
            pageActions.reportManagedPdfAction(actionName + " Original");
        }
    }

    function checkAddPage() {
        if (document?.status === Document.Exporting) {
            root.notifyPageExportWarning();
            return false;
        }
        reportPageAction("Add page");
        return true;
    }

    function addPageToDocument(index, addPageAction) {
        if (pageSelection.isEmpty) {
            // When no selection, use the same logic as we do when clicking
            // the newPageButton on swipe and newPage from document view.
            pageActions.documentView?.addPage(document, index);
            return;
        }

        // Ensure inherit template from nearest page dependent on its placed before or after.
        const isBefore = addPageAction === PagesActions.AddPageAction.Before;
        let beforeAfterPageIndex = isBefore
                                   ? pageSelection.pages[0]
                                   : pageSelection.pages[pageSelection.pages.length - 1];
        const inheritTemplate = document.templateForPage(beforeAfterPageIndex);
        DocumentController.addPageWithTemplateAndPageSize(document, index, inheritTemplate, DeviceScreenInfo.paperSize);

        // Analytics
        const details = isBefore ? "add before" : "add after";
        documentView.reportPageAdded(document, "page overview", { "page_overview_details": details, "template": inheritTemplate });
    }

    function addPageAction() {
        addPageAfterAction();
    }

    function addPageBeforeAction() {
        if (checkAddPage()) {
            const index = pageSelection.pages[0] ?? 0;
            addPageToDocument(index, PagesActions.AddPageAction.Before);
        }
    }

    function addPageAfterAction() {
        if (checkAddPage()) {
            const pages = pageSelection.pages;
            const index = pages.length === 0 ? document.pageCount : pages[pages.length-1] + 1;
            addPageToDocument(index, PagesActions.AddPageAction.After);
        }
    }

    function movePagesAction() {
        if (document.status === Document.Exporting) {
            root.notifyPageExportWarning();
            return;
        }

        reportPageAction("Move");

        if (isPdf()) {
            reportManagedPdfHelper("Move pages");
        }

        pageActions.movePageSelection.document = document;
        pageActions.movePageSelection.pages = pageSelection.pages;
        pageSelection.clear();
    }

    function duplicatePagesAction() {
        if (shouldShowMethodsLimitation()) {
            return;
        }

        if (document.status === Document.Exporting) {
            root.notifyPageExportWarning();
            return;
        }

        if (isEbook() && pageSelection.containsOriginalPages) {
            pageSelection.pages = pageSelection.notePages;
            pageActions.lockSelection.trigger();
            duplicateMode = true;
            return;
        }

         reportPageAction("Duplicate");

        if (isPdf()) {
            reportManagedPdfHelper("Duplicate pages");
        }

        var pages = pageSelection.pages;
        var insertIndex = pages[pages.length - 1] + 1;
        DocumentController.copyPages(document, pages, document, insertIndex);
    }

    function sharePagesAction() {
        if (shouldShowMethodsLimitation()) {
            return;
        }

        if (RetailDemo.enabled) {
            pageActions.windowNavigator.open("retail/window/popup", {
                title: qsTr("Send by email"),
                imageUrl: "qrc:/onboarding/illustrations/send_by_email",
                bodyList: [
                    qsTr("Share signed documents, annotated presentations, or handwritten notes directly from your paper tablet without losing focus. Send content as PDF, PNG, or SVG files."),
                    qsTr("This feature is not available in retail demo mode.")
                ]
                });
            return;
        }
        if (!Authentication.loggedIn) {
            windowNavigator.open("userfrontend/window/cloud-feature-popup");
            return;
        }
        if (LinkProvider.availability === LinkProvider.Offline) {
            connectivityNotifier.show();
            return;
        }

        reportPageAction("Send by mail");
        // action bar can be used without explicit selection, in which case
        // we act on all pages
        if (pageSelection.isEmpty) {
            pageSelection.addRange(0, document.pageCount - 1);
        }

        pageActions.share.trigger();
    }

    function deletePagesAction() {
        if (document.status === Document.Exporting) {
            notificationQueue.enqueue({
                "text": qsTr("Unable to delete while document is being exported")
            });
            return;
        }

        if (isEbook() && pageSelection.containsOriginalPages) {
            pageSelection.pages = pageSelection.notePages;
            pageActions.lockSelection.trigger();
            deleteMode = true;
            return;
        }

        reportPageAction("Delete");

        if (isPdf()) {
            reportManagedPdfHelper("Delete pages");
        }

        pageActions.showConfirmDeleteDialog();
    }

    function convertPagesAction() {
        if (RetailDemo.enabled) {
            pageActions.windowNavigator.open("retail/window/popup", {
                title: qsTr("Handwriting conversion"),
                imageUrl: "qrc:/onboarding/illustrations/hwc",
                bodyList: [
                    qsTr("Make your handwritten notes easy to use in emails, reports, or presentations by " +
                    "converting them into typed text. Handwriting conversion supports 33 languages, " +
                    "cursive and block letters, and sharing your freshly converted notes directly via email."),
                    qsTr("This feature is not available in retail demo mode.")
                ]
                });
            return;
        }
        if (!Authentication.loggedIn) {
            windowNavigator.open("userfrontend/window/cloud-feature-popup");
            return;
        }
        if (LinkProvider.availability === LinkProvider.Offline) {
            connectivityNotifier.show();
            return;
        }
        if (Recognizer.recognitionJob && Recognizer.recognitionJob.status === RecognitionJob.Processing) {
            notificationQueue.enqueue({
                //: Notification shown when user attempted to convert handwritten notes to text.
                "text": qsTr("Unable to convert to text. Another conversion is in progress.")
            });
            return
        }

        const convertAction = () => {
            reportPageAction("Convert");
            if ((isPdf() || isEbook()) && pageSelection.containsOriginalPages) {
                pageSelection.pages = pageSelection.notePages;
                pageActions.lockSelection.trigger();
                convertMode = true;
                return;
            }
            HwcTelemetry.convertedPages(pageSelection.count);
            HwcTelemetry.entryPoint("Page Overview");
            pageActions.convertPages(pageSelection.pages);
        }

        pageActions.windowNavigator.open("onboarding-ui/window/conversionlanguage", { onFinished: convertAction });
    }

    Loader {
        id: actionBarLoader
        objectName: "actionBarLoader"
        anchors.fill: parent
        // The sourceComponent should be an ArkControls.ActionBar
        sourceComponent: standardActionBarComp
    }

    Loader {
        id: foldoutLoader
        objectName: "foldoutLoader"
        anchors {
            top: actionBarLoader.bottom
            topMargin: -item?.background.border.width
        }
        x: pageActions.activeButtonPos.x + pageActions.activeButtonObj?.width - item?.width
        active: internal.moreButtonState === PagesActions.MoreButtonState.MoreFoldout
        sourceComponent: moreFoldout
    }

    Component {
        id: moreFoldout
        PagesMoreFoldout {
            overlayParent: closureOverlay
            showTag: internal.showTag
            showConvert: internal.showConvert
            showSendEmail: internal.showSendEmail
            sendEmailDescription: shouldRestrictMethods ? qsTr("Connect required") : ""
            onConvertClicked: pageActions.convertPagesAction();
            onSendByEmailClicked: pageActions.sharePagesAction();
            onTagClicked: {
                internal.moreButtonState = PagesActions.MoreButtonState.TagFoldout;
                pageActions.tagClicked(pageActions.activeButtonObj);
            }
            onAddBeforeClicked: {
                addPageBeforeAction();
                internal.moreButtonState = PagesActions.MoreButtonState.Default;
            }
            onAddAfterClicked: {
                addPageAfterAction();
                internal.moreButtonState = PagesActions.MoreButtonState.Default;
            }
            onFoldoutOverlayClicked: internal.moreButtonState = PagesActions.MoreButtonState.Default
        }
    }

    Component {
        id: standardActionBarComp

        ActionBarBase {
            id: standardActionBar

            actionButtons: [
                ArkControls.ActionBar.ActionButton {
                    text: qsTr("Duplicate")
                    iconSource: "qrc:/ark/icons/duplicate"
                    onClicked: {
                        // make sure the More foldout is closed whenever one initiates a duplicate
                        internal.moreButtonState = PagesActions.MoreButtonState.Default;
                        changeActiveButton(text);
                        pageActions.duplicatePagesAction();
                    }
                    visible: pageActions.editablePage && !pageSelection.isEmpty
                },
                ArkControls.ActionBar.ActionButton {
                    text: qsTr("Move")
                    iconSource: "qrc:/ark/icons/move"
                    onClicked: {
                        // make sure the More foldout is closed whenever one initiates a move
                        internal.moreButtonState = PagesActions.MoreButtonState.Default;
                        changeActiveButton(text);
                        pageActions.movePagesAction();
                    }
                    visible: pageActions.editablePage && !pageSelection.isEmpty
                },
                ArkControls.ActionBar.ActionButton {
                    text: qsTr("Delete")
                    iconSource: "qrc:/ark/icons/trashcan"
                    onClicked: {
                        changeActiveButton(text);
                        pageActions.deletePagesAction();
                    }
                    visible: !SystemMonitor.enoughFreeSpaceForDownload
                             ||  (pageActions.editablePage && !pageSelection.isEmpty)
                },
                ArkControls.ActionBar.ActionButton {
                    text: internal.moreButtonState === PagesActions.MoreButtonState.TagFoldout ? qsTr("Back") : qsTr("More")
                    iconSource: internal.moreButtonState === PagesActions.MoreButtonState.TagFoldout ? "qrc:/ark/icons/chevron_left" : "qrc:/ark/icons/three_dots_vertical"
                    selected: internal.moreButtonState !== PagesActions.MoreButtonState.Default
                    visible: internal.showSendEmail || internal.showTag
                    onClicked: {
                        if (internal.moreButtonState === PagesActions.MoreButtonState.TagFoldout) {
                            internal.moreButtonState = PagesActions.MoreButtonState.Default;
                            pageActions.hidePopup.trigger();
                        } else if (internal.moreButtonState === PagesActions.MoreButtonState.MoreFoldout) {
                            internal.moreButtonState = PagesActions.MoreButtonState.Default;
                        } else {
                            internal.moreButtonState = PagesActions.MoreButtonState.MoreFoldout;
                        }
                        changeActiveButton(qsTr("More"));
                    }
                }
            ]
            onCancelClicked: {
                internal.moreButtonState = PagesActions.MoreButtonState.Default;
                pageActions.activeButton = "";
                pageActions.reject.trigger();
            }
        }
    }
}
