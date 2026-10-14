import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import xofm.libs.onboarding
import xofm.libs.toolbar

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "settingsMenu"
    type: ToolbarTool.Type.ToolbarButton

    // Input properties
    property bool notePage: toolbar.notePage
    property bool pdfPage: toolbar.pdfPage
    property bool ebookPage: toolbar.ebookPage
    property string documentType: toolbar.documentType
    property string title: toolbar.documentTitle
    property int currentPage: toolbar.currentPage
    property int pageCount: toolbar.pageCount
    property int zoomMode
    property bool backgroundFilterVisible: toolbar.backgroundFilterVisible
    property bool hasAutorotation: toolbar.hasAutorotation

    property ToolbarTool activeTool

    readonly property int stackViewDepth: stackView.depth

    function selectTool(tool) {
        const previousTool = root.activeTool;
        root.activeTool = tool;

        if (root.toolbar.useStackView) {
            _handleStackViewFoldout(tool);
        } else {
            _handleNestedFoldout(previousTool, tool);
        }

        if(previousTool?.toolTip) {
            previousTool.toolTip.OnboardingStateProp.completed = true;
        }
        if(root.activeTool?.toolTip) {
            root.activeTool.toolTip.readyToShow = true;
        }
    }

    function _handleStackViewFoldout(tool) {
        if (!tool) {
            stackView.reset();
            return;
        }

        if (tool.hasFoldout) {
            stackView.push(tool.foldout);
        } else {
            console.warn("Warning: Selected tool has no foldout to display");
        }
    }

    function _handleNestedFoldout(previousTool, newTool) {
        // Clean up previous tool's foldout
        if (previousTool && previousTool.hasFoldout) {
            previousTool.foldout.visible = false;
        }

        // Set up new tool's foldout if available
        if (newTool && newTool.hasFoldout) {
            newTool.foldout.visible = true;
        }
    }

    // Signals
    signal settingsSelected
    signal reportAdjustViewClicked

    signal toggleBackgroundFilter(value : string)
    signal toolbarPositionSelected(value : int)

    // Reimplemented state from ToolbarTool
    label: {
        if (documentType === "pdf") {
            return qsTr("PDF settings");
        } else if (documentType === "ebook") {
            return qsTr("Ebook settings");
        }
        return qsTr("Notebook settings");
    }

    iconSource: {
        if(stackView?.depth > 1) {
            return "qrc:/ark/icons/chevron_left";
        }
        return "qrc:/ark/icons/three_dots_vertical";
    }


    component ToolLoader: Loader {
        property var toolType: model.tool
        property url sourceUrl: model.component
        visible: item?.shown ?? false
        Layout.fillWidth: true
        asynchronous: !root.toolbar.visible
        onSourceUrlChanged: {
            if (sourceUrl === "") {
                return;
            }
            const requiredProperties = { toolbar : root.toolbar, type : ToolbarTool.Type.FoldoutButton };
            setSource(sourceUrl, requiredProperties);
        }

        onLoaded: {
                item.selected = Qt.binding(() => { return visible && root.activeTool === item && root.activeTool.hasFoldout});
                item.foldoutPosition = Qt.binding(() => { return root.foldout.position === ToolbarFoldout.Position.Right
                                                        ? ToolbarFoldout.Position.Right
                                                        : ToolbarFoldout.Position.Left });
        }

        Connections {
            target: item

            function onSelect(tool) {
                root.selectTool(tool);
            }

            function onVisibleChanged() {
                if (!item.visible && item.hasFoldout) {
                    item.foldout.visible = false;
                }
            }
        }
    }

    foldoutContent: StackView {
        id: stackView
        implicitWidth: currentItem.implicitWidth
        implicitHeight: currentItem.implicitHeight
        initialItem: settingsComponent
        focusPolicy: Qt.NoFocus
        popEnter: Transition {}
        popExit: Transition {}
        pushEnter: Transition {}
        pushExit: Transition {}
        replaceEnter: Transition {}
        replaceExit: Transition {}
        function reset() {
            popToIndex(0);
            if(root.activeTool?.foldoutVisible) {
                root.activeTool.foldout.visible = false;
            }

            if(root.activeTool?.toolTip) {
                root.activeTool.toolTip.OnboardingStateProp.completed = true;
            }

            root.activeTool = null;
        }
        onVisibleChanged: {
            // reset the stack when we close
            if (!visible) {
                reset();
            }
        }
    }

    Component {
        id: settingsComponent
        ColumnLayout {
        id: content
        spacing: 0

            Repeater {
                model: ToolbarProxyModel {
                    sourceModel: root.toolbar.toolbarProvider.tools
                    filter: ToolbarModel.ToolGroup.ExtraEditing
                }
                delegate: ToolLoader {
                    id: extraEditingToolLoader
                    objectName: "extraEditingToolLoader_" + item?.objectName
                    active: !root.toolbar.showExtraEditingTools
                }
            }

            Repeater {
                model: ToolbarProxyModel {
                    sourceModel: root.toolbar.toolbarProvider.tools
                    filter: ToolbarModel.ToolGroup.Toggle
                }
                delegate: ToolLoader {
                    id: toggleToolLoader
                    objectName: "toggleToolLoader_" + item?.objectName
                    active: !root.toolbar.showExtraEditingTools
                }
            }

            ArkControls.FoldoutDivider {
                Layout.fillWidth: true
                visible: utilityTools.count > 0 || root.toolbar.showExtraEditingTools
            }

            Repeater {
                id: utilityTools
                model: ToolbarProxyModel {
                    sourceModel: root.toolbar.toolbarProvider.tools
                    filter: ToolbarModel.ToolGroup.Utility
                }
                delegate: ToolLoader {
                    id: utilityToolLoader
                    objectName: "utilityToolLoader_" + item?.objectName
                }
            }

            Repeater {
                model: ToolbarProxyModel {
                    sourceModel: root.toolbar.toolbarProvider.tools
                    filter: ToolbarModel.ToolGroup.Adjustment
                }
                delegate: ToolLoader {
                    id: adjustmentToolLoader
                    objectName: "adjustmentToolLoader_" + item?.objectName
                    active: !root.toolbar.toolbarProvider.hasAdjustmentToolsGrouping
                }
            }

            Repeater {
                model: ToolbarProxyModel {
                    sourceModel: root.toolbar.toolbarProvider.tools
                    filter: ToolbarModel.ToolGroup.Management
                }
                delegate: ToolLoader {
                    id: managementToolLoader
                    objectName: "managementToolLoader_" + item?.objectName
                }
            }
        }
    }

    onSettingsSelected: root.toolbar.settingsSelected()
    onPressed: {
        if(stackView.depth > 1) {
            if(root.activeTool?.toolTip?.OnboardingStateProp.completed === false) {
                root.activeTool.toolTip.OnboardingStateProp.completed = true;
            }

            root.activeTool = null;
            stackView.popCurrentItem();
            return;
        }
        root.select(root);
    }
    onReportAdjustViewClicked: root.toolbar.reportAdjustViewClicked()
}
