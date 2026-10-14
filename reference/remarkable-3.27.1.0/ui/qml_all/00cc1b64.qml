import QtQuick
import QtQuick.Layouts
import com.remarkable
import common
import device.ui.text
import device.ui.controls

import ark.tokens as ArkTokens
import ark.controls as ArkControls

Background {
    id: root
    color: Values.colorBlack

    property string headerText: qsTr("Unable to open")
    property string infoText: qsTr("This document contains data that is not supported.")
    height: column.height + (ArkControls.Values.spacing.xlarge * 2)

    signal closeClicked

    ColumnLayout {
        id: column
        anchors.top: parent.top
        anchors.topMargin: ArkControls.Values.spacing.xlarge
        anchors.left: parent.left
        anchors.leftMargin: ArkControls.Values.margin.horizontal.xlarge
        anchors.right: parent.right
        anchors.rightMargin: ArkControls.Values.margin.horizontal.xlarge
        spacing: ArkControls.Values.spacing.large

        ArkControls.Title {
            id: header
            type: ArkControls.Title.Large
            color: Values.colorWhite
            text: headerText

            ArkControls.Icon {
                id: infoIcon
                anchors.right: parent.left
                anchors.rightMargin: 30
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/ark/icons/information_circle"
                color: Values.colorWhite
                size: 32
            }
        }

        ArkControls.Label {
            id: info
            type: ArkControls.Label.Medium
            text: infoText
            color: Values.colorWhite
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        ArkControls.Button {
            id: cancelButton
            type: ArkTokens.Button.secondary_inverted
            text: qsTr("Close")
            onClicked: closeClicked()
            Layout.minimumWidth: parent.width / 2
            Layout.topMargin: ArkControls.Values.spacing.large
        }
    }
}
