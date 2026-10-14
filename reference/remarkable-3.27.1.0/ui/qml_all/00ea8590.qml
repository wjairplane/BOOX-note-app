import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "shareByUrlButton"
    shown: shareByUrlVisible

    type: ToolbarTool.Type.FoldoutButton
    label: qsTr("Convert and share")
    //TODO: Replace with Ark icon
    iconSource: "qrc:/icons/sparkles.svg"

    onClicked: root.toolbar.shareByUrlSelected()

}
