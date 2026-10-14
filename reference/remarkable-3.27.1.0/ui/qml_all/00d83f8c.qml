import QtQuick
import common
import device.global

Item {
    id: button
    property bool pressed: (releasable && _mouseArea.pressed) || active
    property bool inverted: false
    property bool preventDoubleClick: false
    property bool active: false
    property var foregroundColor: inverted ? Values.colorWhite : Values.colorBlack
    property var backgroundColor: inverted ? Values.colorBlack : Values.colorWhite
    property bool releasable: true
    property int pressMargin: 0
    property bool delayedAntialiasing: true // toggles initial and faster non-aa repaint
    property var navigationHandler
    property bool drawFocus: !!navigationHandler && navigationHandler.current === button
    property alias focusFrame: focusFrame

    signal clicked(var mouse)

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        anchors.margins: pressMargin
        // MouseArea.enabled is separate from Item.enabled
        enabled: parent.enabled
        onPressed: (mouse) => {
            if (releasable) {
                return;
            }

            mouse.accepted = true;
            button.clicked(mouse);
        }
        onClicked: (mouse) => {
            if (releasable) {
                button.clicked(mouse);
            }
        }
    }
    FocusFrame {
        id: focusFrame
        anchors.fill: parent
        visible: drawFocus
        borderColor: (inverted || active) ? Values.colorWhite : Values.colorBlack
    }
}
