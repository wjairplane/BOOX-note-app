import QtQuick
import com.remarkable
import common
import xofm.libs.sceneview

import ark.tokens as ArkTokens
import ark.controls as ArkControls

GlyphSelection {
    id: root

    property alias availableSceneRect: selectionMenu.availableRect

    property string _selectedText: ""
    readonly property string selectedText: _selectedText
    property bool isMenuRendered: false

    signal clicked
    signal close

    function setSelection(areas, text) {
        root.updateSelectedAreas(areas);
        root._selectedText = text;
    }

    function open() {
        if (root.selectionBoundingRect.isEmpty) {
            return;
        }

        isMenuRendered = false;
        root.visible = true;
    }

    function updatePosition() {
        selectionMenu.selectionRect = selectionBoundingRect;
    }

    visible: false

    onSelectionBoundingRectChanged: updatePosition()
    onSceneToViewTransformChanged: updatePosition()

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (isMenuRendered) {
                root.close()
            }
        }
    }

    SelectionContextualMenu {
        id: selectionMenu
        availableRect: Qt.rect(0, 0, glyphSelection.width, glyphSelection.height)
        selectionRect: glyphSelection.selectionBoundingRect
        visible: !root.selectionBoundingRect.isEmpty

        onMenuRendered: {
            root.isMenuRendered = true
        }

        ArkControls.ContextualMenu.Button {
            id: glyphSelectionCopy
            focusPolicy: Qt.NoFocus
            type: selectionMenu.type
            iconSource: "qrc:/ark/icons/copy"
            text: qsTr("Copy")
            onClicked: root.clicked()
        }
    }
}
