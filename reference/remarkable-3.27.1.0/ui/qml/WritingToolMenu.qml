import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import com.remarkable

import xofm.libs.onboarding
import xofm.libs.toolbar
import xofm.libs.epaper as Epaper
import ark.controls as ArkControls
import ark.tokens as ArkTokens

PenTool {
    id: root
    objectName: "penMenu"
    type: ToolbarTool.Type.ToolbarButton

    // Signals
    signal penToolSelected(tool : int)
    signal penThicknessSelected(thickness : int)
    signal penColorSelected(rgb : var, colorEnum : int)
    signal highlighterSnapToTextSelected(enabled : bool)

    function ensureSelection()
    {
        if (!toolModel.isValidTool(root.pen.tool)) {
            root.penToolSelected(toolModel.defaultTool());
        }
        if (!colorModel.isValidColor(root.pen.color, root.pen.colorCode)) {
            root.penColorSelected(colorModel.defaultRgbCode(), colorModel.defaultColorEnum());
        }
        if (!thicknessModel.isValidThickness(root.pen.thickness)) {
            root.penThicknessSelected(thicknessModel.defaultThickness());
        }
    }

    Connections {
        target: pen
        function onPropertyChanged() {
            Qt.callLater(root.ensureSelection);
        }
    }

    // Reimplemented state from ToolbarTool
    iconSource: toolModel.iconForTool(pen.tool)
    implicitlySelected: root.toolbar.selectedPen === root

    content: Item {
        id: indicator

        property color bodyColor: colorModel.displayColor(root.pen.color, root.pen.colorCode)
        property color stackedColor: colorModel.isStacked(root.pen.color, root.pen.colorCode) ? Qt.darker(bodyColor) : "transparent"
        property int borderWidth: colorModel.borderWidth(root.pen.color, root.pen.colorCode)

        property color outlineColor: {
            // Ensure that the indicator doesn't get eaten by the background of the button, by
            // adding an outline.
            if (!(root.selected || root.implicitlySelected) && indicator.bodyColor == "#ffffff") {
                return "#000000";
            } else if ((root.selected || root.implicitlySelected) && indicator.bodyColor == "#000000") {
                return "#ffffff";
            }

            return "transparent"
        }

        anchors.fill: parent

        Rectangle {
            id: indicatorCircle

            anchors {
                top: parent.top
                topMargin: root.topInset + margin
            }

            readonly property int margin: 8
            color: indicator.bodyColor
            width: 28
            height: 28
            radius: width

            // for e.g. shader, we need to stack the bottom half in a second color.
            Item {
                y: height
                rotation: 180
                height: parent.height / 2
                width: parent.width
                clip: true
                visible: indicator.stackedColor != "transparent"
                Rectangle {
                    width: indicatorCircle.width
                    height: indicatorCircle.height
                    radius: width / 2
                    color: indicator.stackedColor
                }
            }

            // the border.. we can't just use border.width because of the stacking above.
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: indicator.outlineColor
                border.width: indicator.borderWidth
                radius: parent.radius
                antialiasing: root.antialiasing
            }

            Epaper.ScreenModeItem {
                anchors.fill: parent
                visible: EPFramebuffer.hasCapability(EPFramebuffer.Capability.Color)
                anchors.margins: 4
                mode: Epaper.ScreenModeItem.Content
                objectName: "pen-color"
            }

            states: [
                State {
                    name: "leftPosition"
                    when: root.toolbar.position === ToolbarPositioner.Position.Right
                    AnchorChanges {
                        target: indicatorCircle
                        anchors.left: parent.left
                        anchors.right: undefined
                    }
                    PropertyChanges {
                        target: indicatorCircle
                        anchors.leftMargin: margin
                        anchors.rightMargin: 0
                    }
                },
                State {
                    name: "rightPosition"
                    when: (true)
                    AnchorChanges {
                        target: indicatorCircle
                        anchors.right: parent.right
                        anchors.left: undefined
                    }
                    PropertyChanges {
                        target: indicatorCircle
                        anchors.leftMargin: 0
                        anchors.rightMargin: margin
                    }
                }
            ]
        }
    }

    property bool hasWidthOption: {
        switch (pen.tool) {
        case Line.Highlighterv2:
        case Line.Highlighter:
            return false;
        }
        return true;
    }

    readonly property bool showHighlighterSnapItem: root.pen.tool === Line.Highlighterv2

    // My models
    PenToolModel {
        id: toolModel
    }

    PenColorModel {
        id: colorModel
        tool: root.pen.tool
        enableFullColorSelection: root.toolbar.toolbarConfiguration.enableFullColorSelection
    }

    PenThicknessModel {
        id: thicknessModel
    }

    // The actual foldout submenu

    foldoutContent: Item {
        implicitWidth: root.toolbar.container.height > 1000 ? columnSelector.implicitWidth : rowSelector.implicitWidth
        implicitHeight: root.toolbar.container.height > 1000 ? columnSelector.implicitHeight : rowSelector.implicitHeight
        ColumnLayout {
            id: columnSelector
            spacing: 0
            visible: root.toolbar.container.height > 1000
            ArkControls.FoldoutSectionHeader {
                label: qsTranslate(toolModel.translationContext(), toolModel.titleForTool(root.pen.tool));
                antialiasing: root.antialiasing
                Layout.fillWidth: true
            }

            PenGrid {}

            ArkControls.FoldoutDivider {
                visible: root.hasWidthOption
                Layout.fillWidth: true
            }

            ArkControls.FoldoutSectionHeader {
                visible: root.hasWidthOption
                label: qsTranslate(thicknessModel.translationContext(), thicknessModel.nameForThickness(root.pen.thickness))
                antialiasing: root.antialiasing
                Layout.fillWidth: true
            }

            ThicknessGrid {}

            ArkControls.FoldoutDivider {
                Layout.fillWidth: true
            }

            ColorGrid {
                extraPadding: true
            }

            ArkControls.FoldoutDivider {
                visible: root.showHighlighterSnapItem
                Layout.fillWidth: true
            }

            HighlighterToggle {}
        }
        RowLayout {
            id: rowSelector
            spacing: 0
            layoutDirection: root.toolbar.position === ToolbarPositioner.Position.Right ? Qt.RightToLeft : Qt.LeftToRight
            visible: root.toolbar.container.height <= 1000
            ColumnLayout {
                spacing: 0
                Layout.fillHeight: true
                ArkControls.FoldoutSectionHeader {
                    label: qsTranslate(toolModel.translationContext(), toolModel.titleForTool(root.pen.tool));
                    antialiasing: root.antialiasing
                    Layout.fillWidth: true
                }

                PenGrid {}
            }

            VerticalDivider {
                visible: root.hasWidthOption
            }

            ColumnLayout {
                spacing: 0
                Layout.fillHeight: true
                visible: root.hasWidthOption
                ArkControls.FoldoutSectionHeader {
                    label: qsTranslate(thicknessModel.translationContext(), thicknessModel.nameForThickness(root.pen.thickness))
                    antialiasing: root.antialiasing
                    Layout.fillWidth: true
                }

                ThicknessGrid {
                    columns: 1
                }
            }

            VerticalDivider {}

            ColumnLayout {
                spacing: 0
                Layout.fillHeight: true

                ArkControls.FoldoutSectionHeader {
                    label: qsTr("Color")
                    antialiasing: root.antialiasing
                    Layout.fillWidth: true
                }

                ColorGrid {}

                // spacer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                ArkControls.FoldoutDivider {
                    id: divider

                    visible: root.showHighlighterSnapItem
                    Layout.fillWidth: true
                }

                HighlighterToggle {
                    // Otherwise, this menu will use more vertical space than the other menus.
                    Layout.topMargin: -divider.height
                }
            }
        }
    }

    hasMinimumFoldoutWidth: false

    component PenGrid: ArkControls.FoldoutGrid {
        columns: toolModel.columns()
        Layout.fillWidth: true
        Repeater {
            id: toolsRepeater
            model: toolModel
            ArkControls.FoldoutItem {
                required property string iconPath
                required property string displayName
                required property int tool
                iconSource: iconPath
                selected: root.pen.tool === tool
                antialiasing: root.antialiasing
                focusPolicy: Qt.NoFocus
                onPressed: root.penToolSelected(tool)
                implicitWidth: implicitHeight
            }
        }
    }

    component ThicknessGrid: ArkControls.FoldoutGrid {
        visible: root.hasWidthOption
        columns: 3
        Layout.fillWidth: true
        Repeater {
            model: thicknessModel
            ArkControls.FoldoutItem {
                required property string iconPath
                required property string displayName
                required property int thickness
                iconSource: iconPath
                selected: root.pen.thickness === thickness
                antialiasing: root.antialiasing
                focusPolicy: Qt.NoFocus
                onPressed: root.penThicknessSelected(thickness)
                implicitWidth: implicitHeight
            }
        }
    }

    component ColorGrid: ArkControls.FoldoutGrid {
        columns: 3
        Layout.fillWidth: true
        Repeater {
            model: colorModel
            ArkControls.FoldoutGridItem {
                id: colorComponent
                required property var displayColor
                required property string displayName
                required property int toolColor
                required property var rgb
                required property bool stacked
                required property int borderWidth
                focusPolicy: Qt.NoFocus
                label: qsTranslate("xofm::libs::toolbar::PenColorModel", displayName)
                selected: {
                    if (root.pen.color !== toolColor) {
                        return false;
                    }
                    if (toolColor === Line.ArgbCode) {
                        return rgb === root.pen.colorCode;
                    }
                    return true;
                }
                iconComponent: ArkControls.ColorSwatch {
                    // According to Andrius and Casper this is the correct size for the color swatch on all pT platforms.
                    size: 39
                    borderColor: colorComponent.selected ? "white" : "black"
                    color: displayColor
                    duoColor: stacked ? Qt.darker(displayColor, 1.6) : ""
                    duoOpacity: 1
                    antialiasing: false
                    borderWidth: colorComponent.borderWidth
                    rotation: stacked && borderWidth == 0 ? 90 : 0
                }
                onPressed: root.penColorSelected(rgb, toolColor)
                // Overwrite these deliberatly for now, until they are updated in ark
                implicitWidth: 112
                implicitHeight: 112
                Epaper.ScreenModeItem {
                    anchors.fill: parent
                    visible: !EPFramebuffer.hasCapability(EPFramebuffer.Capability.Color)
                    mode: Epaper.ScreenModeItem.Mono
                    objectName: "pen-mono-dither"
                }
                // Work-around for incorrect spacing applied by FoldoutGridItem:
                Component.onCompleted: contentItem.spacing = 8
            }
        }
    }

    component HighlighterToggle: ArkControls.FoldoutToggle {
        id: snapToText

        //: Some tools support snapping to text, like the Highlighter which will cleanly highlight typed words
        label: qsTr("Snap to text")
        visible: root.showHighlighterSnapItem
        antialiasing: root.antialiasing
        Layout.fillWidth: true
        // A Row with one item gives us the freedom to set the width to the
        // text label without it being attached to the [implicit]ContentWidth.
        contentItem: Row {
            ArkControls.Label {
                // A bit less than the width of two tool selectors (112),
                // as the switch indicator is oversized (> 112).
                width: 212
                text: snapToText.label
                wrapMode: Text.Wrap
                typography: snapToText.lStyle.typography
                color: snapToText.lStyle.fill
                // To allow special entities in translations
                textFormat: Text.StyledText
            }
        }
        checked: root.pen.snapHighlighterToText
        onClicked: root.highlighterSnapToTextSelected(!root.pen.snapHighlighterToText)
    }

    component VerticalDivider: Rectangle {
            Layout.fillHeight: true
            color: "black"
            width: 2
    }

    toolTip: ToolTip {
        id: penToolTip
        type: ArkTokens.Tooltip.secondary
        //: Recommended character limit for translation: 30
        caption: qsTr("Writing tools and styles")
        positionHint: root.toolbar.tooltipPositionHint
        parent: root.toolbar.tooltipOverlay
        container: root.toolbar.tooltipContainer
        pointTo: root.mapToItem(root.toolbar.tooltipOverlay, root.foldout.x, root.foldout.y, root.foldout.width, root.foldout.height)
        OnboardingStateProp.key: "Tools_Pens"
        OnboardingStateProp.onCompletedChanged: {
            if (OnboardingStateProp.completed) {
                // Hide both pen tooltips when one of them is triggered
                if (penToolType === "primary") {
                    root.toolbar.secondaryPenOnboardingCompleted();
                } else if (penToolType === "secondary") {
                    root.toolbar.primaryPenOnboardingCompleted();
                }
            }
        }
    }

    Connections {
        target: root.toolbar

        function onSecondaryPenOnboardingCompleted() {
            penToolTip.OnboardingStateProp.completed = true;
        }

        function onSelectPen(penType : string) {
            if (penType !== root.penToolType && root.toolbar.selectedPen !== root) {
                return;
            }

            const shouldPenTooltipShow = !OnboardingManager.getCompletedForKey(OnboardingManager.Group.Tooltips, "", "Tools_Pens") &&
                                       !toolbarConfiguration.hideTooltips;
            const activationMode = shouldPenTooltipShow ? Toolbar.SelectMode.Activate : Toolbar.SelectMode.DontActivate;
            root.toolbar.requestPenSelect(root, activationMode);
        }
    }

    onPenToolSelected: (tool) => { root.toolbar.penToolSelected(tool); }
    onPenThicknessSelected: (thickness) => { root.toolbar.penThicknessSelected(thickness); }
    onPenColorSelected: (rgb, paletteEnum) => { root.toolbar.penColorSelected(rgb, paletteEnum); }
    onHighlighterSnapToTextSelected: (enabled) => { root.toolbar.highlighterSnapToTextSelected(enabled); }
    onPressed: {
        if (root.toolbar.selectedPen !== root) {
            root.toolbar.analytics?.sendEvent("Pen Selected", Object.assign({
                                            "pen_position": root.penToolType,
                                            "pen_type": toolModel.titleForTool(root.pen.tool).toLowerCase(),
                                            "color": colorModel.displayName(root.pen.color, root.pen.colorCode).toLowerCase(),
                                            "color_code": pen.colorCode,
                                            "stroke_width": pen.thickness,
                                            "is_notepage": toolbar.isNote
                                        }, toolbar.penToolSelectedTelemetry()));
            }

        root.toolbar.requestPenSelect(root, Toolbar.SelectMode.Activate);
        root.toolbar.selectedPen = root;
        root.penToolSelected(root.pen.tool);
    }
}
