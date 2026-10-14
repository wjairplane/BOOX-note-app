import QtQuick
import QtQuick.Layouts

import ark.tokens as ArkTokens
import ark.controls as ArkControls

Item {
    id: root

    readonly property alias elementHeight: hoursSpinner.elementHeight // used to draw the 2-line selector

    // these properties mirror the hours/minutes values hosted by the DateSpinners' user
    property int hours
    property int minutes

    readonly property int _spacing: 80
    readonly property int _spinnerWidth: 120

    signal newHours(int h)
    signal newMinutes(int m)

    implicitWidth: spinnersLayout.implicitWidth

    RowLayout {
        id: spinnersLayout
        height: parent.height
        spacing: 0

        Spinner {
            id: hoursSpinner
            objectName: "hoursSpinner"
            Layout.fillHeight: true
            Layout.preferredWidth: root._spinnerWidth
            currentIndex: model.indexOf(hours.toString().padStart(2, '0'))
            model: Array.from({length: 24}, (v, i) => (i.toString().padStart(2, '0')))
            onNewElement: (elt) => { root.newHours(elt); }
        }

        Separator {
            Layout.fillHeight: true
            Layout.preferredWidth: root._spacing
        }

        Spinner {
            objectName: "minutesSpinner"
            Layout.fillHeight: true
            Layout.preferredWidth: root._spinnerWidth
            currentIndex: model.indexOf(minutes.toString().padStart(2, '0'))
            model: Array.from({length: 60}, (v, i) => (i.toString().padStart(2, '0')))
            onNewElement: (elt) => { root.newMinutes(elt); }
        }
    }

    component Separator : Item {
        ArkControls.Label {
            type: ArkControls.Label.ExtraLargeStrong
            anchors.fill: parent
            text: ":"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
