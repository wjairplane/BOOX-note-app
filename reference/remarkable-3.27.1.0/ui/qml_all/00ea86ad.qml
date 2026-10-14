import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "tagsMenu"
    type: ToolbarTool.Type.FoldoutButton

    property bool isTagged: toolbar.isTagged

    label: qsTr("Tags")
    iconSource: isTagged ? "qrc:/ark/icons/tag_inverted" : "qrc:/ark/icons/tag"

    foldoutContent: toolbar.tagsFoldout
    Connections {
        target: foldout
        function onParentChanged() {
            foldoutContent.parent = foldout;
        }
    }

    toolTip: ToolTip {
        id: tagsToolTip
        type: ArkTokens.Tooltip.secondary
        //: Recommended character limit for translation: 20
        caption: qsTr("Tags")
        readonly property Item source: root.foldout.parent instanceof StackView ? root.foldout : root
        positionHint: root.toolbar.tooltipPositionHint
        parent: root.toolbar.tooltipOverlay
        container: root.toolbar.tooltipContainer
        pointTo: source.mapToItem(root.toolbar.tooltipOverlay, root.foldout.x, root.foldout.y, root.foldout.width, root.foldout.height)
        OnboardingStateProp.key: "Tags_Introduction"
    }

    onFoldoutVisibleChanged: root.toolbar.tagsPopupVisibleChanged(foldoutVisible)
    onPressed: root.select(root)
}
