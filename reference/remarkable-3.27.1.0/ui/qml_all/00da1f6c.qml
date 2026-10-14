import QtQuick

import com.remarkable
import common
import device.global
import device.view.experimental

import xofm.libs.devicesceneview.impl
import xofm.libs.epaper as Epaper
import xofm.libs.orientation
import xofm.libs.devicescreen
import xofm.libs.toolbar
import xofm.libs.peninput

FocusScope {
    id: root

    //
    // Input Properties
    //

    property Document document

    property bool renderInGrayscale: true
    property bool runningOnDevice: true
    property bool snapEnabled: true
    property real viewScale: 1.0
    property alias adjustViewActive: sceneViewGestures.panAndZoomOnly
    property int keyboardMargin: 0

    required property PenInput penInput
    required property bool penClose
    required property bool quickBrowseMode
    required property string backgroundFilterState
    required property int topOverscrollMargin
    required property Item toolbar

    property Orientation orientation

    //
    // Output Properties
    //

    readonly property SceneController controller: sceneView ? sceneView.controller : null
    readonly property SceneTileManager tileManager: sceneView ? sceneView.tileManager : null
    readonly property Item viewport: sceneView ? sceneView.viewport : null
    readonly property alias strokeHandler: strokeHandler
    readonly property bool viewTracksTextCursor: !sceneViewGestures.touchMultipleClickTimeout.running && !textSelectionHandleManger.blockCursorTracking

    readonly property int status: sceneView ? sceneView.status : SceneView.Inactive
    readonly property int pageStatus: sceneView ? sceneView.pageStatus : Page.None
    readonly property string pageStatusDetails: sceneView ? sceneView.pageStatusDetails : "";

    readonly property bool pageError: pageStatus !== Page.None && pageStatus !== Page.Ready

    readonly property int zoomMode: sceneView ? sceneView.zoomMode : Document.FitToWidth
    readonly property bool zoomedOut: tileManager ? tileManager.scale < defaultScale : false
    readonly property bool zoomedIn: tileManager ? tileManager.scale > defaultScale : false

    readonly property bool notePage: document && document.isNotepage(root.page)
    readonly property bool undoAvailable: controller && controller.undoAvailable
    readonly property bool redoAvailable: controller && controller.redoAvailable

    readonly property bool isLoading: !pageError &&
                                      (status !== SceneView.Active
                                      || (sceneView && sceneView.awaitingInitialTileSet)
                                      || (tileManager && tileManager.pendingTiles && !gesturing)
                                      || (controller && controller.working))
                                      || (selectionHandler && selectionHandler.working)

    readonly property bool textMode: status == SceneView.Active && sceneView.textModeEnabled && activeFocus && !sceneView.imReadOnly;

    readonly property real defaultScale: status == SceneView.Active ? sceneView.defaultScale : 1
    readonly property real penScale: status == SceneView.Active ? sceneView.penScale : 1
    readonly property point defaultCenter: status == SceneView.Active ? sceneView.defaultCenter : Qt.point(0, 0)
    readonly property rect exteriorBoundary: sceneView ? sceneView.sceneExteriorBoundary : Qt.rect(0, 0, 0, 0)

    readonly property bool itemSelectionMode: selectionHandler !== null
    readonly property bool textSelectionMode: textSelectionMenu.item !== null

    readonly property Item uiOverlay: uiOverlay

    readonly property alias glyphSelection: glyphSelectionRoot.item
    readonly property bool glyphSelectionMode: glyphSelectionRoot.item !== null

    // Properties used to handle states when doing hwc using the selection tool.
    readonly property alias hwcSelectionTool: hwcSelectionTool

    readonly property bool gesturing: gestureData !== undefined
    property bool gestureIsLocked
    readonly property bool isDefaultFocalPoint: tileManager !== null && tileManager.scale === defaultScale && tileManager.center === defaultCenter

    readonly property bool backgroundFilterVisible: viewBehavior.backgroundFilter

    readonly property rect availableSceneRect: {
        const availableHeight = root.height - root.keyboardMargin;
        if (!toolbar.shown) {
            return Qt.rect(0, 0, root.width, availableHeight);
        }
        switch(toolbar.position) {
        case ToolbarPositioner.Position.Left:
            return Qt.rect(toolbar.innerWidth, 0, root.width - toolbar.innerWidth, availableHeight);
        case ToolbarPositioner.Position.Right:
            return Qt.rect(0, 0, root.width - toolbar.innerWidth, availableHeight);
        case ToolbarPositioner.Position.Top:
            return Qt.rect(0, toolbar.innerHeight, root.width, availableHeight - Math.max(toolbar.innerHeight, pageLabel.height));
        case ToolbarPositioner.Position.Bottom:
            return Qt.rect(0, pageLabel.height, root.width, availableHeight - toolbar.innerHeight);
        }
    }

    //
    // Internal state..
    //

    property string pageId
    property int page

    property real leftViewportEdge: 0
    property real rightViewportEdge: 0
    property real topViewportEdge: 0
    property real bottomViewportEdge: 0
    property bool scrollPositionChanged

    property real viewWidth: width
    property real viewHeight: height

    readonly property real minimumScaleFactor: 0.5 * viewScale * (controller && !notePage ? Math.min(viewWidth / controller.primaryContentRect.width, viewHeight / controller.primaryContentRect.height) : 1)
    readonly property real maximumScaleFactor: 5.0 * viewScale * (controller && !notePage ? Math.max(viewWidth / controller.primaryContentRect.width, viewHeight / controller.primaryContentRect.height) : 1)
    readonly property real scaleSnapHigh: defaultScale * 1.05
    readonly property real scaleSnapLow: defaultScale * 0.95

    property real verticalJumpDistance: height * 0.8
    property var gestureData: undefined

    readonly property int scrollbarMarginToEdge: 30
    readonly property int scrollbarWidth: 12
    readonly property int scrollbarMarginAlongLength: 234
    readonly property int scrollbarVerticalLength: height - scrollbarMarginAlongLength * 2
    readonly property bool scrollbarsVisible: verticalScrollbar.visible || horizontalScrollbar.visible
    readonly property bool movingWithScrollbar: verticalScrollbar.scrolling || horizontalScrollbar.scrolling

    readonly property rect pageBorderRect: tileManager && controller
        ? (tileManager.sceneToViewTransform, tileManager.sceneToView(controller.primaryContentRect))
        : Qt.rect(0, 0, width, height)

    readonly property var globalScreenMode: screenDriver.globalMode

    readonly property bool hasTextSelection: controller?.hasTextSelection ?? false

    // SceneViewGestures internals
    property bool gesturesEnabled
    property bool uiVisible
    property bool clickGestureEnabled
    readonly property bool textSelectGestureActive: penGestureHandler instanceof TextSelectGesture && penGestureHandler.active

    //
    // Signals
    //

    signal completedStroke
    signal forceMoveTool
    signal keyPressed
    signal requestTextMode
    signal pasteFromShortcut(var actionType)
    signal pasteFromStroke(var position)
    signal requestToggleSelectionTool
    signal convertSelection(var callback)
    signal convertedShapeAdded(string shape)
    signal closeToolbarFoldout
    signal exitTextMode

    // SceneViewGestures forwarded signals
    signal openFastScroll
    signal openDocumentDrawer
    signal showScrollLock
    signal moveForward
    signal moveBackward
    signal closeGesture
    signal setUiVisible(bool mode)

    signal displayLinkNotification(int linkedPage, int currPage)
    signal openPage(int page, int scrollPosition)

    signal touchClicked

    //
    // Logging category for this item
    //
    LoggingCategory {
        id: sceneViewLog
        name: "rm.ui.devicesceneview"
        defaultLogLevel: LoggingCategory.Warning
    }

    //
    // Components
    //
    Component {
        id: sceneViewComponent
        SceneView {
            id: view

            readonly property bool isCurrentView: root.sceneView === view;

            width: root.width
            height: root.height
            viewportType: SceneView.DeviceViewport
            limitScrollingToPaper: true
            tileImageFormat: EPFramebuffer.format ?? SceneView.Format_RGB32
            focus: view === root.sceneView
            tileRefreshInterval: isCurrentView && root.gesturing ? 1000 : 0
            keyHandler.flavor: Settings.inputFlavor === Settings.InputFlavorType.Apple ? SceneKeyHandler.Apple : SceneKeyHandler.Windows
            tileAntialiasing: viewBehavior.sceneAntialiasing
            dottedTemplateLines: viewBehavior.dottedTemplateLines
            backgroundFilter: viewBehavior.backgroundFilter ? root.backgroundFilterState : "off";
            renderingTilesBeyondViewport: isCurrentView && root.notePage
            tileSize: Qt.size(root.width / 2, root.height / 2);
            inputMethodHints: Qt.ImhMultiLine | Qt.ImhNoTextHandles
            KeyboardSettings.actionPanelEnabled: false
            topOverscrollMargin: root.topOverscrollMargin

            cursorTrackingArea: {
                if (!root.viewTracksTextCursor || !root.textMode || !isCurrentView) {
                    return Qt.rect(0, 0, 0, 0);
                }

                const defaultMargin = 200;
                const minimumMargin = 20;
                const margin = Math.max(Math.min(defaultMargin, (DeviceScreenInfo.paperSize.width - textContentBoundary.width) / 2), minimumMargin);

                // NOTE: we cannot use Qt.inputMethod.visible here, because at present, the context doesn't ever hide it
                // when a hardware keyboard is attached, which is a problem. Instead, we use the size of the keyboard rect
                // to determine if it's visible or not. See also: UI-78.
                if (Qt.inputMethod.keyboardRectangle.height > 0) {
                    const vMargin = 120;
                    return Qt.rect(margin, vMargin, view.width - 2 * margin, view.height - 2 * vMargin - Qt.inputMethod.keyboardRectangle.height);
                }

                return Qt.rect(margin, defaultMargin, view.width - 2 * margin, view.height * 0.85 - defaultMargin);
            }
        }
    }

    Component {
        id: selectionHandlerComponent
        SceneSelectionHandler {
            id: selectionHandler
            anchors.fill: parent
            worker: sceneView.worker
            controller: sceneView.controller
            page: root.page
            toolsMargin: pageLabel.height
            toolbarWidth: toolbar.shown ? toolbar.innerWidth : 0
            showConvertToText: notePage
            snapRotation: true
            visible: false
            zoomedOut: root.zoomedOut
            availableSceneRect: root.availableSceneRect
            touchMargin: 15

            Connections {
                target: tileManager
                function onTransformChanged() {
                    if (!autoScrollTimer.running) {
                        selectionHandler.updatePosition();
                    }
                }
            }
            onCopy: () => {
                hwcSelectionTool.close();
                Clipboard.items = controller.cloneSelectedItems(controller.currentLayer, defaultScale);
                root.forceMoveTool();
                root.endItemSelection();
            }
            onCut: () => {
                hwcSelectionTool.close();
                Clipboard.items = controller.cloneSelectedItems(controller.currentLayer, defaultScale);
                controller.deleteSelectedItems(controller.currentLayer);
                root.forceMoveTool();
                root.endItemSelection();
            }
            onConvert: (point) => {
                root.convertSelection(function () {
                    hwcSelectionTool.initialCursorPos = point;
                    hwcSelectionTool.convert(controller.cloneSelectedItems(controller.currentLayer, root.defaultScale));
                    controller.deleteSelectedItems(controller.currentLayer);
                    root.forceMoveTool();
                    root.endItemSelection();
                });
            }
            onDeleteSelection: () => {
                hwcSelectionTool.close();
                controller.deleteSelectedItems(controller.currentLayer);
                root.forceMoveTool();
                root.endItemSelection();
            }
            onDragPositionChanged: {
                autoScrollTimer.speed = calculateAutoScrollSpeed(dragPosition.y);
            }
        }
    }

    //
    // Connections & Bindings
    //

    // On desktop (simulator), the input surface keeps content around until
    // explicitly cleared. So to clean that up, we need to clear its
    // framebuffer at the end of a stroke.
    //
    // This gives slightly different behaviour compared to on device, where
    // the content stays until the next repaint, but that should mean little
    // in practice.
    Connections {
        enabled: !root.runningOnDevice
        target: root
        function onCompletedStroke() {
            Qt.callLater(inputSurface.clearFramebuffer);
        }
    }

    Connections {
        target: root.controller
        function onAreaSelected(layer, sceneRect) {
            inputSurface.clearFramebuffer();
            viewport.requestRepaintDirty();
            const validSelection = sceneRect.width > 0 && sceneRect.height > 0;
            const validGlyphSelection = Experimental.glyphSelection.enabled && root.glyphSelection && !root.glyphSelection.selectionBoundingRect.isEmpty;
            const stillSelecting = strokeHandler.lineTool == Line.SelectionTool;
            if ((validSelection || validGlyphSelection) && stillSelecting) {
                console.log(sceneViewLog, "area selected, layer=" + layer + ", area=" + sceneRect);
                // business as usual, create and/or update selection handler
                strokeHandler.setSelectionActive(true);
                if (validGlyphSelection) {
                    root.glyphSelection.open();
                } else if (validSelection) {
                    if (!root.selectionHandler) {
                        root.selectionHandler = selectionHandlerComponent.createObject(selectionHandlerRoot);
                    }
                    root.selectionHandler.open(layer, sceneRect);
                }
            } else {
                console.log(sceneViewLog, "invalid selection, area=[" + sceneRect.width + "x" + sceneRect.height + "]" + ", selection-tool=" + (stillSelecting ? "yes" : "no"));
                endItemSelection();
                controller.clearSelectedItems();
            }
        }
        function onSelectionCleared() {
            if (!root.glyphSelection || !root.glyphSelection.visible)
                root.endItemSelection();
        }
        function onCurrentLayerChanged() { root.endItemSelection(); }
        function onAboutToRedo() { root.endItemSelection(); }
        function onAboutToUndo() {
            root.endItemSelection();
            if (hwcSelectionTool.processing && !hwcSelectionTool.failed) {
                Recognizer.abortSelectionToolJob();
                hwcSelectionTool.close();
            }

            if (hwcSelectionTool.status === RecognitionJob.Status.Done) {
                root.exitTextMode();
            }
        }

        function onTextSelected() {
            if (!root.textMode) {
                requestTextMode();
            }
            textSelectionMenu.openNow();
        }

        function onTextPasted(startPos, length) {
            if (hwcSelectionTool.done) {
                if (sceneController.textCursorIndex - length >= 0) {
                    sceneController.selectTextRange(sceneController.textCursorIndex - length, sceneController.textCursorIndex);
                }
                hwcSelectionTool.done = false;
            }
        }

        function onPenTapRepeated() {
            textSelectionMenu.openNow();
        }

       function onGlyphsSelected(areas, text) {
           if (!Experimental.glyphSelection.enabled) {
               return;
           }

           glyphSelectionRoot.active = true;
           root.glyphSelection.setSelection(areas, text);
       }
    }

    Connections {
        target: root.sceneView
        function onAwaitingInitialTileSetChanged() {
            if (!root.sceneView.awaitingInitialTileSet) {
                maybeShowInitialScrollbar();
            }
        }
    }

    Connections {
        target: root.tileManager
        function onTransformChanged() {
            inputSurface.updateTransform();
            updateViewportEdges();
        }
    }

    // When coming out of adjust view the view has moved position on screen,
    // so we need to re-apply the right transforms after everything has
    // settled.
    onAdjustViewActiveChanged: {
        if (!adjustViewActive) {
            Qt.callLater(inputSurface.updateTransform);
        }
    }

    onTileManagerChanged: {
        if (root.tileManager) {
            inputSurface.updateTransform();
            updateViewportEdges();
        }
    }

    onHasTextSelectionChanged: {
        if (hasTextSelection) {
            textSelectionMenu.openLater();
        } else {
            textSelectionMenu.close();
        }
    }

    // When text mode and we're typing, we want to make use of the faster
    // direct-to-framebuffer repaint mode in the DeviceSceneViewport.
    Binding {
        target: root.viewport
        when: root.viewport !== null
        property: "minimalChangesInFastMono"
        value: root.textMode
            && viewBehavior.minimalUpdates
            && !(textSelectionHandleManger.handlesVisible || textSelectionHandleManger.dragging)
        restoreMode: Binding.RestoreNone
    }

    Binding {
        target: root.viewport
        when: root.viewport !== null && root.runningOnDevice
        property: "framebuffer"
        value: EPFramebuffer
        restoreMode: Binding.RestoreNone
    }

    Binding {
        target: root.viewport
        when: root.viewport !== null && root.runningOnDevice
        property: "penInputHandler"
        value: strokeHandler
        restoreMode: Binding.RestoreNone
    }

    Binding {
        target: root.viewport
        when: root.viewport !== null
        restoreMode: Binding.RestoreNone
        property: "monoTextArea"
        value: {
            if (root.controller && root.controller.rootDocumentLength > 0
                && root.tileManager
                && screenDriver.globalMode
                && (screenDriver.globalMode == Epaper.ScreenModeItem.Mono
                    || screenDriver.globalMode == Epaper.ScreenModeItem.Animation)) {
                return root.tileManager.sceneToView(root.controller.rootDocumentBoundingRect);
            }
            return Qt.rect(0, 0, 0, 0);
        }
    }

    Connections {
        target: root.sceneView
        // When writing using Seabird, any keyboard presses are considered accidental
        // so we block it when the pen is close or on the screen.
        enabled: {
            return Qt.inputMethod.visible || !PenClosenessMonitor.penClose;
        }
        function onSceneKeyActionReceived(action) {
            if (sceneViewGestures.userIsActive) {
                // To avoid accidental keypresses when the user is touching the screen
                // we just ignore the keypresses if the userIsActive. Meaning that
                // sceneViewGestures (aka TouchArea) has active touch filters.
                return;
            }
            if (hwcSelectionTool.processing) {
                // do not allow any inputs while hwc is in progress
                return;
            }

            endItemSelection();

            textSelectionMenu.close();
            if (controller.hasTextSelection) {
                textSelectionMenu.openLater();
            }

            root.keyPressed();
            root.closeToolbarFoldout();

            let flags = 0;

            if (action.type === SceneKeyHandlerAction.Paste ||
                action.type === SceneKeyHandlerAction.PasteAndMatchStyle) {
                pasteFromShortcut(action.type);
                return;
            } else if (action.type === SceneKeyHandlerAction.PageUp) {
                scrollUp();
                return;
            } else if (action.type === SceneKeyHandlerAction.PageDown) {
                scrollDown();
                return;
            } else if (action.type === SceneKeyHandlerAction.SelectionToolToggle) {
                requestToggleSelectionTool();
                return;
            } else if (action.type === SceneKeyHandlerAction.KeyStroke) {
                showCursorTimer.restart();
                flags = SceneController.KeyAction_HideCursor;
            }

            if (!root.sceneView.textModeEnabled) {
                switch (action.type) {
                case SceneKeyHandlerAction.Enter:
                    // Prevents adding new line if root document is empty
                    if (!controller.rootDocumentLength) {
                        requestTextMode();
                        return;
                    }
                case SceneKeyHandlerAction.KeyStroke:
                case SceneKeyHandlerAction.InputMethodEvent:
                case SceneKeyHandlerAction.CursorMove:
                case SceneKeyHandlerAction.Backspace:
                case SceneKeyHandlerAction.Delete:
                case SceneKeyHandlerAction.DeleteEndOfLine:
                case SceneKeyHandlerAction.DeleteEndOfWord:
                case SceneKeyHandlerAction.DeleteStartOfWord:
                case SceneKeyHandlerAction.DeleteCompleteLine:
                case SceneKeyHandlerAction.SelectAll:
                case SceneKeyHandlerAction.LineBreak:
                    requestTextMode();
                    break;
                }
            }

            controller.keyAction(action, flags);
        }
    }

    Connections {
        target: orientation
        enabled: root.status == SceneView.Active
        function onOrientationChanged() {
            console.log(sceneViewLog, "device orientation changed, updating pen surface transforms");
            // The device orientation has changed, but the QML may not yet
            // have been updated, so rather than updating right away, we flag
            // the input surface transforms to be updated in the immediate
            // future, rather than right away.
            Qt.callLater(function() {
                if (root.status == SceneView.Active) {
                    inputSurface.updateTransform();
                }
            });
        }
    }

    Connections {
        target: sceneView
        enabled: root.status == SceneView.Active
        function onTextModeEnabledChanged() {
            // in case it is open due to double-tap and doesn't have a selection
            // and thus doesn't get closed implicitly from selection being
            // cleared.
            textSelectionMenu.close();
        }
    }

    //
    // Items
    //

    // The views are dynamically allocated in goToPage()
    property SceneView sceneView
    property SceneView nextSceneView;
    property SceneView previousSceneView;

    // Selection handler is dynamically allocated when a selection is made.
    property SceneSelectionHandler selectionHandler

    // Handler is dynamically allocated when certain tools are current
    property var penGestureHandler: null

    Timer {
        id: showCursorTimer
        interval: 250
        running: false
        repeat: false
        onTriggered: {
            if (textMode && controller) {
                controller.setCursorVisible(true, true);
            }
        }
    }

    Timer {
        id: viewportUpdateTimer
        interval: 1000
        running: false
        repeat: false
        function markDirtyAndRestart(dirtyRect) {
            root.viewport.markDirty(dirtyRect);
            viewportUpdateTimer.restart();
        }
        onTriggered: {
            if (strokeHandler.timeSincePenUp() < 100) {
                viewportUpdateTimer.restart();
                return;
            }
            inputSurface.clearFramebuffer();
            root.viewport?.requestRepaintDirty();
        }
    }

    DeviceSceneViewBehavior {
        id: viewBehavior
    }

    ScenePenInputHandler {
        id: strokeHandler

        property bool shapeSnap: Settings.shapeSnapEnabled
        Component.onCompleted: setShapeDetection(shapeSnap)
        onShapeSnapChanged: setShapeDetection(shapeSnap)

        function calculateEraserThickness(thickness) {
            // The eraser is a bit special in that it treats the thickness as
            // a squared value.
            return thickness * thickness;
        }

        function trySelectImageAtPoint(point) {
            return controller.selectImageAtPoint(point, controller.currentLayer);
        }

        rightHandMode: Values.accessibilityRightHanded

        // Note: This assumes DrawAndHold is the only active writingToolGesture
        readonly property int activeWritingGestures: Settings.shapeSnapEnabled ?
                                                         ScenePenInputHandler.WritingToolGestures :
                                                         ScenePenInputHandler.NoGestures


        gestureMode: documentViewTools.isWritingTool(documentViewTools.activePen.tool)
            ? activeWritingGestures
            : (documentViewTools.activePen.tool === Line.SelectionTool)
                ? ScenePenInputHandler.SelectionGestures
                : ScenePenInputHandler.NoGestures
        textColumnRect: root.controller ? root.controller.rootDocumentBoundingRect : Qt.rect(0, 0, 0, 0)
        minHorizDistance: 89 // approx 1cm at 227 DPI
        lineTool: documentViewTools.activePen.tool
        lineColor: documentViewTools.activePen.color
        lineThickness: (lineTool === Line.Eraser
                        ? calculateEraserThickness(documentViewTools.activePen.thickness)
                        : documentViewTools.activePen.thickness)
             / root.penScale
        lineArgbCode: documentViewTools.activePen.colorCode
        pasteEnabled: Clipboard.hasItems && !root.textMode
        pageLoading: root.isLoading
        antialiasing: viewBehavior.hasLiveAntialiasing(lineTool, lineColor, lineArgbCode)

        eraserThickness: calculateEraserThickness(2.4) / root.penScale;

        onPasteTriggered: (position) => {
            if (trySelectImageAtPoint(position)) {
                return;
            }
            pasteFromStroke(position);
        }

        onStrokeCompleted: (stroke) => {
            completedStroke();

            if (stroke.isHighlighter) {
                const snapMode = documentViewTools.activePen.snapHighlighterToText ? SceneController.SnapEnabled
                                                                                   : SceneController.SnapDisabled
                controller.highlightWithLine(stroke, snapMode);
            } else if (stroke.isEraserTool) {
                controller.eraseWithLine(stroke);
            } else if (stroke.isSelectionTool) {
                if (stroke.pointCount === 0) {
                    endItemSelection();
                    return;
                }
                // Make sure that textMode is not lingering around
                if (root.textMode && !Qt.inputMethod.visible) {
                    root.exitTextMode();
                }
                const bounds = stroke.boundingRect;
                const isShort = Math.max(bounds.width, bounds.height) < 30;
                if (isShort) {
                    // First lets check if an image is at the cursor
                    const tapPoint = Qt.point(bounds.x + bounds.width / 2, bounds.y + bounds.height / 2);
                    if (trySelectImageAtPoint(tapPoint)) {
                        return;
                    }
                }
                // If not a tap lets treat it as a line selection
                const textMode = root.textMode ? SceneController.AcceptTapGesture : SceneController.IgnoreTapGesture;
                controller.selectWithLine(stroke, textMode);
            } else {
                controller.addDrawingLine(stroke);
            }

            const behavior = viewBehavior.queryAddStrokeMode(stroke);
            if (behavior.addToTiles) {
                sceneView.tileManager.renderLineToTiles(stroke);
            }
            if (behavior.delayedRefresh) {
                if (screenDriver.globalMode == Epaper.ScreenModeItem.Animation) {
                    // in animation mode, we don't want to trigger flashes
                    sceneView.viewport.markDirty(sceneToView(stroke.boundingRect));
                } else {
                    viewportUpdateTimer.markDirtyAndRestart(sceneToView(stroke.boundingRect));
                }
            } else if (behavior.markViewportDirty) {
                sceneView.viewport.markDirty(sceneToView(stroke.boundingRect));
            }
        }

        onGestureStarted: (gestureId, data) => {
            if (gestureId === ScenePenInputHandler.DrawAndHoldGesture) {
                requestDrawAndHoldGesture();
            } else if (gestureId === ScenePenInputHandler.TextSelectGesture) {
                requestTextSelectGesture();
            } else if (gestureId === ScenePenInputHandler.PartitionGesture) {
                requestPartitionGesture();
            } else {
                requestNoSnapping();
            }
            root.penGestureHandler?.startGesture(data);
        }
    }

    InversionOverlay {
        id: inversionOverlay
    }

    Item {
        id: sceneViewsRoot
        anchors.fill: parent
        objectName: "SceneViewsRoot"
    }

    PenInputSurface {
        id: inputSurface
        handler: sceneView && !root.adjustViewActive ? strokeHandler : null
        manager: root.penInput.surfaceManager
        anchors.fill: parent
        function updateTransform() {
            inputSurface.setTransform(root.tileManager.sceneToViewTransform);
        }
    }

    ScreenDriver {
        id: screenDriver

        property bool isAnimationMode

        signal exitedAnimationMode

        notePage: root.notePage
        visible: root.visible
        pendingTiles: !root.tileManager || root.tileManager.pendingTiles
        penClose: root.penClose

        gestureMode: root.gestureData !== undefined
        selectionMode: root.itemSelectionMode || (root.controller && root.controller.hasTextSelection) || sceneViewGestures.cursorDragging
        textMode: root.textMode
        snapMode: root.penGestureHandler?.gestureId === ScenePenInputHandler.DrawAndHoldGesture
        quickBrowseMode: root.quickBrowseMode

        onGlobalModeChanged: {
            const isNormal = !screenDriver.globalMode;
            const wasAnimation = screenDriver.isAnimationMode;
            if (isNormal && wasAnimation) {
                screenDriver.exitedAnimationMode();
            }
            screenDriver.isAnimationMode = screenDriver.globalMode === Epaper.ScreenModeItem.Animation;
        }
    }

    Epaper.ScreenModeItem {
        id: content
        anchors.fill: parent
        mode: Epaper.ScreenModeItem.Content
        visible: !screenDriver.globalMode
        objectName: "scene-view"
        // screen mode is the "last" item before the UI stuff
    }

    Component {
        id: snapHandlerComponent
        SnapHandler {
            id: snapHandler
            anchors.fill: parent
            penHandler: strokeHandler
            penInputSurface: inputSurface
            visible: active
            sceneToViewTransform: tileManager ? tileManager.sceneToViewTransform : undefined
            viewToSceneTransform: tileManager ? tileManager.viewToSceneTransform : undefined
            onConvertedShapeAdded: (shape) => { root.convertedShapeAdded(shape); }
            onRequestAddLine: (stroke) => {
                completedStroke();
                controller.addDrawingLine(stroke);
                sceneView.tileManager.renderLineToTiles(stroke);
            }
        }
    }

    Component {
        id: textSelectGestureComponent
        TextSelectGesture {
            id: textSelect
            anchors.fill: parent
            penHandler: strokeHandler
            tileManager: root.tileManager

            onTextSelectStarted: (pos) => {
                enterTextMode(true, pos);
                root.controller.setCursorPosition(pos, SceneController.MoveAnchor);
            }

            onTextSelectMoved: (pos) => {
                root.controller.setCursorPosition(pos, SceneController.KeepAnchor);
            }

            onTextSelectEnded: (pos) => {
                textSelectionMenu.openWhenHasSelection();
            }
        }
    }

    Component {
        id: partitionSelectGestureComponent
        PartitionSelectGesture {
            id: partSelect
            anchors.fill: parent
            penHandler: strokeHandler
            tileManager: root.tileManager
            sceneToViewTransform: tileManager ? tileManager.sceneToViewTransform : undefined
            sceneRect: controller ? controller.boundingRect : undefined
            availableSceneRect: root.availableSceneRect

            property bool keepInMono: true

            onSelectWithLine: (stroke) => {
                completedStroke();
                controller.selectWithLine(stroke);
            }
        }
    }

    Connections {
        target: root.penGestureHandler

        function onGestureFinished() {
            requestNoSnapping();
        }
    }

    function requestDrawAndHoldGesture() {
        if (root.penGestureHandler instanceof SnapHandler) {
            return;
        }
        _destroySnapHandler();

        root.penGestureHandler = snapHandlerComponent.createObject(penGestureHandlerRoot);
    }

    function requestTextSelectGesture() {
        if (root.penGestureHandler instanceof TextSelectGesture) {
            return;
        }
        _destroySnapHandler();

        root.penGestureHandler = textSelectGestureComponent.createObject(penGestureHandlerRoot);
    }

    function requestPartitionGesture() {
        if (root.penGestureHandler instanceof PartitionSelectGesture) {
            return;
        }
        _destroySnapHandler();

        root.penGestureHandler = partitionSelectGestureComponent.createObject(penGestureHandlerRoot);
    }
    function requestNoSnapping() {
        _destroySnapHandler();
    }

    function _destroySnapHandler() {
        if (root.penGestureHandler) {
            root.penGestureHandler.destroy();
            root.penGestureHandler = null;
        }
    }

    //
    // UI Overlay items
    //

    Item {
        anchors.fill: parent

        SceneViewGestures {
            id: sceneViewGestures
            enabled: gesturesEnabled
            view: root

            onBeginDragAndZoom: {
                horizontalScrollbar.cancel();
                verticalScrollbar.cancel();
                root.beginDragAndZoom();
            }

            onEndDragAndZoom: {
                root.endDragAndZoom();
            }

            onTouchClicked: root.touchClicked()
            onOpenDocumentDrawer: root.openDocumentDrawer()
            onCursorDragPositionChanged: (pos) => {
                autoScrollTimer.speed = calculateAutoScrollSpeed(pos.y);
            }
        }

        Item {
            id: uiOverlay
            anchors.fill: parent
            visible: !root.adjustViewActive

            Item {
                id: penGestureHandlerRoot
                anchors.fill: parent
            }

            Timer {
                id: autoScrollTimer
                interval: 50
                running: textDragManager.dragging || textSelectionHandleManger.dragging || (root.selectionHandler?.dragging ?? false) || sceneViewGestures.cursorDragging
                onRunningChanged: {
                    if (!running) {
                        speed = 0
                    }
                }
                repeat: true
                property real speed: 0
                onTriggered: {
                    if (speed !== 0) {
                        root.tileManager.moveViewBy(Qt.point(0, autoScrollTimer.speed));
                    }
                }
            }

            Loader {
                id: glyphSelectionRoot
                anchors.fill: parent
                active: false

                sourceComponent: GlyphSelectionHandler {
                    id: glyphSelection
                    anchors.fill: parent
                    sceneToViewTransform: root.tileManager?.sceneToViewTransform ?? Qt.matrix4x4()

                    availableSceneRect: root.availableSceneRect

                    Connections {
                        target: tileManager
                        function onTransformChanged() {
                            root.glyphSelection.updatePosition();
                        }
                    }

                    onClicked: {
                        Clipboard.setTextFromString(root.glyphSelection.selectedText);
                        // FIXME: This text is temporary, need to involve the copy team.
                        showNotification(qsTr("Text copied to clipboard. Go to a notepage to paste."));
                        endItemSelection();
                    }

                    onClose: endItemSelection()
                }
            }

            TextDragManager {
                id: textDragManager
                anchors.fill: parent
                visible: root.controller && root.controller.hasTextSelection && !root.tileManager?.transactionRunning
                z: root.penClose ? 10 : 0

                penInput: root.penInput
                sceneView: root.sceneView
                anchorPosition: root.controller ? root.controller.textCursorAnchorPosition : Qt.point(0, 0)
                cursorPosition: root.controller ? root.controller.textCursorPosition : Qt.point(0, 0)
                onDragPositionChanged: {
                    const dragPos = root.tileManager.sceneToView(dragPosition);
                    autoScrollTimer.speed = calculateAutoScrollSpeed(dragPos.y);
                }
                Connections {
                    target: root.tileManager
                    function onTransformChanged() {
                        textDragManager.updateForTransform();
                    }
                }
            }

            TextSelectionHandleManager {
                id: textSelectionHandleManger
                penInput: root.penInput
                sceneView: root.sceneView
                tileManager: root.tileManager
                sceneScale: tileManager ? tileManager.scale : root.defaultScale
                sceneController: root.controller
                handlesVisible: !dragging && !textDragManager.dragging && ((textSelectionMode && root.controller.hasTextSelection) || root.textSelectGestureActive) && !root.tileManager?.transactionRunning
                hasSelection: root.controller?.hasTextSelection || root.textSelectGestureActive
                anchors.fill: parent
                onDragPositionChanged: {
                    autoScrollTimer.speed = calculateAutoScrollSpeed(dragPosition.y);
                }
            }

            TextSelectionMenu {
                id: textSelectionMenu
                visible: !textSelectionHandleManger.dragging && !textDragManager.dragging && !root.textSelectGestureActive && !root.tileManager?.transactionRunning
                availableSceneRect: root.availableSceneRect

                onRequestKeyboard: {
                    if (root.sceneView && root.controller) {
                        enterTextMode(true);
                        root.sceneView.showVirtualKeyboard();
                    }
                }
            }

            // Explicit closing of scrollbar when we exit animation mode to
            // avoid unnessesary additional blinking.
            Connections {
                target: screenDriver
                function onExitedAnimationMode() {
                    verticalScrollbar.hide();
                    horizontalScrollbar.hide();
                }
            }

            DeviceScrollBar {
                id: verticalScrollbar
                type: DeviceScrollBar.Type.Vertical
                z: 10 // Show when zoomed out.
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                    margins: 14
                }
                antialiasing: false

                /*
                  Visible conditions

                    Portrait and landscape:
                        Show vertical scrollbar when scrolling/panning/zooming.

                        If in an ebook:
                        - Only show vertical scrollbar when zoomed in.

                    Toolbar gets closed in conjunction with exiting animation
                    mode, see connection to screendriver just above.
                */
                readonly property bool isEbook: document && document.fileType === Document.Ebook
                readonly property bool isNotEbook: !isEbook
                readonly property bool panningVertical: gesturing && sceneViewGestures.panLockedVertical
                zoomedOut: root.zoomedOut
                zoomedIn: root.zoomedIn
                penClose: root.penClose
                visible: (scrollbarPressed || scrollbarTimersRunning || panningVertical)
                         && (isNotEbook || isEbook && zoomedIn)
                view: root
                states: [
                    State {
                    when: toolbar.position === ToolbarPositioner.Position.Right
                        AnchorChanges {
                            target: verticalScrollbar
                            anchors.left: parent.left
                            anchors.right: undefined
                        }
                    }
                ]
            }

            DeviceScrollBar {
                id: horizontalScrollbar
                type: DeviceScrollBar.Type.Horizontal
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 14
                }
                antialiasing: false

                /*
                    Visible conditions

                    Never:
                        - When zoomed out.

                    Portrait:
                        If content in the landscape-margins:
                        - Show horizontal scrollbar at 100 % zoom level when opening a document, scrolling and panning vertically and horizontally.

                        If no content in the landscape margins:
                        - Show horizontal scrollbar at 100 % zoom level only when panning horizontally.

                    Landscape:
                        - Show horizontal scrollbar only when zooming.

                    Toolbar gets closed in conjunction with exiting animation
                    mode, see connection to screendriver just above.
                */
                readonly property bool contentOutsideMargins: view.controller && (Math.abs(view.controller.boundingRect.x) > Values.deviceWidth / 2
                                                                                  || view.controller.boundingRect.width > Values.deviceWidth)
                zoomedOut: root.zoomedOut
                zoomedIn: root.zoomedIn
                visible: !zoomedOut && orientation?.isPortraitOrientation
                         ? (scrollbarPressed || (scrollbarTimersRunning && (!didPanVertical || didPanVertical && contentOutsideMargins)))
                           && (contentOutsideMargins || didPanHorizontal || zoomedIn)
                         : ((scrollbarPressed || scrollbarTimersRunning) && zoomedIn)

                view: root
                panLockedVertical: sceneViewGestures.panLockedVertical
                panLockedHorizontal: sceneViewGestures.panLockedHorizontal
            }

            HwcSelection {
                id: hwcSelectionTool
                z: 10 // Show when zoomed out
                anchors.fill: parent
                anchors.leftMargin: toolbar.shown && toolbar.position === ToolbarPositioner.Position.Left ? toolbar.innerWidth : 0
                anchors.rightMargin: toolbar.shown && toolbar.position === ToolbarPositioner.Position.Right ? toolbar.innerWidth : 0
                document: root.document
                currentPage: root.page
                property point initialCursorPos
                property bool done: false

                onVisibleChanged: {
                    if (visible && clipboardNotificationVisible) {
                        clipboardNotificationVisible = false;
                    }
                }

                onClose: {
                    if (visible) {
                        hwcSelectionTool.visible = false;
                    }
                }
                onConversionFinished: {
                    const margin = 50;
                    const scenePos = viewToScene(Qt.point(initialCursorPos.x, initialCursorPos.y + margin));
                    moveCursorWithPen(scenePos);
                    sceneController.pasteText(Clipboard.text, SceneController.KeepStyle, SceneController.MergeWithPreviousAction);
                    hwcSelectionTool.done = true;
                    hwcSelectionTool.close();

                }
                onConversionFailed: {
                    root.exitTextMode();
                    sceneController.undo();
                }

                onCloseAndUndo: {
                    if (visible) {
                        hwcSelectionTool.close();
                        sceneController.undo();
                        root.exitTextMode();
                    }
                }
            }

            Image {
                id: leftPortraitEdgeIndicator
                source: "qrc:/qml/device/portrait-indicator-line.png"
                height: parent.height
                width: 2
                property bool shouldShowIndicator: notePage
                    && gesturing
                    && zoomedOut
                    && tileManager.scale != gestureData.initialScale
                    && root.height > root.width
                visible: shouldShowIndicator
                fillMode: Image.Tile
                function updatePosition() {
                    // Figure out the position to show it, and make sure we're not at a subpixel position.
                    x = Math.round(tileManager.sceneToView(Qt.point(-DeviceScreenInfo.paperSize.width / 2, 0)).x) - width / 2;
                }
            }
            Image {
                id: rightPortraitEdgeIndicator
                source: leftPortraitEdgeIndicator.source
                height: leftPortraitEdgeIndicator.height
                width: leftPortraitEdgeIndicator.width
                visible: leftPortraitEdgeIndicator.visible
                fillMode: leftPortraitEdgeIndicator.fillMode
                function updatePosition() {
                    // Figure out the position to show it, and make sure we're not at a subpixel position.
                    x = Math.round(tileManager.sceneToView(Qt.point(DeviceScreenInfo.paperSize.width / 2, 0)).x) - width / 2;
                }
            }

            // Put each overlay into a corner and align to an edge padded to a multiple of the
            // size of the dither image so that there is no overlap and the tiling lines up where
            // they meet.
            Rectangle {
                id: leftOverlay
                // (top) left side overlay
                property real size: root.leftViewportEdge
                width: size
                height: bottomOverlay.y
                visible: size > 0
                color: "white"
                Image {
                    id: ditherImage
                    anchors.fill: parent
                    fillMode: Image.Tile
                    source: "qrc:/qml/device/light_black_dither.png"
                    horizontalAlignment: Image.AlignLeft
                    verticalAlignment: Image.AlignTop
                }
            }

            Rectangle {
                id: rightOverlay
                // (bottom) right side overlay
                property real size: root.rightViewportEdge
                width: parent.width + (parent.width % ditherImage.implicitHeight) - x
                x: parent.width - size
                y: topOverlay.height
                height: parent.height + (parent.height % ditherImage.implicitHeight) - y
                visible: size > 0
                color: "white"
                Image {
                    fillMode: Image.Tile
                    source: "qrc:/qml/device/light_black_dither.png"
                    anchors.fill: parent
                    horizontalAlignment: Image.AlignRight
                    verticalAlignment: Image.AlignBottom
                }
            }
            Rectangle {
                id: topOverlay
                // top (right) side overlay
                property real size: root.topViewportEdge
                x: leftOverlay.width
                width: parent.width + (parent.width % ditherImage.implicitWidth) - x
                height: size
                visible: size > 0
                color: "white"
                Image {
                    anchors.fill: parent
                    fillMode: Image.Tile
                    source: "qrc:/qml/device/light_black_dither.png"
                    horizontalAlignment: Image.AlignRight
                    verticalAlignment: Image.AlignTop
                }
            }

            Rectangle {
                id: bottomOverlay
                // bottom (left) side overlay
                property real size: root.bottomViewportEdge
                y: parent.height - size
                width: rightOverlay.x
                height: parent.height + (parent.height % ditherImage.implicitHeight) - y
                visible: size > 0
                color: "white"
                Image {
                    fillMode: Image.Tile
                    source: "qrc:/qml/device/light_black_dither.png"
                    anchors.fill: parent
                    horizontalAlignment: Image.AlignLeft
                    verticalAlignment: Image.AlignBottom
                }
            }

            // Draw a border as 4 individual lines.
            Rectangle { // left
                id: leftBorder
                x: root.pageBorderRect.x - width
                y: root.pageBorderRect.y - width

                width: 1
                height: root.pageBorderRect.height + width

                color: Values.colorBlack
                visible: !root.isLoading && !root.notePage && !root.isDefaultFocalPoint
            }
            Rectangle { // right
                x: root.pageBorderRect.x + root.pageBorderRect.width
                y: root.pageBorderRect.y

                width: 1
                height: root.pageBorderRect.height + width

                color: Values.colorBlack
                visible: leftBorder.visible
            }
            Rectangle { // top
                x: root.pageBorderRect.x
                y: root.pageBorderRect.y - height

                width: root.pageBorderRect.width + height
                height: 1

                color: Values.colorBlack
                visible: leftBorder.visible
            }
            Rectangle { // bottom
                x: root.pageBorderRect.x - height
                y: root.pageBorderRect.y + root.pageBorderRect.height

                width: root.pageBorderRect.width + 1
                height: 1

                color: Values.colorBlack
                visible: leftBorder.visible
            }
        }

        Item {
            id: selectionHandlerRoot
            anchors.fill: parent
        }
    }

    //
    // Functions
    //

    function nukeView(view) {
        view.visible = false;
        view.parent = null;
        view.destroy();
    }

    function resetCaches() {
        if (sceneView) {
            nukeView(sceneView);
            sceneView = null;
        }
        if (nextSceneView) {
            nukeView(nextSceneView);
            nextSceneView = null;
        }
        if (previousSceneView) {
            nukeView(previousSceneView);
            previousSceneView = null;
        }
    }

    function close() {
        endItemSelection();
        hwcSelectionTool.close();
        resetCaches();
        pageId = "";
        page = -1;
        requestNoSnapping();
    }

    function goToPage(pageNumber) {
        console.assert(!!document, "goToPage requires a valid document to be called..");
        if (pageNumber < 0 || pageNumber >= document.pageCount) {
            console.warn(sceneViewLog, "bad page, " + pageNumber + ", document has " + document.pageCount + " pages");
            return;
        }
        goToPageId(document.idForPage(pageNumber));
    }

    function goToPageId(pageId) {
        console.assert(!!document, "goToPageId requires a valid document to be called..");

        const pageIndex = document.pageForId(pageId);
        const idNext = document.idForPage(pageIndex + 1);
        const idPrev = document.idForPage(pageIndex - 1);

        console.log(sceneViewLog, "goToPage(" + pageIndex + "), id=" + pageId);

        verticalScrollbar.hide();
        horizontalScrollbar.hide();

        endItemSelection();
        hwcSelectionTool.close();

        // Disabling preloading can help with debugging..
        const enablePreloading = true;
        if (!enablePreloading) {
            console.log(sceneViewLog, " - preloading disabled, recycling main view..");
            if (sceneView) {
                sceneView.visible = false;
                sceneView.destroy();
            }
            sceneView = sceneViewComponent.createObject(sceneViewsRoot, { pageId: pageId, document: document });
            root.page = pageIndex;
            root.pageId = pageId;
            screenDriver.finalizeNewPage();
            updateViewportEdges();
            return;
        }

        let allViews = [sceneView, nextSceneView, previousSceneView].filter(function(view) { return view != undefined; });

        // Figure out which of these we want to keep
        let viewsToKeep = allViews.filter(function(view) { return view.pageId == pageId || view.pageId == idNext || view.pageId == idPrev });
        viewsToKeep.map(function(view) {
            console.log(sceneViewLog, " - keep view: id=" + view.pageId + ", page=" + document.pageForId(view.pageId));
        });

        // nuke the ones we don't need
        root.nextSceneView = null;
        root.previousSceneView = null;
        let viewsToNuke = allViews.filter(function(view) { return !viewsToKeep.includes(view); });
        viewsToNuke.map(function(view) {
            console.log(sceneViewLog, " - nuke view: id=" + view.pageId + ", page=" + document.pageForId(view.pageId));
            nukeView(view);
        });
        viewsToNuke = undefined;

        // Set up the views.
        root.sceneView = viewsToKeep.find(function(view) { return view.pageId == pageId; }) || null;
        if (!root.sceneView) {
            console.log(sceneViewLog, " - new view (main): id=" + pageId + ", page=" + pageIndex);
            root.sceneView = sceneViewComponent.createObject(sceneViewsRoot, { pageId: pageId, document: document });
        }
        root.sceneView.visible = true;

        function resetViewport(view) {
            if (view.status == SceneView.Active) {
                view.setFocalPointToContent();
            }
        }

        if (idNext) {
            root.nextSceneView = viewsToKeep.find(function(view) { return view.pageId == idNext; }) || null;
            if (!root.nextSceneView) {
                console.log(sceneViewLog, " - new view (next): id=" + idNext + ", page=" + (pageIndex + 1));
                root.nextSceneView = sceneViewComponent.createObject(sceneViewsRoot, { pageId: idNext, document: document });
            }
            root.nextSceneView.visible = false;
            resetViewport(root.nextSceneView);
        }

        if (idPrev) {
            root.previousSceneView = viewsToKeep.find(function(view) { return view.pageId == idPrev; }) || null;
            if (!root.previousSceneView) {
                console.log(sceneViewLog, " - new view (prev): id=" + idPrev + ", page=" + (pageIndex - 1));
                root.previousSceneView = sceneViewComponent.createObject(sceneViewsRoot, { pageId: idPrev, document: document });
            }
            root.previousSceneView.visible = false;
            resetViewport(root.previousSceneView);
        }

        root.pageId = pageId;
        root.page = pageIndex;

        // If we have a valid cache, show scrollbars as we flip pages.
        // Otherwise it will come later as a result of the initial tile set
        // landing.
        if (root.sceneView && !root.sceneView.awaitingInitialTileSet) {
            maybeShowInitialScrollbar();
        }

        screenDriver.finalizeNewPage();
        updateViewportEdges();
    }

    function maybeShowInitialScrollbar() {
        if (root.status !== SceneView.Active) {
            return;
        }

        const y = root.tileManager.viewToScene(Qt.point(0, 0)).y;
        let initShowVerticalScrollbar = y > 0 || root.exteriorBoundary.height > Values.deviceHeight;
        if (!notePage) {
            // In a i.e PDF we only want to show the vertical scrollbar
            // if we have content outside the view.
            const boundingRect = root.controller.boundingRect;
            const primaryContent = root.controller.primaryContentRect;
            initShowVerticalScrollbar = boundingRect.y + boundingRect.height > primaryContent.height;
        }

        const initShowHorizontalScrollbar = horizontalScrollbar.contentOutsideMargins;
        if (initShowVerticalScrollbar || initShowHorizontalScrollbar) {
            updateScrollbars(initShowVerticalScrollbar, initShowHorizontalScrollbar);
        }
        // If called updateScrollbars() will set scrollPositionChanged to true so make sure we clear
        // it after or the initial scroll position will be saved on leaving the page despite not
        // being scrolled by the user, and due to corrections for orientation and display size the
        // initial position may be different to the existing saved position.
        root.scrollPositionChanged = false;
    }

    // Ends the selection and nukes the selection handler.
    function endItemSelection() {
        strokeHandler.setSelectionActive(false);
        endGlyphSelection();

        if (!root.selectionHandler) {
            controller?.cancelPendingEdit();
            return;
        }
        console.log(sceneViewLog, "ending item selection");
        controller.applyPendingEdit(controller.currentLayer);
        root.selectionHandler.close();
        root.selectionHandler.destroy();
        root.selectionHandler = null;
    }

    function endGlyphSelection() {
        glyphSelectionRoot.active = false;
    }

    function updateScrollbars(showVertical, showHorizontal) {
        const availableHeight = height - scrollbarMarginAlongLength * 2;
        const availableWidth = width - scrollbarMarginAlongLength * 2;

        // the available scrollable area
        const boundary = root.exteriorBoundary;

        // Find the part of the scene that is currently visible on screen
        const sceneTopLeft = root.tileManager.viewToScene(Qt.point(0, 0));
        const sceneBottomRight = root.tileManager.viewToScene(Qt.point(width, height));

        // Find the y-range for visible part on screen and map those into ny1
        // and ny2. Those values will be between 0 and 1 indicating where
        // along the y-axis we are. When we have those, we can convert them
        // into scrollbar geometry.
        const ny1 = Math.max(0, (sceneTopLeft.y - boundary.y) / boundary.height);
        const ny2 = Math.min(1, (sceneBottomRight.y - boundary.y) / boundary.height);

        const verticalPos = scrollbarMarginAlongLength + ny1 * availableHeight;
        const verticalSize = Math.max(Values.scrollBarMinimumHeight, (ny2 - ny1) * availableHeight);
        verticalScrollbar.update(verticalPos, verticalSize);
        if (showVertical === undefined || showVertical) {
            verticalScrollbar.show();
        }

        // Repeat for x
        const nx1 = Math.max(0, (sceneTopLeft.x - boundary.x) / boundary.width);
        const nx2 = Math.min(1, (sceneBottomRight.x - boundary.x) / boundary.width);
        const horizontalPos = scrollbarMarginAlongLength + nx1 * availableWidth;
        const horizontalSize = Math.max(Values.scrollBarMinimumWidth, (nx2 - nx1) * availableWidth);
        horizontalScrollbar.update(horizontalPos, horizontalSize);
        if (showHorizontal === undefined || showHorizontal) {
            horizontalScrollbar.show();
        }

        root.scrollPositionChanged = true;
    }

    /*!
        Performs a single-step zoom operation. If \p delta is greater than 1,
        it zooms in; otherwise, it zooms out.

        If we're zooming back towards 1:1, we always perform the zoom to 1:1
        and the function returns true to indicate that it locked the viewport
        at 1:1.

        For any other operation, the zooms in the given direction and returns
        false, indicating no locking has taken place.
     */
    function singleStepZoom(delta, center) {
        verticalScrollbar.hide();
        horizontalScrollbar.hide();

        const view = root.sceneView
        const tm = root.tileManager;
        let locked = false;

        if (delta > 1) {
            // zooming in
            if (tm.scale < root.defaultScale) {
                // Zoom in from <100% -> 100%.
                const notNoteOrSceneTopVisible = !root.notePage || tm.viewToScene(Qt.point(0, 0)).y <= 0;
                view.setFocalPoint(notNoteOrSceneTopVisible ? root.defaultCenter : tm.center, root.defaultScale);
                locked = true;
            } else {
                // normal zoom in, do this on the target point which is a
                // relative scale in view coordinates.
                let scale = 2;
                if (tm.scale * scale > maximumScaleFactor) {
                    scale = maximumScaleFactor / tm.scale;
                }
                tm.zoomOnPoint(center, scale);
            }
        } else {
            // zooming out
            if (tm.scale > root.defaultScale) {
                // zooming out from >100% -> 100%.
                const notNoteOrCloseToTop = !root.notePage || tm.viewToScene(Qt.point(0, root.height)).y < root.height
                view.setFocalPoint(notNoteOrCloseToTop ? root.defaultCenter : Qt.point(0, tm.center.y), root.defaultScale);
                locked = true;
            } else {
                tm.setFocalPoint(tm.center, Math.max(minimumScaleFactor, tm.scale * 0.5));
            }
        }

        return locked;
    }

    function zoom(delta)
    {
        verticalScrollbar.hide();
        horizontalScrollbar.hide();

        const tm = root.tileManager;
        let scale = tm.scale + delta;
        let locked = false;

        if ((tm.scale < root.defaultScale && scale > scaleSnapLow)
                || (tm.scale > root.defaultScale && scale < scaleSnapHigh)) {
            locked = true;
            scale = root.defaultScale;
        } else {
            scale = Math.max(minimumScaleFactor, Math.min(scale, maximumScaleFactor));
        }
        tm.setFocalPoint(tm.center, scale);

        updateScrollbars();
        return locked;
    }

    function scrollDown() {
        const nearestAlignment = function() {
            const documentHeight = root.controller.primaryContentRect.height;
            const viewHeight = height / root.tileManager.scale;
            const topCenter = viewHeight / 2;
            const bottomCenter = documentHeight - topCenter;
            if (viewHeight > documentHeight) {
                return documentHeight / 2;
            } else if (root.tileManager.center.y < topCenter - 1) {
                return topCenter;
            } else {
                return bottomCenter;
            }
        }();
        const distanceToAligned = (nearestAlignment - root.tileManager.center.y) * root.tileManager.scale;
        root.tileManager.moveViewBy(Qt.point(0, distanceToAligned > 1 && distanceToAligned < verticalJumpDistance ? -distanceToAligned : -verticalJumpDistance));
        updateScrollbars();
    }

    function scrollUp() {
        const nearestAlignment = function() {
            const documentHeight = root.controller.primaryContentRect.height;
            const viewHeight = height / root.tileManager.scale;
            const topCenter = viewHeight / 2;
            const bottomCenter = documentHeight - topCenter;
            if (viewHeight > documentHeight) {
                return documentHeight / 2;
            } else if (root.tileManager.center.y > bottomCenter + 1) {
                return bottomCenter;
            } else {
                return topCenter;
            }
        }();
        const distanceToAligned = (nearestAlignment - root.tileManager.center.y) * root.tileManager.scale;
        let jumpDistance = verticalJumpDistance;
        if (distanceToAligned < -1 && -distanceToAligned < verticalJumpDistance) {
            const currentTopPosition = root.tileManager.viewToScene(Qt.point(0, 0)).y;
            if (root.notePage && -distanceToAligned > currentTopPosition && currentTopPosition >= 0) {
                // Snap to the top of the page and ignore the gray area.
                // Only for notepages.
                jumpDistance = currentTopPosition;
            } else {
                jumpDistance = -distanceToAligned;
            }
        }

        root.tileManager.moveViewBy(Qt.point(0, jumpDistance));
        updateScrollbars();
    }

    /**
        Calculates auto-scroll speed based on the dragPosition relative to the availableSceneRect.
        When dragPosition is within a threshold (8% of the top or bottom), scrolling starts at minScrollSpeed and increases to maxScrollSpeed as the dragPosition approaches the edge.
        Using availableSceneRect makes sure that we account for the virtualKeyboard or toolbar being present.
    **/
    function calculateAutoScrollSpeed(dragPosition) {
        const threshold = root.height * 0.08;
        const scrollAreaBottom = root.availableSceneRect.bottom;
        const scrollAreaTop = root.availableSceneRect.top;
        const minScrollSpeed = 20;
        const maxScrollSpeed = 80;
        if (dragPosition < (scrollAreaTop + threshold)) {
            return  Math.min(maxScrollSpeed, minScrollSpeed + (maxScrollSpeed - minScrollSpeed) * (1 - (dragPosition - scrollAreaTop) / threshold));
        } else if (dragPosition > (scrollAreaBottom - threshold)) {
            return -Math.min(maxScrollSpeed, minScrollSpeed + (maxScrollSpeed - minScrollSpeed) * (1 + (dragPosition - scrollAreaBottom) / threshold));
        } else {
            return 0;
        }
    }

    function beginDragAndZoom() {
        console.assert(root.gestureData == undefined, "inconsistent use of beginDragAndZoom / endDragAndZoom");
        const tm = root.tileManager;

        function xyDomain(pos, defaultPos) {
            return Math.abs(pos - defaultPos) < 1.0
                ? undefined
                : (pos < defaultPos ? -1 : 1);
        }

        function zoomDomain(zoom, defaultZoom) {
            return Math.abs((zoom - defaultZoom) / defaultZoom) < 0.01
                ? undefined
                : zoom < defaultZoom ? -1 : 1;
        }

        root.gestureData = {
            // These 'domain' values are used as std::optional values. If
            // we're starting at the origin, they are undefined. Then they
            // get set during updateDragAndZoom() indicate "on which side"
            // we're at.
            //
            // We use the optional concept to help us distinguish unset from
            // set as comparing a c++ float with a QML float doesn't always
            // give accurate equality.
            scaleDomain: zoomDomain(tm.scale, root.defaultScale),
            horizontalDomain: xyDomain(tm.center.x, root.defaultCenter.x),
            verticalDomain: xyDomain(tm.center.y, root.defaultCenter.y),
            scaleIsLocked: false,
            horizontalPanIsLocked: false,
            verticalPanIsLocked: false,
            firstUpdate: true
        };
    }

    function endDragAndZoom() {
        console.assert(root.gestureData != undefined, "inconsistent use of beginDragAndZoom / endDragAndZoom");

        // Cancel all running tile jobs as those would just cause
        // additional flicker at this point.
        root.tileManager.resetPendingJobs();

        // Then request the single tile.
        root.tileManager.requestMissingTiles();

        root.gestureData = undefined;
        root.gestureIsLocked = false;
    }

    function updateDragAndZoom(distance, center, scale) {
        console.assert(root.gestureData != undefined, "inconsistent use of beginDragAndZoom / updateDragAndZoom");

        const d = root.gestureData;
        const snapCenter = root.defaultCenter;
        let targetScale = tileManager.scale * scale;

        // If we're starting at the initial viewpoint, update the initial
        // state with the first update, so we know which sides we're on when
        // checking against locking / snapping later in the gesture.
        if (d.scaleDomain === undefined && scale !== 1.0) {
            d.scaleDomain = scale < 1.0 ? -1 : 1;
        }
        if (d.horizontalDomain === undefined && distance.x !== 0) {
            d.horizontalDomain = distance.x < 0 ? 1 : -1;
        }
        if (d.verticalDomain === undefined && distance.y !== 0) {
            d.verticalDomain = distance.y < 0 ? 1 : -1;
        }

        let lockedAt1x = false;

        if (targetScale < minimumScaleFactor) {
            // min zoom is 0.5x
            scale = minimumScaleFactor / tileManager.scale;
        } else if (targetScale > maximumScaleFactor) {
            // max zoom is 5x
            scale = maximumScaleFactor / tileManager.scale;
        } else if (!snapEnabled) {
            // Don't snap.
        } else if (d.scaleDomain !== undefined) {
            if (d.scaleDomain > 0 && targetScale < scaleSnapHigh) {
                // snap at 100% when zooming back out
                lockedAt1x = true;
            } else if (d.scaleDomain < 0 && targetScale > scaleSnapLow) {
                // snap at 100% when zooming back in
                lockedAt1x = true;
            }
        }

        if (lockedAt1x) {
            d.scaleIsLocked = true;
            sceneView.setFocalPoint(Qt.point(snapCenter.x, tileManager.center.y - distance.y), root.defaultScale);
        } else {
            tileManager.zoomOnPoint(center, scale);
            tileManager.moveViewBy(distance);
        }

        if (d.scaleIsLocked && (tileManager.scale > scaleSnapHigh || tileManager.scale < scaleSnapLow)) {
            // if we were scale locked but came back in/out, reset the state.
            d.scaleIsLocked = false;
        }

        // Apply snapping to the (top) center when panning, but only do this
        // at zoom 1:1. Doing it elsewhere makes it conflict with pinch/zoom
        // and the scale locking so it "feels" odd.
        if (snapEnabled && (d.scaleDomain === undefined || tileManager.scale === root.defaultScale)) {
            if (d.horizontalDomain
                && ((d.horizontalDomain > 0 && tileManager.center.x < snapCenter.x)
                    || (d.horizontalDomain < 0 && tileManager.center.x > snapCenter.x))) {
                d.horizontalPanIsLocked = true;
            }

            const canLockVertically = !root.notePage;
            if (canLockVertically && d.verticalDomain && ((d.verticalDomain > 0 && tileManager.center.y < snapCenter.y)
                    || (d.verticalDomain < 0 && tileManager.center.y > snapCenter.y))) {
                d.verticalPanIsLocked = true;
            }

            if (d.horizontalPanIsLocked && d.verticalPanIsLocked) {
                // snap to center
                sceneView.setFocalPoint(snapCenter, tileManager.scale);
            } else if (d.horizontalPanIsLocked) {
                // snap to horizontal center
                sceneView.setFocalPoint(Qt.point(snapCenter.x, tileManager.center.y), tileManager.scale);
            } else if (d.verticalPanIsLocked) {
                // snap to horizontal center
                sceneView.setFocalPoint(Qt.point(tileManager.center.x, snapCenter.y), tileManager.scale);
            }

            const unlockThreshold = 10;
            if (d.horizontalPanIsLocked) {
                console.assert(d.horizontalDomain);
                // then check if we should unlock again...
                if (d.horizontalDomain > 0 && distance.x < -unlockThreshold) {
                    d.horizontalPanIsLocked = false;
                } else if (d.horizontalDomain < 0 && distance.x > unlockThreshold) {
                    d.horizontalPanIsLocked = false;
                }
            }
            if (d.verticalPanIsLocked) {
                console.assert(d.verticalDomain);
                // then check if we should unlock again...
                if (d.verticalDomain > 0 && distance.y < -unlockThreshold) {
                    d.verticalPanIsLocked = false;
                } else if (d.verticalDomain < 0 && distance.y > unlockThreshold) {
                    d.verticalPanIsLocked = false;
                }
            }
        } else {
            d.horizontalPanIsLocked = false;
            d.verticalPanIsLocked = false;
        }

        if (d.firstUpdate) {
            d.firstUpdate = false;
        } else {
            updateGestureIsLocked();
        }

        updateScrollbars();
        leftPortraitEdgeIndicator.updatePosition();
        rightPortraitEdgeIndicator.updatePosition();
    }

    // Because the 'gestureIsLocked' property is based on the state in a JS
    // object, it doesn't receive notifications in bindings, so we have to
    // update it explicitly.
    function updateGestureIsLocked() {
        root.gestureIsLocked = gestureData !== undefined &&
            (gestureData.scaleIsLocked
             || gestureData.horizontalPanIsLocked
             || gestureData.verticalPanIsLocked);
    }

    function updateViewportEdges() {
        if (!tileManager) {
            return;
        }
        const bounds = tileManager.sceneToView(sceneView.sceneExteriorBoundary);
        leftViewportEdge = Math.round(bounds.left);
        rightViewportEdge = Math.round(root.width - bounds.right);
        topViewportEdge = Math.round(bounds.top);
        bottomViewportEdge = !root.notePage ? Math.round(root.height - bounds.bottom) : 0;
    }

    function updateViewFromSearchResult(resultLocation) {
        const margin = root.notePage ? 200 : 0;
        root.tileManager.scrollToMakeSceneRectangleVisible(resultLocation, margin, margin, margin, margin);
    }

    function resetViewport() {
        const wasDefaultFocalPoint = root.isDefaultFocalPoint;

        root.sceneView.setFocalPoint(root.defaultCenter, root.defaultScale);

        if (root.nextSceneView && root.nextSceneView.status === SceneView.Active) {
            root.nextSceneView.setFocalPoint(root.nextSceneView.defaultCenter, root.nextSceneView.defaultScale);
        }
        if (root.previousSceneView && root.previousSceneView.status === SceneView.Active) {
            root.previousSceneView.setFocalPoint(root.previousSceneView.defaultCenter, root.previousSceneView.defaultScale);
        }

        return !wasDefaultFocalPoint;
    }

    //
    // Scene / view mapping functions, currently used in conjunction with
    // SceneSelectionHandler
    //
    function viewToScene(pointOrRect) {
        return tileManager ? tileManager.viewToScene(pointOrRect) : pointOrRect;
    }
    function sceneToView(pointOrRect) {
        return tileManager ? tileManager.sceneToView(pointOrRect) : pointOrRect;
    }

    function moveCursorWithPen(position) {
        if (!root.textMode) {
            enterTextMode(true, position);
        }
        controller.setCursorPosition(position, SceneController.MoveAnchor, SceneController.OverscrollAlwaysAllowed);
    }

    function requestOpenTextSelectionMenu() {
        textSelectionMenu.openLater();
    }

    function notifyDidQuickBrowse() {
        screenDriver.notifyDidQuickBrowse();
    }
}
