
import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding
import xofm.libs.toolbar

import ark.controls as ArkControls
import ark.tokens as ArkTokens

PenTool {
    id: root
    objectName: "selectionButton"
    type: ToolbarTool.Type.ToolbarButton

    label: qsTr("Selection tool")
    iconSource: "qrc:/ark/icons/selection_tool"
    pen: toolbar.selectionPen
    penToolType: "selection"
    implicitlySelected: root.toolbar.selectedPen === root

    toolTip: ToolTip {
        id: selectionToolTip
        type: ArkTokens.Tooltip.secondary
        //: Recommended character limit for translation: 20
        caption: qsTr("Selection tool")
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
        OnboardingStateProp.key: "Tools_Selection"
    }

    onPressed: {
        if (root.toolbar.selectedPen !== root) {
            toolbar.analytics?.sendEvent("Selection Tool Selected", Object.assign({
                                            "is_notepage": toolbar.isNote
                                        }, toolbar.penToolSelectedTelemetry()));
        }

        root.toolbar.requestPenSelect(root, Toolbar.SelectMode.Activate);
    }

    Connections {
        target: root.toolbar
        function onSelectSelection() {
            root.toolbar.requestPenSelect(root, Toolbar.SelectMode.DontActivate);
        }
    }
}
