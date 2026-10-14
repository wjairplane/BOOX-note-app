import QtQuick
import com.remarkable
import common

import ark.controls as ArkControls

Item {
    property Entry entry
    property color color: Values.colorBlack
    property int entryStatus: entry ? entry.status : Entry.Unknown
    property bool active: entryStatus === Entry.Uploading || entryStatus === Entry.Downloading || entryStatus === Entry.Exporting || statusTimeout.running || iconOverride
    property alias size: icon.size
    property alias iconSource: icon.source
    property int clickMargin: width
    property alias hoverEnabled: mouseArea.hoverEnabled
    property alias containsMouse: mouseArea.containsMouse
    property bool canceledExport: false
    property string iconOverride

    implicitWidth: Values.iconSizeMedium
    implicitHeight: Values.iconSizeMedium

    visible: active

    Timer {
        property int oldStatus: Entry.Ok
        property int currentStatus: entryStatus
        id: statusTimeout
        interval: 1000
        repeat: false
        onCurrentStatusChanged: {
            if ((currentStatus === Entry.Ok || currentStatus === Entry.SyncError) && (oldStatus === Entry.Uploading || oldStatus === Entry.Downloading || oldStatus === Entry.Exporting)) {
                running = true;
            }

            if (((currentStatus === Entry.Exporting) && (oldStatus === Entry.Uploading)) || ((currentStatus === Entry.Uploading) && (oldStatus === Entry.Exporting))) {
                running = true;
            }

            //this means we have a new export and should reset cancel flag
            if ((currentStatus === Entry.Exporting) && (oldStatus !== Entry.Exporting)) {
                canceledExport = false;
            }

            oldStatus = currentStatus;
        }
    }

    ArkControls.Icon {
        id: icon
        anchors.centerIn: parent
        color: parent.color
        size: Values.iconSizeMedium
        visible: !!source
        source: {
            // if user logs out after a sync error, we should not show
            if (!Authentication.loggedIn) {
                return "";
            }

            if (iconOverride) {
                return iconOverride;
            }

            switch (entryStatus) {
            case Entry.Ok:
                //if we canceled an export we should not show check mark
                if (!canceledExport) {
                    return statusTimeout.running ? "qrc:/ark/icons/checkmark" : "";
                } else {
                    return ""
                }
            case Entry.Exporting:
                return statusTimeout.running ? "" : "qrc:/ark/icons/x_small";
            case Entry.Uploading:
                return statusTimeout.running ? "" : "qrc:/ark/icons/cloud_upload";
            case Entry.Downloading:
                return "qrc:/ark/icons/cloud_download";
            case Entry.SyncError:
                return "qrc:/ark/icons/cloud_x";
            }
            return "";
        }
    }

    MouseArea {
        id: mouseArea
        enabled: entry ? entry.isExporting : false
        anchors.fill: parent
        anchors.margins: -clickMargin
        onClicked: {
            entry.abortExport();
            canceledExport = true;
        }
    }
}
