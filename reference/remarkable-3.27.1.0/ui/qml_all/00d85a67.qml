import QtQuick
import common
import com.remarkable

Item {
    id: root

    property int indicators: 0
    property int currentIndicator: 0
    property bool invertColors: false
    property alias spacing: row.spacing
    property int radius: Values.pageIndicatorRadius

    height: row.implicitHeight
    width: row.implicitWidth

    QtObject {
        id: internal

        property color selectedColor: invertColors ? Values.colorWhite : Values.colorBlack
        property color unselectedColor: invertColors ? Values.colorBlack : Values.colorWhite
    }

    Row {
        id: row

        spacing: Values.navigatorMargin

        Repeater {
            model: root.indicators

            Rectangle {
                radius: root.radius
                width: radius * 2
                height: width
                border.color: internal.selectedColor
                border.width: Values.outlineSize
                color: root.currentIndicator === index ? internal.selectedColor : internal.unselectedColor
            }
        }
    }
}
