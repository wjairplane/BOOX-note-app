import QtQuick
import com.remarkable
import common

import xofm.libs.explorer // EntityListModel

import ark.controls as ArkControls

ArkControls.Icon {
    id: syncStatusIcon

    property bool canceledExport: false
    property var syncStatus

    readonly property bool isExporting: syncStatus === EntityListModel.Status.Exporting
    readonly property bool syncError: syncStatus === EntityListModel.Status.SyncError

    signal retrySync
    signal abortExport

    size: ArkControls.Values.iconSize.small
    width: size * 1.5
    height: size * 1.5
    source: {
        // if user logs out after a sync error, we should not show anything
        if (!Authentication.loggedIn) {
            return "";
        }

        switch (syncStatus) {
        case EntityListModel.Status.Idle:
        case EntityListModel.Status.Uploading:
        case EntityListModel.Status.Downloading:
            return "";
        case EntityListModel.Status.Complete:
            return "qrc:/ark/icons/checkmark";
        case EntityListModel.Status.Exporting:
            return "qrc:/ark/icons/x_small";
        case EntityListModel.Status.DocumentError:
            return "qrc:/ark/icons/warning_circle";
        case EntityListModel.Status.SyncError:
            return "qrc:/ark/icons/cloud_x";
        default:
            return "";
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: isExporting || syncError
        onClicked: {
            if (isExporting) {
                syncStatusIcon.abortExport();
            }

            if (syncError) {
                syncStatusIcon.retrySync();
            }
        }
    }
}
