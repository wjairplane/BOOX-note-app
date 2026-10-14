import QtQuick

import com.remarkable
import common
import device.ui.controls
import device.ui.text

import xofm.libs.batterymanager
import xofm.modules.softwareupdate

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ArkControls.InfoMessage {
    id: root

    signal close
    required property Updater updater
    required property ShutdownCommand shutdownCommand

    showProgress: updater.state == Updater.UpdateState.Updating
    progress: updater.progress
    iconSource: "qrc:/ark/icons/checkmark"

    states: [
        State {
            name: "nowifi"
            when: !LinkProvider.isOnline && updater.state === Updater.UpdateState.NoUpdatesAvailable
            PropertyChanges {
                target: root
                message: qsTr("Please connect to Wi-Fi to update.")
                iconSource: "qrc:/ark/icons/wifi_x"
            }
            PropertyChanges {
                target: closeTimer
                running: true
            }
        },
        State {
            name: "noupdates"
            when: updater.state === Updater.UpdateState.NoUpdatesAvailable && LinkProvider.isOnline
            PropertyChanges {
                target: root
                message: qsTr("Your device is up to date.")
                iconSource: "qrc:/ark/icons/checkmark"
            }
            PropertyChanges {
                target: closeTimer
                running: true
            }
        },
        State {
            name: "error"
            when: updater.state === Updater.UpdateState.Error
            PropertyChanges {
                target: root
                message: updater.error
                iconSource: "qrc:/ark/icons/warning_circle"
            }
            PropertyChanges {
                target: closeTimer
                running: true
            }
        },
        State {
            name: "updating"
            when: updater.state === Updater.UpdateState.Updating
            PropertyChanges {
                target: root
                message: updater.status
                iconSource: "qrc:/ark/icons/cloud_download"
            }
        },
        State {
            name: "updated"
            when: updater.state == Updater.UpdateState.Updated
            PropertyChanges {
                target: root
                message: qsTr("Tap to restart and update to version %1 of your reMarkable.").arg(updater.newVersion);
                iconSource:  "qrc:/ark/icons/restore"
            }
        }
    ]

    Timer {
        id: closeTimer
        interval: 10000
        running: false
        repeat: false
        onTriggered: root.close()
    }

    onClicked: {
        if (updater.state == Updater.UpdateState.Updated) {
            shutdownCommand.execute(ShutdownCommand.Reason.Reboot, "Updated software");
        }
    }
}
