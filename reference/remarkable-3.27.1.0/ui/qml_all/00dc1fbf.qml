import QtQuick
import com.remarkable
import common

import ark.controls as ArkControls
import ark.tokens as ArkTokens

Item {
    id: selectionRoot

    property int page
    property QtObject worker
    property SceneController controller

    property int selectionLayer
    property int toolsMargin
    property int toolbarWidth
    property rect availableSceneRect: Qt.rect(0, 0, selectionRoot.width, selectionRoot.height)

    property rect sceneSelectionRect
    property rect viewSelectionRect: tileManager ? tileManager.sceneToView(sceneSelectionRect) : Qt.rect(0,0,0,0)

    // visual props
    property real handleSize: 30
    property real touchMargin: 0
    property real rotationHandleSize: 40
    property real controlsWidth: 2
    property real minRectSize: 100
    property color controlsColor: Values.colorWhite
    property color controlsBorderColor: Values.colorBlack
    property bool roundControls: false

    property bool showConvertToText: false
    property bool limitToPageBounds: false
    property bool snapRotation: false
    property alias selectionRect: selectionBorder
    property point dragPosition: mapFromItem(viewMouseArea, viewMouseArea.mouseX, viewMouseArea.mouseY)
    property alias dragging: viewMouseArea.dragging

    property bool tinted: controlsAreVisible
    property bool antialiased: false
    property bool lightThemed: false

    // Propagate the busy state upwards
    property bool working: selectionPreview.working

    property rect pageBounds

    required property bool zoomedOut

    signal copy
    signal cut
    signal convert(var point)
    signal deleteSelection

    visible: false

    Shortcut {
        enabled: selectionRoot.visible
        sequence: "Ctrl+C"
        onActivated: selectionRoot.copy()
    }

    Shortcut {
        enabled: selectionRoot.visible
        sequence: "Ctrl+X"
        onActivated: selectionRoot.cut()
    }

    Shortcut {
        enabled: selectionRoot.visible
        sequence: "Delete"
        onActivated: selectionRoot.deleteSelection()
    }

    // Consume key events while selection is visible
    // so for instance 'delete' does not fall through
    Keys.onPressed: (event) => {
        if (selectionRoot.visible) {
            event.accepted = true
        }
    }

    // Internal members
    property bool initialSelection
    property bool controlsAreVisible

    Item {
        id: selection

        // As QML doesn't support mirroring an item using negative width /
        // height, use an intermediate item and flip the content using
        // a transformation and some geometry tweaks.
        //
        // One might think that this would have been possible through some
        // cleverness using just a Scale transform directly on the
        // SelectionPreview instance, but no-oope, EPRenderer doesn't like
        // that, so this is what we'll be doing for now.
        SelectionPreview {
            id: selectionPreview
            tinted: selectionRoot.tinted
            lightThemed: selectionRoot.lightThemed
            x: parent.width < 0 ? parent.width : 0
            y: parent.height < 0 ? parent.height : 0
            width: parent.width < 0 ? -parent.width : parent.width
            height: parent.height < 0 ? -parent.height : parent.height

            transform: Scale {
                origin.x: selectionPreview.width / 2
                origin.y: selectionPreview.height / 2
                xScale: selection.width < 0 ? -1 : 1
                yScale: selection.height < 0 ? -1 : 1
            }
        }
    }

    Rectangle {
        id: selectionBorder
        border.width: controlsWidth
        border.color: controlsBorderColor
        anchors.fill: selection
        color: "transparent"
        visible: controlsAreVisible
        antialiasing: false
    }

    MouseArea {
        id: viewMouseArea
        anchors.fill: selection
        drag.target: selection
        drag.threshold: 10 // Override 30 px global qpa threshold

        drag.minimumX: limitToPageBounds ? pageBounds.x : -10000
        drag.maximumX: limitToPageBounds ? pageBounds.x + pageBounds.width - selection.width : 10000
        drag.minimumY: limitToPageBounds ? pageBounds.y : -10000
        drag.maximumY: limitToPageBounds ? pageBounds.y + pageBounds.height - selection.height : 10000

        property point dragStart

        property bool dragging: drag.active
        onDraggingChanged: {
            controlsAreVisible = !dragging;
            if (dragging) {
                dragStart = tileManager.viewToScene(Qt.point(selection.x, selection.y))
            } else {
                const pt0 = dragStart;
                const pt1 = tileManager.viewToScene(Qt.point(selection.x, selection.y));
                const dx = pt1.x - pt0.x;
                const dy = pt1.y - pt0.y;
                moveSelectedItems(dx, dy);

            }
        }
        onPressed: (event) => {
            if (event.modifiers & Qt.ShiftModifier) {
                event.accepted = false;
            }
        }
    }

    SelectionHandle {
        id: topLeftHandle
        x: selection.x - width / 2 + controlsWidth / 2
        y: selection.y - height / 2 + controlsWidth / 2
        updateX: true
        updateY: true
        cursorShape: Qt.SizeFDiagCursor
        function lineAcross() {
            return {
                x0: dragStartX,
                y0: dragStartY,
                x1: dragStartX + dragStartWidth,
                y1: dragStartY + dragStartHeight
            }
        }
    }

    SelectionHandle {
        id: topRightHandle
        x: selection.x + selection.width - width / 2 - controlsWidth / 2
        y: selection.y - height / 2 + controlsWidth / 2
        updateY: true
        cursorShape: Qt.SizeBDiagCursor
        function lineAcross() {
            return {
                x0: dragStartX + dragStartWidth,
                y0: dragStartY,
                x1: dragStartX,
                y1: dragStartY + dragStartHeight
            }
        }
    }

    SelectionHandle {
        id: bottomLeftHandle
        x: selection.x - width / 2 + controlsWidth / 2
        y: selection.y + selection.height - height / 2 - controlsWidth / 2
        updateX: true
        cursorShape: Qt.SizeBDiagCursor
        function lineAcross() {
            return {
                x0: dragStartX,
                y0: dragStartY + dragStartHeight,
                x1: dragStartX + dragStartWidth,
                y1: dragStartY
            }
        }
    }

    SelectionHandle {
        id: bottomRightHandle
        objectName: "bottomRightHandle"
        x: selection.x + selection.width - width / 2 - controlsWidth / 2
        y: selection.y + selection.height - height / 2 - controlsWidth / 2
        cursorShape: Qt.SizeFDiagCursor
        function lineAcross() {
            return {
                x0: dragStartX + dragStartWidth,
                y0: dragStartY + dragStartHeight,
                x1: dragStartX,
                y1: dragStartY
            }
        }
    }

    MouseArea {
        id: rotationHandle

        property real lastSnapAngle: NaN
        property bool snapOn
        property bool didFirstSnap

        function snapToAngle(angle) {
            const negativeValue = angle < 0;
            const absAngle = Math.abs(angle);

            if (angle > -10 && absAngle < 10) {
                return 0;
            } else if (absAngle > 35 && absAngle < 55) {
                return negativeValue ? -45 : 45;
            } else if (absAngle > 80 && absAngle < 100) {
                return negativeValue ? -90 : 90;
            } else if (absAngle > 125 && absAngle < 145) {
                return negativeValue ? -135 : 135;
            } else if (absAngle > 170) {
                return 180;
            }
            return NaN;
        }

        width: rotationHandleSize + 2 * touchMargin
        height: width
        x: selection.x + selection.width / 2 - width / 2
        y: selection.y - width / 2

        Rectangle {
            // Hidden rect to ensure we get touch events
            // as we filter those out for empty items
            anchors.fill: parent
            color: "transparent"
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: touchMargin
            border.width: controlsWidth
            border.color: controlsBorderColor
            radius: width / 2;
            visible: controlsAreVisible
            antialiasing: antialiased
        }

        onPressed: (event) => {
            controlsAreVisible = false;
            lastSnapAngle = NaN;
            didFirstSnap = false;
        }

        onPositionChanged: (event) => {
            const pt = mapToItem(selectionRoot, Qt.point(event.x, event.y));
            const cx = selection.x + selection.width / 2;
            const cy = selection.y + selection.height / 2;
            let angle = Math.atan2(pt.x - cx, cy - pt.y);
            angle = angle * 360 / (Math.PI * 2);

            if (snapRotation) {
                if (!didFirstSnap && angle > -10 && angle < 10) {
                    selection.rotation = angle;
                    return;
                }

                // Rotate the item, snapping if it is within the snap threshold.
                // Once it snaps, if you move over +/- 10 degrees outside of the snap angle, disable
                // snapping until you move over +/- 35 degrees outside of the snap angle.
                if (isNaN(lastSnapAngle)) {
                    // Try to snap to the nearest angle, if possible.
                    const snapAngle = snapToAngle(angle);
                    if (!isNaN(snapAngle)) {
                        lastSnapAngle = snapAngle;
                        angle = snapAngle;
                        snapOn = true;
                        didFirstSnap = true;
                    }
                } else {
                    // A snap is currently in place. See if it should be removed.
                    const deltaToLastSnap = Math.abs(Math.abs(angle) - Math.abs(lastSnapAngle));
                    if (Math.floor(deltaToLastSnap) > 10) {
                        snapOn = false;
                        if (deltaToLastSnap >= 35) {
                            // Rotation is within 10 degrees of next snapping angle, so reset and allow
                            // snapping to occur again.
                            lastSnapAngle = NaN;
                        }
                    } else {
                        angle = snapOn ? lastSnapAngle : angle;
                    }
                }
            }

            selection.rotation = angle;
        }

        onReleased: (event) => {
            controlsAreVisible = true;
            const cx = selection.x + selection.width / 2;
            const cy = selection.y + selection.height / 2;
            const sceneOrigin = tileManager.viewToScene(Qt.point(cx, cy));
            controller.rotateSelectedItems(selectionRoot.selectionLayer, sceneOrigin, selection.rotation);
        }
    }

    SelectionContextualMenu {
        id: tools

        pageBounds: selectionRoot.pageBounds
        availableRect: selectionRoot.availableSceneRect
        selectionRect: Qt.rect(selection.x, selection.y, selection.width, selection.height)

        visible: controlsAreVisible
        objectName: "selectionHandlerMenu"

        ArkControls.ContextualMenu.Button {
            id: selectionCut
            focusPolicy: Qt.NoFocus
            type: tools.type
            iconSource: "qrc:/ark/icons/cut"
            onClicked: selectionRoot.cut()
        }

        ArkControls.ContextualMenu.Button {
            id: selectionDuplicate
            focusPolicy: Qt.NoFocus
            type: tools.type
            iconSource: "qrc:/ark/icons/copy"
            onClicked: selectionRoot.copy()
        }

        ArkControls.ContextualMenu.Button {
            id: convertToText
            focusPolicy: Qt.NoFocus
            visible: showConvertToText && controller && controller.selectionContainsStroke
            type: tools.type
            iconSource: "qrc:/ark/icons/hwc"
            onClicked: {
                const selectionPoint = Qt.point(selection.x, selection.y);
                selectionRoot.convert(selectionPoint);
            }
        }

        ArkControls.ContextualMenu.Button {
            id: selectionDelete
            focusPolicy: Qt.NoFocus
            type: tools.type
            iconSource: "qrc:/ark/icons/trashcan"
            onClicked: selectionRoot.deleteSelection()
        }
    }

    // Updates position based on the member 'sceneSelectionRect'
    function updatePosition() {
        const viewRect = expandToAtLeast(MathUtils.sceneToViewAligned(tileManager, sceneSelectionRect), minRectSize);
        selection.width = selection.height = 0;
        selection.x = viewRect.x;
        selection.y = viewRect.y;
        selection.width = viewRect.width;
        selection.height = viewRect.height;
        selection.rotation = 0;

        selectionPreview.setStrokeSize(MathUtils.sceneToViewAligned(tileManager, sceneSelectionRect));

        initialSelection = false;
    }

    function open(layer, sceneRect) {
        if (sceneRect.width === 0 || sceneRect.height === 0) {
            return;
        }

        selectionLayer = layer;
        sceneSelectionRect = sceneRect;

        updatePosition();
        selectionPreview.updateStrokeImage(worker, page, selectionLayer, MathUtils.sceneToViewAligned(tileManager, sceneSelectionRect), controller.pendingEdit);

        // This is only shown the very first time..
        initialSelection = !visible;
        controlsAreVisible = true;
        visible = true;
    }

    function close() {
        if (!controller) {
            print("SceneSelectionHandler::close: closed without a SceneController")
            return;
        }
        if (selectionLayer >= 0) {
            controller.clearSelectedItems();
            selectionLayer = -1;
        }
        visible = false;
    }

    function viewRect() {
        const pad = tools.height + Values.iconSizeMedium;
        return Qt.rect(selection.x - pad, selection.y - pad, selection.width + pad * 2, selection.height + pad * 2);
    }

    function selectionPreview() {
        return selectionPreview;
    }

    function lineLength(x0, y0, x1, y1) {
        const dx = x1 - x0;
        const dy = y1 - y0;
        return Math.sqrt(dx * dx + dy * dy);
    }

    function expandToAtLeast(r, size) {
        if (r.width < size) {
            const cx = r.x + r.width / 2;
            r.x = cx - size / 2;
            r.width = size;
        }
        if (r.height < size) {
            const cy = r.y + r.height / 2;
            r.y = cy - size / 2;
            r.height = size;
        }
        return r;
    }

    function insidePageBounds(x, y, width, height, offset) {
        if (width < 0) {
            width = Math.abs(width);
            x = x - width;
        }
        if (height < 0) {
            height = Math.abs(height);
            y = y - height;
        }

        if (x >= pageBounds.x - offset && x + width <= pageBounds.x + pageBounds.width + offset && y >= pageBounds.y) {
            if (notePage) {
                return true;
            } else if (y + height <= pageBounds.y + pageBounds.height) {
                // Only take bottom bounds into account for pdf and epub pages
                return true;
            }
        }
        return false;
    }

    function insideSceneBounds(x, y, width, height) {
        if (x >= sceneBounds.x && x + width <= sceneBounds.x + sceneBounds.width && y >= sceneBounds.y) {
           if (notePage) {
               return true;
           } else if (y + height <= sceneBounds.y + sceneBounds.height) {
                return true;
           }
        }
        return false;
    }

    function moveSelectedItems(dx, dy) {
        controller.moveSelectedItems(controller.currentLayer, Qt.point(dx, dy));
    }
}
