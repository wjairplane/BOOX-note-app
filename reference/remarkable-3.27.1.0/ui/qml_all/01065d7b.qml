import QtQuick
import QtQuick.Layouts

import com.remarkable
import device.ui.controls

import xofm.libs.settings
import xofm.libs.qtgui
import xofm.libs.controls

import ark.tokens as ArkTokens
import ark.controls as ArkControls

BaseView {
    id: root

    required property var keyboardInfo

    contentItem: DeviceKeyboardNavigationHandler {
        id: navRoot
        navigationModel: []
        firstNavigationIndex: 1

        InputBlocker {
            anchors.fill: parent
        }

        onActivated: (element) => {
            if (element) {
                element.clicked();
            }
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
                onClicked: root.windowNavigator.close()
                Component.onCompleted: navRoot.navigationModel[0] = back
                showFocus: navRoot.current === back
            }
        }

        ArkControls.Title {
            id: header
            type: ArkControls.Title.Large
            anchors.top: navigationBar.bottom
            anchors.left: parent.left
            anchors.leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
            text: qsTr("Keyboard")
        }

        ColumnLayout {
            id: column
            spacing: 0
            anchors {
                top: header.bottom
                topMargin: ArkControls.Values.spacing.xlarge
                left: parent.left
                leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
                right: parent.right
                rightMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
            }

            ArkControls.Cell {
                title: qsTr("Specifications")
                Layout.fillWidth: true
                ArkControls.CellItem {
                    text: qsTr("Serial number")
                    status: keyboardInfo.serialNumber
                    iconSource: ""
                }
                ArkControls.CellItem {
                    text: qsTr("Firmware")
                    status: qsTr("Version: %1").arg(keyboardInfo.seabirdFirmware)
                    iconSource: ""
                }
            }

            ArkControls.Panel {
                Layout.fillWidth: true
                Layout.topMargin: ArkControls.Values.spacing.xlarge
                label: qsTr("Shortcuts")
                description: qsTr("Choose your preferred style of key combinations.", "Settings for preferred keyboard setup, Mac or PC.")
                showAttachment: true
                attachment: RowLayout {
                    id: radioButtons
                    spacing: ArkControls.Values.spacing.large
                    Layout.fillWidth: true

                    ArkControls.Selector {
                        id: selector1
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("PC")
                        objectName: "pcSettingsSelector"
                        illustration: "qrc:/settings/illustrations/keyboard_flavour_windows"
                        checked: Settings.inputFlavor === Settings.InputFlavorType.Windows;
                        onClicked: Settings.inputFlavor = Settings.InputFlavorType.Windows;
                        Component.onCompleted: navRoot.navigationModel[1] = selector1
                        showFocus: navRoot.current === selector1
                    }

                    ArkControls.Selector {
                        id: selector2
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Mac")
                        objectName: "macSettingsSelector"
                        illustration: "qrc:/settings/illustrations/keyboard_flavour_mac"
                        checked: Settings.inputFlavor === Settings.InputFlavorType.Apple;
                        onClicked: Settings.inputFlavor = Settings.InputFlavorType.Apple;
                        Component.onCompleted: navRoot.navigationModel[2] = selector2
                        showFocus: navRoot.current === selector2
                    }
                }
            }

            ArkControls.InfoMessage {
                type: ArkTokens.InfoMessage.secondary
                Layout.fillWidth: true
                Layout.topMargin: ArkControls.Values.spacing.large
                message: qsTr("The shortcuts menu will open when you press and hold <b>%1</b> for <b>3&nbsp;seconds</b>.", "Explaining how to reach cheat sheet.").arg(Settings.inputFlavor === Settings.InputFlavorType.Apple ? "alt" : "ctrl")
                iconSource: "qrc:/ark/icons/information_circle"
            }
        }
    }
}
