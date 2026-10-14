import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ark.tokens as ArkTokens
import ark.controls as ArkControls

import xofm.libs.controls
import xofm.libs.wifi
import xofm.modules.wifi

Column {
    id: root

    required property string ssid
    required property bool selected
    required property bool configured
    required property string signalIcon
    required property int security

    QtObject {
        id: detail

        property bool open: security === WifiTypes.Security.Open
    }

    property bool showButtons: false
    property bool simplifiedButtons: false

    signal clicked
    signal forget
    signal edit
    signal connect
    signal disconnect

    ArkControls.CellItem {
        width: parent.width
        text: ssid
        topPadding: ArkControls.Values.spacing.xsmall
        bottomPadding: ArkControls.Values.spacing.xsmall

        iconsList: [
            detail.open ? "" : "qrc:/ark/icons/padlock",
            root.signalIcon
        ]
        onClicked: root.clicked()
    }

    Loader {
        active: root.showButtons
        height: item ? item.implicitHeight : 0

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: ArkControls.Values.margin.horizontal.xsmall
            rightMargin: ArkControls.Values.margin.horizontal.xsmall
        }

        sourceComponent: RowLayout {
            spacing: ArkControls.Values.spacing.medium

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            ArkControls.Button {
                text: root.simplifiedButtons ? qsTr("Try again") : qsTr("Edit")
                type: root.simplifiedButtons ? ArkTokens.Button.primary : ArkTokens.Button.secondary
                visible: root.configured && !root.selected
                onClicked: root.edit()
            }

            ArkControls.Button {
                text: qsTr("Forget")
                type: ArkTokens.Button.secondary
                visible: root.selected ? true : (root.simplifiedButtons ? false : root.configured)
                onClicked: root.forget()
            }

            ArkControls.Button {
                text: qsTr("Connect")
                type: ArkTokens.Button.primary
                visible: !root.selected && !root.simplifiedButtons
                onClicked: root.connect()
            }

            ArkControls.Button {
                text: qsTr("Disconnect")
                type: ArkTokens.Button.primary
                visible: root.selected
                onClicked: root.disconnect()
            }
        }
    }
}
