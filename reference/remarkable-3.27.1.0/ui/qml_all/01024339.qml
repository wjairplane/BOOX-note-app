import QtQuick
import QtQuick.Layouts

import common

import ark.tokens as ArkTokens
import ark.controls as ArkControls

import "DateHelper.js" as Helper

Item {
    id: root

    readonly property alias elementHeight: yearSpinner.elementHeight // used to draw the 2-line selector

    // these properties mirror the year/month/date values hosted by the DateSpinners' user
    property int year
    property int month
    property int date

    readonly property int _spacing: 80
    readonly property int _spinnerWidth: 120

    signal newYear(int y)
    signal newMonth(int m)
    signal newDate(int d)

    implicitWidth: spinnersLayout.implicitWidth

    onMonthChanged: {
        dateSpinner.model = Qt.binding(function() {
            let length = Helper.getMonthDuration(root.year, root.month);
            return Array.from({length: length}, (v, i) => i + 1)
        })
        dateSpinner.currentIndex = Qt.binding(function() {
            return dateSpinner.model.indexOf(root.date)
        })
    }

    RowLayout {
        id: spinnersLayout
        height: parent.height
        spacing: 0

        Spinner {
            id: dateSpinner
            objectName: "dateSpinner"
            Layout.fillHeight: true
            Layout.preferredWidth: root._spinnerWidth
            onNewElement: (elt) => { root.newDate(elt); }
        }

        Separator {
            Layout.fillHeight: true
            Layout.preferredWidth: root._spacing
        }

        Spinner {
            objectName: "monthSpinner"
            Layout.fillHeight: true
            Layout.preferredWidth: root._spinnerWidth
            currentIndex: model.map(elt => elt.value).indexOf(root.month)
            model: [
                {
                    value: 1,
                    label: qsTr("Jan")
                },
                {
                    value: 2,
                    label: qsTr("Feb")
                },
                {
                    value: 3,
                    label: qsTr("Mar")
                },
                {
                    value: 4,
                    label: qsTr("Apr")
                },
                {
                    value: 5,
                    label: qsTr("May")
                },
                {
                    value: 6,
                    label: qsTr("Jun")
                },
                {
                    value: 7,
                    label: qsTr("Jul")
                },
                {
                    value: 8,
                    label: qsTr("Aug")
                },
                {
                    value: 9,
                    label: qsTr("Sep")
                },
                {
                    value: 10,
                    label: qsTr("Oct")
                },
                {
                    value: 11,
                    label: qsTr("Nov")
                },
                {
                    value: 12,
                    label: qsTr("Dec")
                }
            ]
            onNewElement: (elt) => { root.newMonth(elt.value); }
        }

        Separator {
            Layout.fillHeight: true
            Layout.preferredWidth: root._spacing
        }

        Spinner {
            id: yearSpinner
            objectName: "yearSpinner"
            Layout.fillHeight: true
            Layout.preferredWidth: root._spinnerWidth
            currentIndex: model.indexOf(root.year)
            model: Array.from({length: 2038-2022}, (v, i) => i + 2022) // show the range 2022 - 2037 (due to the jan 19th 2038 known issue)
            onNewElement: (elt) => { root.newYear(elt); }
        }
    }

    component Separator : Item {
        ArkControls.Label {
            type: ArkControls.Label.ExtraLargeStrong
            anchors.fill: parent
            text: "/"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
