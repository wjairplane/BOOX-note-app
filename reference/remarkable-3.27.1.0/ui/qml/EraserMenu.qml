import QtQuick
import QtQuick.Layouts

import com.remarkable

import xofm.libs.onboarding
import xofm.libs.toolbar

import ark.controls as ArkControls
import ark.tokens as ArkTokens

PenTool {
    id: root
    objectName: "eraserMenu"
    type: ToolbarTool.Type.ToolbarButton

    // Input properties
    pen: toolbar.eraserPen
    penToolType: "eraser"

    // Signals
    signal eraserToolSelected(tool : int)
    signal eraserThicknessSelected(thickness : int)
    signal eraseAllSelected

    // Internals state
    readonly property bool hasWidthOption: pen.tool == Line.Eraser

    label: qsTr("Eraser")
    iconSource: toolModel.iconForTool(pen.tool)
    implicitlySelected: root.toolbar.selectedPen === root

    // My models
    EraserToolModel {
        id: toolModel
    }
    PenThicknessModel {
        id: thicknessModel
    }

    hasMinimumFoldoutWidth: false

    foldoutContent: ColumnLayout {
        id: content
        spacing: 0

        ArkControls.FoldoutSectionHeader {
            objectName: "eraserFoldout"
            label: qsTranslate("xofm::libs::toolbar::ToolModel", toolModel.titleForTool(root.pen.tool));
            antialiasing: root.antialiasing
            Layout.fillWidth: true
        }

        ArkControls.FoldoutGrid {
            id: toolGrid
            // Make sure we don't shrink in size when the width options
            // are hidden.
            // 2 * left padding because right padding is defined based on content width
            Layout.minimumWidth: columns * ArkTokens.Style.variable.controlsHeight.large + toolGrid.leftPadding * 2
            columns: 3
            Repeater {
                model: toolModel
                ArkControls.FoldoutItem {
                    required property string iconPath
                    required property string displayName
                    required property int tool
                    Layout.alignment: Qt.AlignLeft
                    iconSource: iconPath
                    selected: root.pen.tool == tool
                    antialiasing: root.antialiasing
                    onPressed: root.eraserToolSelected(tool)
                }
            }
        }

        ArkControls.FoldoutDivider {
            visible: root.hasWidthOption
            Layout.fillWidth: true
        }

        ArkControls.FoldoutSectionHeader {
            objectName: "thicknessFoldout"
            visible: root.hasWidthOption
            label: qsTranslate(thicknessModel.translationContext(), thicknessModel.nameForThickness(root.pen.thickness))
            antialiasing: root.antialiasing
            Layout.fillWidth: true
        }

        ArkControls.FoldoutGrid {
            id: thicknessGrid
            visible: root.hasWidthOption
            columns: 3

            Repeater {
                model: thicknessModel
                ArkControls.FoldoutItem {
                    required property string iconPath
                    required property string displayName
                    required property int thickness
                    iconSource: iconPath
                    selected: root.pen.thickness == thickness
                    antialiasing: root.antialiasing
                    onPressed: root.eraserThicknessSelected(thickness)
                }
            }
        }

        ArkControls.FoldoutItem {
            objectName: "eraseAllFoldout"
            iconSource: "qrc:/ark/icons/erase_all"
            label: qsTr("Erase all strokes")
            Layout.fillWidth: true
            topDivider: true
            onClicked: root.eraseAllSelected()
        }

    }

    toolTip: ToolTip {
        id: eraseToolTip
        type: ArkTokens.Tooltip.secondary
        //: Recommended character limit for translation: 20
        caption: qsTr("Eraser")
        positionHint: root.toolbar.tooltipPositionHint
        parent: root.toolbar.tooltipOverlay
        container: root.toolbar.tooltipContainer
        pointTo: root.mapToItem(root.toolbar.tooltipOverlay, root.foldout.x, root.foldout.y, root.foldout.width, root.foldout.height)
        OnboardingStateProp.key: "Tools_Eraser"
    }

    onEraserToolSelected: (tool) => { root.toolbar.eraserToolSelected(tool); }
    onEraserThicknessSelected: (thick) => { root.toolbar.eraserThicknessSelected(thick); }
    onEraseAllSelected: () => { root.toolbar.eraseAllSelected(); }
    onPressed: {
        if(root.toolbar.selectedPen !== root) {
            toolbar.analytics?.sendEvent("Eraser Selected", Object.assign({
                                            "is_notepage": root.toolbar.isNote,
                                            "stroke_width": root.pen.thickness,
                                            "eraser_type": toolModel.titleForTool(root.pen.tool).toLowerCase()
                                        }, root.toolbar.penToolSelectedTelemetry()));
        }

        root.toolbar.requestPenSelect(root, Toolbar.SelectMode.Activate);
        root.toolbar.eraserToolSelected(root.pen.tool);
    }
}
