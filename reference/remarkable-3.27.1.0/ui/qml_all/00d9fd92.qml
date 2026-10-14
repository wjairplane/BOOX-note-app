import QtQuick

import common
import com.remarkable
import device.ui.controls
import xofm.libs.toolbar

import ark.controls as ArkControls

PageSlider {
    id: pageSlider

    required property var toolbar

    signal pageNavigatedTelemetry(string source)
    signal quickBrowseInteractedTelemetry(string interaction)
    signal didQuickBrowse()

    // These properties ensures that we only enter mono mode
    // when page thumbnails are shown, not when the slider is first visible.
    property bool requestMono
    property bool wasAccepted

    from: 0
    to: pageCount - 1
    portrait: portrait

    anchors {
        left: parent.left
        leftMargin: toolbar.shown && toolbar.position === ToolbarPositioner.Position.Left ? toolbar.innerWidth : 0
        rightMargin: toolbar.shown && toolbar.position === ToolbarPositioner.Position.Right ? toolbar.innerWidth : 0
        right: parent.right
        bottom: parent.bottom
        alignWhenCentered: true
        bottomMargin: {
            let margin = 50;
            // Add space for the page label if the notification bar and page label are visible
            if (documentView.notificationBar && documentView.pageLabel &&
                    documentView.notificationBar.visible && documentView.pageLabel.visible) {
                margin += documentView.pageLabel.height;
            }

            // Add space for the toolbar if it's shown at the bottom
            if (toolbar && toolbar.position === ToolbarPositioner.Position.Bottom && toolbar.shown) {
                margin += toolbar.innerHeight;
            }
            return margin;
        }
    }

    leftVisibleMargin: ArkControls.Values.spacing.xlarge
    rightVisibleMargin: ArkControls.Values.spacing.xlarge

    onAccepted: {
        didQuickBrowse();
        wasAccepted = true;
        requestMono = false;
        const pageNumber = pageSlider.value;
        if (pageNumber != documentView.currentPage) {
            pageNavigatedTelemetry("Quick Browse");
            if (pageNumber != documentView.lastPageLocation) {
                quickBrowseInteractedTelemetry("New location");
            } else {
                quickBrowseInteractedTelemetry("Previous location");
            }
        } else {
            quickBrowseInteractedTelemetry("Current location");
        }
        documentView.openPage(pageNumber, DocumentView.ScrollPosition.SaveAndRestore);
    }

    onPageThumbnailVisibleChanged: {
        if (!wasAccepted) {
            requestMono = true;
        }
    }

    onVisibleChanged: {
        wasAccepted = false;
        requestMono = false;
        if (!visible) {
            quickBrowseInteractedTelemetry("Close");
        } else {
            quickBrowseInteractedTelemetry("Open");
        }
        hidePageSliderTimer.stop()
    }

    onDocumentChanged: {
        pageSlider.visible = false;
    }

    function delayAutoHide() {
        if (hidePageSliderTimer.running) {
            hidePageSliderTimer.restart();
        }
    }

    Timer {
        id: hidePageSliderTimer
        interval: Values.popupTimeout
        onTriggered: {
            if (!pageSlider.pressed) {
                pageSlider.visible = false;
            }
        }
    }

    onPressedChanged: {
        if (!pageSlider.pressed) {
            hidePageSliderTimer.restart();
        }
    }

    Connections {
        target: DeviceApp
        function onPenCloseChanged() {
            if (pageSlider.visible && DeviceApp.penClose) {
                hidePageSliderTimer.start();
            }
        }
    }
}
