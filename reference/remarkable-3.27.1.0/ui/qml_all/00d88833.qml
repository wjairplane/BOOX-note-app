import QtQuick
import device.ui.text
import common

import ark.controls as ArkControls

Rectangle {
    id: pill

    readonly property color _partialSelectionColor: "#cccccc"

    property bool selected: false
    property bool editing: false
    property bool partiallySelected: false
    property alias text: tagLabel.text
    readonly property alias pressed: mouseArea.pressed
    property var navigationHandler
    property bool drawFocus: !!navigationHandler && navigationHandler.current === pill
    property int stdPadding: 50
    readonly property color foregroundColor: selected && !editing ? Values.colorWhite : Values.colorBlack
    readonly property color backgroundColor: foregroundColor === Values.colorWhite ? Values.colorBlack : Values.colorWhite
    property int maxWidth: -1

    signal clicked
    signal pressAndHold

    width: tagLabel.width + stdPadding
    height: tagLabel.height + 2 * 9
    color: partiallySelected ? _partialSelectionColor : backgroundColor
    radius: height / 2
    border.width: 2
    border.color: partiallySelected ? _partialSelectionColor : Values.colorBlack
    antialiasing: false

    Rectangle {
        anchors.fill: parent
        anchors.margins: -10
        border.width: 8
        border.color: Values.colorBlack
        color: "transparent"
        radius: height / 2
        antialiasing: pill.antialiasing
        visible: editing
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -10
        onClicked: pill.clicked()
        onPressAndHold: pill.pressAndHold()
    }

    ArkControls.Label {
        id: tagLabel
        type: ArkControls.Label.SmallSubtle
        anchors.centerIn: parent
        color: foregroundColor
        horizontalAlignment: Text.AlignHCenter
        width: {
            // if a maxWidth is provided, consider it in the calculation of the Label's width
            if (maxWidth > 0) {
                return Math.min(maxWidth, Math.max(50, implicitWidth));
            }
            // otherwise, just ensure a minimumWidth is applied
            return Math.max(50, implicitWidth);
        }
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: pill.antialiasing
        elide: maxWidth > 0 ? Text.ElideMiddle : Text.ElideNone
    }

    FocusFrame {
        id: focusFrame
        anchors.fill: parent
        visible: drawFocus
        borderColor: foregroundColor
        width: tagLabel.width + stdPadding
        height: parent.height
        radius: (height / 2) + 4
    }
}
