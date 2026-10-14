import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "textSettingsButton"

    type: ToolbarTool.Type.FoldoutButton
    shown: toolbar.ebookPage
    label: qsTr("Text settings")
    iconSource: "qrc:/ark/icons/accessibility"

    onClicked: root.toolbar.ebookSettingsSelected()

}
