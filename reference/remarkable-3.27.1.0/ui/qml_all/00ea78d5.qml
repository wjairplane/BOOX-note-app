import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "documentSettingsButton"

    type: ToolbarTool.Type.FoldoutButton
    label: {
        if (toolbar.documentType === "pdf")
            return qsTr("PDF settings");
        if (toolbar.documentType === "ebook")
            return qsTr("Ebook settings");
        return qsTr("Notebook settings");
    }

    iconSource: "qrc:/ark/icons/cog"

    onClicked: root.toolbar.settingsSelected()
}
