import QtQuick

import common // Values

import xofm.libs.qtgui // BaseView
import xofm.libs.epaper as Epaper

import xofm.libs.retail // RetailSettings

BaseView {
    id: root

    required property RetailSettings retailSettings
    required property var metrics
    required property var ghostBuster
    required property var activityMonitor

    property var paths: []
    property int iterator: 0
    readonly property bool markerConnected: activityMonitor.markerDocked

    Binding {
        target: root.retailSettings
        property: "carouselActive"
        value: root.visible
    }

    function close() {
        root.ghostBuster.retailRefresh();
        root.metrics.sessionStarted();
        root.windowNavigator.open("legacydevice/window/main", { documentId: root.retailSettings.defaultDocumentId, openedFrom: "retail" });
        root.windowNavigator.close();
    }

    onOpened: (args) => {
        const { screensaverPaths } = args;
        if (!screensaverPaths){
            console.warn("Screensaver requires screensaverPaths");
            root.windowNavigator.close();
            return;
        }
        root.paths = screensaverPaths;
        screenImage.source = "file:///" + root.paths[0];
        timer.start();
        root.metrics.sessionEnded();
    }

    onMarkerConnectedChanged: {
        if (!markerConnected) {
            root.close();
            return;
        }
    }
    contentItem: Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: Values.colorWhite
        }
        Image {
            id: screenImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close();
        }
    }

    Timer {
        id: timer
        interval: root.retailSettings.carouselTimerMs
        repeat: true
        onTriggered: {
            const i = (root.iterator + 1) % root.paths.length;
            if (i === root.iterator) {
                return;
            }
            root.iterator = i;
            root.ghostBuster.retailRefresh();
            screenImage.source = "file:///" + root.paths[root.iterator];
        }
    }

    Epaper.ScreenModeItem {
        mode: Epaper.ScreenModeItem.Content
        anchors.fill: parent
        objectName: "retail-carousel"
    }
}
