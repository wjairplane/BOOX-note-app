import QtQuick

MouseArea {
    id: handle

    width: handleSize + 2 * touchMargin
    height: width

    property real mouseDownX
    property real mouseDownY

    property real dragStartX
    property real dragStartY
    property real dragStartWidth
    property real dragStartHeight

    property bool updateX
    property bool updateY

    /*
        We resize proportionally by looking at the line from the
        handle we are dragging, through the selection's center and
        over to the opposing handle. The ratio of the distances
        between the two lines is the scale factor:

            scale = |oppostePt -> mousePt| / |oppositePt -> handlePt|

        The function lineAcross() is reimplemented in each handle
        to return the line from this handle to the opposite side.

        Once we've calculated the new size, we check if it's inside the
        page bounds and update the selection
     */
    function calculateScale(event) {
        const pt = mapToItem(selectionRoot, Qt.point(event.x, event.y));
        const across = lineAcross();

        const originalDistance = lineLength(across.x1, across.y1, across.x0, across.y0);
        const currentDistance = lineLength(across.x1, across.y1, pt.x, pt.y);
        const scale = originalDistance > 0 ? currentDistance / originalDistance : 1.0;

        // Figure out mirroring. We're mirroring if we're on the opposite side
        // of the opposite point (pt1) compared to our handle point (p0).
        function sign(x) {
            return x < 0 ? -1 : 1;
        }
        const invertX = sign(across.x0 - across.x1) != sign(pt.x - across.x1);
        const invertY = sign(across.y0 - across.y1) != sign(pt.y - across.y1);
        let xScale = invertX ? -scale : scale;
        let yScale = invertY ? -scale : scale;

        // And if we are mirroring, try to snap to the original size
        if ((invertX || invertY) && Math.abs(1.0 - scale) < 0.1) {
            xScale = sign(xScale);
            yScale = sign(yScale);
        }

        return [xScale, yScale];
    }

    onPositionChanged: (event) => {
        const [xScale, yScale] = calculateScale(event);

        let imageRect = Qt.rect(0, 0, 0, 0);
        imageRect.width = dragStartWidth * xScale;
        imageRect.height = dragStartHeight * yScale;

        imageRect.x = updateX ? (dragStartX + dragStartWidth - imageRect.width) : selection.x;
        imageRect.y = updateY ? (dragStartY + dragStartHeight - imageRect.height) : selection.y;

        // Check new bounds are valid
        if (!limitToPageBounds || insidePageBounds(imageRect.x, imageRect.y, imageRect.width, imageRect.height, 1)) {
            selection.x = imageRect.x;
            selection.y = imageRect.y;
            selection.width = imageRect.width;
            selection.height = imageRect.height;
        }
    }

    onPressed: (event) => {
        controlsAreVisible = false;
        const pt = mapToItem(selectionRoot, Qt.point(event.x, event.y));
        mouseDownX = pt.x;
        mouseDownY = pt.y;

        /*
            The image of the strokes usually fills the selection.
            The selection has a minimum size.
            If the strokes being selected are smaller than this, then the
            image no longer fills the selection box. Margins are used to center the image
            within the selection.

            These margins aren't necessary when resizing as the selection box is hidden,
            so we remove them to make all of our logic deal with the image itself.
        */
        const preview = selectionRoot.selectionPreview();
        preview.normalizeSelectionForDrag(selection);

        dragStartX = selection.x;
        dragStartY = selection.y;
        dragStartWidth = selection.width;
        dragStartHeight = selection.height;
    }

    onReleased: (event) => {
        controlsAreVisible = true;

        const [xScale, yScale] = calculateScale(event);
        const across = lineAcross();
        const origin = tileManager.viewToScene(Qt.point(across.x1, across.y1));
        controller.scaleSelectedItems(selectionLayer, origin, xScale, yScale);

        dragStartX = 0;
        dragStartY = 0;
        dragStartWidth = 0;
        dragStartHeight = 0;
    }

    Rectangle {
        // This invisible rect is just to ensure we get pen input on the
        // padded touch margins as a plain MouseArea has no content and
        // will be masked out otherwise
        anchors.fill: parent
        color: "transparent"
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: touchMargin
        antialiasing: antialiased
        border.color: controlsBorderColor
        border.width: controlsWidth
        radius: roundControls ? 2 : 0
        visible: controlsAreVisible
    }
}
