import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "enableShapesButton"

    type: ToolbarTool.Type.FoldoutButton
    label: qsTr("Enable shapes")
    focusPolicy: Qt.NoFocus

    content: ArkControls.Toggle {
        id: shapeSnapToggle
        // right padding is not static anymore - waiting for a foldout item that supports a toggle (as we'd miss elide here too)
        anchors.rightMargin: root.item ? root.item.leftPadding : parent.leftPadding
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: root.toolbar.shapeSnapEnabled
        onCheckedChanged: {
            root.toolbar.shapeSnapEnabled = checked;
            root.toolbar.shapeSnapChanged(checked);
        }
    }
}
