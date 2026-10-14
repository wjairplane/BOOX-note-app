import QtQuick
import com.remarkable
import common
import xofm.libs.devicesceneview.impl
import xofm.libs.sceneview
import ark.controls as ArkControls
import ark.tokens as ArkTokens

Item {
    id: gestureHandler

    required property ScenePenInputHandler penHandler
    required property rect availableSceneRect

    property SceneTileManager tileManager
    property var sceneToViewTransform
    property var sceneRect

    enum SelectionAction {
        NoAction,
        WaitForInput,
        SelectBelow
    }
    /// the action to do on holdEnded
    property var pendingAction: PartitionSelectGesture.SelectionAction.NoAction

    property bool active: pendingAction !== PartitionSelectGesture.SelectionAction.NoAction
    /// the point where the hold started in scene space
    property point initialPos
    /// true while the pen is down
    property bool dragging: false

    readonly property int verticalThreshold: 15
    readonly property int arrowOffset: 5
    readonly property int gestureId: ScenePenInputHandler.PartitionGesture

    signal selectWithLine(var stroke);
    signal gestureFinished();

    function _endCurrentOperation() {
        pendingAction = PartitionSelectGesture.SelectionAction.NoAction;
        dragging = false;
        selectOverlay.clearLine();
        gestureHandler.gestureFinished();
    }

    function _selectAction(action) {
        let lasso = undefined;
        if (action === PartitionSelectGesture.SelectionAction.SelectBelow) {
            lasso = selectOverlay.getArea(sceneRect.left, sceneRect.right, sceneRect.bottom);
            gestureHandler.selectWithLine(lasso);
        }
        _endCurrentOperation();
    }

    function _positionControls(line) {
        selectOverlay.setLine(line);
        _updateButtonPositions();
    }

    function _updateButtonPositions() {
        let viewPoint = tileManager.sceneToView(selectOverlay.getInitialPosition());

        // ensure button is on screen
        const deviceLeftEdge = availableSceneRect.left + Values.outlineSize;
        const deviceRightEdge = availableSceneRect.right - Values.outlineSize - (selectBelow.width);
        const leftLimit = Math.max(viewPoint.x - (selectBelow.width / 2), deviceLeftEdge);
        viewPoint.x = Math.min(leftLimit, deviceRightEdge);

        selectBelow.x = viewPoint.x;
        selectBelow.y = viewPoint.y + arrowOffset;
    }

    function startGesture(data) {
        dragging = true;
        _positionControls(data.line);
        initialPos = selectOverlay.getInitialPosition();
        pendingAction = PartitionSelectGesture.SelectionAction.WaitForInput;
    }

    onSceneToViewTransformChanged: {
        selectOverlay.refreshImage();
        _updateButtonPositions();
    }

    SelectGestureOverlay {
        id: selectOverlay
        anchors.fill: parent
        tileManager: gestureHandler.tileManager
    }

    MouseArea {
        id: cancelArea
        anchors.fill: parent
        enabled: pendingAction === PartitionSelectGesture.SelectionAction.WaitForInput

        onPressed: _endCurrentOperation()
    }

    ArkControls.ContextualMenu {
        id: selectBelow
        visible: pendingAction !== PartitionSelectGesture.SelectionAction.NoAction
        enabled: visible && !dragging || (pendingAction !== PartitionSelectGesture.SelectionAction.NoAction)

        ArkControls.ContextualMenu.Button {
            type: ArkTokens.ContextualMenu.secondary
            focusPolicy: Qt.NoFocus
            iconSource: "qrc:/ark/icons/selection_tool"
            //: Recommended character limit for translation: 20
            text: qsTr("Select below")
            onClicked: _selectAction(PartitionSelectGesture.SelectionAction.SelectBelow)
        }
    }

    Connections {
        target: penHandler

        function onGestureMoved(pos) {
            let scenePos = tileManager.viewToScene(mapFromItem(null, pos));
            let dy = initialPos.y - scenePos.y;
            if (dy < -verticalThreshold) {
                pendingAction = PartitionSelectGesture.SelectionAction.SelectBelow;
            } else {
                pendingAction = PartitionSelectGesture.SelectionAction.WaitForInput;
            }
        }

        function onGestureEnded(pos) {
            if (pendingAction !== PartitionSelectGesture.SelectionAction.WaitForInput) {
                _selectAction(pendingAction);
            }
        }
    }
}
