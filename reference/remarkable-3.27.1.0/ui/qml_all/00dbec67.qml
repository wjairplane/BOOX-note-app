import QtQuick
import com.remarkable
import common

import ark.controls as ArkControls

Rectangle {
    property Entry entry
    property bool selected
    property int size: Values.iconSizeMedium
    readonly property bool active: entryStatus === Entry.SyncError || entryStatus === Entry.DocumentError
    readonly property int entryStatus: entry ? entry.status : Entry.Unknown
    width: size * 1.5
    height: size * 1.5
    radius: width / 2
    color: selected ? Values.colorBlack : Values.colorWhite

    ArkControls.Icon {
        size: parent.size
        anchors.centerIn: parent
        visible: !!source
        color: selected ? Values.colorWhite : Values.colorBlack
        source: {
            // if user logs out after a sync error, we should not show
            if (!Authentication.loggedIn) {
                return "";
            }

            switch (entryStatus) {
            case Entry.SyncError:
                return "qrc:/ark/icons/cloud_x";
            case Entry.DocumentError:
                return "qrc:/ark/icons/warning_circle";
            }
            return "";
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: entryStatus === Entry.SyncError
        onClicked: {
            entry.handleSyncError(Entry.Retry);
        }
    }
}
