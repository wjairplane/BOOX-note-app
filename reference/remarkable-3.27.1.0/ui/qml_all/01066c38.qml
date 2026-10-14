import QtQuick

import xofm.libs.epaper as Epaper
import xofm.libs.ui

TextInput {
    id: textEdit

    FontStyleHelper {
        target: textEdit
        styleStrategy: FontStyleHelper.NoAntialias // Speeds up typing
    }

    property color cursorColor: color
    property int cursorHeight: font.pixelSize
    property bool autoSelectOnFocus: false
    color: "black"
    selectionColor: "black"
    selectedTextColor: "white"
    clip: true
    topPadding: 4 // Needed for uppercase accents like ÉË etc
    bottomPadding: topPadding
    cursorDelegate: Rectangle {
        width: 2
        height: cursorHeight
        color: cursorColor
        // We want the cursor to auto-hide and not blink
        // similar to what we do in sceneView
        visible: !cursorTimeout.running && textEdit.activeFocus
    }
    onActiveFocusChanged: {
        if (!activeFocus) {
            return;
        }

        if(!autoSelectOnFocus) {
            return;
        }
        selectAll();
    }

    onTextChanged: {
        cursorTimeout.restart();
    }

    Timer {
        id: cursorTimeout
        interval: 500
    }

    Epaper.ScreenModeItem {
        anchors.fill: parent
        visible: parent.focus
        mode: Epaper.ScreenModeItem.Animation
        objectName: "general-touch-input"
    }
}
