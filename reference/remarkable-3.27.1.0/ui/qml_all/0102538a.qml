import QtQuick

import common

import ark.tokens as ArkTokens
import ark.controls as ArkControls

Rectangle {
    id: root

    property bool showDate: true
    property int year
    property int month
    property int date
    property int hours
    property int minutes
    property int highlightBorder

    readonly property int _tumblerViewerHeight: 92
    readonly property int _closeButtonMargin: 40
    readonly property int _selectedElementHeight: 112 // note: this value should be the same as the Spinner's selectedElementHeight
    readonly property double _spinnnersScreenRatio: 656/848 // this ratio allows responsiveness; it is based on the figma sketches that were made on rM2

    signal newYear(int year)
    signal newMonth(int month)
    signal newDate(int date)
    signal newHours(int hours)
    signal newMinutes(int minutes)

    color: Values.colorWhite

    Rectangle {
        width: parent.width
        height: Values.outlineSize
        color: Values.colorBlack
        anchors.top: parent.top
    }

    Loader {
        objectName: "spinnersLoader"
        anchors.centerIn: parent
        height: Math.max(parent.height * root._spinnnersScreenRatio, Screen.height/3.5) // ensure the size of the spinnersLoader has a minimal height
        sourceComponent: showDate ? dateSpinnersComponent : timeSpinnersComponent

        Item {
            width: parent.width + (showDate ? 16 : 0) // this extra padding is specified by designers to deal with years (4 digits)
            height: parent.item?.elementHeight ?? root._selectedElementHeight
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                color: "transparent"
                anchors.fill: parent
                border {
                    width: highlightBorder
                    color: Values.colorBlack
                }
            }
        }
    }

    Component {
        id: dateSpinnersComponent

        DateSpinners {
            year: root.year
            month: root.month
            date: root.date

            onNewYear: (year) => { root.newYear(year); }
            onNewMonth: (month) => { root.newMonth(month); }
            onNewDate: (date) => { root.newDate(date); }
        }
    }

    Component {
        id: timeSpinnersComponent

        TimeSpinners {
            hours: root.hours
            minutes: root.minutes

            onNewHours: (hours) => { root.newHours(hours); }
            onNewMinutes: (minutes) => { root.newMinutes(minutes); }
        }
    }
}
