import QtQuick

import com.remarkable
import common
import device.global
import device.view.experimental

import xofm.libs.gestures
import xofm.libs.devicescreen

TouchArea {
    id: touchArea
    anchors.fill: parent

    /*
        Input properties
    */
    property bool panAndZoomOnly

    /*
        Output properties
    */
    readonly property alias touchMultipleClickTimeout: touchMultipleClickTimeout

    readonly property bool panLockedHorizontal: dragFilter.mode == TouchAreaDragFilter.Mode.LockedToX
    readonly property bool panLockedVertical: dragFilter.mode == TouchAreaDragFilter.Mode.LockedToY
    readonly property bool cursorDragging: cursorDragFilter.dragging

    /*
        Internal properties
    */
    readonly property int tapPalmThreshold: 20 * 20
    readonly property real pixelsPerCm: DeviceScreenInfo.pixelsPerCm
    readonly property real edgeSize: pixelsPerCm
    readonly property bool userIsActive: touchArea.candidateCount > 0 || touchArea.activeFilter
    property var view

    readonly property bool gesturesBlocked: PenClosenessMonitor.penWasClose || panAndZoomOnly

    signal beginDragAndZoom()
    signal endDragAndZoom()
    signal touchClicked
    signal openDocumentDrawer
    signal cursorDragPositionChanged(point position)

    Connections {
        target: PenClosenessMonitor
        function onPenWasCloseChanged() {
            if (PenClosenessMonitor.penWasClose) {
                touchArea.cancelSequence();
            }
        }
    }

    /*
        Timers
    */
    Timer {
        id: touchMultipleClickTimeout
        property int touchCount: 0
        property point lastTouch
        property bool cursorTouched: false
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            checkForMultipleTaps();
            reset();
        }

        function reset() {
            touchCount = 0;
            lastTouch = Qt.point(0, 0);
            cursorTouched = false;
        }

        function checkForMultipleTaps() {
            if (!textMode) { return; }

            // Check for multiple taps.
            if (touchCount === 1 && cursorTouched) {
                // Show the text selection menu if we touched the cursor
                textSelectionMenu.openNow();
            } else if (touchCount === 2) {
                // Select word on double tap
                controller.selectText(SceneParticipant.SelectToken);
                textSelectionMenu.openWhenHasSelection();
            } else if (touchCount === 3) {
                // Select paragraph on tripple tap
                controller.selectText(SceneParticipant.SelectBlock);
                textSelectionMenu.openWhenHasSelection();
            } else if (touchCount === 4) {
                // Select all text on quadruple tap
                controller.selectText(SceneParticipant.SelectAll);
                textSelectionMenu.openWhenHasSelection();
            } else if (touchCount > 4) {
                reset();
            }
        }
    }

    /*
        Functions
    */
    function squishTriggerFastScroll() {
        fastScroll.triggered();
    }

    // With Qt 6 / OSX / Desktop, we working touch areas and thus gesture
    // recognition. This is great, but the undo / redo gestures are a bit too
    // easy to trigger, so we simply disable these for now.
    property bool enableUndoRedoGestures: runningOnDevice

    // Undo/Redo specific pen closeness monitor with shorter interval
    // to allow undo/redo gestures sooner after pen usage than other gestures,
    // to make them a bit more responsive in use.
    PenClosenessMonitorImpl {
        id: undoRedoPenMonitor
        interval: 200
    }

    /*
        Items
    */
    SceneLinkHandler {
        id: linkHandler

        onGoToPage: (index) => {
            touchClick.linkedPage = index;
            inversionOverlay.invert(touchClick.linkRect)
        }
        onToggleCheckbox: (index) => {
            controller.toggleCheckboxByIndex(index);
        }
    }

    /*
        Touch filters
    */
    TouchAreaCursorDragFilter {
        id: cursorDragFilter
        objectName: "cursor-drag"
        palmAreaThreshold: touchArea.tapPalmThreshold
        enabled: !PenClosenessMonitor.penWasClose && !touchArea.panAndZoomOnly && textMode && controller
        dragThreshold: 0.2 * touchArea.pixelsPerCm
        verticalThreshold: 0.8 * touchArea.pixelsPerCm // 0.8 cm, enough to peak over line height
        cursorBounds: {
            if (!tileManager || !controller) {
                return Qt.rect(0, 0, 0, 0);
            }
            const cursorPos = tileManager.sceneToView(controller.textCursorPosition);
            // Convert cursor height from scene to view coordinates to account for zoom
            const cursorHeightView = controller.textLineHeight * tileManager.scale;
            const grabWidth = touchArea.pixelsPerCm; // 1 cm
            const grabHeight = Math.max(touchArea.pixelsPerCm, cursorHeightView);
            const grabOffsetY = grabHeight / 2;
            return Qt.rect(cursorPos.x - grabWidth / 2,
                           cursorPos.y - cursorHeightView - grabOffsetY,
                           grabWidth,
                           grabHeight + cursorHeightView);
        }

        onDragStarted: (pos) => {
            textSelectionMenu.close();
        }

        onDragUpdated: (pos) => {
            if (!tileManager) { return; }
            const scenePos = tileManager.viewToScene(pos);
            controller.setCursorPosition(scenePos, SceneController.MoveAnchor, SceneController.OverscrollAllowed);
            touchArea.cursorDragPositionChanged(pos);
        }

        onDragFinished: (pos) => {
            if (!tileManager) { return; }
            const scenePos = tileManager.viewToScene(pos);
            controller.setCursorPosition(scenePos, SceneController.MoveAnchor, SceneController.OverscrollAllowed);
        }
    }

    TouchAreaClickFilter {
        id: twoFingerTapFilter
        palmAreaThreshold: touchArea.tapPalmThreshold
        enabled: !undoRedoPenMonitor.penWasClose && !touchArea.panAndZoomOnly && undoAvailable && enableUndoRedoGestures
        onClick: controller.undo()
        fingers: 2
    }

    TouchAreaClickFilter {
        id: threeFingerTapFilter
        palmAreaThreshold: touchArea.tapPalmThreshold
        enabled: !undoRedoPenMonitor.penWasClose && !touchArea.panAndZoomOnly && redoAvailable && enableUndoRedoGestures
        onClick: controller.redo()
        fingers: 3
    }

    TouchAreaClickFilter {
        id: ghostbusterFilter
        objectName: "ghost-buster"
        enabled: !PenClosenessMonitor.penWasClose && Experimental.gestures.enabled
        fingers: 5
        onClick: {
            ghostBuster.forceClearNow("5-finger gesture");
        }
    }

    TouchAreaClickFilter {
        id: touchClick
        objectName: "click-1"
        palmAreaThreshold: touchArea.tapPalmThreshold

        // We allow all movement, but need to prevent clicks from absorbing focus
        // while in a search state
        enabled: !touchArea.gesturesBlocked && view.clickGestureEnabled

        readonly property int textBoundsMargin: 50
        property int linkedPage: -1
        property rect linkRect
        property bool linkPressed

        function reset() {
            linkedPage = -1;
            linkRect = Qt.rect(0, 0, 0, 0);
            linkPressed = false;
        }

        function tapOutsideSelection(pos) {
            if (!controller) { return false; }
            if (view?.selectionHandler) {
                const rect = view.selectionHandler.viewSelectionRect;
                const right = rect.x + rect.width;
                const bottom = rect.y + rect.height;
                return pos.x < rect.x || pos.x > right || pos.y < rect.y || pos.y > bottom;
            }
            return false;
        }

        function clearItemSelection() {
            if (!controller) { return false; }
            if (view?.selectionHandler) {
                // selection visible in UI, so clear it there
                view.endItemSelection();
                return true;
            }
            return false;
        }

        onPress: (pos) => {
            if (!tileManager) { return false; }
            const link = controller.linkAt(tileManager.viewToScene(pos));
            if (link.valid) {
                linkRect = tileManager.sceneToView(link.rect);
                linkPressed = true;
                linkHandler.activate(link);
            }
        }

        onClick: (pos) => {
            toolbar.closeFoldout();
            touchClicked();

            touchMultipleClickTimeout.touchCount++;

            // Clear any existing selection if tapping outside the selection area
            if (tapOutsideSelection(pos)) {
                if (clearItemSelection()) {
                    reset();
                    return;
                }
            }

            // Try to select an image at the tap point, unless it's a link
            if (!linkPressed && controller && tileManager) {
                const scenePos = tileManager.viewToScene(pos);
                if (controller.selectImageAtPoint(scenePos, controller.currentLayer)) {
                    reset();
                    return;
                }
            }

            if (touchMultipleClickTimeout.running) {
                // TODO: we could contemplate moving the timer and all this into TouchAreaClickFilter as a 'taps'
                // property. So e.g. { fingers: 2; taps: 2 } would require tapping two fingers twice to trigger 'click'.
                // But that's a bit more work than just adapting this, and there's a lot more going on,
                // so let's not be too fancy now.
                let deltaX = Math.abs(touchMultipleClickTimeout.lastTouch.x - pos.x);
                let deltaY = Math.abs(touchMultipleClickTimeout.lastTouch.y - pos.y);
                const distThreshold = 0.6 * touchArea.pixelsPerCm
                if (deltaX > distThreshold || deltaY > distThreshold) {
                    touchMultipleClickTimeout.reset();
                    touchMultipleClickTimeout.stop();
                    return;
                }

                touchMultipleClickTimeout.lastTouch = pos;

                if (!textMode) {
                    // Double click detected - entering text mode.
                    if (tileManager && tapInsideTextBounds(true)) {
                        const scenePos = tileManager.viewToScene(position);
                        enterTextMode(true, scenePos);
                        touchMultipleClickTimeout.reset();
                        Qt.inputMethod.show();
                    }
                }
            } else if (linkedPage === view.page) {
                // Currently not supporting links to other place on same page.
                // So just clear the link in this case.
                inversionOverlay.invert(linkRect);
            } else if (linkedPage >= 0) {
                view.displayLinkNotification(linkedPage, view.page);
                view.openPage(linkedPage, DocumentView.ScrollPosition.Save);
            } else if (textMode && !linkPressed) {
                // If a link was pressed we prevent placing the cursor.
                // It's mostly related in interacting with a checkbox, where we
                // don't want the cursor to move after a checkbox toggle.
                touchedOrPlacedCursor();
            }

            reset();
            touchMultipleClickTimeout.restart();
            touchMultipleClickTimeout.lastTouch = pos;
        }

        onCancel: {
            if (linkedPage >= 0) {
                inversionOverlay.invert(linkRect);
                reset();
            }
            linkPressed = false;
        }

        function placeCursor() {
            if (!tileManager) { return false; }
            textSelectionMenu.close();
            const scenePos = tileManager.viewToScene(position);
            controller.setCursorPosition(scenePos, SceneController.MoveAnchor, SceneController.OverscrollAllowed);
        }

        function touchedOrPlacedCursor() {
            if (!tileManager) { return false; }
            const cursorPos = tileManager.sceneToView(controller.textCursorPosition);
            // Check if tapped inside the cursor bounds.
            if (tapInsideCursorBounds()) {
                touchMultipleClickTimeout.cursorTouched = true;
            } else {
                if (tapInsideTextBounds(false)) {
                    placeCursor();
                } else {
                    // We want to hide the textSelectionMenu every time we
                    // touch outside the text bounds.
                    controller.clearSelectedText();
                    textSelectionMenu.close();
                }
            }
        }

        function tapInsideCursorBounds() {
            if (!tileManager || !controller) { return false; }
            const cursorPos = tileManager.sceneToView(controller.textCursorPosition);
            // Convert cursor height from scene to view coordinates to account for zoom
            const cursorHeight = controller.textLineHeight * tileManager.scale;
            const cursorWidth = 0.7 * touchArea.pixelsPerCm;
            const cursorBounds = Qt.rect(cursorPos.x - (cursorWidth / 2),
                                         cursorPos.y - cursorHeight,
                                         cursorWidth,
                                         cursorHeight + 10);
            return MathUtils.pointInRect(position, cursorBounds);
        }

        function tapInsideTextBounds(useTextBounds) {
            if (!tileManager) { return false; }
            const scenePos = tileManager.viewToScene(position);
            let textBounds = controller.rootDocumentBoundingRect;
            textBounds = Qt.rect(textBounds.x - textBoundsMargin, textBounds.y, textBounds.width + 2*textBoundsMargin, useTextBounds ? textBounds.height : scenePos.y);
            return MathUtils.pointInRect(scenePos, textBounds);
        }
    }

    TouchAreaSwipeFilter {
        id: swipeDownForRecent
        objectName: "recent";
        /*
            This one will fight dragFilter over the 2-finger gesture, but
            this one will be matched first due to its order, and it is
            also set up with a shorter distance, so it should consistenly
            match before the drag.
         */
        distance: 0.3 * touchArea.pixelsPerCm
        direction: Qt.point(0, 1)
        area: Qt.rect(0, 0, touchArea.width, touchArea.edgeSize)
        fingers: 2
        enabled: !touchArea.gesturesBlocked
        onTriggered: touchArea.openDocumentDrawer()
    }

    TouchAreaDragFilter {
        id: dragFilter
        objectName: "docview-scroll"
        timeout: 2000
        area: Qt.rect(0, 0, touchArea.width, touchArea.height)
        panMinVelocity: 2.0 * touchArea.pixelsPerCm
        scaleMinVelocity: 2.0 * touchArea.pixelsPerCm
        // Not using gesturesBlocked here: to not include pan/zoom only mode
        enabled: !PenClosenessMonitor.penWasClose

        onActiveChanged: {
            // current default behavior
           if (active) {
                touchArea.beginDragAndZoom();
            } else {
                touchArea.endDragAndZoom();
            }
            return;
        }

        onValuesChanged: {
            if (active) {
                updateDragAndZoom(distanceDelta, center, scaleDelta);
            }
        }
    }

    SwipeFilterFastScroll {
        id: fastScroll
        touchSize: Qt.size(touchArea.width, touchArea.height)
        onActivated: view.openFastScroll()
    }

    // We have two modes here... Short drags require a release, to rule out accidentals,
    // e.g. brushing a knuckle or finger across the page when writing, because flicking
    // pages due to that would be very annoying.
    //
    // Long drags, though, don't require a release, as we can clearly disambiguate the intention.
    property real _shortPageSwipe: 0.6 * touchArea.pixelsPerCm
    property real _longPageSwipe: 3.0 * touchArea.pixelsPerCm

    TouchAreaSwipeFilter {
        id: nextPageGesture
        objectName: "next-page"
        direction: Qt.point(-1, 0)
        area: Qt.rect(0, 0, touchArea.width, touchArea.height)
        enabled: !touchArea.gesturesBlocked

        property bool longMode: touchArea.candidateCount == 1 && swipedLength >= touchArea._longPageSwipe && !textMode
        releaseRequired: !longMode
        distance: longMode ? touchArea._longPageSwipe : touchArea._shortPageSwipe

        onActiveChanged: {
            if (active) {
                view.moveForward();
            }
        }
    }

    TouchAreaSwipeFilter {
        id: prevPageGesture
        objectName: "prev-page"
        direction: Qt.point(1, 0)
        area: Qt.rect(0, 0, touchArea.width, touchArea.height)
        enabled: !touchArea.gesturesBlocked

        property bool longMode: touchArea.candidateCount == 1 && swipedLength >= touchArea._longPageSwipe && !textMode
        releaseRequired: !longMode
        distance: longMode ? touchArea._longPageSwipe : touchArea._shortPageSwipe

        onActiveChanged: {
            if (active) {
                view.moveBackward();
            }
        }
    }

    TouchAreaSwipeFilter {
        objectName: "close-scene-view"
        direction: Qt.point(0, 1)
        area: Qt.rect(0, 0, touchArea.width - Values.quickSettingsGestureWidth, touchArea.edgeSize)
        enabled: !touchArea.gesturesBlocked
        onTriggered: view.closeGesture();
    }

    TouchAreaSwipeFilter {
        objectName: "open-quick-settings-scene-view"
        direction: Qt.point(0, 1)
        area: Qt.rect(touchArea.width - Values.quickSettingsGestureWidth, 0, Values.quickSettingsGestureWidth, touchArea.edgeSize)
        enabled: !touchArea.gesturesBlocked
        onTriggered: windowNavigator.open("settings/window/quicksettings")
    }

    TouchAreaSwipeFilter {
        id: jumpDownGesture
        objectName: "jump-down"
        direction: Qt.point(0, -1)
        area: Qt.rect(0, 0, touchArea.width, touchArea.height)
        releaseRequired: true
        enabled: !touchArea.gesturesBlocked
        onActiveChanged: {
            if (active) {
                view.scrollDown();
            }
        }
    }

    TouchAreaSwipeFilter {
        id: jumpUpGesture
        objectName: "jump-up"
        direction: Qt.point(0, 1)
        area: Qt.rect(0, 0, touchArea.width, touchArea.height)
        releaseRequired: true
        enabled: !touchArea.gesturesBlocked
        onActiveChanged: {
            if (active) {
                view.scrollUp();
            }
        }
    }
}
