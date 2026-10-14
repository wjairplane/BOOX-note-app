import QtQuick

import com.remarkable
import common
import device.ui.text

Rectangle {
    id: zoomButton
    implicitWidth: icon.width + margin * 2.5
    height: icon.implicitHeight + (margin * 2)
    color: inverted ? Values.colorBlack : Values.colorWhite

    readonly property int margin: 32
    property int zoomMode
    property bool inverted: false
    property real zoomLevel: 1.0
    property real defaultScale: 1.0
    property real zoomMin: 0.5
    property real zoomMax: 5.0


    property alias topGestureMargin: mouseArea.anchors.topMargin
    property alias bottomGestureMargin: mouseArea.anchors.bottomMargin

    property bool didZoom: false
    onZoomLevelChanged: didZoom = true
    onVisibleChanged: {
        if (!visible) {
            didZoom = false;
        }
    }

    signal clicked(var mouse)

    IconTitle {
        id: icon
        objectName: "icon"

        anchors.centerIn: parent

        antialiasing: false
        color: zoomButton.inverted ? Values.colorWhite : Values.colorBlack
        iconSource: {
            switch (zoomMode) {
            case Document.FitToWidth:
                return "qrc:/ark/icons/fit_to_width";
            case Document.FitToHeight:
                return "qrc:/ark/icons/fit_to_height";
            case Document.CustomFit:
                return "qrc:/ark/icons/fit_custom";
            default:
                return "qrc:/ark/icons/fit_to_width";
            }
        }

        readonly property string symbol: "x"
        title: mapZoomLevel(zoomButton.zoomLevel) + symbol
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: (mouse) => {
            zoomButton.clicked(mouse);
        }
    }

    function mapZoomLevel(zoomLevel) {
        // When opening a PDF, we change the defaultScale to make it fit within the view and in addition we scale the pen thickness similarly to make it appear as 1x on the new defaultScale.
        // The mapped min and max values are intended to reflect the pen thickness, we therefore scale them according to the new defaultScale.
        let properties = {
            "zoomMin": zoomButton.zoomMin,
            "zoomMax": zoomButton.zoomMax,
            "mappedMin": zoomButton.zoomMin / defaultScale,
            "mappedMax": zoomButton.zoomMax / defaultScale,
            "mappedCenter": 1.0,
            "decimals": 1
        };

        // Special case when zoom level is at default scale, we always return 1.0
        if (Math.abs(zoomLevel - defaultScale) < 0.001) {
            return properties.mappedCenter.toFixed(properties.decimals);
        }

        // Special case so that mappedMin does not become 0.
        if (properties.mappedMin <= 0.1) {
            properties.mappedMin = 0.1;
        }

        const mappedZoomLevel = zoomLevel < defaultScale
                        ? mapValueToRange(zoomLevel, properties.zoomMin, defaultScale, properties.mappedMin, properties.mappedCenter)
                        : mapValueToRange(zoomLevel, defaultScale, properties.zoomMax, properties.mappedCenter, properties.mappedMax);
        return mappedZoomLevel.toFixed(properties.decimals);
    }

    function mapValueToRange(x, inMin, inMax, outMin, outMax) {
        return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
    }
}
