
import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding
import xofm.libs.toolbar

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "redoButton"
    type: ToolbarTool.Type.ToolbarButton

    label: qsTr("Redo")
    iconSource: enabled ? "qrc:/ark/icons/redo" : "qrc:/ark/icons/redo_disabled"
    enabled: toolbar.redoEnabled || toolTip.visible
    implicitlySelected: toolTip.visible || down
    property bool closeOnRelease: false

    toolTip: ToolTip {
        id: redoToolTip
        type: ArkTokens.Tooltip.secondary
        //: Recommended character limit for translation: 20
        caption: qsTr("Redo")

        positionHint: root.toolbar.tooltipPositionHint
        parent: root.toolbar.tooltipOverlay
        container: root.toolbar.tooltipContainer
        pointTo: {
            // we want to perserve the binding to parent x/y/width/height, but mapping is done relative to the loadee.
            root.parent.x;
            root.parent.y;
            root.parent.width;
            root.parent.height;
            return root.mapToItem(root.toolbar.tooltipOverlay, 0, 0, root.width, root.height)
        }
        OnboardingStateProp.key: "Redo_Introduction"
    }

    function buttonReleased() {
        if (root.closeOnRelease) {
            root.toolTip.OnboardingStateProp.completed = true;
            root.closeOnRelease = false;
        }
        root.toolbar.releaseIfNotShowingTooltip(root);
    }

    onPressed: {
        if (root.toolTip.OnboardingStateProp.completed) {
            root.closeOnRelease = true;
            return;
        }
        root.select(root);
    }
    onClicked: root.toolbar.redoSelected()
    onReleased: buttonReleased()
    onCanceled: buttonReleased()
}
