import QtQuick
import common

/**
    An focus frame for use in buttons.
*/
Rectangle {
    property color borderColor: Values.colorBlack

    color: "transparent"
    anchors {
        margins: 4
    }
    border {
        color: borderColor
        width: 4
    }
}
