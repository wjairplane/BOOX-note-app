import QtQuick

import com.remarkable
import common

import ark.controls as ArkControls

Rectangle {
    id: root

    // Input

    required property int buttonSize
    required property var selectedStyle
    required property string iconSource
    required property var style
    property bool inverted: false

    // Internal

    // Selected check current selected style and a extra check for checkboxes since it can be toggled.
    readonly property bool selected: TextFormattingUtils.isFormattingButtonSelected(root.style, root.selectedStyle)
    readonly property bool invertedSelected: inverted ? !selected : selected

    // Signals
    signal clicked(int style)

    color: invertedSelected ? Values.colorBlack : Values.colorWhite
    width: root.buttonSize
    height: root.buttonSize
    ArkControls.Icon {
        size: ArkControls.Values.iconSize.medium
        color: root.invertedSelected ? Values.colorWhite : Values.colorBlack
        source: root.iconSource
        anchors.centerIn: parent
        antialiasing: false
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked(root.style)
    }
}
