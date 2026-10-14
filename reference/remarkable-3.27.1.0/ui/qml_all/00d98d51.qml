import QtQuick
import QtQuick.Layouts

import com.remarkable
import common

import device.ui.text
import device.ui.controls

import xofm.libs.qtgui
import xofm.modules.settings

import ark.controls as ArkControls
import ark.tokens as ArkTokens

DeviceKeyboardNavigationHandler {
    id: root
    objectName: "Battery"

    required property WindowNavigator windowNavigator
    required property AutosleepDelayDevicePolicy autosleepDelayDevicePolicy
    property bool showheader: true
    property bool fullscreen: false

    signal close

    navigationModel: []
    firstNavigationIndex: 1

    onActivated: (element) => {
        if (element) {
            element.clicked();
        }
    }
    function buildSleepIntervalModel(maximumInterval) {
        let model = [
            { text: qsTr("5 minutes"), timeout: 5 * 60 * 1000 },
            { text: qsTr("20 minutes"), timeout: 20 * 60 * 1000 },
            { text: qsTr("1 hour"), timeout: 60 * 60 * 1000 },
        ];
        let maximumMS = maximumInterval * 60 * 1000;
        if (maximumMS) {
            // MDM will not limit the user setting a shorter interval
            // than the enforced one.
            model = model.filter(item => item.timeout <= maximumMS);
        }
        return model;
    }

    Background {
        anchors.fill: parent
    }

    ArkControls.NavigationBar {
        id: navigationBar
        type: ArkTokens.NavigationBar.secondary
        width: parent.width

        ArkControls.NavigationBar.Button {
            id: back
            text: qsTr("Back")
            textPosition: ArkControls.Button.TextPosition.Right
            iconSource: "qrc:/ark/icons/chevron_left"
            onClicked: root.close()
            Component.onCompleted: navigationModel[0] = back
            showFocus: root.current === back
        }
    }

    ArkControls.Title {
        id: header
        type: ArkControls.Title.Large
        anchors {
            top: navigationBar.bottom
            left: parent.left
            leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
        }
        //: Title of Battery settings page
        text: qsTr("Battery")
    }

    ColumnLayout {
        id: column
        anchors {
            top: header.bottom
            topMargin: ArkControls.Values.platform.spacing.x2large
            left: parent.left
            leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
            right: parent.right
            rightMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
        }
        spacing: ArkControls.Values.platform.spacing.x2large

        ArkControls.Panel {
            id: autoSleep_CheckBox

            function activate() {
                if (Settings.idleSuspendDelay === 0) {
                    Settings.idleSuspendDelay = Settings.defaultValue(Settings.IdleSuspendDelay);
                } else {
                    Settings.idleSuspendDelay = 0;
                    Settings.powerOffDelay = Settings.defaultValue(Settings.SuspendPowerOffDelay);
                }
            }

            //: Name of toggle in Battery settings
            label: qsTr("Standby")
            description: RetailDemo.enabled ? Strings.notAvailableInRetailString : qsTr("Choose a time interval before your display turns off.")
            Layout.fillWidth: true
            action: ArkToggleWrapper {
                id: toggle3
                visible: !RetailDemo.enabled && autosleepDelayDevicePolicy.maximumValue === 0
                checked: Settings.idleSuspendDelay !== 0
                showFocus: root.current === toggle3
                extendedMouseArea.onPressed: autoSleep_CheckBox.activate()
                Component.onCompleted: root.navigationModel[1] = toggle3
            }

            showAttachment: Settings.idleSuspendDelay !== 0
            attachment: ArkControls.ContextualMenu {
                uniformSize: true
                Repeater {
                    model: root.buildSleepIntervalModel(autosleepDelayDevicePolicy.maximumValue)
                    delegate: ArkControls.ContextualMenu.Button {
                        required property var modelData

                        text: modelData.text
                        selected: Settings.idleSuspendDelay === modelData.timeout
                        onClicked: Settings.idleSuspendDelay = modelData.timeout
                    }
                }
            }
        }

        ArkControls.Panel {
            id: autoPowerOff_CheckBox

            function activate() {
                if (Settings.powerOffDelay === 0) {
                    Settings.powerOffDelay = Settings.defaultValue(Settings.SuspendPowerOffDelay);
                } else {
                    Settings.powerOffDelay = 0;
                }
            }

            //: Name of toggle in Battery settings
            label: qsTr("Power off")
            description: {
                if (RetailDemo.enabled) {
                    return Strings.notAvailableInRetailString;
                }
                return BatteryManager.infiniteSleep ? qsTr("Make your device turn off after 12 hours of inactivity.")
                                                    : qsTr("Let your paper tablet power off when it's inactive for 12 hours.")
            }
            Layout.fillWidth: true
            visible: Settings.powerOffDelaySet

            action: ArkToggleWrapper {
                id: toggle4
                enabled: !RetailDemo.enabled
                checked: Settings.powerOffDelay !== 0
                showFocus: root.current === toggle4
                extendedMouseArea.onPressed: autoPowerOff_CheckBox.activate()
                Component.onCompleted: root.navigationModel[2] = toggle4
            }
        }
    }


}
