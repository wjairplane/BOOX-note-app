import QtQuick

import com.remarkable
import common
import device.ui.text
import device.ui.controls

import ark.controls as ArkControls

Rectangle {
    visible: SystemMonitor.partitionMountFailed
    color: Values.colorBlack

    MouseArea {
        anchors.fill: parent
    }

    ArkControls.Title {
        type: ArkControls.Title.Large
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 150
        }

        text: qsTr("Disk corrupted")
        color: Values.colorWhite
    }

    ArkControls.Icon {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: - parent.height / 4
        size: 90
        color: "white"
        source: "qrc:/ark/icons/x_medium"
    }

    Rectangle {
        visible: SystemMonitor.canRepair
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.verticalCenter
            topMargin: Values.navigatorMargin
        }
        height: 150
        width: 500

        color: Values.colorBlack
        border.color: Values.colorWhite
        border.width: Values.outlineSize

        TextHeaderRegular {
            id: repairButtonText
            anchors.centerIn: parent
            text: qsTr("Tap to attempt\nautomatic repair and restart")
            color: Values.colorWhite
            font.bold: false
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                enabled = false;
                repairButtonText.text = "Working...";
                repairButtonText.color = Values.colorBlack;
                parent.visible = false;
                busyIndicator.visible = true;

                SystemMonitor.runFsck();
            }
        }
    }

    TextHeaderRegular {
        visible: busyIndicator.visible
        anchors {
            horizontalCenter: busyIndicator.horizontalCenter
            bottom: busyIndicator.top
        }

        text: qsTr("Attempting repair...")
        color: Values.colorWhite
        font.bold: false
        horizontalAlignment: Text.AlignHCenter
    }

    Loading {
        id: busyIndicator
        visible: false
        anchors.centerIn: parent
    }
}
