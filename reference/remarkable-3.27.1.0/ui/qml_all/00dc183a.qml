import QtQuick
import com.remarkable
import common

import ark.controls as ArkControls
import ark.tokens as ArkTokens

Rectangle {
    id: root
    property color textColor: Values.colorBlack
    property int iconSpacing: Values.navigatorContentListItemMargin
    property alias iconRightMargin: icon.anchors.rightMargin
    property alias iconVerticalOffset: icon.anchors.verticalCenterOffset
    property alias font: notSyncing.font
    color: "transparent"
    border.width: 0
    // avoid overwriting the bottom border:
    anchors.bottomMargin: 1

    ArkControls.Label {
        id: notSyncing
        text: qsTr("Not syncing")
        type: ArkControls.Label.SmallSubtle
        anchors {
            verticalCenter: parent.verticalCenter
            right: icon.left
            rightMargin: root.iconSpacing
            left: parent.left
            leftMargin: root.iconSpacing
        }
        elide: Text.ElideRight
        color: root.textColor
    }

    ArkControls.Icon {
        id: icon
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        size: Values.iconSizeSmall
        color: root.textColor
        source: "qrc:/ark/icons/cloud_not_synced"
    }
}
