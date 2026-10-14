import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "sendByEmailButton"

    type: ToolbarTool.Type.FoldoutButton
    label: toolbar.sendByEmailString
    iconSource: "qrc:/ark/icons/send"

    onClicked: root.toolbar.sendByEmailSelected()

}
