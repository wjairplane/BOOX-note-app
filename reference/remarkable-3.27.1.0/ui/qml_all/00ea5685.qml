import QtQuick
import QtQuick.Layouts

import xofm.libs.explorer
import xofm.libs.onboarding
import xofm.libs.toolbar

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "exportIntegrationOptionsButton"

    readonly property var exportIntegrationsModel: toolbar.exportIntegrationsModel

    type: ToolbarTool.Type.FoldoutButton

    label: qsTr("Export to storage integrations")
    iconSource: "qrc:/ark/icons/cloud_upload"
    foldoutBottomDivider: true

    shown: root.toolbar.showExportIntegrationOptionsButton

    onPressed: root.select(root)

    foldoutContent: ColumnLayout {
        objectName: "exportIntegrationOptionsContent"
        spacing: 0
        Repeater {
            id: exportIntegrations
            model: root.exportIntegrationsModel
            delegate: ExportIntegrationButton {
                required property var modelData
                integrationId: modelData.id
                integrationName: modelData.name
                integrationIconSource: modelData.iconSource
                toolbar: root.toolbar
            }
        }
    }
}
