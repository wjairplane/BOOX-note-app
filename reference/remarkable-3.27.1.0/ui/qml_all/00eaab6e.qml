import QtQuick
import QtQuick.Controls

import ark.controls as ArkControls

Control {
    id: root

    // We still use position for nested foldouts, however we likely want to solve those with anchors instead
    // lets keep it around while we migrate away from the ark foloduts
    property int position
    onPositionChanged: repositionFoldout()

    enum Position {
        Top,
        Bottom,
        Left,
        Right,
        Absolute
    }

    property Item toolbar

    signal foldoutRepositioned

    readonly property size size: Qt.size(width, height)
    onSizeChanged: root.repositionFoldout()

    onVisibleChanged: root.repositionFoldout()

    function repositionFoldout() {
        if (!root.visible || parent instanceof StackView) {
            return;
        }
        const containerPos = root.toolbar.container.mapToItem(parent, 0, 0);
        const preferredPos = (function (){
            const relativeX = -containerPos.x > root.toolbar.container.width / 2 ? -root.width + parent.width : 0;
            const relativeY = -containerPos.y > root.toolbar.container.height / 2 ? -root.height + parent.height : 0;
            switch(root.position) {
            case ToolbarFoldout.Position.Top:
                return Qt.point(relativeX, -root.height);
            case ToolbarFoldout.Position.Bottom:
                return Qt.point(relativeX, parent.height);
            case ToolbarFoldout.Position.Left:
                return Qt.point(-root.width, relativeY);
            case ToolbarFoldout.Position.Right:
                return Qt.point(parent.width, relativeY);
            }
        })();

        if (root.toolbar.container) {
            const containerRightEdge = containerPos.x + root.toolbar.container.width;
            const containerBottomEdge = containerPos.y + root.toolbar.container.height;
            const maxX = containerRightEdge - root.width;
            const maxY = containerBottomEdge - root.height;
            root.x = Math.min(Math.max(containerPos.x, preferredPos.x), maxX);
            root.y = Math.min(Math.max(containerPos.y, preferredPos.y), maxY);
        }
        foldoutRepositioned();
    }

    background: Rectangle {
        color: "white"

        MultiPointTouchArea {
            anchors.fill: parent
        }
    }

    // We do overlapping borders on the content item
    Rectangle {
        color: "transparent"
        z: 10
        anchors.fill: parent
        border {
            width: 2
            color: "black"
        }
    }
}
