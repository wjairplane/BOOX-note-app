import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "orientationButton"

    type: ToolbarTool.Type.FoldoutButton
    shown: (toolbar.notePage || toolbar.pdfPage) && !toolbar.hasAutorotation
    label: toolbar.portraitDocument ? qsTr("Set to landscape") : qsTr("Set to portrait")
    iconSource: toolbar.portraitDocument ? "qrc:/ark/icons/set_landscape_view" : "qrc:/ark/icons/set_portrait_view"

    onClicked: root.toolbar.toggleOrientationSelected()
}
