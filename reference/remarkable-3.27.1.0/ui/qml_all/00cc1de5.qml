import QtQuick
import com.remarkable
import common
import device.ui.text
import device.ui.controls

import ark.controls as ArkControls

Rectangle {
    id: root
    color: Values.colorBlack

    property string headerText: qsTr("Update software to view")
    property string infoText: qsTr("This document is not supported by your current software version.")
    height: 428

    signal checkForUpdatesClicked
    signal cancelClicked

    ArkControls.Icon {
        id: infoIcon
        size: ArkControls.Values.iconSize.medium
        anchors.top: parent.top
        anchors.topMargin: 90
        anchors.left: parent.left
        anchors.leftMargin: 170
        color: Values.colorWhite
        source: "qrc:/ark/icons/information_circle"
    }

    ArkControls.Title {
        id: header
        type: ArkControls.Title.Large
        anchors.top: parent.top
        anchors.topMargin: 85
        anchors.left: parent.left
        anchors.leftMargin: 261
        color: Values.colorWhite
        text: headerText
    }

    TextParagraph {
        id: info
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: header.bottom
        anchors.topMargin: Values.navigatorSidebarIndentation
        anchors.left: header.left
        width: 867
        color: Values.colorWhite
        wrapMode: Text.WordWrap
        text: infoText
    }

    Button {
        id: cancelButton
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
        anchors.leftMargin: 254
        width: 426
        height: 80
        text: qsTr("Cancel")
        inverted: true
        onClicked: {
            cancelClicked();
        }
    }

    Button {
        id: checkForUpdatesButton
        anchors.left: cancelButton.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: cancelButton.anchors.bottomMargin
        anchors.leftMargin: 30
        width: cancelButton.width
        height: cancelButton.height
        text: qsTr("Check for updates")
        inverted: true
        onClicked: {
            checkForUpdatesClicked();
        }
    }
}
