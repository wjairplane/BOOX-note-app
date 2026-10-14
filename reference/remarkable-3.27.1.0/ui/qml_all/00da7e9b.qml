import com.remarkable
import common

import xofm.libs.gestures
import xofm.libs.devicescreen

TouchAreaSwipeFilter {
    id: root
    objectName: "fast-scroll"

    required property size touchSize

    readonly property real pixelsPerCm: DeviceScreenInfo.pixelsPerCm
    readonly property real edgeSize: pixelsPerCm

    signal activated

    distance: 1.0 * root.pixelsPerCm
    direction: Qt.point(0, -1)
    area: Qt.rect(0, touchSize.height - root.edgeSize, touchSize.width, root.edgeSize)
    // As the hand rests below the pen, chances for accidentals on the
    // bottom edge are quite a bit higher than on the top, so we
    // require release here to better avoid accidental fast-scroll
    // opening when moving the hand around while drawing.
    releaseRequired: true
    onTriggered: activated()
}
