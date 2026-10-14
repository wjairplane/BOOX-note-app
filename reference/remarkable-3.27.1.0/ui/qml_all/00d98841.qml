import QtQuick
import com.remarkable
import common
import device.ui.controls
import device.ui.text

import ark.controls as ArkControls
import ark.tokens as ArkTokens

Background {
    id: root

    anchors.fill: parent

    signal close

    function goBack() {
        root.close();
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
        }
    }

    ArkControls.Title {
        id: header
        type: ArkControls.Title.Large
        //: Settings - General - title of Account page on retail device
        text: qsTr("Account")
        anchors.left: parent.left
        anchors.leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
        height: Values.navigatorSettingsHeaderHeight
    }

    component ArkIconTitle: Item {
        property alias iconSource: icon.source
        property alias title: titleText.text

        implicitWidth: icon.width + ArkControls.Values.spacing.medium + titleText.implicitWidth
        implicitHeight: Math.max(icon.height, titleText.height)

        Image {
            id: icon
            x: 30
            width: ArkControls.Values.iconSize.medium
            height: ArkControls.Values.iconSize.medium
            anchors.verticalCenter: parent.verticalCenter
        }

        ArkControls.Body {
            id: titleText
            type: ArkControls.Body.Medium
            anchors.left: icon.right
            anchors.leftMargin: ArkControls.Values.spacing.medium
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }

    Column {
        id: infoColumn
        anchors.top: header.bottom
        anchors.topMargin: ArkControls.Values.platform.spacing.x2large
        anchors.left: parent.left
        anchors.leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
        anchors.right: parent.right
        anchors.rightMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
        spacing: ArkControls.Values.platform.spacing.x2large

        ArkIconTitle {
            id: userIcon
            iconSource: "qrc:/ark/icons/user"
            //: Settings - General - list of Connect benefits on retail device
            title: qsTr("reMarkable cloud")
            width: parent.width
        }

        Column {
            spacing: infoColumn.spacing
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.right: parent.right
            ArkControls.Title {
                type: ArkControls.Title.Medium
                //: Settings - General - list of Connect benefits on retail device
                text: qsTr("The cloud service lets you:")
            }
            ArkIconTitle {
                width: parent.width
                iconSource: "qrc:/ark/icons/cloud_upload"
                //: Settings - General - list of Connect benefits on retail device
                title: qsTr("Sync files between your paper tablet, mobile, and desktop")
            }
            ArkIconTitle {
                width: parent.width
                iconSource: "qrc:/ark/icons/storage"
                //: Settings - General - list of Connect benefits on retail device
                title: qsTr("Back up your work")
            }
            ArkIconTitle {
                width: parent.width
                iconSource: "qrc:/ark/icons/send"
                //: Settings - General - list of Connect benefits on retail device
                title: qsTr("Send files by email")
            }
            ArkIconTitle {
                width: parent.width
                iconSource: "qrc:/ark/icons/hwc"
                //: Settings - General - list of Connect benefits on retail device
                title: qsTr("Convert handwritten notes into typed text")
            }
            ArkControls.Title {
                type: ArkControls.Title.Medium
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                //: Settings - General - Logged in - Account page on retail device
                text: qsTr("The cloud service is disabled on this retail device.")
            }
        }
    }
}
