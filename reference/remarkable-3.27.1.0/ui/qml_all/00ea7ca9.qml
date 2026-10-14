import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "convertToTextButton"

    type: ToolbarTool.Type.FoldoutButton
    shown: toolbar.notePage
    label: qsTr("Convert to text")
    iconSource: "qrc:/ark/icons/hwc"

    onClicked: root.toolbar.convertToTextSelected()

}
