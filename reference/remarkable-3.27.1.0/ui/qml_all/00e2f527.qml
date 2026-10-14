import QtQuick
import com.remarkable
import common

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.setup
import xofm.modules.softwareupdate
import xofm.libs.batterymanager

SetupBasePage {
    id: root
    required property var updater
    required property var currentVersion
    required property ShutdownCommand shutdownCommand
    property int wifiStabilizationDelay: 5000
    property alias wifiStabilizationRunning: wifiStabilization.running // test purpose

    property string highlightOrange: ""
    property string highlightClose: ""

    property string defaultTitle: qsTr("Installing update")
    //: If two sentence structure is re-used in translation, then non breaking spaces shall be placed between the last
    //: 2-3 words of the first sentence and the first 2-3 (as well as last) words of the second sentence, depending on
    //: the lengths of the words. This is done as a visual text formatting improvement.
    property string defaultDescription: qsTr("We're installing the latest features and&#160;improvements. This&#160;could&#160;take a&#160;few&#160;minutes.")
    property string upToDateTitle: qsTr("Latest software %1installed%2", "words between %1 and %2 will be highlighted").arg(highlightOrange).arg(highlightClose)
    property string upToDateDescription: qsTr("Your paper tablet is on version %1").arg(currentVersion)
    property string errorTitle: qsTr("Something %1went wrong%2", "words between %1 and %2 will be highlighted").arg(highlightOrange).arg(highlightClose)

    property bool softwareUpdated: false

    readonly property string settingsGroup: "SoftwareUpdateSetup"
    readonly property string settingsUpdatedKey: "Updated"

    pageReady: LinkProvider.isOnline
    showSkipButton: false
    stateName: "SoftwareUpdate"

    signal restartDevice()

    onRestartDevice: {
        shutdownCommand.execute(ShutdownCommand.Reason.Reboot, "Updated software");
    }

    onVisibleChanged: {
        if (!visible) { return; }

        const val = Settings.rawValue(settingsGroup, settingsUpdatedKey);
        const updated = val === undefined ? false : val;

        if (updated) {
            // This means we have just rebooted after an update. Make sure to reset the Setting.
            Settings.setRawValue(settingsGroup, settingsUpdatedKey, false);
            softwareUpdated = true;
            return;
        }

        if (updater.state !== Updater.UpdateState.Updating ||
            updater.state !== Updater.UpdateState.Updated) {
            // this timeout gives more time to the wifi connection to get established before the software update
            wifiStabilization.start();
        }
    }
    states: [
        State {
            name: "error"
            when: updater.state === Updater.UpdateState.Error
            PropertyChanges {
                target: page
                title: root.errorTitle
                description: qsTr("We were unable to update your device. Please try again. If this issue persists, please contact us at support.remarkable.com.")
                primaryButtonText: qsTr("Try again")
                onPrimaryClicked: updater.update()
            }
            PropertyChanges {
                target: root
                showSkipButton: true
            }
            PropertyChanges {
                target: image
                source: Values.isPortraitOrientation ? "qrc:setup/qml/images/error_portrait.png" : "qrc:setup/qml/images/error_landscape.png"
            }
        },
        State {
            name: "stabilization"
            when: (updater.state === Updater.UpdateState.NoUpdatesAvailable) && wifiStabilization.running
            PropertyChanges {
                target: page
                title: root.defaultTitle
                description: root.defaultDescription
                primaryOption: false
            }
            PropertyChanges {
                target: image
                source: Values.isPortraitOrientation ? "qrc:softwareupdate/qml/images/update_portrait.png" : "qrc:softwareupdate/qml/images/update_landscape.png"
            }
            PropertyChanges {
                target: progressBar
                visible: true
            }
        },
        State {
            name: "updating"
            when: updater.state === Updater.UpdateState.Updating
            PropertyChanges {
                target: page
                title: root.defaultTitle
                description: root.defaultDescription
                primaryOption: false
            }
            PropertyChanges {
                target: image
                source: Values.isPortraitOrientation ? "qrc:softwareupdate/qml/images/update_portrait.png" : "qrc:softwareupdate/qml/images/update_landscape.png"
            }
            PropertyChanges {
                target: progressBar
                visible: true
            }

            // Show the Skip button if there is one minute of inactivity from the updater at any
            // time during the "updating" state.
            PropertyChanges {
                target: root
                showSkipButton: !updateTimeout.running
            }
            PropertyChanges {
                target: updateTimeout
                interval: 120000
                running: true
            }
            PropertyChanges {
                target: updateProgressMonitor
                enabled: true
            }
        },
        State {
            name: "updated"
            when: updater.state === Updater.UpdateState.Updated
            StateChangeScript {
                script: {
                    Settings.setRawValue(settingsGroup, settingsUpdatedKey, true);
                    root.restartDevice();
                }
            }
        },
        State {
            name: "noUpdatesAvailable"
            when: updater.state === Updater.UpdateState.NoUpdatesAvailable || root.softwareUpdated
            PropertyChanges {
                target: page
                title: root.upToDateTitle
                description: root.upToDateDescription
                primaryButtonText: qsTr("Next")
                onPrimaryClicked: root.forward()
            }
            PropertyChanges {
                target: image
                source: Values.isPortraitOrientation ? "qrc:softwareupdate/qml/images/update_portrait.png" : "qrc:softwareupdate/qml/images/update_landscape.png"
            }
            PropertyChanges {
                target: root
                softwareUpdated: false
            }
        }
    ]

    Timer {
        id: updateTimeout
        objectName: "updateTimeout"
    }

    SlumberInhibit {
        id: documentViewSlumberInhibit
        powerState: PowerState
        name: "xochitl.setup.softwareupdate"
        canSuspend: !wifiStabilization.running
    }

    Timer {
        id: wifiStabilization
        interval: root.wifiStabilizationDelay
        repeat: false
        onTriggered: {
            updater.update();
        }
    }

    Connections {
        id: updateProgressMonitor

        target: root.updater
        enabled: false

        function onProgressChanged() {
            updateTimeout.restart();
        }
    }

    ArkControls.SetupPage {
        id: page
        objectName: "page"
        anchors.fill: parent
    }

    Item {
        id: progressBar
        objectName: "progressBar"
        anchors {
            bottom: parent.bottom
            bottomMargin: page.contentPosition.bottomMargin
            horizontalCenter: parent.horizontalCenter
        }
        width: 360
        height: 22
        visible: false

        Rectangle {
            // the minimum progress value to be displayed is 0.02
            width: Math.round(parent.width * Math.max(0.02, updater.progress))
            height: parent.height
            color: Values.colorBlack
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: Values.outlineSize
            color: Values.colorBlack
        }
    }

    Image {
        id: image
        anchors.centerIn: parent
    }
}
