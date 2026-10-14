import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "searchButton"

    type: ToolbarTool.Type.FoldoutButton
    label: qsTr("Search")
    iconSource: "qrc:/ark/icons/lens"

    onClicked: root.toolbar.searchSelected()

}
