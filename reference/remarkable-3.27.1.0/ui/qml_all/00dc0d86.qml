import QtQuick
import com.remarkable
import common

Item {
    property Entry entry
    property color color: selected ? Values.colorWhite : Values.colorBlack
    property double progress: {
        switch (entry.status) {
        case Entry.Exporting:
            return entry.exportProgress;
        case Entry.Uploading:
        case Entry.Downloading:
            return entry.syncProgress;
        }
        return 0;
    }
    height: progressBar.height

    Rectangle {
        id: progressBar
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        width: parent.width * progress
        height: Values.outlineSize * 3
        color: parent.color
    }
}
