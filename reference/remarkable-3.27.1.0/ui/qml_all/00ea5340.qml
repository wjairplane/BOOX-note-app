import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding
import xofm.libs.toolbar

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "filterMenu"

    FilterStateModel {
        id: filterStates
    }

    readonly property filterState activeFilterState: root.toolbar.backgroundFilter

    shown: toolbar.backgroundFilterVisible
    type: ToolbarTool.Type.FoldoutButton
    label: qsTr("Increase contrast")
    iconSource: activeFilterState.filterIcon
    description: qsTranslate("xofm::libs::toolbar::FilterStateModel", activeFilterState.filterLabel)

    onPressed: root.select(root)

    foldoutContent: ColumnLayout {
        spacing: 0
        Repeater {
            model: filterStates
            ArkControls.FoldoutItem {
                required property string filterLabel
                required property string filterIcon
                required property string filterTag
                label: qsTranslate("xofm::libs::toolbar::FilterStateModel", filterLabel)
                selected: filterTag == root.activeFilterState.filterTag
                iconSource: filterIcon
                antialiasing: root.antialiasing
                focusPolicy: Qt.NoFocus
                Layout.fillWidth: true
                onClicked: {
                    if (!highlighted) {
                        root.toolbar.toggleBackgroundFilter(filterTag);
                    }
                }
            }
        }
    }
}
