import xofm.libs.qtgui
import xofm.libs.batterymanager
import xofm.libs.dialogs

BaseView {
    id: root

    property bool reboot: false
    required property ShutdownCommand shutdownCommand
    required property var insecureSettings

    onOpened: (config) => {
        root.reboot = !!config.reboot;
    }

    contentItem: DialogScreen {
        gobackButton: false
        iconSource: root.reboot ? "qrc:/ark/icons/restore" : "qrc:/ark/icons/power"
        accidentalTouchPrevention: insecureSettings.setup
        text: root.reboot
            ? qsTr("Do you want to restart your reMarkable?", "Dialog: restart title")
            : qsTr("Do you want to turn off your reMarkable?", "Dialog: turn off title")
        buttons: {
            const rebootDescription = {
                text: qsTr("Restart"),
                highlight: true,
                action: function() {
                    shutdownCommand.execute(ShutdownCommand.Reason.Reboot, "Reboot button clicked");
                }
            };
            const poweroffDescription = {
                text: qsTr("Turn off"),
                highlight: true,
                action: function() {
                    shutdownCommand.execute(ShutdownCommand.Reason.Poweroff, "Turn off button clicked");
                }
            };
            const factoryResetDescription = {
                text: qsTr("Factory reset"),
                highlight: true,
                action: function() {
                    shutdownCommand.execute(ShutdownCommand.Reason.FactoryReset, "Factory reset button clicked during setup");
                }
            };
            const cancelDescription = {
                text: qsTr("Cancel"),
                highlight: false,
                action: function() {
                    root.windowNavigator.close();
                }
            };

            if(insecureSettings.setup) {
                return [cancelDescription, factoryResetDescription];
            }
            if(root.reboot) {
                return [cancelDescription, rebootDescription];
            }
            return [cancelDescription, poweroffDescription];
        }
    }
}
