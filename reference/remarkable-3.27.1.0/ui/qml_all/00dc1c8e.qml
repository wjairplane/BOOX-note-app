import QtQuick
import common

FocusScope {

    default property alias data: mouseArea.data

    property alias mouseAreaEnabled: mouseArea.enabled
    property alias color: rectangle.color
    property alias border: rectangle.border

    // Fills the background with a solid color.
    Rectangle {
        id: rectangle

        anchors.fill: parent
        color: Values.colorWhite
    }

    // Intercepts multi-touch events so they aren't
    // propagated to the underlying UI
    MultiPointTouchArea {
        id: multiTouch

        enabled: mouseAreaEnabled
        mouseEnabled: mouseAreaEnabled
        anchors.fill: parent
    }

    // Intercepts mouse events so avoid them leaking down to
    // the underlying UI.
    MouseArea {
        id: mouseArea

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        anchors.fill: parent
        onClicked: (mouse) => {
            /*Eat clicks*/
            mouse.accept = true;
        }
    }
}
