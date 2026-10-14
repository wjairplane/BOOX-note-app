import QtQuick

Rectangle {
    id: root

    required property var virtualKeyboard

    property alias keys: keyRepeater.model
    property rect targetRect

    signal keySelected(string symbol);

    readonly property int minMargin: 20
    readonly property int targetKeyVerticalOffset: -30
    readonly property int autoHideTimeout: 10000
    readonly property int arrowSize: 40
    readonly property int keySize: 100
    readonly property int fontSize: 34

    function getKey(index) {
        return keyRepeater.itemAt(index);
    }

    onVisibleChanged: {
        if (visible) {
            hideTimer.restart();
        }
    }

    width: keyGrid.implicitWidth
    height: keyGrid.height
    antialiasing: false
    color: "black"
    visible: false

    // Ensure popup edges stay within minimum margins and avoid rounding
    x: Math.round(Math.max(minMargin,
                           Math.min(Qt.inputMethod.keyboardRectangle.width - width - minMargin,
                                    targetRect.x - width / 2 + targetRect.width / 2)))
    y: Math.round(targetRect.y - keyGrid.height + targetKeyVerticalOffset)

    onKeysChanged: {
        if (keys) {
            // Use two rows when more than 5 keys
            if (keys.length > 5) {
                keyGrid.columns = Math.round(keys.length / 2);
            } else {
                keyGrid.columns = keys.length;
            }
        }
    }

    Timer {
        id: hideTimer
        interval: autoHideTimeout
        repeat: false
        running: false
        onTriggered: root.visible = false
    }

    // Draw a basic white non-antialiased
    // triangle pointing down to the target key
    Canvas {
        id: arrow

        parent: root.virtualKeyboard
        width: arrowSize
        height: arrowSize / 2
        antialiasing: false
        visible: root.visible

        x: targetRect.x + targetRect.width / 2 - width/2
        y: root.y + root.height

        onPaint: {
            var ctx = getContext("2d");
            ctx.fillStyle = "white";
            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width / 2, height);
            ctx.fill();
        }
    }

    Grid {
        id: keyGrid

        Repeater {
            id: keyRepeater

            MouseArea {
                id: keyButton

                width: keySize
                height: keySize

                readonly property string text: modelData

                Rectangle {
                    anchors.fill: parent
                    color: "white"
                    visible: keyButton.pressed
                }

                Text {
                    id: symbol
                    antialiasing: false
                    anchors.centerIn: parent
                    font.pixelSize: root.fontSize
                    color: keyButton.pressed ? "black" : "white"
                    text: keyButton.text
                }

                onReleased: {
                    keySelected(symbol.text);
                    root.visible = false;
                }
            }
        }
    }

    // Border outline
    Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        color: "transparent"
        border.width: 3
        border.color: "white"
    }
}
