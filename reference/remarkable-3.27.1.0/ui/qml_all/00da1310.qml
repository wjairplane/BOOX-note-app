import QtQuick

import xofm.libs.peninput

MouseArea {
    id: rootArea

    required property PenInput penInput
    signal penDown(point position)
    signal penDrag(point position)
    signal penUp(point position)

    onPressed: (mouse) => {
        penDown(parent.mapFromItem(rootArea, mouse.x, mouse.y));
    }
    onReleased: (mouse) => {
        penUp(parent.mapFromItem(rootArea, mouse.x, mouse.y));
    }
    onPositionChanged: (mouse) => {
        penDrag(parent.mapFromItem(rootArea, mouse.x, mouse.y));
    }

    PenInputBlocker {
        anchors.fill: parent
        manager: root.penInput.surfaceManager
    }
}
