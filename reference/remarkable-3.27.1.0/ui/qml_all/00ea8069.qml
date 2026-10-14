import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "pageOverviewButton"
    type: ToolbarTool.Type.ToolbarButton

    iconSource: "qrc:/ark/icons/page_overview"
    label: qsTr("Page overview")

    onClicked: {
        cooldownTimer.restart();
        root.toolbar.pageOverviewSelected()
    }
    onReleased: releaseIfNotShowingTooltip(root)
    onCanceled: releaseIfNotShowingTooltip(root)

    MouseArea {
        anchors.fill: parent
        // We need to ensure we block presses on the button. ToolbarTool is a Loader, so the child is dynamically created.
        // So we must set z to stack above it.
        z: 100
        visible: cooldownTimer.running

        Timer {
            id: cooldownTimer
            interval: 100
            running: false
            repeat: false
        }

        onClicked: console.log("Cooldown ate Page Overview press")
    }
}
