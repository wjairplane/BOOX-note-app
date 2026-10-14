
import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding
import xofm.libs.toolbar

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "undoButton"
    type: ToolbarTool.Type.ToolbarButton

    iconSource: enabled ? "qrc:/ark/icons/undo" : "qrc:/ark/icons/undo_disabled"
    label: qsTr("Undo")
    enabled: toolbar.undoEnabled || toolTip.visible
    implicitlySelected: toolTip.visible || down
    property bool closeOnRelease: false

    toolTip: ToolTip {
        id: undoToolTip
        type: ArkTokens.Tooltip.secondary
        //: Recommended character limit for translation: 20
        caption: qsTr("Undo")

        positionHint: root.toolbar.tooltipPositionHint
        parent: root.toolbar.tooltipOverlay
        container: root.toolbar.tooltipContainer
        pointTo: {
            // we want to perserve the binding to parent x/y/width/height, but mapping is done relative to the loadee.
            root.parent.x;
            root.parent.y;
            root.parent.width;
            root.parent.height;
            return root.mapToItem(root.toolbar.tooltipOverlay, root.x, root.y, root.width, root.height)
        }
        OnboardingStateProp.key: "Undo_Introduction"
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
    onClicked: root.toolbar.undoSelected()
    onReleased: buttonReleased()
    onCanceled: buttonReleased()
}
