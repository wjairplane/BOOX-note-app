import QtQuick
import QtQuick.Layouts
import common
import device.global
import device.ui.text

import ark.controls as ArkControls

ButtonBase {
    id: root
    property alias text: buttonText.text
    property string section // Section of dropdown this button belongs to
    property alias iconSource: arkIcon.source
    property bool iconOnly: false
    property bool reserveSpace: true // Reserve space for the icon even when not visible
    property bool beta: false

    width: parent.width
    height: Values.navigatorDropdownButtonHeight

    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
    }

    Row {
        id: row
        objectName: "dropdownButtonRow"
        spacing: iconOnly ? 0 : 16
        leftPadding: iconOnly ? (row.width - arkIcon.width) / 2 : 20
        anchors.fill: parent

        ArkControls.Icon {
            id: arkIcon
            objectName: "dropdownButtonIcon"
            visible: root.reserveSpace
            anchors.verticalCenter: parent.verticalCenter
            size: ArkControls.Values.iconSize.medium
            color: root.foregroundColor
            antialiasing: root.antialiasing
        }

        ColumnLayout {
            objectName: "labelContainer"
            visible: !iconOnly
            width: parent.width - arkIcon.implicitWidth - row.leftPadding - row.spacing
            height: parent.height - 8 // Figma specifies 2*14, but doing so, due to Values.navigatorDropdownButtonHeight, would lead to an overlay of BETA and Label
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Rectangle {
                objectName: "betaLabel"
                Layout.preferredWidth: betaLabel.implicitWidth + (2 * 10)
                Layout.preferredHeight: buttonText.implicitHeight
                color: "transparent"
                border {
                    width: 2
                    color: root.foregroundColor
                }
                visible: beta
                radius: height / 2

                ArkControls.Label {
                    id: betaLabel
                    type: ArkControls.Label.SmallSubtle
                    color: root.foregroundColor
                    text: qsTr("BETA")
                    anchors.centerIn: parent
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                visible: beta
            }
            ArkControls.Label {
                id: buttonText
                objectName: "buttonText"
                type: ArkControls.Label.Medium
                color: root.foregroundColor
            }
        }
    }
}
