import QtQuick

import com.remarkable
import xofm.libs.peninput

/*!
 *  TextDragManager collects three components which operate together to let the user drag text with the pen.
 *  (See below for the reasons we use this approach)
 *
 *  The TextDragHotspot components cover the currently selected text and catch mouse/pen events that happen
 *  in the text selection and forward them to TextDragHandler.
 *  The TextDragHandler maps event positions to character indices within the text document and determines if and
 *  where text can be dragged.
 *  The TextInsertCaret is a display only component that shows the insert position.
 *
 *  Reasons for the current approach
 *  Originally, TextDragHandler was the sole component and handled both events and drawing directly. This works
 *  on the simulator but not on the real hardware due to the way that pen events are routed for performance reasons
 *  (see the peninput library for more details).
 *  So, TextDragManager is a containing Item that passes pen events through to PenInput, while the TextDragHotspot
 *  children block pen events over the selected text areas and forward pen events to the TextDragHandler using the
 *  coordinate space of TextDragHandler (their common parent).
 *  The TextInsertCaret component exists to draw the caret but also provides a way to hook the background processing
 *  that we do in scene into the QtQuick polish() step of rendering and minimise updates.
 */
Item {
    id: dragManager

    required property PenInput penInput
    property alias sceneView: handler.sceneView
    property alias anchorPosition: handler.anchorPosition
    property alias cursorPosition: handler.cursorPosition
    property alias dragPosition: handler.dragPosition
    readonly property bool dragging: handler.dragging

    onVisibleChanged: handler.enableMouseAreas(visible)

    function updateForTransform() { handler.updateMouseAreas(); }

    TextDragHotspot {
        id: topHotspotArea

        penInput: dragManager.penInput
        onPenDown: (position) => { handler.penDown(position); }
        onPenDrag: (position) => { handler.penDrag(position); }
        onPenUp: (position) => { handler.penUp(position); }
    }
    TextDragHotspot {
        id: middleHotspotArea

        penInput: dragManager.penInput
        onPenDown: (position) => { handler.penDown(position); }
        onPenDrag: (position) => { handler.penDrag(position); }
        onPenUp: (position) => { handler.penUp(position); }
    }
    TextDragHotspot {
        id: bottomHotspotArea

        penInput: dragManager.penInput
        onPenDown: (position) => { handler.penDown(position); }
        onPenDrag: (position) => { handler.penDrag(position); }
        onPenUp: (position) => { handler.penUp(position); }
    }
    TextDragHandler {
        id: handler
        active: parent.visible
        topHotspot: topHotspotArea
        middleHotspot: middleHotspotArea
        bottomHotspot: bottomHotspotArea
        visibleCaret: caret

        onAnchorPositionChanged: updateMouseAreas()
        onCursorPositionChanged: updateMouseAreas()
        onInsertMoved: caret.scheduleUpdate();
    }
    TextInsertCaret {
        id: caret
        visible: false
        onPositionNeeded: handler.updateCaret()
    }
}
