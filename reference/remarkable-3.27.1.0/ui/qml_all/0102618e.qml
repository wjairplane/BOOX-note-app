import QtQuick
import QtQuick.Layouts

import com.remarkable
import common
import device.ui.controls

import xofm.libs.qtgui
import xofm.modules.systemclock

import ark.tokens as ArkTokens
import ark.controls as ArkControls

BaseView {
    id: root

    required property SystemClockWrapper clock

    onOpened: clock.update()

    property date _date: clock.datetime // used to reevaluate datetime when it has changed

    on_DateChanged: datePanel.label = clock.toString();

    contentItem: Background {

        ArkControls.NavigationBar {
            id: navigationBar
            type: ArkTokens.NavigationBar.secondary
            width: parent.width
            anchors.left: parent.left

            ArkControls.NavigationBar.Button {
                id: back
                text: qsTr("Back")
                textPosition: ArkControls.Button.TextPosition.Right
                iconSource: "qrc:/ark/icons/chevron_left"
                onClicked: root.windowNavigator.close()
            }
        }

        ColumnLayout {
            id: mainColumn
            anchors {
                top: navigationBar.bottom
                left: parent.left
                leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
                right: parent.right
                rightMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
            }
            spacing: ArkControls.Values.platform.spacing.x2large

            ArkControls.Title {
                text: qsTr("System time")
                type: ArkControls.Title.Large
            }

            ArkControls.Panel {
                id: datePanel
                Layout.fillWidth: true
                label: clock.toString()
                iconSource: "qrc:/ark/icons/system_clock"
                width: parent.width
                action: ArkControls.Button {
                    type: ArkTokens.Button.secondary
                    text: qsTr("Set date and time")
                    onClicked: root.windowNavigator.open("systemclock/window/date-time-picker");
                }
            }

            ArkControls.InfoMessage {
                type: ArkTokens.InfoMessage.secondary
                Layout.fillWidth: true
                title: qsTr("Sync and updating issues")
                message:  qsTr("To update software and sync with the cloud, make sure that system date and time is set correctly to Coordinated Universal Time (UTC).");
                iconSource: "qrc:/ark/icons/information_circle"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: ArkControls.Values.spacing.large

                ArkControls.Body {
                    Layout.fillWidth: true
                    type: ArkControls.Body.Medium
                    wrapMode: Text.WordWrap
                    text: qsTr("Scan the QR-code to <b>https://support.remarkable.com</b> for more information")
                }

                // A container item is necessary for the Image to scale properly.
                Item {
                    Layout.preferredHeight: 300
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignLeft

                    QRCodeProvider {
                        id: provider
                        text: "https://support.remarkable.com/s/article/Unable-to-update-reMarkable-Paper-Tablet"
                    }

                    Image {
                        id: qrcode
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: provider.imageUrl
                    }
                }
            }
        }
    }
}
