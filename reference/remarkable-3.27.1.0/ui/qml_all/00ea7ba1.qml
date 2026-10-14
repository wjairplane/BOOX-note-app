import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "messagingIntegrationButton"
    property var integrationData

    type: ToolbarTool.Type.FoldoutButton
    label: qsTr("Send to %1").arg(integrationData.name)
    iconSource: integrationData.iconSource

    onClicked: root.toolbar.shareToMessagingClicked(integrationData.id)
}
