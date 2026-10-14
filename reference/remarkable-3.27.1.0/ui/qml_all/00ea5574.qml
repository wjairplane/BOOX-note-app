import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "addPageButton"

    type: ToolbarTool.Type.FoldoutButton

    label: toolbar.notePage ? qsTr("Add page") : qsTr("Add note page")
    iconSource: "qrc:/ark/icons/page_add"

    foldoutTopDivider: true
    foldoutBottomDivider: true

    onClicked: root.toolbar.addPageSelected()

}
