import QtQuick
import common
import com.remarkable

import ark.controls as ArkControls

Item {
    id: root

    property bool noBackground: false
    property alias backgroundColor: visualRoot.color

    width: Values.loadingIndicatorSize
    height: Values.loadingIndicatorSize

    onVisibleChanged: {
        if (visible) {
            showSoon();
        } else {
            hide();
        }
    }

    Timer {
        id: delayedShowTimer
        interval: 500
        repeat: false
        onTriggered: show()
    }

    function showSoon() {
        delayedShowTimer.start();
        visualRoot.visible = false;
    }

    function show() {
        dots.step = 2;
        tickTimer.start();
        visualRoot.visible = true;
    }

    function hide() {
        delayedShowTimer.stop();
        tickTimer.stop();
        visualRoot.visible = false;
    }

    Rectangle {
        id: visualRoot
        width: parent.width
        height: parent.height
        color: root.noBackground ? "transparent" : Values.colorBlack
        antialiasing: root.antialiasing

        ArkControls.Icon {
            anchors.centerIn: parent
            source: "qrc:/ark/icons/three_dots_horisontal"
            size: parent.width / 3
            color: noBackground ? Values.colorBlack : Values.colorWhite
            antialiasing: root.antialiasing
        }

        Rectangle {
            id: dots

            property int step: 0

            width: (parent.width / 9) * step
            height: (parent.height / 3)
            anchors.top: parent.top
            anchors.topMargin: parent.height / 3
            anchors.right: parent.right
            anchors.rightMargin: parent.width / 3
            color: noBackground ? Values.colorWhite : Values.colorBlack
            antialiasing: root.antialiasing
        }

        Timer {
            id: tickTimer
            interval: 2000
            repeat: true
            onTriggered: {
                if (dots.step <= 0) {
                    dots.step = 2;
                } else {
                    dots.step--;
                }
            }
        }
    }
}
