import QtQuick
import QtQuick.Layouts

import xofm.libs.toolbar
import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "adjustmentToolsMenu"

    type: ToolbarTool.Type.FoldoutButton

    label: qsTr("Adjust view")
    iconSource: "qrc:/ark/icons/sliders_horizontal"
    foldoutTopDivider: true
    shown: toolbar.pdfPage || toolbar.ebookPage || toolbar.backgroundFilterVisible

    onPressed: root.select(root)

    component ToolLoader: Loader {
        property var toolType: model.tool
        property url sourceUrl: model.component
        visible: item?.shown ?? false
        Layout.fillWidth: true
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
                root.select(tool);
            }
        }
    }

    foldoutContent: ColumnLayout {
        spacing: 0
        Repeater {
            model: ToolbarProxyModel {
                sourceModel: root.toolbar.toolbarProvider.tools
                filter: ToolbarModel.ToolGroup.Adjustment
            }
            delegate: ToolLoader {
                id: toolLoader
            }
        }
    }
}
