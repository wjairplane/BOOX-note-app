import QtQuick
import com.remarkable
import common


// 3D shadow border
Item {
    property Item target: undefined
    property real shadowOffset: Values.shadowOffset

    x: target.x
    y: target.y
    width: target.width + shadowOffset
    height: target.height + shadowOffset

    property real contentWidth: target.width
    property real contentHeight: target.height

    Triangle {
        x: parent.contentWidth
        y: 0
        width: shadowOffset
        height: shadowOffset

        edge: Qt.BottomEdge | Qt.LeftEdge

        color: Values.colorBlack
    }

    Rectangle {
        x: parent.contentWidth
        y: shadowOffset
        width: shadowOffset
        height: parent.contentHeight

        color: Values.colorBlack
    }

    Triangle {
        x: 0
        y: parent.contentHeight
        width: shadowOffset
        height: shadowOffset

        edge: Qt.TopEdge | Qt.RightEdge

        color: Values.colorBlack
    }

    Rectangle {
        x: shadowOffset
        y: parent.contentHeight
        width: parent.contentWidth
        height: shadowOffset

        color: Values.colorBlack
    }
}
