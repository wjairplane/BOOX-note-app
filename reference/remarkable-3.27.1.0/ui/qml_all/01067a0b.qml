import QtQuick

import ark.controls as ArkControls

import xofm.libs.epaper as Epaper

Rectangle {
    id: root
    readonly property bool accepted: _internal.accepted

    // We don't animate smoothly, so we divide the slider into discrete steps
    property int steps: 5
    property alias text: label.text

    QtObject {
        id: _internal
        property bool accepted
    }

    height: 112
    implicitWidth: Math.max(560, label.implicitWidth + 2 * dragHandle.height + ArkControls.Values.spacing.medium * 2)
    color: "white"
    radius: height / 2

    ArkControls.Label {
        id: label
        type: ArkControls.Label.Medium
        color: "black"
        anchors.centerIn: parent
        visible: dragHandle.width === dragHandle.height
        text: qsTr("Swipe to continue")
    }

    MouseArea {
        property bool rejected: false
        anchors.fill: parent

        function reset() {
            if (_internal.accepted) {
                return;
            }
            rejected = false;
            dragHandle.width = dragHandle.height;
        }

        onPositionChanged: (event) => {
            // Check if the drag is outside the vertical bounds
            if (event.y < 0 || event.y > height) {
                rejected = true;
            }

            // If already accepted or rejected, do nothing
            if (_internal.accepted || rejected) {
                return;
            }

            // Update the drag indicator width based on the steps completed
            const stepSize = width / root.steps;
            if (event.x > dragHandle.width) {
                const stepsCompleted = Math.floor(event.x / stepSize);
                dragHandle.width = stepSize * stepsCompleted;

                // Mark as accepted if all steps are completed
                if (stepsCompleted >= root.steps) {
                    _internal.accepted = true;
                }
            }
        }

        onReleased: {
            reset();
        }

        onPressed: (event) => {
            reset();
            if (event.x > dragHandle.width) {
                rejected = true;
            }
        }

    }

    Rectangle {
        id: dragHandle
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        width: height
        radius: height
        antialiasing: false
        color: "black"

        ArkControls.Icon {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: parent.height / 4
            }
            size: ArkControls.Values.iconSize.large
            source: "qrc:/ark/icons/arrow_right"
            color: "white" // Values.colorWhite
        }
    }

    Rectangle {
        // External border
        antialiasing: false
        anchors.fill: parent
        anchors.margins: -border.width
        color: "transparent"
        radius: height / 2
        border {
            width: 2
            color: "black"
        }
    }

    Epaper.ScreenModeItem {
        mode: Epaper.ScreenModeItem.Animation
        anchors.fill: parent
        objectName: "accidental-touch-slider"
    }
}
