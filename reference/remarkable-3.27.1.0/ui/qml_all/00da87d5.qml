import QtQuick
import com.remarkable
import common
import xofm.libs.devicesceneview.impl

ShapesOverlay {
    id: snapHandler

    property ScenePenInputHandler penHandler
    property PenInputSurface penInputSurface
    property var lastPos: undefined
    property var sceneToViewTransform
    property var viewToSceneTransform
    property bool active: Object.keys(gestureData).length > 0
    readonly property int gestureId: ScenePenInputHandler.DrawAndHoldGesture

    signal requestAddLine(var stroke);
    signal gestureFinished();
    signal convertedShapeAdded(string shapeType);

    function resetSnap() {
        snapImageTimer.stop();
        gestureData = {};
        lastPos = undefined;
        if (sceneToViewTransform) {
            snapHandler.reset(sceneToViewTransform);
        }
        snapHandler.gestureFinished();
    }

    function startGesture(data) {
        if (data && sceneToViewTransform && viewToSceneTransform) {
            snapImageTimer.start();
            gestureData = data;
            lastPos = data.pos;
            snapHandler.updateImage(gestureData, lastPos, sceneToViewTransform, viewToSceneTransform);
        } else {
            console.warn("Invalid arguments to updateImage: gestureData: " + gestureData +
                         ", sceneToViewTransform: " + sceneToViewTransform +
                         ", viewToSceneTransform: " + viewToSceneTransform);
            snapHandler.resetSnap();
        }
    }

    Timer {
        id: snapImageTimer
        interval: 100
        repeat: true
        onTriggered: {
            if (lastPos && gestureData && sceneToViewTransform && viewToSceneTransform) {
                snapHandler.updateImage(gestureData, lastPos, sceneToViewTransform, viewToSceneTransform);
            } else {
                console.warn("Invalid arguments to updateImage: lastPos: " + lastPos +
                             ", gestureData: " + gestureData +
                             ", sceneToViewTransform: " + sceneToViewTransform +
                             ", viewToSceneTransform: " + viewToSceneTransform);
                snapHandler.resetSnap();
            }
        }
    }

    Connections {
        target: penHandler

        function onGestureMoved (pos) {
            lastPos = pos;
        }

        function onGestureEnded (pos) {
            finishGesture();
        }
    }

    function finishGesture() {
        const lastLine = snapHandler.lastLine();
        // moving line back to the origin effectively cancels
        if (lastLine.lineLength() > 0) {
            snapHandler.requestAddLine(lastLine);
            convertedShapeAdded(gestureData.name);
        }
        snapHandler.resetSnap();
    }
}
