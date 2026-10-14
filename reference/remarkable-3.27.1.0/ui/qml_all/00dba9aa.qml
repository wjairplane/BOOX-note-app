import QtQuick

import com.remarkable

Item {
    id: root

    property int interval: 500

    property bool penCloseOverride: false // for testing
    readonly property bool penClose: penCloseOverride ? penCloseOverride : DeviceApp.penClose
    onPenCloseChanged: {
        if (!root.penClose) {
            root._restarting = true;
            closeTimer.stop();
            closeTimer.start();
            root._restarting = false;
        }
    }

    property bool _restarting

    readonly property bool penWasClose: {
        if (root.penClose) {
            return true;
        }

        if (root._restarting) {
            return true;
        }

        return closeTimer.running;
    }

    Timer {
        id: closeTimer
        running: false
        repeat: false
        interval: root.interval
    }
}
