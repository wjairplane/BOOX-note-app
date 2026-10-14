import QtQuick
import device.global
import device.ui.controls
import device.ui.headers
import com.remarkable
import common

import ark.controls as ArkControls

Popup {
    id: adjustViewOverlay

    property DeviceSceneView view

    property real savedScale
    property point savedCenter

    readonly property real topMargin: topBar.height + ArkControls.Values.margin.vertical.medium
    readonly property real bottomMargin: ArkControls.Values.margin.vertical.large
    readonly property real adjustScale: height > 0 ? (height - (topMargin + bottomMargin)) / height : 1
    readonly property real horizontalMargin: Math.round(width * (1 - adjustScale)) / 2

    signal viewSaved()

    function start() {
        savedScale = view.tileManager.scale;
        savedCenter = view.tileManager.center;

        showPopup();

        view.sceneView.setFocalPoint(savedCenter, savedScale * adjustScale);
    }

    function commit() {
        const scale = view.tileManager.scale / adjustScale;
        const center = view.tileManager.center;

        const pageRect = view.controller.primaryContentRect;

        hidePopup();

        LibraryController.setCustomZoomFit(
            view.document.id, scale, center, Qt.size(Math.round(pageRect.width), Math.round(pageRect.height)));

        view.resetViewport();

        viewSaved();
    }

    function cancel() {
        hidePopup();

        view.sceneView.setFocalPoint(savedCenter, savedScale);
    }

    outsidePenInputBlocked: true

    Item {
        id: viewBorder

        x: adjustViewOverlay.horizontalMargin
        y: adjustViewOverlay.topMargin
        width: adjustViewOverlay.width - (2 * x)
        height: adjustViewOverlay.height - adjustViewOverlay.topMargin - adjustViewOverlay.bottomMargin

        Rectangle { // top
            x: -Values.outlineSize
            y: -Values.outlineSize
            width: viewBorder.width + Values.outlineSize
            height: Values.outlineSize

            color: Values.colorBlack
        }

        Rectangle { // left
            x: -Values.outlineSize
            width: Values.outlineSize
            height: viewBorder.height + Values.outlineSize

            color: Values.colorBlack
        }

        Rectangle { // bottom
            y: viewBorder.height
            width: viewBorder.width + Values.outlineSize
            height: Values.outlineSize

            color: Values.colorBlack
        }

        Rectangle { // right
            x: viewBorder.width
            y: -Values.outlineSize
            width: Values.outlineSize
            height: viewBorder.height + Values.outlineSize

            color: Values.colorBlack
        }
    }

    ArkControls.Label {
        y: adjustViewOverlay.height - height
        width: adjustViewOverlay.width
        height: adjustViewOverlay.bottomMargin
        type: ArkControls.Label.SmallSubtle

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        //: Custom view instructions underneath frame
        text: qsTr("Zoom and pan to adjust the page")
    }

    Header {
        id: topBar
        visible: true
        acceptEnabled: true
        hideOnDismiss: false
        blackOnWhite: false
        //: Custom view title in action bar; recommended character limit for translation: 32
        text: qsTr("Custom view")
        //: Custom view regressive button in action bar
        rejectText: qsTr("Cancel")
        //: Custom view progressive button in action bar
        acceptText: qsTr("Set")
        onAccepted: {
            adjustViewOverlay.commit();
        }
        onRejected: {
            adjustViewOverlay.cancel();
        }
    }
}
