import QtQuick
import QtQuick.Layouts

import com.remarkable
import common
import device.ui.controls
import device.ui.text

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.qtgui
import xofm.libs.batterymanager

ArkControls.Panel {
    id: root
    required property WindowNavigator windowNavigator
    required property var currentVersion
    required property var updater
    required property ShutdownCommand shutdownCommand
    required property bool updateEnabled

    label: qsTr("Version %1").arg(currentVersion)
    iconSource: "qrc:/ark/icons/software_version"

    descriptionItem: Item {
        ArkControls.Label {
            id: releaseNotesText
            type: ArkControls.Label.Type.SmallSubtle
            text: qsTr("Release notes")
            font.underline: true

            MouseArea {
                anchors.fill: parent
                anchors.margins: -20
                onClicked: {
                    windowNavigator.open("releasenotes/window/releasenotes");
                }
            }
        }
        implicitHeight: releaseNotesText.implicitHeight + 16
    }

    action: ArkControls.Button {
        type: ArkTokens.Button.secondary
        text: qsTr("Check for updates")
        visible: root.updateEnabled
        width: visible ? implicitWidth : 0
        onClicked: {
            root.showAttachment = true;
            if(LinkProvider.isOnline) {
                updater.update();
            }
        }
    }

    attachment: UpdateProgress {
        updater: root.updater
        shutdownCommand: root.shutdownCommand
        onClose: {
            root.showAttachment = false;
        }
    }
}
