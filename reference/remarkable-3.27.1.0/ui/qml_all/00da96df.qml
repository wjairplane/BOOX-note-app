import QtQuick
import QtQuick.Controls
import com.remarkable
import common
import device.ui.controls
import com.remarkable.devicetelemetry
import com.remarkable.hwctelemetry
import com.remarkable.telemetry as Telemetry
import device.ui.text
import device.ui.headers

import device.view.navigator
import device.view.settings
import xofm.libs.onboarding
import device.view.dialogs
import device.view.experimental
import device.global
import device.system

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.batterymanager
import xofm.libs.devicesceneview.impl
import xofm.libs.epub
import xofm.libs.gestures
import xofm.libs.qtgui
import xofm.libs.sceneview
import xofm.libs.toolbar
import xofm.modules.refine
import xofm.libs.system
import xofm.libs.retail
import xofm.libs.orientation
import xofm.libs.devicescreen
import xofm.libs.sharebyurl
import xofm.libs.search.ui  // SearchIndexStatus
import xofm.libs.peninput
import xofm.libs.analytics.ui
import xofm.libs.ghostbuster
import xofm.libs.notificationbar as Notifications
import xofm.libs.explorer

import "ShareUtils.js" as ShareUtils

FocusScope {
    id: root

    property int iconMargin: 8
    readonly property alias currentPage: sceneView.page
    readonly property alias currentPageId: sceneView.pageId
    property bool inSuspend: BatteryManager.displaySleeping
    property alias pageSelection: _pageSelection
    property var pageTagMap: []
    property var tagsForCurrentPage: pageTagMap[currentPage]
    property Document document
    readonly property bool drawingAreaFocused: sceneView.activeFocus
    property string selectedButton
    property bool portrait: document ? (document.orientation === Qt.Vertical) : true
    property alias zoomMode: sceneView.zoomMode
    property WindowNavigator windowNavigator
    required property Orientation orientation
    required property Notifications.NotificationQueue notificationQueue

    property alias pages: pages
    property bool newPageVisible: false
    property bool clipboardNotificationVisible: false
    property string clipboardText: defaultClipBoardText
    readonly property string defaultClipBoardText: qsTr("Tap with Marker to paste")
    readonly property int notificationTimerInterval: 5000
    property string password
    property bool aboutToEnterInitialPage: true
    property var tocModel: []
    property alias searchResultsHeader: _searchResultsHeader
    readonly property int pageCount: document ? document.pageCount : 0
    readonly property bool notePage: sceneView.notePage
    onPageCountChanged: pageLabelTimer.restart()
    property bool addingPage: false;
    property bool resetViewportWhenCleared: false
    readonly property bool shortcutsEnabled: visible && !adjustViewPopup.active
    readonly property bool backgroundFilterVisible: toolbar.shown && toolbar.backgroundFilterVisible && !isLoading
    readonly property bool hideTooltips: toolbarConfiguration.hideTooltips

    readonly property NavigationManager navigationManager: NavigationManager
    readonly property ExportManager exportManager: navigationManager.exportManager

    required property bool penClose
    readonly property alias globalScreenMode: sceneView.globalScreenMode
    required property TextColumn textColumn
    required property PenInput penInput
    required property Config toolbarConfiguration
    required property ToolbarProvider toolbarProvider
    required property RetailSettings retailSettings
    required property EpubSettings epubSettings
    required property ShareByUrl shareByUrl
    required property SearchIndexStatus searchIndexStatus
    required property Analytics analytics
    required property GhostBuster ghostBuster

    required property PageSelection movePageSelection

    property DocumentTelemetry documentTelemetry

    //Document orientation currently takes presedence over system orientation
    //So we need to expose it when a document is loaded
    property var documentOrientation: document ? document.orientation : undefined

    // True when user has navigated to a sub dialog of DocumentView. This
    // property is used to disable gestures within these contexts
    property bool subDialogOpen: pages.visible
                                 || formatSettings.visible

    property bool fullscreenSubDialogOpen: pages.visible
                                           || formatSettings.visible

    property bool hasCustomGestures: documentLoaded && !fullscreenSubDialogOpen

    property bool isTagged: false

    /*!
        isLoading tells you whether or not the document is being worked on.
        This state is immediate and gets toggled frequently, even for trivial
        changes which take very little time.
     */
    property alias isLoading: sceneView.isLoading

    /*!
        isBusy tells you whether or not the document has been in the isLoading
        state for a while, meaning that the system is busy working on
        something, and the UI should probably also reflect that.

        This state gets updated from isLoading based on a timer.
    */
    property bool isBusy: delayedLoading.currentValue

    property bool isWorking: sceneView.isLoading || searchResultsHeader.running

    /*!
        shouldRestrictMethods tells you if the document is Methods content and if
        the user isn't subscribed to Connect, so you can apply restrictions on
        the document as needed.
        Methods documents are pre-made content Connect users can download from the
        rM Methods website.
    */
    property bool shouldRestrictMethods: !UserInfo.isSubscribed && !!root.document?.isMethodsContent;

    onFullscreenSubDialogOpenChanged: {
        if (fullscreenSubDialogOpen && sceneController) {
            // Make sure thumbnails and such are generated when moving into a
            // subdialog, like Page Overview.
            sceneController.requestDeferredCompleted();
            sceneView.endItemSelection();
        }
    }

    onInSuspendChanged: {
        lockManager.setSleepState(inSuspend);
    }

    onBackgroundFilterVisibleChanged: {
        root.windowNavigator.open("devicesceneview/window/backgroundfilter");
    }

    property alias uiContainer: _uiContainer

    property alias connectivityDialogContainer: connectivityDialogContainerItem

    readonly property alias formatMenu: formatMenuDelegate.defaultMenu

    signal searchRequested
    signal documentOpened(Document document)
    signal documentFailedToLoad(string description) // emits when loadError is detected and the view has to close
    signal closeQuickSettings
    signal documentClosed

    DocumentViewShortcuts {
        shortcutsEnabled: root.shortcutsEnabled
        subDialogOpen: root.subDialogOpen
        textMode: sceneView.textMode
        pageSliderVisible: pageSlider.visible
        pagesVisible: pages.visible

        onSearchRequested: root._openInDocSearch()
        onMoveBackwardRequested: {
            root.moveBackward();
            pageSlider.updateNavigationPoints();
        }
        onMoveForwardRequested: {
            root.moveForward();
            pageSlider.updateNavigationPoints();
        }
        onOpenFastScrollRequested: root.openFastScroll()
        onCloseFastScrollRequested: root.closeFastScroll()
        onPasteRequested: root.pasteFromShortcut()
        onUndoRequested: sceneController.undo()
        onRedoRequested: sceneController.redo()
        onCloseRequested: (sequence) => {
            if (selectionHelper.refineMode) {
                selectionHelper.exitRefineMode();
                return;
            }
            documentTelemetry.closeMethod.reportButton(true);
            root.reportDocumentClosed("keyboard", sequence);
            root.close();
        }
    }

    // Some of the keys featuring '+' as an alternate character can't be expressed in a
    // QKeySequence format string which makes using Shortcut impossible. We don't need it as long
    // the DocumentView has focus when active and SceneView's key handling rejects shortcut keys so
    // they can be propagate out.
    Keys.enabled: root.shortcutsEnabled
    Keys.onPressed: (event) => {
        if (event.modifiers !== Qt.ControlModifier) {
            return;
        } else if (event.key === TypeFolioLanguageModel.shortcutKey(StandardKey.ZoomIn, Settings.inputLocale)) {
           const showLockIndicator = sceneView.zoom(0.1);
           if (showLockIndicator) {
               scrollLockFlashTimer.restart();
            }
        } else if (event.key === TypeFolioLanguageModel.shortcutKey(StandardKey.ZoomOut, Settings.inputLocale)) {
           const showLockIndicator = sceneView.zoom(-0.1);
           if (showLockIndicator) {
               scrollLockFlashTimer.restart();
           }
        } else {
            return;
        }
        event.accepted = true;
    }

    Connections {
        target: KeyboardInfo
        function onKeyboardConnectedChanged() {
            if (!KeyboardInfo.keyboardConnected) {
                exitTextMode();
                selectionHelper.exitRefineMode();
            } else if (hasEmptyScene()) {
                // Passing 'drawingAreaFocused' make sure we only
                // requesting focus if the sceneView has focus.
                // Meaning that whatever else already in focus stay in focus.
                enterTextMode(drawingAreaFocused);
            }
        }
    }

    onDocumentChanged: {
        if (!!document){
            root.updatePageTags();
        }
    }

    Item {
        id: documentDrawer
        visible: false

        Connections {
            target: root.windowNavigator
            function onWindowOpened(name) {
                if (name === "documentdrawer/window/main") {
                    documentDrawer.visible = true;
                }
            }
            function onWindowClosed(name) {
                if (name === "documentdrawer/window/main") {
                    documentDrawer.visible = false;
                }
            }
        }

        function show() {
            let ignoreIds = [];
            let openDocument = documentView.item?.document;
            if (openDocument) {
                // Filter out currently open document
                ignoreIds = [openDocument.id];
            }
            windowNavigator.open("documentdrawer/window/main", { ignoreIds: ignoreIds });
        }
    }

    // Analytics
    function reportTemplateSetFromDocument(aTemplate) {
        root.analytics.sendEvent("Template Set", {
            "template": aTemplate.name,
            "template_from_methods": aTemplate.customTemplate,
            "template_orientation": aTemplate.landscape ? "landscape" : "portrait",
            "device_orientation": AnalyticsUtils.enumToString(root.orientation?.orientation, "xofm::libs::qtgui::WindowLayout::Orientation"),
            "document_type": AnalyticsUtils.enumToString(document.fileType, "Document::FileType"),
            "is_quick_sheets": document.isQuickSheet(),
            "source": document.eventSource
        });
    }

    function hasEmptyScene() {
        return sceneController
                && sceneController.rootDocumentLength === 0
                && sceneController.itemsBoundingRect.width === 0
                && sceneController.itemsBoundingRect.height === 0;
    }

    function updatePageTags() {
        // Build map from pageNumber to a stringlist width tags
        let map = [];
        for (let tag of document.getPageTags()) {
            const label = tag.name;
            if (!map[tag.page]) {
                map[tag.page] = [label];
            } else {
                map[tag.page].push(label);
            }
        }
        pageTagMap = map;
        if (currentPage > -1) {
            isTagged = tagsForCurrentPage ? true : false
        } else {
            isTagged = false;
        }
        allTags = Library.tagLabels();
    }

    function resetViewportAndFlash() {
        if (sceneView.resetViewport()) {
            scrollLockFlashTimer.restart();
        }
    }

    // Analytics
    function reportDocumentClosed(closedFrom, kbDetails = null) {
        if (!root.document) {
            return;
        }

        const properties = {
            "document_id": root.document.id,
            "parent_id": root.document.parentId,
            "trigger": closedFrom
        };

        if (closedFrom === "keyboard") {
            if (!kbDetails) {
                console.warn("Missing 'keyboard_details' for Document Closed event.");
                return;
            }
            properties["keyboard_details"] = kbDetails;
        }

        root.analytics.sendEvent("Document Closed", properties);
    }

    function reportPageAdded(document, addedFrom, details = {}) {
        if (!document) {
            return;
        }

        const properties = Object.assign({
            "trigger": addedFrom,
            "template": document.templateForPage(root.currentPage),
            "document_type": AnalyticsUtils.enumToString(document.fileType, "Document::FileType"),
            "is_quick_sheets": document.isQuickSheet(),
            "source": document.eventSource
        }, details);

        root.analytics.sendEvent("Page Added", properties);
    }

    // Analytics
    function reportFileSharedEvent(shareType, fileType, isEntireDocument) {
        const properties = {
            "trigger": "inside document",
            "share_type": shareType,
            "file_type": fileType,
            "is_entire_document": isEntireDocument
        };

        root.analytics.sendEvent("File Shared", properties);
    }

    // Unloads document and closes document view
    function close() {
        screenCastRotationProtection = true;

        _saveScrollPosition();
        if (selectionHelper.refineMode) {
            selectionHelper.exitRefineMode();
        }
        if (sceneView.textMode) {
            exitTextMode();
        }
        toolbar.closeFoldout();
        sceneView.close();
        formatMenu.contract();
        hwcDialog.close();
        pages.visible = false;
        _searchResultsHeader.visible = false;
        root.movePageSelection.clear();
        document = null;
        aboutToEnterInitialPage = true;

        addedTextInTextModeUsingSeabird = false;
        addedTextInTextMode = false;
        documentExtended = false;
        documentEdited = false;
        Settings.lastOpen = "";

        root.documentClosed();
    }

    function handleDialogGhosting(isVisible) {
        if (isVisible) {
            ghostBuster.viewChange(GhostBuster.DocumentViewDialogOpened);
        } else {
            ghostBuster.viewChange(GhostBuster.DocumentViewDialogClosed);
        }
    }

    property bool documentLoaded: !!document

    property int lastPageLocation: -1

    // We do not want to accidentally expose user data so we block screen cast whenever the
    // user navigates out of a document, the document drawer is open or while exporting a document
    property bool screenCastRotationProtection: false
    readonly property bool screenCastAllowed: Experimental.overrideScreenCast.enabled || !!document && !documentDrawer.visible && !pages.visible && !screenCastRotationProtection

    onScreenCastAllowedChanged: {
        if (screenCastAllowed) {
            // enable the connection that sets blockUpdate on next frame swap
            screenShareFrameSwapConnection.enabled = true;
            ScreenShare.documentId = document !== null ? document.id : "";
        } else {
            ScreenShare.setAllowUpdates(false);
        }
    }

    onScreenCastRotationProtectionChanged: {
        screenShareFrameRotationProtection.enabled = true;
    }

    Connections {
        id: screenShareFrameRotationProtection
        enabled: false
        target: window
        function onFrameSwapped() {
            screenCastRotationProtection = false;
            screenShareFrameRotationProtection.enabled = false;
        }
    }

    Connections {
        target: document
        function onTableOfContentsUpdated(results) {
            tocModel = results;
        }

        function onPageCountChanged(newPageCount, oldPageCount) {
            if (document.fileType === Document.Ebook && root.currentPage > 0) {
                let newPage = 0;
                if (newPageCount > 1 && oldPageCount > 1) {
                    // Find the prior progress as a value between 0 to 1,
                    // inclusive.
                    const progressRatio = root.currentPage / (oldPageCount - 1);
                    // Scale that progress up to a page count.
                    newPage = Math.round(progressRatio * (newPageCount - 1));
                }
                sceneView.goToPage(newPage);
            }
        }

        function onPageTagsChanged() {
            root.updatePageTags();
        }

        function onPageMapChanged() {
            // We're in the middle of a page add, lets have the addPage stuff
            // go to page instead
            if (!addingPage) {
                let pageIndex = document.pageForId(sceneView.pageId);
                if (pageIndex >= 0) {
                    // page is still valid, reload page via ID so changes in
                    // next/prev are taken into account and so the
                    // internal 'page' variable in SceneView gets updated.
                    sceneView.goToPageId(sceneView.pageId);
                } else {
                    sceneView.goToPage(0);
                }
            }

            // any change in pages should request a new ToC
            LibraryController.loadTableOfContents(document.id);
            root.updatePageTags();
        }

        function onLoadErrorChanged() {
            if (document.loadError) {
                let description = document.loadErrorDescription
                close();
                documentFailedToLoad(description);
            }
        }
    }

    Connections {
        id: screenShareFrameSwapConnection
        enabled: false
        target: window
        function onFrameSwapped() {
            ScreenShare.setAllowUpdates(screenCastAllowed);
            screenShareFrameSwapConnection.enabled = false;
        }
    }

    function _open_helper(documentToOpen, pageToOpen, highlightDetails) {
        // Reset state of document view and store changes of unclosed document
        if (!!document && document.id !== documentToOpen.id) {
            root.close();
        }
        const forceMoveTool = documentViewTools.forceMoveTool;
        document = documentToOpen;

        if (!document) {
            formatSettings.resetConfirmedLayoutChange();
            pages.visible = false;
            aboutToEnterInitialPage = true;
            password = "";
            tocModel = [];
            Settings.lastOpen = "";
            return;
        }

        // Used to restore open document after a restart
        Settings.lastOpen = document.id;

        lastPageLocation = -1;

        if (!root.movePageSelection.isEmpty) {
            pages.visible = true;
        }

        inactiveWarning.haveShownInactiveWarning = false;

        LibraryController.loadTableOfContents(document.id);
        pageToOpen = Math.max(0, Math.min(pageToOpen, document.pageCount - 1));
        searchResultsHeader.visible = false;

        // forward the LibrarySearcher (Would be nice if the DocumentSearchController could get this at construction)
        searchResultsHeader.searchController.forwardLibrarySearcher(LibrarySearcher);

        // If there are searchResults from outside, we'll
        // tell the searchController to pick them up
        if(highlightDetails?.hasDetails())
        {
            searchResultsHeader.visible = true;
            searchResultsHeader.unfocus();

            // set the search input field to the search term from outside
            searchResultsHeader.text = highlightDetails.currentSearchText();
            searchResultsHeader.committedSearchInput = highlightDetails.currentSearchText();
            searchResultsHeader.searchController.forwardHighlightDetails(pageToOpen, highlightDetails);
        }

        sceneView.goToPage(pageToOpen);

        // Make sure the right tools are selected
        const isPenTooltipCompleted = OnboardingManager.getCompletedForKey(OnboardingManager.Group.Tooltips, "", "Tools_Pens");
        if (forceMoveTool && isPenTooltipCompleted) {
            documentViewTools.selectionPen.tool = Line.SelectionTool;
            documentViewTools.activeTool = "selection";
            toolbar.selectSelection();
        } else {
            // Restore previously used pen tool
            const lastTool = documentViewTools.lastActiveTool();
            const penToChoose = lastTool === "secondary" ? "secondary" : "primary";
            toolbar.selectPen(penToChoose);
        }

        updateLastOpened.start();
        document.markOpened();
        documentOpened(document);
        exitTextMode(false);
    }

    function openDocument(documentToOpen) {
        _open_helper(documentToOpen, documentToOpen.lastOpenedPage);
    }

    function openDocumentOnPage(documentToOpen, pageToOpen, highlightDetails) {
        _open_helper(documentToOpen, pageToOpen, highlightDetails);
    }

    Timer {
        id: updateLastOpened
        interval: 5000
        running: false
        repeat: false
        onTriggered: {
            // We want to prevent accidental opening of a document to update lastOpened. For sorting purposes.
            // Analytics show 69% of our users open a document and close it in less than 5 seconds.
            if (!!document) {
                document.updateLastOpened();
            }
        }
    }

    onCurrentPageChanged: {
        if (!!document) {
            pageLabelTimer.restart();
            if (aboutToEnterInitialPage) {
                aboutToEnterInitialPage = false;
            } else {
                documentTelemetry.pageChanged();
            }

            isTagged = currentPage >= 0 && Boolean(document.hasPageTags(currentPage) && pageTagMap[currentPage]);
            toolbar.closeFoldout();
        }
        newPageVisible = false;

        addedTextInTextModeUsingSeabird = false;
        addedTextInTextMode = false;
        documentExtended = false
        documentEdited = false
    }

    function pageActionClicked(name, selection) {
        documentTelemetry.pageActionClicked(name, selection);
    }

    function reportManagedPdfAction(actionName) {
        documentTelemetry.reportManagedPdf(actionName);
    }

    function storeExtraProperties() {
        documentViewTools.storeExtraProperties();
    }

    function notifyPageExportWarning() {
        notificationQueue.enqueue({
            text: qsTr("Unable to add page while file is being exported")
        });
    }

    function moveForward() {
       if (root.currentPage < document.pageCount - 1) {
            exitTextMode();
            openPage(root.currentPage + 1, DocumentView.ScrollPosition.SaveAndRestore);
        } else if (SystemMonitor.enoughFreeSpaceForCreating) {
            if (document && document.isExporting) {
                root.notifyPageExportWarning();
                return;
            }
            if (retailIntroLoader.active) {
                retailIntroLoader.resetDocument();
                return;
            }

            if (newPageVisible) {
                // if the new page button is visible a press or swipe should confirm it
                root.addPage(root.document, undefined);
                root.reportPageAdded(root.document, "swipe left");
            } else {
                // show the confirm new page button
                newPageVisible = true;
                pageLabelTimer.restart();
            }
        } else {
            // Show page label as a clue that the gesture was recognized
            // even if we do not want to show the new page button
            pageLabelTimer.restart();
        }
    }

    function moveBackward() {
        if (root.currentPage > 0) {
            exitTextMode();
            openPage(root.currentPage - 1, DocumentView.ScrollPosition.SaveAndRestore);
        }
    }

    enum ScrollPosition {
        Save,
        Restore,
        SaveAndRestore
    }

    /*!
        Move to a new \a page index.

        The \a position argument if specified determines if the current scroll position of the
        outgoing page will be saved \c DocumentView.ScrollPosition.Save, if the saved scroll
        position of the incoming page will be restored \c DocumentVieW.ScrollPosition.Restore or
        both \c DocumentView.ScrollPosition.SaveAndRestore. If omitted the position will neither
        saved nor restored.
    */
    function openPage(page, position) {
        if (sceneController) {
            sceneController.clearSelectedText();
        }
        if (position !== undefined && position !== DocumentView.ScrollPosition.Restore) {
            _saveScrollPosition();
        }

        sceneView.goToPage(page);
        LibraryController.setLastOpenedPage(document.id, page);

        pages.visible = false;

        if (KeyboardInfo.keyboardConnected && hasEmptyScene()) {
            sceneController.focusRootDocument(Qt.point(NaN, NaN)); // Force focus to propely show the cursor (mainly on swipe left/right).
            enterTextMode(true);
        }
    }

    function _saveScrollPosition() {
        if (!document || sceneView.status != SceneView.Active || !sceneView.scrollPositionChanged) {
            return;
        }

        // Save the position where the bottom of the view / top of the keyboard intersects the scene.
        const position = sceneView.viewToScene(
            Qt.point(0, height - (Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height: 0))).y;
        LibraryController.setScrollPosition(document.id, root.currentPage, position)
    }

    function openOverview() {
        if (sceneController) {
            sceneController.clearSelectedText();
        }
        _saveScrollPosition();
        pages.visible = true;
    }

    function closeOverview() {
        pages.visible = false;
    }

    function openFastScroll() {
        toolbar.closeFoldout();
        formatMenu.contract();
        pageSlider.activate();
    }

    function closeFastScroll() {
        pageSlider.visible = false;
    }

    function showDocumentSettings() {
        windowNavigator.open("library-ui/window/edit-document", {
            documentId: root.document.id
        });
    }

    function _openInDocSearch() {
        // Reset any adjustment in the view so results are positioned correctly

        // ### For continuous note, this will need some further work
        //     as we need to make sure the selected part is visible,
        //     not just the initial viewport.
        sceneView.resetViewport();
        searchResultsHeader.text = "";
        searchResultsHeader.visible = true;
        if (root.searchIndexStatus.status === SearchIndexStatus.Status.Ineligible) {
            windowNavigator.open("search/window/no-connect-onboarding");
        }

     }

    function convertPages(pages) {
        hwcDialog.convert(pages);
    }

    DocumentLockManager {
        id: lockManager
        taskTracker: LibraryController
        document: root.document
        onDevice: true
    }

    // Solid white background filling the view.
    Rectangle {
        anchors.fill: parent

        color: Values.colorWhite
    }

    property SceneController sceneController: sceneView.controller

    DeviceSceneView {
        id: sceneView

        anchors.fill: parent
        anchors.leftMargin: adjustViewPopup.active ? adjustViewPopup.horizontalMargin : 0
        anchors.rightMargin: adjustViewPopup.active ? adjustViewPopup.horizontalMargin : 0
        anchors.topMargin: adjustViewPopup.active ? adjustViewPopup.topMargin : 0
        anchors.bottomMargin: adjustViewPopup.active ? adjustViewPopup.bottomMargin : 0
        document: root.document
        runningOnDevice: DeviceApp.runningOnDevice;
        snapEnabled: !adjustViewPopup.active
        viewScale: adjustViewPopup.active ? adjustViewPopup.adjustScale : 1.0
        adjustViewActive: adjustViewPopup.active
        viewWidth: root.width
        viewHeight: root.height
        penInput: root.penInput
        penClose: root.penClose
        quickBrowseMode: pageSlider.requestMono
        backgroundFilterState: toolbar.backgroundFilter
        keyboardMargin: formatMenuDelegate.vkbMenu.visible ?  root.height - formatMenuDelegate.vkbMenu.y : 0
        toolbar: toolbar
        focus: !root.subdialogOpen
            && !root.fullscreenSubDialogOpen
            && !_popupOverlay.active
            && document
            && document.isNotepage(root.currentPage)
            && !_searchResultsHeader.visible
            && !toolbar.layersToolActive
        orientation: root.orientation
        topOverscrollMargin: _searchResultsHeader.visible ? _searchResultsHeader.height : 0

        onForceMoveTool: documentViewTools.forceMoveTool = true;

        onKeyPressed: formatMenu.startHideInterval();
        onPasteFromStroke: (position) => {
            if (sceneView.textMode) {
                return;
            }

            if (Clipboard.lastCopiedType === Clipboard.Items && Clipboard.hasItems) {
                performPaste(position);
                return;
            }

            if (Clipboard.hasText && document.isNotepage(root.currentPage)) {
                moveCursorWithPen(position);
                sceneController.pasteClipboardContent(Clipboard.text, SceneController.KeepStyle);
            }
        }

        onExitTextMode: {
            root.exitTextMode();
        }

        onPasteFromShortcut: (actionType) => {
            root.pasteFromShortcut(actionType);
        }

        onCompletedStroke: updateAfterStroke();

        onRequestTextMode: enterTextMode(true);

        onRequestToggleSelectionTool: selectionHelper.toggleRefineMode()

        onConvertSelection: (callback) => {
            if (retailSettings.enabled) {
                root.windowNavigator.open("retail/window/popup", {
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
                showNotification({
                                     message: qsTr("This feature requires a Wi-Fi connection"),
                                     messageIconSource: "qrc:/ark/icons/wifi_x"
                                 });
                return;
            }
            root.windowNavigator.open("onboarding-ui/window/conversionlanguage", { onFinished: callback })
        }

        onConvertedShapeAdded: (shape) => {
            // Make sure we don't change strings in analytics by accident
            console.assert(["Straight Line", "Triangle", "Rectangle", "Ellipse", "Quad"].includes(shape));
            documentTelemetry.shapeAdded(shape);
        }

        onStatusChanged: {
            if (status === SceneView.Active && KeyboardInfo.keyboardConnected && hasEmptyScene()) {
                // Given that we're using seabird, this occurs when creating a
                // new notebook, or when a new page is created in quicksheets
                // from the navigation bar.
                enterTextMode(true);
            }
        }

        onCloseToolbarFoldout: toolbar.closeFoldout();

        Connections {
            target: penHandler
            enabled: KeyboardInfo.keyboardConnected
                     && sceneView.textMode
            function onStroke() {
                if (documentViewTools.currentBrush === Line.SelectionTool) {
                    toolbar.closeFoldout();
                    return;
                }
                // If not in HWC mode, exit text mode when using the pen.
                // Will be re-enabled when using the keyboard.
                exitTextMode();
            }
        }

        // When we press the "close" button on the vkb, we want to exit textmode.
        // Only applicable when keyboard is not connected
        Connections {
            target: Qt.inputMethod
            enabled: !KeyboardInfo.keyboardConnected
            function onVisibleChanged() {
                if (!Qt.inputMethod.visible && sceneView.textMode) {
                    exitTextMode();
                }
            }
        }

        /*
            Gesture internal properties and signals
        */
        gesturesEnabled: !subDialogOpen
        uiVisible: !toolbar.expanded
        clickGestureEnabled: !isLoading && !_searchResultsHeader.visible

        onOpenFastScroll: root.openFastScroll()
        onOpenDocumentDrawer: documentDrawer.show()
        onShowScrollLock: {
            scrollLockFlashTimer.restart();
            documentTelemetry.snapBackToDefaultView("Gesture");
        }
        onMoveForward: {
            sceneView.endItemSelection();
            root.exitTextMode();
            root.moveForward();
            root.documentTelemetry.pageNavigated("Swipe");
        }
        onMoveBackward: {
            sceneView.endItemSelection();
            root.exitTextMode();
            root.moveBackward();
            root.documentTelemetry.pageNavigated("Swipe");
        }
        onSetUiVisible: (mode) => {
            toolbar.expanded = !mode;
        }
        onCloseGesture: {
            documentTelemetry.closeMethod.reportGesture();
            root.reportDocumentClosed("gesture");
            root.close();
        }
        onDisplayLinkNotification: (linkedPage, currPage) => {
            root.showNotification({
                                            message: qsTr("Page %1 of %2").arg(linkedPage + 1).arg(root.pageCount),
                                            action: qsTr("Back to page %1").arg(currPage + 1),
                                            onClicked: () => {
                                                  if (root.currentPage !== currPage) {
                                                      root.openPage(currPage, DocumentView.ScrollPosition.SaveAndRestore);
                                                  }
                                                  messageTimer.stop();
                                            },
                                            type: ArkTokens.NotificationBar.secondary
                                          },
                                          8000);
        }
        onOpenPage: (page, scrollPosition) => {
            root.openPage(page, scrollPosition);
        }
        onTouchClicked: {
            newPageVisible = false;
        }
    }

    property bool documentExtended : false
    property bool documentEdited : false

    /*
        Continuous page used measurement
    */
    Connections {
        enabled: !documentExtended
        target: sceneView.tileManager
        function onTransformChanged() {
            const bottomOfScreen = Qt.point(0, sceneView.height);
            const bottomOfVisibleScreen = sceneView.viewToScene(bottomOfScreen).y;
            const below = bottomOfVisibleScreen > bottomOfScreen.y;

            if (below) {
                documentExtended = true;
            }
        }
    }

    Connections {
        enabled: documentExtended && !documentEdited
        target: penHandler
        function onStrokeCompleted() {
            documentEdited = true;
            documentTelemetry.continuousPageUsed();
        }
    }

    Connections {
        enabled: documentExtended && !documentEdited
        target: sceneView
        function onKeyPressed() {
            documentEdited = true;
            documentTelemetry.continuousPageUsed();
        }
    }



    /*
        Report added text in textmode w/wo seabird
    */
    property bool addedTextInTextMode : false
    property bool addedTextInTextModeUsingSeabird : false


    Connections {
        enabled: !addedTextInTextMode && !KeyboardInfo.keyboardConnected
        target: sceneView
        function onKeyPressed() {
            documentTelemetry.addedTextInTextMode();
            addedTextInTextMode = true;
        }
    }

    Connections {
        enabled: !addedTextInTextModeUsingSeabird && KeyboardInfo.keyboardConnected
        target: sceneView
        function onKeyPressed() {
            documentTelemetry.addedTextInTextModeUsingSeabird();
            document.setKeyboardUsedDuringSession();
            sceneController.markKeyboardUsedDuringSession();
            addedTextInTextModeUsingSeabird = true;
        }

    }

    function pasteFromShortcut(actionType) {
        if (Clipboard.lastCopiedType === Clipboard.Items && Clipboard.hasItems) {
            if (sceneView.textMode) {
                sceneController.insertItemsAtCursorPosition(Clipboard.items);
                return;
            }
        }

        if (Clipboard.hasText && document.isNotepage(root.currentPage)) {
            if (!sceneView.textMode) {
                enterTextMode(true);
            }
            const pasteMode = actionType === SceneKeyHandlerAction.PasteAndMatchStyle ?
                              SceneController.MatchStyle : SceneController.KeepStyle;
            sceneController.pasteClipboardContent(Clipboard.text, pasteMode);
        } else if (Clipboard.hasItems) {
            // Enter into selection mode
            documentViewTools.primaryPen.tool = Line.SelectionTool;
            root.selectedButton = "SelectionTool"
            // Clear any current selection, for instance a previous paste.
            sceneView.endItemSelection();
            sceneController.cloneAddAndSelectItems(sceneController.currentLayer, Clipboard.items, Qt.point(width / 2, height / 2));
        }
    }

    // ### Move to sceneview
    function enterTextMode(requestFocus, cursorPosition) {
        if (!sceneView.notePage) {
            console.warn("not a notepage, not entering seabird mode");
            return;
        }

        if (clipboardNotificationVisible) {
            sceneView.endItemSelection();
        }

        const hadRootDocument = sceneController.hasRootDocument
        if (!hadRootDocument) {
            sceneController.createRootDocument(ParagraphStyle.Type.Title);
            sceneController.focusRootDocument();
        }

        if (requestFocus) {
            // If the controller has a root document but seabird mode has not yet been enabled
            // the root document has focus now.
            if (!sceneView.textMode && hadRootDocument) {
                sceneController.focusRootDocument(cursorPosition === undefined ? Qt.point(NaN, NaN) : cursorPosition);
            }

            sceneView.sceneView.textModeEnabled = true;
            // This should be a no-op, the DarlingArea will have focus within the view by default
            // and will regain it whenever any dialogs that might have stolen it are hidden. But
            // it just takes one thing calling forceActiveFocus() at an inappropriate time for that
            // to break down, so keep this just in case.
            sceneView.forceActiveFocus();
            sceneController.setCursorVisible(true, true);
        }
    }

    // ### Move to SceneView
    function exitTextMode(selectLastTool = true) {
        if (sceneController) {
            sceneController.setCursorVisible(false, true);
            if (sceneController.hasTextSelection) {
                // If we have any selection on exit, make sure to clear it.
                sceneController.clearSelectedText();
            }
        }
        if (sceneView?.sceneView) {
            sceneView.sceneView.textModeEnabled = false;
        }

        if(selectLastTool) {
            toolbar.selectLastTool();
        }
        Qt.inputMethod.hide(); // Ensure closing VKB.
    }

    function updateAfterStroke() {
        root.closeQuickSettings();
        toolbar.closeFoldout();
        formatMenu.contract();
        root.newPageVisible = false;

        if (pageLabelTimer.running) {
            pageLabelTimer.restart();
        }
        if (!sceneController.isLayerVisible(sceneController.currentLayer)) {
            sceneController.setLayerVisible(sceneController.currentLayer, true);
        }
        pageSlider.delayAutoHide();
        documentTelemetry.colorMeasurement.appendColorCount(documentViewTools.primaryPen.tool, documentViewTools.currentColor);
    }

    function performPaste(position) {
        const snapped = Qt.point(Math.round(position.x), Math.round(position.y)); // for compatibility with the old way
        sceneController.cloneAddAndSelectItems(sceneController.currentLayer, Clipboard.items, 1 / sceneView.defaultScale, snapped);
    }

    property ScenePenInputHandler penHandler: sceneView.strokeHandler

    function showNotification(notification = {},
                              timerInterval = root.notificationTimerInterval,
                              showWithoutTimeout = false) {

        notificationBar.notification = notification;
        notificationBar.timerInterval = timerInterval;
        notificationBar.showWithoutTimeout = showWithoutTimeout;

        messageTimer.restart();
    }

    Connections {
        target: sceneController

        function onTextCopied(content) {
            Clipboard.text = content;
            clipboardNotificationVisible = false;
            clipboardText = defaultClipBoardText;
        }

        function onItemsBoundingRectChanged() {
            if (root.resetViewportWhenCleared && hasEmptyScene()) {
                root.resetViewportAndFlash();
                root.resetViewportWhenCleared = false;
            }
        }
    }

    DocumentToolSettings {
        id: documentViewTools

        document: root.document

        objectName: "DocumentView.ToolSettings"

        onActivePenChanged: {
            sceneView.endItemSelection();
            sceneView.hwcSelectionTool.close();
            if (documentViewTools.activePen.tool === Line.SelectionTool && Clipboard.hasItems) {
                clipboardText = defaultClipBoardText;
                clipboardNotificationVisible = true;
            } else {
                clipboardNotificationVisible = false;
            }
        }

        onDocumentAboutToChange: {
            Settings.setLastWritingTool(toolSettings());
        }

        Component.onCompleted: {
            setToolSettings(Settings.lastWritingTool());
        }
    }

    PageErrorOverlay {
        id: pageError
        anchors.fill: parent
        status: sceneView.pageStatus
        details: sceneView.pageStatusDetails
        fontSize: Values.fontSizeBody1
        runningOnDevice: true
        documentId: root && root.document ? root.document.id : ""
        pageId: sceneView.pageId
        onVisibleChanged : {
            if (visible) {
                pageErrorTelemetry.reportErrorType(status);
            }
        }
    }

    PageErrorTelemetry {
        id: pageErrorTelemetry
        dispatcher: Telemetry.Dispatcher
    }

    Connections {
        target: SendMail

        function onUpgrade(message, failed) {
            showNotification({
                                 message: message,
                                 messageIconSource: failed ? "qrc:/ark/icons/x_medium": "qrc:/ark/icons/send"
                             });
        }
        function onSuccess(message, boldMessage) {
            showNotification({
                                 message: message,
                                 type: ArkTokens.NotificationBar.secondary
                             });
        }
        function onFailure(message, boldMessage, map) {
            showNotification({
                                 message: "<b>" + boldMessage + "</b> " + message,
                                 messageIconSource: "qrc:/ark/icons/send"
                             });
        }
        function onAttachmentTooLarge(message, boldMessage, map) {
            showNotification({
                                 message: "<b>" + boldMessage + "</b> " + message,
                                 messageIconSource:"qrc:/ark/icons/send"
                             });
        }
        function onAttemptSending(message) {
            showNotification({
                                 message: message,
                                 action: qsTr("Close"),
                                 onClicked: () => { messageTimer.stop(); notificationBar.showWithoutTimeout = false; },
                                 type: ArkTokens.NotificationBar.secondary
                             },
                            0, true);
        }
    }

    ToolMeasurement {
        tool: documentViewTools.activePen.tool
        documentLoaded: !!document
        dispatcher: Telemetry.Dispatcher
    }

    Loading {
        id: loadingIndicator
        anchors.centerIn: parent
        visible: root.isBusy
        DelayedValue {
            id: delayedLoading
            timeout: 500
            eventualValue: root.isLoading
            onEventualValueChanged: {
                // Change to 'false' immediately, we only want to delay changes to 'true'.
                if (!delayedLoading.eventualValue) {
                    delayedLoading.changeValueImmediately(false);
                }
            }
        }
    }

    function addPage(document, pageIndex) {
        if (document.status === Entry.Exporting) {
            root.notifyPageExportWarning();
            return;
        }

        let newPage = root.currentPage;
        if (pageIndex) {
            newPage = pageIndex;
        } else if (newPage >= 0) {
            newPage++;
        }

        // If we're adding a new page from the toolbar. We need to make sure
        // we reset the selectedButton state so we get the correct tool active.
        // Otherwise we might end up in a state without any tools active.
        toolbar.closeFoldout();
        formatMenu.contract();
        sceneView.endItemSelection();

        // Blocks an additional goToPage in onPageMapChanged().
        root.addingPage = true;

        const validTemplate = document.templateForPage(currentPage);
        const paperSize = DeviceScreenInfo.paperSize;
        DocumentController.addPageWithTemplateAndPageSize(document, newPage, validTemplate, paperSize, function() {
            root.addingPage = false;
            root.openPage(newPage);
        });
    }

    Item {
        id: _uiContainer
        anchors.centerIn: parent
        width: root.width
        height: root.height
        visible: !Experimental.pdfPrototype.enabled

        MinimalBatteryIndicator {
            visible: BatteryManager.battery.percentage <= 10 && BatteryManager.battery.chargerState === Battery.Disconnected
            lowBatteryWarning: true
            showBatteryText: true
            batteryLevel: BatteryManager.battery.percentage
            charging: (BatteryManager.battery.chargerState === Battery.Charging)
            padding: ArkTokens.Style.variable.platform.padding.xsmall

            anchors {
                right: parent.right
                top: parent.top
                rightMargin: {
                    // Always respect right toolbar
                    if (toolbar.position === ToolbarPositioner.Position.Right) {
                        return Values.documentViewToolButtonSize;
                    }
                    // Respect close button, except for top toolbar
                    if (toolbar.position !== ToolbarPositioner.Position.Top && toolbar.shown) {
                        return Values.documentViewToolButtonSize;
                    }
                    return ArkTokens.Style.variable.platform.padding.large;
                }
                topMargin: {
                    if (toolbar.position === ToolbarPositioner.Position.Top && toolbar.shown) {
                        return Values.documentViewToolButtonSize;
                    }
                    return ArkTokens.Style.variable.platform.padding.large;
                }
            }

            background: MouseArea {
                Rectangle {
                    anchors.fill: parent
                    color: "white"
                }
                onClicked: (event) => {
                    if (PenClosenessMonitor.penClose && event.source !== Qt.MouseEventNotSynthesized) {
                        return;
                    }
                    root.windowNavigator.open("settings/window/battery");
                }
            }
        }

        Background {
            id: pageLabel
            width: Values.accessibilityMode ? 426 : 258 // 2x or 4x grid + 3x spacing
            height: Values.navigatorStatusbarHeight
            anchors.bottom: notificationBar.top
            anchors.horizontalCenter: parent.horizontalCenter
            visible: (pageLabelTimer.running || pageSlider.visible)
                     && !pages.visible && !hwcDialog.visible && !sceneView.hwcSelectionTool.visible && !searchResultsProgress.visible && !notificationBar.visible && !adjustViewPopup.visible
            color: Values.colorWhite
            mouseAreaEnabled: false

            Timer {
                id: pageLabelTimer
                interval: Values.popupTimeout
            }

            TextParagraph {
                id: pageLabelText
                anchors.centerIn: parent
                anchors.alignWhenCentered: true
                text: qsTr("Page %1 of %2").arg(root.currentPage + 1).arg(pageCount)
                color: Values.colorBlack
                antialiasing: false
                font.weight: Font.Medium
            }

            states: [
                State {
                    when: toolbar.position === ToolbarPositioner.Position.Top
                    PropertyChanges {
                        target: pageLabel
                        anchors.bottomMargin: zoomButton.visible ? zoomButton.height : 0
                    }
                }
            ]
        }

        Background {
            id: titleLabel
            width: parent.width
            height: Values.documentViewToolButtonSize
            anchors.top: parent.top
            anchors.topMargin: toolbar.position === ToolbarPositioner.Position.Top && toolbar.shown ? Values.documentViewToolButtonSize : 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.alignWhenCentered: true
            visible: pageSlider.visible

            TextParagraph {
                antialiasing: false
                anchors.margins: 125
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: parent.width - Values.documentViewToolButtonSize * 2
                height: parent.height
                elide: Text.ElideRight
                maximumLineCount: 2
                anchors.alignWhenCentered: true
                text: document ? document.visibleName : ""
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.weight: Font.Medium
            }
        }

        PageSelection {
            id: _pageSelection
            function clearPageSelection() {_pageSelection.clear();}
            singleSelection: !root.movePageSelection.isEmpty
            document: root.document
        }

        // This must stack below the ToolBox to not look ugly.
        Rectangle {
            id: pageSliderBackground
            anchors.top: pageSlider.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: -100
            anchors.margins: -pageSlider.anchors.margins
            visible: pageSlider.visible
        }

        SelectionHelper {
            id: selectionHelper
            anchors.bottom: notificationBar.visible ? notificationBar.top : parent.bottom
            anchors.left: parent.left
            anchors.margins: 40

            onRefineModeChanged: {
                if (refineMode) {
                    toolbar.expanded = false;
                     if (documentViewTools.activeTool !== "selection") {
                        documentViewTools.activeTool = "selection";
                        toolbar.selectSelection();
                    }
                } else {
                    toolbar.expanded = true;
                    documentViewTools.activeTool = "primary";
                    toolbar.selectPen("primary");
                }
            }
        }

        // We let touch events bleed through top and bottom toolbars
        // However, we don't want do draw or to be able to see the content.
        // This still needs to be stacked behind the toolbar, as our
        // selected buttons overlap the area.
        PenInputBlocker {
            id: gestureArea
            visible: false
            anchors {
                left: parent.left
                right: parent.right
            }
            height: toolbar.gestureMargin
            manager: root.penInput.surfaceManager

            Rectangle {
                anchors.fill: parent
                color: Values.colorWhite
            }
            states: [
                State {
                    when: toolbar.position === ToolbarPositioner.Position.Top
                    AnchorChanges {
                        target: gestureArea
                        anchors.top: parent.top
                    }
                    PropertyChanges {
                        target: gestureArea
                        visible: toolbar.shown
                    }
                },
                State {
                    when: toolbar.position === ToolbarPositioner.Position.Bottom
                    AnchorChanges {
                        target: gestureArea
                        anchors.bottom: parent.bottom
                    }
                    PropertyChanges {
                        target: gestureArea
                        visible: toolbar.shown
                    }
                }
            ]
        }

        NewPageButton {
            id: newPageButton
            visible: newPageVisible
            anchors {
                right: parent.right
                margins: (toolbar.position === ToolbarPositioner.Position.Right && toolbar.shown ? toolbar.innerWidth : 0) + 80
                verticalCenter: parent.verticalCenter
            }
            onClicked: {
                root.addPage(document);
                root.reportPageAdded(root.document, "floating button");
            }
            border.color: Values.colorWhite
            border.width: 4
            antialiasing: false
        }

        Toolbar {
            id: toolbar

            anchors.fill: parent

            toolbarConfiguration: root.toolbarConfiguration
            toolbarProvider: root.toolbarProvider
            hasAutorotation: root.toolbarConfiguration.autoRotation
            exportIntegrationsModel: NavigationSortedListModel {
                list: root.navigationManager.navigationView
                filter: "storage"
                filterBy: NavigationSortedListModel.Filters.Type
            }

            analytics: root.analytics
            penToolSelectedTelemetry: (() => {
                                           return {
                                               "document_type": AnalyticsUtils.enumToString(document.fileType, "Document::FileType"),
                                               "is_quick_sheets": document.isQuickSheet()
                                           }
                                       })

            // Convenience property for ui that respects the presence of the toolbar
            readonly property bool shown: visible && expanded

            visible: !inSuspend
                     && !pages.visible
                     && !selectionHelper.refineMode
                     && !formatSettings.visible
                     && (!Qt.inputMethod.visible || !sceneView.textMode || KeyboardInfo.keyboardConnected)
                     && !_searchResultsHeader.visible
                     && !adjustViewPopup.active
                     && !sceneView.hwcSelectionTool.processing
                     && !hwcDialog.processing

            onExpandedChanged: {
                pageSlider.visible = false;
                if(!expanded) {
                    formatMenu.contract();
                }
            }

            property bool isNote: document && document.isNotepage(root.currentPage)

            penInput: root.penInput
            primaryPen: documentViewTools.primaryPen
            secondaryPen: documentViewTools.secondaryPen
            eraserPen: documentViewTools.eraserPen
            selectionPen: documentViewTools.selectionPen
            Binding {
                target: toolbar.toolbarProvider.positioner
                property: "handedness"
                value: Values.accessibilityRightHanded ? ToolbarPositioner.Handedness.Righty : ToolbarPositioner.Handedness.Lefty
            }
            Binding {
                target: toolbar.toolbarProvider.positioner
                property: "orientation"
                value: root.orientation.orientation
            }
            typingModeVisible: isNote

            messagingIntegrationManager: MessagingIntegrationManager

            tagsFoldout: TagSelectionPopup {
                id: tagPopup
                implicitWidth: width
                delayClose: false
                outsidePenInputBlocked: false
                layoutDirection: toolbar.position === ToolbarPositioner.Position.Right ? Qt.RightToLeft : Qt.LeftToRight
                documentTelemetry: root.documentTelemetry
                isToolbarProxy: true
                orientation: root.orientation
                overlay: _popupOverlay
                windowNavigator: root.windowNavigator
                parent: null

                function setPageTags() {
                    if (modified) {
                        LibraryController.setPageTags(document.id, [currentPage], selectedTags, partiallySelectedTags);
                        const map = pageTagMap;
                        const newTags = document.tagsForPage(currentPage);
                        map[currentPage] = newTags.length ? newTags : undefined
                        pageTagMap = map;
                        notifyTagsTelemetryForPage();
                    }
                }

                // Normally a popup is placed inside the popup overlays. But since we're not
                // taking advantage of its close on tap outside handling and we're anchoring to the button;
                // override that to stay a child of the button. And since the popup isn't enclosed in the
                // popup layer focus scope disable giving it focus when active.
                focus: false

                onEditClicked: {
                    LibraryController.setPageTags(document.id, [currentPage], selectedTags, partiallySelectedTags);
                    addTagPopup.open(tagPopup);
                }

                onVisibleChanged: {
                    if (!visible) {
                        tagPopup.accept();
                    }
                }

                onAccepted: {
                    tagPopup.setPageTags();

                    if (pageSlider.visible) {
                        pageSlider.updateNavigationPoints();
                        pageSlider.delayAutoHide();
                    }
                }
            }

            Connections {
                target: MessagingIntegrationManager
                function onSendFailed(integrationId, message) {
                    showNotification({
                                         message: qsTr("Unable to send"),
                                         messageIconSource: MessagingIntegrationManager.iconForIntegration(integrationId)
                                     });
                }

                function onSendSuccess(integrationId) {
                    showNotification({
                                         message: qsTr("Sent page"),
                                         messageIconSource: MessagingIntegrationManager.iconForIntegration(integrationId)
                                     });
                }

                function onAttemptSending(integrationId) {
                    showNotification({
                                         message: qsTr("Sending..."),
                                         messageIconSource: MessagingIntegrationManager.iconForIntegration(integrationId)
                                     });
                }
            }

            Connections {
                target: root.shareByUrl
                function onSendFailed() {
                    //: notification feedback when failing to send for any reason
                    showNotification({
                                         message: qsTr("Unable to send"),
                                         messageIconSource: "qrc:/ark/icons/link"
                                     });
                }
                function onSendSuccess(link) {
                    //: notification for completing the task successfully
                    showNotification({
                                         message: qsTr("The link has been sent to your email"),
                                         messageIconSource: "qrc:/ark/icons/link",
                                         //: button label - call to action to open the QR code dialog
                                         action: qsTr("Open QR-code"),
                                         onClicked: () => {
                                             root.windowNavigator.open("sharebyurl/window/qr-dialog", { link: link });
                                             messageTimer.stop();
                                         },
                                         type: ArkTokens.NotificationBar.secondary
                                     },
                                     30000
                                     );
                }

                function onAttemptSending() {
                    //: Intermediary notification for when the share by url feature is in progress
                    showNotification({
                                         message: qsTr("Sending..."),
                                         messageIconSource: "qrc:/ark/icons/link"
                                     });
                }
            }

            Connections {
                target: root.orientation
                function onOrientationChanged() {
                    toolbar.closeFoldout();
                }
            }

            undoEnabled: sceneController && sceneController.undoAvailable
            redoEnabled: sceneController && sceneController.redoAvailable

            documentTitle: document ? document.visibleName : ""
            pageCount: document ? document.pageCount : 0
            currentPage: root.currentPage

            container: _uiContainer

            shapeSnapEnabled: Settings.shapeSnapEnabled
            onShapeSnapChanged: (enabled) => { Settings.shapeSnapEnabled = enabled; }

            onShareToMessagingClicked: (integrationId) => {
                if (!networkActionResponse() && !retailSettings.enabled) {
                    return;
                }
                MessagingIntegrationManager.shareToIntegration({id: root.document.id, pages: [root.currentPage] }, integrationId);
            }

            onExportToIntegrationClicked: (integrationId) => {
                exportManager.exportPagesFromDocument(Library.entityIdForEntry(document), [currentPage], integrationId);
                root.reportFileSharedEvent("export to drive", "pdf", document.pageCount == 1);
                closeFoldout();
            }

            fitMode: {
                const mode = sceneView.zoomMode
                if (mode) {
                   if (mode === Document.FitToWidth) {
                        return "width";
                    } else if (mode === Document.FitToHeight) {
                        return "height";
                    } else if (mode === Document.CustomFit) {
                        return "custom";
                    }
                }
                return "";
            }
            documentType: {
                if (document) {
                    if (document.fileType === Document.Pdf) {
                        return "pdf";
                    } else if (document.fileType === Document.Ebook) {
                        return "ebook";
                    }
                }
                return "note";
            }
            pageType: isNote ? "note" : documentType
            sendByEmailString: qsTr("Send by email")
            shareByUrlVisible: root.shareByUrl.available
            screenShareActive: ScreenShare.serverActive
            portraitDocument: root.portrait
            backgroundFilter: root.document ? root.document.viewBackgroundFilter : ""
            backgroundFilterVisible: !sceneView.notePage && sceneView.backgroundFilterVisible

            typingModeEnabled: sceneView.textMode && (KeyboardInfo.keyboardConnected || Qt.inputMethod.visible)
            documentLength: sceneController?.rootDocumentLength ?? 0
            textWidth: sceneController ? root.textColumn.resolvedWidth(sceneController.rootDocumentTextWidth, sceneController.rootDocumentPreferredTextLayout) : 0
            columnTextWidth: sceneController ? sceneController.rootDocumentPreferredTextLayout : 0
            hasPageAnnotations: sceneController ? sceneController.hasAnnotations : false
            autoReflowEnabled: Experimental.autoReflowTextColumns.enabled

            isTagged: tagPopup.visible ? tagPopup.selectedTags.length : !!tagsForCurrentPage

            SceneLayersModel {
                id: sceneLayersModel
                controller: root.sceneController
            }
            layersModel: sceneLayersModel
            layersBackgroundVisible: sceneController && sceneController.backgroundVisible
            layersRootDocumentVisible: sceneController && sceneController.isRootDocumentVisible
            layersRootDocumentAvailable: sceneController && sceneController.rootDocumentLength > 0

            function defaultActionResponse() {
                closeFoldout();
                root.newPageVisible = false;
            }

            function networkActionResponse() {
                defaultActionResponse();
                if (retailSettings.enabled) {
                    return false;
                }
                if (!Authentication.loggedIn) {
                    windowNavigator.open("userfrontend/window/cloud-feature-popup");
                    return false;
                }
                if (LinkProvider.availability === LinkProvider.Offline) {
                    showNotification({
                                         message: qsTr("This feature requires a Wi-Fi connection"),
                                         messageIconSource: "qrc:/ark/icons/wifi_x"}
                                     );
                    return false;
                }
                return true;
            }

            function reportToolbarActionTelemetry(telemetryKey) {
                documentTelemetry.toolbarActionClicked(telemetryKey);
            }

            onPenToolSelected: (tool) => {
                if (!documentViewTools.isWritingTool(documentViewTools.activePen.tool)) {
                    return;
                }
                documentViewTools.activePen.tool = tool;
                root.newPageVisible = false;
            }

            onPenColorSelected: (rgb, paletteEnum) => {
                if (!documentViewTools.isWritingTool(documentViewTools.activePen.tool)) {
                    return;
                }
                documentViewTools.activePen.color = paletteEnum;
                documentViewTools.activePen.colorCode = rgb;
                root.newPageVisible = false;
            }

            onPenThicknessSelected: (thickness) => {
                if (!documentViewTools.isWritingTool(documentViewTools.activePen.tool)) {
                    return;
                }
                documentViewTools.activePen.thickness = thickness;
                root.newPageVisible = false;
            }

            onHighlighterSnapToTextSelected: (snap) => {
                if (!documentViewTools.isWritingTool(documentViewTools.activePen.tool)) {
                    return;
                }
                documentViewTools.activePen.snapHighlighterToText = snap;
                root.newPageVisible = false;
            }

            onTypingModeSelected: () => {
                closeFoldout();
                enterTextMode(true);
                sceneView.sceneView?.showVirtualKeyboard();
                root.newPageVisible = false;
            }
            onTextWidthSelected: (width) => {
                if (sceneController.hasRootDocument) {
                    sceneView.sceneView?.recenter();
                    sceneController.rootDocumentTextWidth = width;
                } else {
                    sceneController.createRootDocument(ParagraphStyle.Type.Title, width);
                }
            }

            onTextColumnWidthSelected: (columnWidth) => {
                if (sceneController.hasRootDocument) {
                    sceneView.sceneView?.recenter();
                    sceneController.rootDocumentPreferredTextLayout = columnWidth;
                }
            }

            onEnableAutoReflow: {
                if (sceneController.hasRootDocument) {
                    sceneView.sceneView?.recenter();
                    sceneController.enableAutoReflow();
                }
            }

            onDisableAutoReflow: (columnWidth) => {
                if (sceneController.hasRootDocument) {
                    sceneView.sceneView?.recenter();
                    sceneController.rootDocumentPreferredTextLayout = columnWidth;
                }
            }

            onEraserToolSelected: (tool) => {
                documentViewTools.eraserPen.tool = tool;
                root.newPageVisible = false;
            }
            onEraserThicknessSelected: (t) => {
                documentViewTools.eraserPen.thickness = t;
                root.newPageVisible = false;
            }
            onEraseAllSelected: ()  => {
                root.newPageVisible = false;
                toolbar.selectPen("auto");
                sceneView.endItemSelection();
                sceneController.clearLinesInLayer(sceneController.currentLayer);

                if (root.hasEmptyScene()) {
                    root.resetViewportAndFlash();
                } else {
                    root.resetViewportWhenCleared = true;
                }
            }

            onSelectionSelected: () => {
                root.newPageVisible = false;
            }

            onSelectedPenChanged: {
                documentViewTools.activeTool = selectedPen.penToolType;
                root.exitTextMode(false);
            }

            onUndoSelected: () => {
                sceneController.undo();
                root.newPageVisible = false;
            }
            onRedoSelected: () => {
                sceneController.redo();
                root.newPageVisible = false;
            }

            onPageOverviewSelected: {
                root.openOverview();
                toolbar.selectLastTool();
                sceneView.hwcSelectionTool.close();
                pages.setSelected([]);
                pages.fromConvert = false;
                root.newPageVisible = false;
                reportToolbarActionTelemetry("Page overview");
            }

            onToggleScreenShareSelected: {
                if (!networkActionResponse() && !retailSettings.enabled) {
                    return;
                }
                ShareUtils.toggleScreenShareServer(root.windowNavigator);
                reportToolbarActionTelemetry("Liveview");
            }

            onSendByEmailSelected: {
                if (!networkActionResponse() && !retailSettings.enabled) {
                    return;
                }
                if (root.shouldRestrictMethods) {
                    root.showNotification({
                                                      message: qsTr("Unable to send emails without Connect subscription"),
                                                      messageIconSource: "qrc:/ark/icons/information_circle"
                                                  });
                    return;
                }
                ShareUtils.sendPages(root.windowNavigator);
                reportToolbarActionTelemetry("Send by mail");
            }

            onShareByUrlSelected: {
                if (!networkActionResponse() && !retailSettings.enabled) {
                    return;
                }
                root.shareByUrl.requestShareByUrl({documentId: root.document.id, page: root.currentPage });
            }

            onConvertToTextSelected: {
                if (!networkActionResponse() && !retailSettings.enabled) {
                    return;
                }

                if (retailSettings.enabled) {
                    root.windowNavigator.open("retail/window/popup", {
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

                const convertAction = () => {
                    sceneView.endItemSelection();
                    root.convertPages([root.currentPage]);
                    HwcTelemetry.entryPoint("Share tool");
                }

                root.windowNavigator.open("onboarding-ui/window/conversionlanguage", { onFinished: convertAction })
                reportToolbarActionTelemetry("Convert to text");
            }

            onTagsPopupVisibleChanged: (tagsPopupVisible) => {
                if (tagsPopupVisible) {
                    tagPopup.addTagsForEntry(tagsForCurrentPage ?? []);
                    tagPopup.initialTagsModel = Library.tagLabels();
                    tagPopup.show();
                }
                root.newPageVisible = false;
            }

            onSettingsSelected: {
                defaultActionResponse();
                root.showDocumentSettings();
                reportToolbarActionTelemetry("Settings");
            }
            onSearchSelected: {
                defaultActionResponse();
                root._openInDocSearch();
                reportToolbarActionTelemetry("Search");
            }
            onEbookSettingsSelected: {
                defaultActionResponse();
                formatSettings.show()
                reportToolbarActionTelemetry("Text settings");
            }
            onAddPageSelected: {
                defaultActionResponse();
                root.addPage(root.document, undefined);
                reportToolbarActionTelemetry("New page");
                root.reportPageAdded(root.document, "toolbar");
            }
            onToggleOrientationSelected: {
                sceneView.endItemSelection();
                LibraryController.setOrientation(root.document.id, !portrait ? Qt.Vertical : Qt.Horizontal);
                root.newPageVisible = false;
                reportToolbarActionTelemetry("Set orientation");
            }
            onFitToWidthSelected: {
                LibraryController.setZoomMode(root.document.id, Document.FitToWidth);
                root.resetViewportAndFlash();
                root.newPageVisible = false;
            }
            onFitToHeightSelected: {
                LibraryController.setZoomMode(root.document.id, Document.FitToHeight);
                root.resetViewportAndFlash();
                root.newPageVisible = false;
            }
            onFitToCustomSelected: {
                defaultActionResponse();
                adjustViewPopup.start();
            }
            onChooseTemplateSelected: {
                closeFoldout();
                root.newPageVisible = false;
                reportToolbarActionTelemetry("Set template");
                _documentMethodsTelemetry.templateOverviewOpened("From document");

                const templateFilename = root.document.templateForPage(root.currentPage);
                const currentTemplate = Templates.list().find((t) => t.filename === templateFilename) || null;

                root.ghostBuster.viewChange(GhostBuster.DocumentViewDialogOpened);
                windowNavigator.open("document/window/template-selector", {
                    currentTemplate: currentTemplate,
                    paperSize: sceneController?.explicitPaperSize ?? DeviceScreenInfo.paperSize,
                    onApplied: (aTemplate, templateApplied, setRecent) => {
                            if (templateApplied) {
                                const templateFilename = aTemplate?.filename ?? "";

                                // set name and template, if it's valid
                                if (root?.document?.type === Entry.Document) {
                                    DocumentController.setTemplateForPage(root.document, root.currentPage, templateFilename);
                                    _documentMethodsTelemetry.templateAction(aTemplate, DocumentMethodsTelemetry.TemplateActions.Applied);

                                    const isPortrait = !aTemplate?.landscape;

                                    LibraryController.setOrientation(root.document.id, isPortrait ? Qt.Vertical : Qt.Horizontal);
                                    if (!KeyboardInfo.keyboardConnected && isPortrait !== root.orientation.isPortraitOrientation) {
                                        // one-shot a orientation change if the template is in a different orientation than the screen
                                        root.orientation.requestOneShotOrientation(isPortrait ?
                                                                                           WindowLayout.Orientation.Portrait :
                                                                                           WindowLayout.Orientation.InvertedLandscape);
                                    }

                                    if (setRecent) {
                                        Templates.setRecentTemplate(aTemplate);
                                    }
                                }

                            // Analytics
                            root.reportTemplateSetFromDocument(aTemplate);
                            root.ghostBuster.viewChange(GhostBuster.DocumentViewDialogClosed);
                        }
                    },
                    onRejected: () => {
                        root.ghostBuster.viewChange(GhostBuster.DocumentViewDialogClosed);
                    }

                });
            }
            onToggleBackgroundVisibleSelected: {
                sceneController.setBackgroundVisible(!sceneController.backgroundVisible);
                root.newPageVisible = false;
                reportToolbarActionTelemetry("Layer visibility");
            }
            onToggleRootDocumentVisibleSelected: {
                sceneController.setRootDocumentVisible(!sceneController.isRootDocumentVisible);
                root.newPageVisible = false;
                reportToolbarActionTelemetry("Layer visibility");
            }
            onSetCurrentLayerSelected: (index) => {
                sceneController.setCurrentLayer(index);
                root.newPageVisible = false;
            }
            onToggleLayerVisibilitySelected: (index) => {
                sceneController.setLayerVisible(index, !sceneController.isLayerVisible(index));
                root.newPageVisible = false;
                reportToolbarActionTelemetry("Layer visibility");
            }
            onMoveLayerUpSelected: (index) => {
                sceneController.moveLayer(index, index + 1);
                root.newPageVisible = false;
                reportToolbarActionTelemetry("Layer move");
            }
            onMoveLayerDownSelected: (index) => {
                sceneController.moveLayer(index, index - 1);
                root.newPageVisible = false;
                reportToolbarActionTelemetry("Layer move");
            }
            onMergeLayerSelected: (index) => {
                sceneController.mergeLayerDown(index);
                root.newPageVisible = false;
            }
            onDeleteLayerSelected: (index) => {
                sceneController.deleteLayer(index);
                root.newPageVisible = false;
                reportToolbarActionTelemetry("Layer delete");
            }
            onRenameLayerSelected: (index, name) => {
                sceneController.setLayerName(index, name);
                root.newPageVisible = false;
            }
            onNewLayerSelected: {
                sceneController.addLayer();
                root.newPageVisible = false;
                reportToolbarActionTelemetry("Layer add");
            }
            onToggleBackgroundFilter: (value) => {
                DocumentController.setViewBackgroundFilter(root.document, value);
            }
            // Telemetry signals
            onReportLayersFoldoutOpened: {
                reportToolbarActionTelemetry("Layers foldout")
            }
            onReportAdjustViewClicked: {
                reportToolbarActionTelemetry("Adjust view");
            }
            onToolbarPositionSelected: {
                defaultActionResponse();
            }

            // In order to prevent accidentals, we only allow the pen to click the close button while the pen is close.
            onCloseDocumentClicked: (event) => {
                if (PenClosenessMonitor.penClose && event.source !== Qt.MouseEventNotSynthesized) {
                    return;
                }
                documentTelemetry.closeMethod.reportButton(false);
                root.reportDocumentClosed("toolbar");
                root.close();
            }

            tooltipOverlay: _toolbarTooltipOverlay
        }

        Item {
            id: _toolbarTooltipOverlay
            anchors.fill: parent
        }

        FormatMenuDelegate {
            id: formatMenuDelegate

            viewItem: root
            tileManager: sceneView.tileManager
            sceneController: root.sceneController

            readonly property bool commonVisibleConditions: sceneView.status === SceneView.Active
                                                         && sceneController !== null
                                                         && sceneView.textMode

            defaultMenu.parent: sceneView.uiOverlay

            vkbMenu.visible: commonVisibleConditions
                          && Qt.inputMethod.visible
                          && !searchResultsHeader.visible
                          && !KeyboardInfo.keyboardConnected

            defaultMenu.visible: commonVisibleConditions
                              && !sceneView.gesturing
                              && sceneController.isRootDocumentVisible
                              && sceneController.hasRootDocument
                              && !sceneController.hasPreliminaryLineBreaks
                              && !defaultMenu.hideTimerRunning
                              && !sceneView.textSelectionMode
                              && !sceneView.itemSelectionMode
                              && sceneController.textParagraphBounds.width > 0 // No width means we have no valid paragraph bounds.
                              && !vkbMenu.visible
        }

        AddTagPopup {
            id: addTagPopup
            width: _uiContainer.width

            overlay: _popupOverlay

            onAccepted: {
                pageSlider.updateNavigationPoints();
                tagPopup.setPageTags();
            }
            onRejected: toolbar.selectLastTool();
        }

        PageSearchResultOverlayItem {
            visible: _searchResultsHeader.visible && !root.isLoading
            visibleResults: _searchResultsHeader.filteredResults
            activeResultIndex: _searchResultsHeader.filteredResultIndex
            tileManager: sceneView.tileManager
            highlightMode: PageSearchResultOverlayItem.InvertAndGrayHighlights

            width: parent.width
            height: parent.height
            anchors.centerIn: parent
        }

        SearchResultsHeader {
            id: _searchResultsHeader
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            visible: false
            z: 1
            documentView: root
            document: root.document
            currentPage: root.currentPage
            rejectText: qsTr("Close", "Button label to close the in-document search bar")
            isSceneViewActive: sceneView.status === SceneView.Active

            onOpenPage: (pageNumber) => {
                root.openPage(pageNumber, DocumentView.ScrollPosition.SaveAndRestore);
            }

            onUpdateViewFromSearchResult: (location) => {
                sceneView.updateViewFromSearchResult(location);
            }

            Connections {
                target: sceneView
                enabled: _searchResultsHeader.visible
                function onStatusChanged() {
                    if (sceneView.status === SceneView.Active && _searchResultsHeader.searchController.currentResultIndex >= 0) {
                        sceneView.updateViewFromSearchResult(_searchResultsHeader.searchController.resultLocation());
                    }
                }
            }
        }

        SearchResultsFooter {
            id: searchResultsProgress
            visible: _searchResultsHeader.running && !_searchResultsHeader.pageOnly
            progress: _searchResultsHeader.progress
            text: _searchResultsHeader.searchProgressionText
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
        }

        SearchResultsFooter {
            readonly property bool _matchesFound:  _searchResultsHeader.committedSearchInput !== "" && _searchResultsHeader.totalResults > 0
            readonly property bool _noResultFound: _searchResultsHeader.committedSearchInput !== "" && _searchResultsHeader.totalResults <= 0

            visible: _searchResultsHeader.committedSearchInput !== ""
            inverted: _noResultFound
            text: _noResultFound
                  //: Search results for text search inside the document
                  ? qsTr("No results found")
                  //: Search results for text search inside the document; requires plural form
                  : qsTr("%n match(es) found", "", _searchResultsHeader.totalResults)

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
        }

        MouseArea {
            // Used to close the page slider
            anchors.fill: parent
            onPressed: (mouse) => {
                // we hide the slider, and explicitly let the event through,
                // so the toolbar (or whatever) can take it
                pageSlider.visible = false;
                mouse.accepted = false;
            }
            visible: pageSlider.visible
        }

        // The PageSlider is deliberately stacked over the top of the toolbox,
        // to make it easier to hit the left hand side of the slider.
        DocumentPageSlider {
            id: pageSlider
            documentView: root
            toolbar: toolbar
            document: root.document
            tocModel: root.tocModel
            pageCount: root.pageCount
            portrait: root.portrait

            onDidQuickBrowse: sceneView.notifyDidQuickBrowse()
            onPageNavigatedTelemetry: (source) => { documentTelemetry.pageNavigated(source); }
            onQuickBrowseInteractedTelemetry: (interaction) => { documentTelemetry.quickBrowseInteracted(interaction); }
        }

        Connections {
            target: Clipboard
            function onItemsChanged() {
                if (Clipboard.hasItems) {
                    clipboardText = qsTr("Copied to clipboard. Tap any page with Marker to paste.");
                    clipboardNotificationVisible = true;
                } else {
                    documentViewTools.forceMoveTool = false;
                    clipboardNotificationVisible = false;
                    clipboardText = defaultClipBoardText;
                }
            }
        }

        InactiveWarning {
            id: inactiveWarning
            visible: false
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            property bool haveShownInactiveWarning: false
            property bool shouldShowWarning: document && (document.status === Entry.ExcludedFromSync) && Settings.showInactiveWarning && !inactiveWarning.haveShownInactive

            onShouldShowWarningChanged: {
                inactiveWarning.visible = shouldShowWarning && !haveShownInactiveWarning;
            }
        }

        FormatSettings {
            id: formatSettings
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            document: root.document
            epubSettings: root.epubSettings

            onVisibleChanged: {
                root.handleDialogGhosting(visible);
            }
        }

        Pages {
            id: pages
            anchors.fill: parent
            documentView: root
            document: root.document
            documentTelemetry: root.documentTelemetry
            notificationQueue: root.notificationQueue
            visible: false
            tocModel: root.tocModel
            popupOverlay: _popupOverlay
            shouldRestrictMethods: root.shouldRestrictMethods
            pageSelection: root.pageSelection
            movePageSelection: root.movePageSelection
            orientation: root.orientation
            windowNavigator: root.windowNavigator
            notificationBarHeight: Math.max(notificationBar.height, hwcDialog.height)
            addTagPopup: addTagPopup
            onVisibleChanged: {
                if (visible) {
                    if (KeyboardInfo.keyboardConnected) {
                        root.exitTextMode();
                    }
                }
                root.handleDialogGhosting(visible);
            }
        }

        NotificationBar {
            id: notificationBar

            property bool showWithoutTimeout: false
            property int timerInterval: root.notificationTimerInterval

            clipboardText: root.clipboardText
            showDocumentViewNotifier: messageTimer.running || notificationBar.showWithoutTimeout
            showClipboardNotifier: root.clipboardNotificationVisible && !sceneView.selectionMode && !sceneView.textMode

            anchors {
                left: parent.left
                leftMargin: !pages.visible && (toolbar.shown && toolbar.position === ToolbarPositioner.Position.Left) ? toolbar.innerWidth : 0
                right: parent.right
                rightMargin: !pages.visible && (toolbar.shown && toolbar.position === ToolbarPositioner.Position.Right) ? toolbar.innerWidth : 0
                bottom: parent.bottom
                bottomMargin: !pages.visible && (toolbar.shown && toolbar.position === ToolbarPositioner.Position.Bottom) ? toolbar.innerHeight : 0
            }
            visible: showDocumentViewNotifier || showClipboardNotifier
            height: notificationBar.getBackgroundHeight

            onVisibleChanged: {
                if (!visible) {
                    root.clipboardText = root.defaultClipBoardText;
                }
            }

            onClipboardActionClicked: {
                root.clipboardNotificationVisible = false;
                Clipboard.items = undefined;
            }
            onSwipeGestureActivated: root.openFastScroll()

            Timer {
                id: messageTimer
                interval: notificationBar.timerInterval
            }
        }

        DocumentMethodsTelemetry {
            id: _documentMethodsTelemetry
            dispatcher: Telemetry.Dispatcher

            function templateAction(template, action = DocumentMethodsTelemetry.TemplateActions.Selected) {
                const telemetryFunc = (actionFunc) => () => {
                    if (template.name === "Blank") {
                        actionFunc(template.name, template.customTemplate);
                        return;
                    }

                    template.categories.forEach((category) => actionFunc(category, template.customTemplate));
                }

                if (DocumentMethodsTelemetry.TemplateActions.Selected === action) {
                    telemetryFunc(_documentMethodsTelemetry.templateSelectedResolve)();
                } else if (DocumentMethodsTelemetry.TemplateActions.Applied === action) {
                    telemetryFunc(_documentMethodsTelemetry.templateAppliedResolve)();
                }
            }

            function reportTemplateOverviewClosed() {
                _documentMethodsTelemetry.templateOverviewClosed('From document');
            }
        }


        HwcDialog {
            id: hwcDialog
            document: root.document
            visible: false
            onRequestOpenPage: (pageIndex, scrollPosition) => {
                root.openPage(pageIndex, scrollPosition);
            }
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                leftMargin: toolbar.position === ToolbarPositioner.Position.Left && toolbar.shown ? toolbar.innerWidth : 0
                rightMargin: toolbar.position === ToolbarPositioner.Position.Right && toolbar.shown ? toolbar.innerWidth : 0
                bottomMargin: toolbar.position === ToolbarPositioner.Position.Bottom && toolbar.shown ? toolbar.innerHeight : 0
            }

            Connections {
                target: root
                function onInSuspendChanged() {
                    if (!inSuspend) {
                        return;
                    }
                    hwcDialog.close();
                }
            }
        }

        Loader {
            id: retailIntroLoader
            anchors.right: parent.right
            anchors.rightMargin: ArkControls.Values.spacing.large
            anchors.bottom: parent.bottom
            anchors.bottomMargin: ArkControls.Values.spacing.large
            active: {
                return retailSettings.enabled && !!document &&
                       (document.id === retailSettings.defaultDocumentId);
            }

            function resetDocument() {
                root.openPage(0);
                root.close();
            }

            Connections {
                target: root
                enabled: retailIntroLoader.active

                function onCurrentPageChanged() {
                    if (currentPage === 0) {
                        toolbar.expanded = true;
                    }
                }
            }
        }

        Loader {
            objectName: "screenShareIndicators"
            anchors.fill: parent
            active: ScreenShare.serverActive && ScreenShare.numClients > 0
            sourceComponent: ScreenShareIndicators {}
            z: pageLabel.z + 1
        }

        Connections {
            target: ScreenShare
            function onServerStarted() {
                showNotification({
                                     message: qsTr("Accept the connection at app.remarkable.com/screenshare or in the desktop app"),
                                     messageIconSource: "qrc:/ark/icons/screen_share"
                                 },
                                 root.notificationTimerInterval,
                                 true);
            }
            function onServerStopped() {
                showNotification({
                                     message: qsTr("Screen Share is no longer active"),
                                     messageIconSource: "qrc:/ark/icons/screen_share"
                                 });
            }
            function onClientConnected() {
                showNotification({
                                     message: qsTr("Screen Share is active"),
                                     messageIconSource: "qrc:/ark/icons/screen_share"
                                 });
            }
            function onClientDisconnected() {
                if (ScreenShare.serverActive) {
                    showNotification({
                                         message: qsTr("Screen Share lost connection. Trying to reconnect..."),
                                         messageIconSource: "qrc:/ark/icons/screen_share"
                                     });
                }
            }
        }

        AdjustViewPopup {
            id: adjustViewPopup

            anchors.fill: parent

            view: sceneView

            overlay: _popupOverlay

            onViewSaved: scrollLockFlashTimer.restart()
        }

        PopupOverlay {
            id: _popupOverlay

            penInputManager: root.penInput.surfaceManager
            anchors.fill: parent

            focus: active
        }

        ZoomButton {
            id: zoomButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            z: pageSlider.z - 1 // Hides behind the pageSlider.
            visible: zoomLevel !== defaultScale && !adjustViewPopup.visible
                  || scrollLockVisualCue.visible
                  || (sceneView.scrollbarsVisible && !toolbar.expanded && didZoom) // This part make sure we don't show the zoombutton when panning if the toolbar is hidden.

            inverted: scrollLockVisualCue.visible
            zoomMin: sceneView.minimumScaleFactor
            zoomMax: sceneView.maximumScaleFactor
            zoomMode: root.zoomMode
            defaultScale: sceneView.defaultScale
            zoomLevel: sceneView.tileManager ? sceneView.tileManager.scale : defaultScale
            topGestureMargin: toolbar.gestureMargin

            onClicked: (mouse) => {
                // To avoid accidental jumping to 1x zoom, we reject touch events while pen is close
                // and the event source is touch. Pen events should still be accepted
                if (root.penClose && mouse.source === Qt.MouseEventSynthesizedByQt) {
                    return;
                }
                if (zoomLevel !== defaultScale) {
                    // We don't want to trigger if we're already in 100%.
                    const zoomIn = 2;    // any value above 1 will do
                    const zoomOut = 0.5; // any value below 1 will do
                    sceneView.singleStepZoom(zoomLevel < sceneView.defaultScale ? zoomIn : zoomOut);
                    documentTelemetry.snapBackToDefaultView("Button");
                }
            }

            states: [
                State {
                    when: toolbar.position === ToolbarPositioner.Position.Top
                    AnchorChanges {
                        target: zoomButton
                        anchors.bottom: notificationBar.top
                        anchors.top: undefined
                    }
                    PropertyChanges {
                        target: zoomButton
                        topGestureMargin: 0
                        bottomGestureMargin: toolbar.gestureMargin
                    }
                }
            ]
        }

        Item {
            id: connectivityDialogContainerItem

            anchors.fill: parent
        }
    }

    ToolTip {
        id: writingFormatsToolTip
        parent: pointTo.parent
        readonly property int tooltipMargin: 112
        container: Qt.rect(formatMenuDelegate.x + tooltipMargin, formatMenuDelegate.y + tooltipMargin, formatMenuDelegate.width - tooltipMargin * 2, formatMenuDelegate.height - tooltipMargin * 2)
        //: Recommended character limit for translation: 20
        caption: qsTr("Text formats")
        closeButtonFocusPolicy: Qt.NoFocus
        pointTo: formatMenuDelegate.vkbMenu.visible ? formatMenuDelegate.vkbMenu : formatMenuDelegate.defaultMenu.formatMenuFrame
        positionHint: formatMenu.formatMenuFrame.foldDown && !formatMenuDelegate.vkbMenu.visible ?
                      ArkControls.Tooltip.Position.Below :
                      ArkControls.Tooltip.Position.Above
        horizontalAlignment: ArkControls.Tooltip.Position.Right
        OnboardingStateProp.key: "WritingFormatsTool_Introduction"
        // pointTo.visible would reevaluate once, therefore we repeat the options here.
        readyToShow: formatMenuDelegate.vkbMenu.visible || formatMenuDelegate.defaultMenu.visible

        Connections {
            target: root.sceneController
            enabled: writingFormatsToolTip.visible
            function onRootDocumentLengthChanged() {
                writingFormatsToolTip.OnboardingStateProp.completed = true;
            }
        }

        Connections {
            target: formatMenuDelegate.vkbMenu
            enabled: writingFormatsToolTip.visible
            function onTextStyleFoldoutOpenChanged() {
                writingFormatsToolTip.OnboardingStateProp.completed = true;
            }
        }
    }

    Rectangle {
        id: scrollLockVisualCue
        visible: sceneView.gestureIsLocked
              || scrollLockFlashTimer.running
        anchors.fill: parent
        border.color: "black"
        border.width: 12
        color: "transparent"

        onVisibleChanged: {
            if (visible && sceneView.gestureIsLocked) {
                documentTelemetry.snapBackToDefaultView("Gesture");
            }
        }
    }
    Timer {
        id: scrollLockFlashTimer
        interval: 1000
    }
}
