import QtQuick
import com.remarkable

Item {
    id: root

    property bool tinted: false
    property bool lightThemed: false

    // Used to convey upwards in the hierarchy that we're busy, which can be
    // accumulated into overall loading state for instance.
    property bool working: false;

    readonly property alias image: selectionImage

    Rectangle {
        id: backgroundTint
        anchors.fill: parent
        visible: root.tinted
        color: Qt.hsla(0, 0, 0.6, 0.6)
        antialiasing: false
    }

    SelectionImage {
        id: selectionImage
        lightThemed: root.lightThemed
        anchors.fill: parent
    }

    function getImageMargins() {
        return {
            top: selectionImage.anchors.topMargin || 0,
            right: selectionImage.anchors.rightMargin || 0,
            bottom: selectionImage.anchors.bottomMargin || 0,
            left: selectionImage.anchors.leftMargin || 0
        };
    }

    function zeroImageMargins() {
        selectionImage.anchors.leftMargin = 0;
        selectionImage.anchors.rightMargin = 0;
        selectionImage.anchors.topMargin = 0;
        selectionImage.anchors.bottomMargin = 0;
    }

    // Shift the given selection item so that its rect matches the inner image rect
    // and clear margins so all drag math can ignore margins entirely.
    function normalizeSelectionForDrag(selectionItem) {
        const { top, right, bottom, left }  = getImageMargins();

        selectionItem.x = selectionItem.x + left;
        selectionItem.y = selectionItem.y + top;
        selectionItem.width = selectionItem.width - (left + right);
        selectionItem.height = selectionItem.height - (top + bottom);

        zeroImageMargins();
    }

    function updateStrokeImage(worker, page, layer, viewRect, previewTransform) {
        root.working = true;
        selectionImage.updateImage(worker, page, layer, tileManager.viewToScene(viewRect), previewTransform);
        root.working = false;
        setStrokeSize(viewRect);
    }

    function setStrokeSize(strokeSelectionSize) {
        if (root.width > 0 && root.height > 0) {
            const widthDiff = root.width - strokeSelectionSize.width;
            const heightDiff = root.height - strokeSelectionSize.height;

            selectionImage.anchors.leftMargin = Math.max(0, widthDiff / 2);
            selectionImage.anchors.rightMargin = Math.max(0, widthDiff / 2);
            selectionImage.anchors.topMargin = Math.max(0, heightDiff / 2);
            selectionImage.anchors.bottomMargin = Math.max(0, heightDiff / 2);
        }
    }
}
