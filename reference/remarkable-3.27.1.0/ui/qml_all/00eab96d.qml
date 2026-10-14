import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "exportIntegrationButton_%1".arg(integrationName)
    required property string integrationId
    required property string integrationName
    required property string integrationIconSource

    type: ToolbarTool.Type.FoldoutButton
    label: qsTr("Export to %1").arg(integrationName)
    iconSource: root.integrationIconSource

    onClicked: {
        root.toolbar.exportToIntegrationClicked(integrationId);
    }
}
