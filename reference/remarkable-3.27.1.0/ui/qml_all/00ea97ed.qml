import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding
import xofm.libs.toolbar
import xofm.libs.peninput
import xofm.libs.analytics.ui

import com.remarkable
import ark.tokens as ArkTokens
import ark.controls as ArkControls

FocusScope {
    id: root

    // -1 to consider the hide/show toggle
    readonly property int showableToolsCount: Math.floor(Math.max(innerWidth, innerHeight) /  ArkTokens.Style.variable.controlsHeight.large) - 1
    readonly property size minSize: Qt.size(ArkTokens.Style.variable.controlsHeight.large, ArkTokens.Style.variable.controlsHeight.large)
    readonly property alias innerWidth: toolbar.width
    readonly property alias innerHeight: toolbar.height

    // input
    required property QtObject primaryPen
    required property QtObject secondaryPen
    required property QtObject eraserPen
    required property QtObject selectionPen

    property var exportIntegrationsModel

    // Container that foldouts are to be contained within
    property Item container

    property bool expanded: true

    required property PenInput penInput
    readonly property bool dragging: dragTarget.dragging

    required property bool typingModeVisible
    required property bool typingModeEnabled
    required property int documentLength
    required property real textWidth
    required property int columnTextWidth
    required property bool autoReflowEnabled

    required property Config toolbarConfiguration
    required property ToolbarProvider toolbarProvider
    readonly property ToolbarPositioner toolbarPositioner: toolbarProvider.positioner
    readonly property int position: toolbarPositioner?.position ?? ToolbarPositioner.Left
    property bool hasAutorotation: false

    required property bool undoEnabled
    required property bool redoEnabled

    // valid values include "note", "pdf" and "ebook".
    property string documentType: "note"
    property string pageType: "note"

    required property QtObject layersModel
    required property bool layersBackgroundVisible
    required property bool layersRootDocumentAvailable
    required property bool layersRootDocumentVisible

    required property bool isTagged

    required property bool portraitDocument
    required property string documentTitle
    required property int pageCount
    required property int currentPage
    required property string sendByEmailString
    required property bool shareByUrlVisible
    required property bool screenShareActive
    required property var messagingIntegrationManager
    required property bool hasPageAnnotations

    // Valid values include "width", "height", "custom".
    required property string fitMode

    // value values ["" (auto), on", "off"]
    required property string backgroundFilter
    required property bool backgroundFilterVisible

    required property bool shapeSnapEnabled

    readonly property TextWidthModel textWidthModel: toolbarProvider.textWidthModel

    property Analytics analytics

    // we allow the tags foldout to be specified from the outside
    property Item tagsFoldout

    required property Item tooltipOverlay
    readonly property rect tooltipContainer: {
        const horizontalMargin = 112;
        const verticalMargin = 0;
        return Qt.rect(
            tooltipOverlay.x + horizontalMargin,
            tooltipOverlay.y + verticalMargin,
            tooltipOverlay.width - 2 * horizontalMargin,
            tooltipOverlay.height - 2 * verticalMargin
        );
    }
    readonly property int tooltipPositionHint: {
        switch (root.position) {
            case ToolbarPositioner.Position.Top:
                return ArkControls.Tooltip.Position.Below;
            case ToolbarPositioner.Position.Bottom:
                return ArkControls.Tooltip.Position.Above;
            case ToolbarPositioner.Position.Left:
                return ArkControls.Tooltip.Position.Right;
            case ToolbarPositioner.Position.Right:
                return ArkControls.Tooltip.Position.Left;
            default:
                return ArkControls.Tooltip.Position.Right;
        }
    }

    // Selects pen tool using penType
    // "primary" selects primaryPen
    // "secondary": selects secondaryPen
    // "auto" picks the last active pen
    signal selectPen(penType : string)
    signal selectSelection

    signal requestPenSelect(penTool : Item, mode : int)
    onRequestPenSelect: (penTool, mode) => {
        if (!(penTool instanceof PenTool)) {
            console.error(log, "requestPenSelect: item is not a PenTool", penTool);
            return;
        }

        root._select(penTool, mode);
        root.selectedPen = penTool;
    }

    onShowableToolsCountChanged: toolbarProvider.updateToolbarTools(showableToolsCount);

    function closeFoldout() {
        if (selectedTool) {
            if (selectedTool.hasFoldout && selectedTool.foldoutVisible) {
                root._select(selectedTool, Toolbar.SelectMode.DontActivate);
            }
            if (selectedTool.toolTip) {
                selectedTool.toolTip.OnboardingStateProp.completed = true;
            }
        }
    }

    onExpandedChanged: {
        if (!root.expanded) {
            root.closeFoldout();
        }
    }

    onStateChanged: {
        root.closeFoldout();
    }

    function selectLastTool() {
        root._select(root.selectedPen, Toolbar.SelectMode.DontActivate);
    }

    function reportToolbarPositionChanged() {
        if (root.dragging) {
            return;
        }

        root.analytics?.sendEvent("Toolbar Position Changed", {
            "trigger": "drag",
            "position": AnalyticsUtils.enumToString(toolbarPositioner.position, "xofm::libs::toolbar::ToolbarPositioner::Position"),
            "applied_to_orientation": toolbarPositioner.isPortraitOrientation ? "portrait" : "landscape"
        });
    }

    // output
    signal tagsPopupVisibleChanged(visible : bool)
    readonly property bool pdfPage: pageType === "pdf"
    readonly property bool ebookPage: pageType === "ebook"
    readonly property bool notePage: !pdfPage && !ebookPage

    // Since the gesture area is stacked behind the toolbar, we need a slight offset to allow grabbing gestures
    // that start outside the screen.
    readonly property int gestureMargin: 20

    // action signals
    signal penToolSelected(tool : int)
    signal secondaryPenToolSelected(tool : int)
    signal penThicknessSelected(thickness : int)
    signal penColorSelected(rgb : var, paletteEnum : int)
    signal highlighterSnapToTextSelected(enabled : bool)
    signal typingModeSelected
    signal textWidthSelected(real width)
    signal textColumnWidthSelected(columnWidth : int)
    signal enableAutoReflow
    signal disableAutoReflow(columnWidth : int)
    signal eraserToolSelected(tool : int)
    signal eraserThicknessSelected(thickness : int)
    signal eraseAllSelected
    signal selectionSelected
    signal undoSelected
    signal redoSelected

    signal pageOverviewSelected
    signal sendByEmailSelected
    signal shareByUrlSelected
    signal convertToTextSelected
    signal toggleScreenShareSelected
    signal shareToMessagingClicked(integrationId : string)
    signal exportToIntegrationClicked(integrationId : string)

    signal newLayerSelected
    signal chooseTemplateSelected
    signal toggleBackgroundVisibleSelected
    signal toggleRootDocumentVisibleSelected
    signal setCurrentLayerSelected(index : int)
    signal toggleLayerVisibilitySelected(index : int)
    signal moveLayerUpSelected(index : int)
    signal moveLayerDownSelected(index : int)
    signal mergeLayerSelected(index : int)
    signal deleteLayerSelected(index : int)
    signal renameLayerSelected(index : int, name : string)

    signal settingsSelected
    signal fitToWidthSelected
    signal fitToHeightSelected
    signal fitToCustomSelected
    signal toggleOrientationSelected
    signal searchSelected
    signal ebookSettingsSelected
    signal addPageSelected
    signal toggleBackgroundFilter(value : var)
    signal toolbarPositionSelected
    signal shapeSnapChanged(enabled : bool)

    signal primaryPenOnboardingCompleted
    signal secondaryPenOnboardingCompleted

    signal closeDocumentClicked(event : var)

    // Telemetry
    signal reportLayersFoldoutOpened
    signal reportAdjustViewClicked

    // callback returning a object with additional properties we care about
    property var penToolSelectedTelemetry: (() => {})

    // internals

    readonly property bool useStackView: toolbarConfiguration.useStackView
    readonly property bool showExtraEditingTools: toolbarProvider.hasEditingToolsGrouping && root.container.height < 1000
    readonly property bool showExportIntegrationOptionsButton: root.container.height < 1000

    antialiasing: false
    focus: false
    property Item selectedTool: null
    property Item selectedPen

    onSelectedPenChanged: {
        // in case the selected tool gets invalidated, default to the primary pen
        if (!selectedPen) {
            root.selectPen("primary");
        }
    }

    // Analytics
    onDraggingChanged: reportToolbarPositionChanged()

    enum SelectMode {
        DontActivate,
        Activate
    }

    enum Zone {
        None,
        Top,
        Bottom,
        Left,
        Right
    }

    LoggingCategory {
        id: log
        name: "xofm.libs.toolbar"
        defaultLogLevel: LoggingCategory.Warning
    }

    Item {
        id: dragTarget
        objectName: "dragTarget"

        property bool dragging: hideShowButtonDragPoint.dragging

        width: root.minSize.width
        height: root.minSize.height
        anchors {
            top: toolbar.top
            left: toolbar.left
        }
        Drag.active: true

        function updatePosition(dragProxyItem, position) {
            const globalPosition = dragProxyItem.mapToItem(root, Qt.point(position.x, position.y));
            dragTarget.x = globalPosition.x - dragTarget.width / 2;
            dragTarget.y = globalPosition.y - dragTarget.height / 2;
        }

        onDraggingChanged: {
            root.closeFoldout();
            if (!toolbar.dragging) {
                if (dropZone.zone === Toolbar.Zone.Top) {
                    toolbarPositioner.preference = ToolbarPositioner.Position.Top;
                } else if (dropZone.zone === Toolbar.Zone.Bottom) {
                    toolbarPositioner.preference = ToolbarPositioner.Position.Bottom;
                } else if (dropZone.zone === Toolbar.Zone.Left) {
                    toolbarPositioner.preference = ToolbarPositioner.Position.Left;
                } else if (dropZone.zone === Toolbar.Zone.Right) {
                    toolbarPositioner.preference = ToolbarPositioner.Position.Right;
                }
            }
        }

        states: [
            State {
                name: "dragging"
                when: root.dragging
                AnchorChanges {
                    target: dragTarget
                    anchors.left: undefined
                    anchors.right: undefined
                    anchors.top: undefined
                    anchors.bottom: undefined
                }
                PropertyChanges {
                    target: dropZone
                    zone: dropZone.findClosestZone();
                }
            }
        ]
    }

    Item {
        id: toolbar
        antialiasing: root.antialiasing
        anchors.rightMargin: parent.rightMargin
        anchors.leftMargin: parent.leftMargin

        Rectangle {
            id: toolbarBackground
            color: "white"
            anchors.fill: toolbar
            antialiasing: parent.antialiasing
            visible: root.expanded
        }

        MouseArea {
            // eat all mouse events
            id: backgroundMouseArea
            anchors.fill: toolLayout
            anchors.topMargin: root.position !== ToolbarPositioner.Position.Bottom ? root.gestureMargin : 0
            enabled: root.expanded
        }

        component ToolLoader: Loader {
            property var toolType: model.tool
            property url sourceUrl: model.component
            antialiasing: root.antialiasing
            visible: (item?.shown ?? false) && root.expanded
            // we bump the z-order of the tool in case we need to nudge the foldout
            // and it overlaps with other UI elements (other tools), we want the foldout
            // to be on top.
            z: item?.totalHeight > root.height ? 1 : 0
            asynchronous: !root.visible
            onSourceUrlChanged: {
                if (sourceUrl === "") {
                    return;
                }
                const requiredProperties = { toolbar : root, antialiasing : root.antialiasing, type : ToolbarTool.Type.ToolbarButton };
                setSource(sourceUrl, requiredProperties);
            }

            Connections {
                target: item
                function onSelect(tool) {
                    root._select(tool);
                }
            }
        }

        GridLayout {
            id: toolLayout
            objectName: "toolbarLayout"
            anchors.fill: parent
            anchors.topMargin: root.position !== ToolbarPositioner.Position.Bottom ? root.gestureMargin : 0
            anchors.bottomMargin: root.position === ToolbarPositioner.Position.Bottom ? root.gestureMargin : 0
            flow: root.position === ToolbarPositioner.Position.Left || root.position === ToolbarPositioner.Position.Right ? GridLayout.TopToBottom : GridLayout.LeftToRight
            rowSpacing: 0
            columnSpacing: 0

            ArkControls.ToolButton {
                id: hideShowButton
                objectName: "hide-show-toolbar-button"
                topInset: root.position !== ToolbarPositioner.Position.Bottom ? -root.gestureMargin : 0
                bottomInset: root.position === ToolbarPositioner.Position.Bottom ? -root.gestureMargin : 0
                iconSource: root.expanded ? "qrc:/ark/icons/toolbar_hide" : "qrc:/ark/icons/multicolor/toolbar_show"
                focusPolicy: Qt.NoFocus
                multicolor: !root.expanded
                background: Item {}
                onClicked: root.expanded = !root.expanded
                visible: true
                contentItem.rotation: root.position === ToolbarPositioner.Position.Right && !root.expanded ? 90 : 0

                PenInputBlocker {
                    anchors.fill: parent
                    enabled: true
                    manager: root.penInput.surfaceManager
                }

                MouseArea {
                    id: hideShowButtonDragPoint
                    objectName: "hideShowButtonDragPoint"
                    property bool dragging: hideShowButtonDragPoint.drag.active
                    anchors.fill: parent
                    drag.target: dragTarget
                    drag.smoothed: false
                    drag.threshold: root.minSize.width / 2
                    onClicked: parent.clicked()

                    onPositionChanged: (mouse) => {
                        if (hideShowButtonDragPoint.dragging) {
                            dragTarget.updatePosition(hideShowButtonDragPoint, Qt.point(mouse.x, mouse.y));
                        }
                    }
                }
            }

            Repeater {
                objectName: "editingTools"
                model: ToolbarProxyModel {
                    sourceModel: toolbarProvider.tools
                    filter: ToolbarModel.ToolGroup.Editing
                }
                delegate: ToolLoader {
                    id: toolLoader
                    objectName: "editingToolLoader_" + item?.objectName
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Repeater {
                objectName: "secondaryTools"
                model: ToolbarProxyModel {
                    sourceModel: toolbarProvider.tools
                    filter: ToolbarModel.ToolGroup.Secondary
                }
                delegate: ToolLoader {
                    id: toolLoader
                    objectName: "secondaryToolLoader_" + item?.objectName
                }
            }
        }
    }

    ArkControls.ToolButton {
        id: closeButton
        objectName: "close-documentview-button"
        iconSource: "qrc:/ark/icons/multicolor/x_circle"
        multicolor: true
        visible: root.expanded && !root.dragging

        anchors {
            right: parent.right
            top: parent.top
            topMargin: root.gestureMargin
        }
        topInset: -root.gestureMargin
        focusPolicy: Qt.NoFocus

        background: Rectangle {
            color: "white"
            visible: root.position === ToolbarPositioner.Position.Top
        }

        // States are not available in the parent item so doing the reposition here
        Item {
            states: [
                State {
                    when: root.position === ToolbarPositioner.Position.Right
                    AnchorChanges {
                        target: closeButton
                        anchors.left: parent.left
                        anchors.right: undefined
                    }
                }
            ]
        }

        // Since the source of the event is not available in the controls onClicked signal, we overlap a mouse area.
        MouseArea {
            anchors.fill: parent
            onClicked: (event) => {
                closeDocumentClicked(event);
            }
        }
    }

    ToolbarDropZone {
        id: dropZone
        anchors.fill: parent
        toolbarPosition: root.position
        dragTarget: dragTarget
        dragging: root.dragging
    }

    states: [
        State {
            name: "left"
            when: root.position === ToolbarPositioner.Position.Left
            AnchorChanges {
                target: toolbar
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: undefined
            }
            PropertyChanges {
                target: toolbar
                width: root.minSize.width
            }
        },
        State {
            name: "right"
            when: root.position === ToolbarPositioner.Position.Right
            AnchorChanges {
                target: toolbar
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: undefined
            }
            PropertyChanges {
                target: toolbar
                width: root.minSize.width
            }
        },
        State {
            name: "top"
            when: root.position === ToolbarPositioner.Position.Top
            AnchorChanges {
                target: toolbar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: undefined
            }
            PropertyChanges {
                target: toolbar
                anchors.rightMargin: root.minSize.width
                height: root.minSize.height
            }
        },
        State {
            name: "bottom"
            when: root.position === ToolbarPositioner.Position.Bottom
            AnchorChanges {
                target: toolbar
                anchors.top: undefined
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }
            PropertyChanges {
                target: toolbar
                height: root.minSize.height
            }
        }
    ]

    function releaseIfNotShowingTooltip(item)
    {
        if (item.toolTip?.visible) {
            return;
        }
        selectLastTool();
    }

    function _select(item, mode = Toolbar.SelectMode.Activate) {
        const stillSameItem = !!item && (item === root.selectedTool);

        console.log(log, "select:", item, "last=", root.selectedPen, "tooltip-completed:", item ? item.toolTip?.OnboardingStateProp.completed : "n/a", "mode:", mode);

        if (stillSameItem) {
            // Same item clicked, simply toggle the foldout (and potentially
            // the tooltip)
            console.assert(item.selected === true);
            console.assert(selectedTool.selected === true);

            // Clicked an item which is active, but not sticky, meaning we
            // should simply pick the pen and leave it.
            if (!item.sticky) {
                console.log(log, " - not stick, selecting last tool");
                selectLastTool();
                return;
            }

            if (mode === Toolbar.SelectMode.DontActivate) {
                if (item.hasFoldout && item.foldoutVisible) {
                    console.log(log, " -", (item.foldoutVisible ? "hiding" : "showing"), "foldout");
                    item.foldout.visible = false;
                }
                if (item.toolTip) {
                    console.log(log, " - hiding tooltip");
                    item.toolTip.OnboardingStateProp.completed = true;
                }
                return;
            }

            if (item.hasFoldout) {
                console.log(log, " -", (item.foldoutVisible ? "hiding" : "showing"), "foldout");
                item.foldout.visible = !item.foldoutVisible;
            }
            // Can this if be collapsed now?
            if (item.toolTip) {
                console.log(log, " - hiding tooltip");
                item.toolTip.OnboardingStateProp.completed = true;
            } else {
                maybeShowToolTip(item);
            }
            return;
        }

        // Deactivate the old current item
        if (selectedTool) {
            console.log(log, " - deselecting:", selectedTool);
            selectedTool.selected = false;

            if (selectedTool.toolTip) {
                console.log(log, " - hiding tooltip");
                selectedTool.toolTip.OnboardingStateProp.completed = true;
            }
            if (selectedTool.hasFoldout) {
                selectedTool.foldout.visible = false;
            }
        }

        // Activate the new current item
        selectedTool = item;
        selectedTool.selected = true;

        if (mode === Toolbar.SelectMode.DontActivate) {
            return;
        }
        if (selectedTool.hasFoldout && (!selectedTool.sticky || !selectedTool.toolTip?.OnboardingStateProp.completed)) {
            console.log(log, " - showing foldout:");
            selectedTool.foldout.visible = true;
        }
        maybeShowToolTip(item);
    }

    function maybeShowToolTip(item) {
        if (item.toolTip?.OnboardingStateProp.completed ?? true) {
            return;
        }
        if (toolbarConfiguration.hideTooltips) {
            return;
        }

        console.log(log, " - showing tooltip");
        item.toolTip.readyToShow = Qt.binding(() => item?.selected ?? false );
    }
}
