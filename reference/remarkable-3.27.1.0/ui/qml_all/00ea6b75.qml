import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "screenShareButton"

    type: ToolbarTool.Type.FoldoutButton
    label: toolbar.screenShareActive ? qsTr("Stop sharing your screen") : qsTr("Present with Screen Share")
    implicitlySelected: toolbar.screenShareActive
    iconSource: "qrc:/ark/icons/screen_share"

    onClicked: root.toolbar.toggleScreenShareSelected()
}
