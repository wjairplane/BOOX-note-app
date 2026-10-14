import QtQuick

import com.remarkable
import common
import device.global


Item {
    id: root

    enum Type {
        Vertical,
        Horizontal
    }

    antialiasing: false
    visible: false
    width: scrollbarToucharea
    height: root.verticalScrollbar ? view.height : scrollbarToucharea
    required property int type

    readonly property bool verticalScrollbar: type === DeviceScrollBar.Type.Vertical
    readonly property bool horizontalScrollbar: type === DeviceScrollBar.Type.Horizontal

    /*
        Properties
    */
    readonly property int scrollbarToucharea: 84
    readonly property int scrollbarWidth: 8
    readonly property bool scrollbarTimersRunning: scrollbarTimer.running
    readonly property bool scrollbarPressed: touchArea.pressed
    required property bool zoomedOut
    required property bool zoomedIn

    property var view
    property alias scrolling: touchArea.scrolling
    property int scrollbarMarginAlongLength: view.scrollbarMarginAlongLength
    property bool panLockedVertical
    property bool panLockedHorizontal
    property bool didPanVertical
    property bool didPanHorizontal
    property bool penClose: false

    /*
        Signals
    */
    onPanLockedVerticalChanged: {
        if (panLockedVertical) {
            didPanVertical = true;
            didPanHorizontal = false;
        }
    }

    onPanLockedHorizontalChanged: {
        if (panLockedHorizontal) {
            didPanHorizontal = true;
            didPanVertical = false;
        }
    }

    /*
        Functions
    */
    function show() {
        scrollbarTimer.restart();
    }

    function hide() {
        scrollbarTimer.stop();
    }

    function cancel() {
        if (touchArea.touchedIndicatorOnPressed) {
            view.endDragAndZoom();
        }
        releaseTimer.stop();
        touchArea.touchedIndicatorOnPressed = false;
        touchArea.scrolling = false;
    }

    function update(position, size) {
        if (root.verticalScrollbar) {
            const maxPos = scrollbar.height - scrollbarMarginAlongLength - size;
            const minPos = scrollbarMarginAlongLength;
            const pos = Math.max(minPos, Math.min(maxPos, position));
            scrollbarIndicator.y = pos;
            scrollbarIndicator.height = size;
            return;
        }

        const maxPos = scrollbar.width - scrollbarMarginAlongLength - size;
        const minPos = scrollbarMarginAlongLength;
        const pos = Math.max(minPos, Math.min(maxPos, position));
        scrollbarIndicator.x = pos;
        scrollbarIndicator.width = size;
    }

    function fakeUpdateVerticalScrollbar(diff) {
        scrollbarIndicator.y = scrollbarIndicator.y + diff;
    }

    function fakeUpdateHorizontalScrollbar(diff) {
        scrollbarIndicator.x = scrollbarIndicator.x + diff;
    }

    function mapValueToRange(x, inMin, inMax, outMin, outMax) {
        return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
    }

    function resetProperties() {
        didPanVertical = false;
        didPanHorizontal = false;
    }

    /*
        Timers
    */
    Timer {
        id: scrollbarTimer
        interval: Values.popupTimeout
        onTriggered: {
            resetProperties();
        }
    }

    /*
        Interaction
    */
    MouseArea {
        id: touchArea
        anchors.fill: parent
        property bool touchedIndicatorOnPressed   // Used to decide if the user can scroll or not.
        property bool scrolling                   // Used to enable the 'FastUpdateArea' and mono mode.
        property real previousPosition            // Used to check if we're reached the 'threshold'. Mainly when using the marker/pen and reduce accidental scrolling.
        property real pressedPos                  // Used to calculate the correct mouseX/mouseY position so that we can grab the scrollbar from anywhere.
        readonly property int threshold: 50       // Used to decide if should allow scroll or not.

        onMouseXChanged: {
            // In a vertical scrolbar we ignore horizontal changes.
            if (root.verticalScrollbar) {
                return;
            }

            // Early return if we're didn't touch the indicator or the timer running.
            if (!touchedIndicatorOnPressed || releaseTimer.running) { return; }

            const diff = Math.abs(mouseX - previousPosition);
            // Early return if trying to update the scrollbar with the pen as it updates
            // on 0.00001 frequency. So we only update when a certain threshold is met.
            // We also use this to limit the amount of accidentalt scrolls caused by the infamous 'ertben'.
            if (diff < threshold) {
                return;
            }

            // Indicate scrolling so we can enable the FastUpdateArea and mono mode.
            scrolling = true;
            scrollbarTimer.restart();

            // Fake update scrollbar before performing scrolling so it appear a bit more reponsive.
            fakeUpdateHorizontalScrollbar(diff);

            // Calculate new scroll position.
            const mappedMouseX = mapValueToRange(mouseX + pressedPos,
                                                 scrollbarMarginAlongLength,
                                                 width - scrollbarMarginAlongLength,
                                                 view.exteriorBoundary.x + scrollbarMarginAlongLength,
                                                 (view.exteriorBoundary.width / 2) - scrollbarMarginAlongLength);
            const distance = Qt.point((view.tileManager.center.x - mappedMouseX) * view.tileManager.scale, 0);
            view.updateDragAndZoom(distance, Qt.point(0, 0), 1);

            previousPosition = mouseX;
        }

        onMouseYChanged: {
            // In a horizontal scrolbar we ignore vertical changes.
            if (!root.verticalScrollbar) {
                return;
            }

            // Early return if we didn't touch the indicator or the release timer still running.
            if (!touchedIndicatorOnPressed || releaseTimer.running) { return; }

            const diff = Math.abs(mouseY - previousPosition);
            // Early return if trying to update the scrollbar with the pen as it updates
            // on 0.00001 frequency. So we only update when a certain threshold is met.
            // We also use this to limit the amount of accidentalt scrolls caused by the infamous 'ertben'.
            if (diff < threshold) {
                return;
            }

            // Indicate scrolling so we can enable the FastUpdateArea and mono mode.
            scrolling = true;
            scrollbarTimer.restart();

            // Fake update scrollbar before performing scrolling so it appear a bit more reponsive.
            fakeUpdateVerticalScrollbar(diff);

            // Calculate new scroll position.
            const mappedMouseY = mapValueToRange(mouseY + pressedPos,
                                                 scrollbarMarginAlongLength,
                                                 height - scrollbarMarginAlongLength,
                                                 view.exteriorBoundary.y,
                                                 view.exteriorBoundary.height);
            const distance = Qt.point(0, (view.tileManager.center.y - mappedMouseY) * view.tileManager.scale);
            view.updateDragAndZoom(distance, Qt.point(0, 0), 1);

            previousPosition = mouseY;
        }

        onPressed: function (event) {
            // To avoid accidental scrolling, we reject touch events while pen is close
            // and the event source is touch. Pen events should still be accepted
            if (root.penClose && event.source === Qt.MouseEventSynthesizedByQt) {
                event.accepted = false;
                return;
            }

            releaseTimer.restart();

            // Need to handle the vertical/horizontal scrolling differently.
            // Here we check if the user pressed inside the indicator to allow scrolling,
            // and calculate the correct pressed position so that we can grab the scrollbar from any y-value.
            if (root.verticalScrollbar) {
                touchedIndicatorOnPressed = mouseY >= scrollbarIndicator.y
                                         && mouseY <= scrollbarIndicator.y + scrollbarIndicator.height
                                         && mouseX >= 0
                                         && mouseX <= width;
                previousPosition = mouseY;

                const scrollbarMid = scrollbarIndicator.y + (scrollbarIndicator.height / 2);
                pressedPos = scrollbarMid - mouseY;

                const scrollbarAtBottom = scrollbarIndicator.y + scrollbarIndicator.height >= height - scrollbarMarginAlongLength;
                if (scrollbarAtBottom) {
                    // Since the scrollbar is shrinking when 'requesting' more paper,
                    // the mapping between the pressed y-value on the scrollbar to exterior boundary
                    // will be wrong. So we need to find the actual scrollbar size and use that middle value
                    // instead to prevent glitching when scrolling.
                    const availableHeight = view.height - scrollbarMarginAlongLength * 2;
                    const scrollbarSize = (Values.deviceHeight / view.exteriorBoundary.height) * availableHeight;
                    const scrollbarSizeMid = scrollbarIndicator.y + (scrollbarSize / 2)
                    pressedPos = scrollbarSizeMid - mouseY;
                }
            } else {
                touchedIndicatorOnPressed = mouseX >= scrollbarIndicator.x
                                         && mouseX <= scrollbarIndicator.x + scrollbarIndicator.width
                                         && mouseY >= 0
                                         && mouseY <= height;
                previousPosition = mouseX;

                const scrollbarMid = scrollbarIndicator.x + (scrollbarIndicator.width / 2);
                pressedPos = scrollbarMid - mouseX;
            }

            // If we touched the indicator we want to enable drag.
            if (touchedIndicatorOnPressed) {
                view.beginDragAndZoom();
            }
        }

        onReleased: root.cancel()
        onCanceled: root.cancel()

        Timer {
            id: releaseTimer
            interval: 100
        }
    }

    /*
        UI Components
    */
    Item {
        id: scrollbar
        antialiasing: parent.antialiasing
        anchors.centerIn: parent
        width: root.verticalScrollbar ? scrollbarWidth : root.width
        height: root.verticalScrollbar ? root.height : scrollbarWidth

        Item {
            id: ditherBackground
            antialiasing: parent.antialiasing
            anchors {
                fill: parent
                topMargin: root.verticalScrollbar ? scrollbarMarginAlongLength : 0
                bottomMargin: root.verticalScrollbar ? scrollbarMarginAlongLength : 0
                leftMargin: root.verticalScrollbar ? 0 : scrollbarMarginAlongLength
                rightMargin: root.verticalScrollbar ? 0 : scrollbarMarginAlongLength
                left: root.verticalScrollbar ? undefined : scrollbar.left
            }
            y: root.verticalScrollbar ? 0 : scrollbar.height / 2
            z: scrollbarIndicator.z - 1
            width: root.verticalScrollbar ? scrollbarWidth : scrollbar.width
            height: root.verticalScrollbar ? 0 : scrollbarWidth

            Image {
                id: ditherImageBody
                anchors.fill: parent
                fillMode: Image.Tile
                source: "qrc:/qml/images/dithered-double.png"

                Component {
                    id: maskSemicircle
                    Canvas {
                        id: canvas
                        width: scrollbarWidth
                        height: width
                        antialiasing: false
                        x: ditherImageBody.x
                        y: ditherImageBody.y
                        onVisibleChanged: requestPaint()
                        onPaint: {
                            let ctx = getContext("2d");
                            ctx.fillStyle = Values.colorWhite;
                            ctx.beginPath();
                            ctx.rect(0, 0, width, height);
                            ctx.moveTo(width / 2, height);
                            ctx.arc(width / 2, height, width / 2, 0, Math.PI, true);
                            ctx.clip();
                            ctx.fill();
                        }
                    }
                }

                Loader {
                    id: top
                    visible: root.verticalScrollbar
                    sourceComponent: maskSemicircle
                }

                Loader {
                    id: bottom
                    visible: root.verticalScrollbar
                    sourceComponent: maskSemicircle
                    y: ditherBackground.height - scrollbarWidth
                    rotation: 180
                }

                Loader {
                    id: left
                    visible: !root.verticalScrollbar
                    sourceComponent: maskSemicircle
                    x: parent.x
                    rotation: -90
                }

                Loader {
                    id: right
                    visible: !root.verticalScrollbar
                    sourceComponent: maskSemicircle
                    x: parent.x + parent.width - scrollbarWidth
                    rotation: 90
                }
            }
        }

        Rectangle {
            id: scrollbarIndicator
            antialiasing: parent.antialiasing
            x: -2
            y: - 2
            width: root.verticalScrollbar ? scrollbarWidth + 4 : 0
            height: root.verticalScrollbar ? 0 : scrollbarWidth + 4
            radius: width / 2
            color: Values.colorBlack
            border.width: 2
            border.color: Values.colorWhite
        }
    }
}
