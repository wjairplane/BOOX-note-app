import QtQuick
import QtQuick.Layouts

import xofm.libs.explorer
import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "shareMenu"

    type: ToolbarTool.Type.FoldoutButton

    label: qsTr("Share")
    iconSource: "qrc:/ark/icons/share"

    readonly property var exportIntegrationsModel: toolbar.exportIntegrationsModel

    property bool forceStackView: false

    foldoutContent: ColumnLayout {
        objectName: "shareMenuContent"
        spacing: 0
        ScreenShareButton {
            id: screenShareButton
            toolbar: root.toolbar
            Layout.fillWidth: true
            foldoutBottomDivider: exportIntegrationsLoader.hasMultipleIntegrationButtons
        }
        Repeater {
            model: toolbar.messagingIntegrationManager?.integrations ?? []
            delegate: MessagingIntegrationButton {
                required property var modelData
                toolbar: root.toolbar
                integrationData: modelData
                Layout.fillWidth: true
            }
        }
        SendByEmailButton {
            id: sendByEmailButton
            toolbar: root.toolbar
            Layout.fillWidth: true
        }
        ShareByUrlButton {
            id: shareByUrlButton
            toolbar: root.toolbar
            Layout.fillWidth: true
            foldoutBottomDivider: exportIntegrationsLoader.hasMultipleIntegrationButtons
        }
        Loader {
            id: exportIntegrationsLoader
            objectName: "exportIntegrationsLoader"
            readonly property bool hasMultipleIntegrationButtons: !!item?.hasMultipleIntegrationButtons
            Layout.fillWidth: true
            sourceComponent: root.toolbar.showExportIntegrationOptionsButton || root.forceStackView ? exportIntegrationStackDelegate : exportIntegrationsExpandedDelegate
        }
    }

    Component {
        id: exportIntegrationStackDelegate
        ExportIntegrationOptionsButton {
            id: exportIntegrationOptionsButton
            objectName: "exportIntegrationOptionsButton"
            readonly property bool hasMultipleIntegrationButtons: false
            toolbar: root.toolbar
            Layout.fillWidth: true
            shown: true
            onPressed: {
                root.select(exportIntegrationOptionsButton);
            }
        }
    }

    Component {
        id: exportIntegrationsExpandedDelegate
        ColumnLayout {
            objectName: "exportIntegrationsExpandedDelegate"
            readonly property bool hasMultipleIntegrationButtons: exportIntegrations.count > 1
            spacing: 0
            Repeater {
                id: exportIntegrations
                objectName: "exportIntegrations"
                model: root.exportIntegrationsModel
                delegate: ExportIntegrationButton {
                    required property var modelData
                    integrationId: modelData.id
                    integrationName: modelData.name
                    integrationIconSource: modelData.iconSource
                    toolbar: root.toolbar
                    Layout.fillWidth: true
                }
            }
        }
    }

    onPressed: root.select(root)
}
