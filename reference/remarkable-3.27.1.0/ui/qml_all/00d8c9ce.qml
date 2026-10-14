import QtQuick
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import device.global

import ark.tokens as ArkTokens
import ark.controls as ArkControls

Rectangle {
    id: root
    required property string backText
    required property string imageSource

    signal close

    MouseArea {
        anchors.fill: parent
        onClicked: (mouse) => {
            mouse.accept = true;
        }
        onPressAndHold: (mouse) => {
            mouse.accept = true;
        }
    }

    focus: true
    visible: true
    color: Values.colorBlack

    ArkControls.NavigationBar {
        id: header
        type: ArkTokens.NavigationBar.primary
        width: parent.width
        antialiasing: true
        transparent: true

        ArkControls.NavigationBar.Button {
            id: backButton
            iconSource: "qrc:/ark/icons/chevron_left"
            text: root.backText
            onClicked: root.close()
            textPosition: ArkControls.Button.TextPosition.Right
            state: "selected"
        }
    }

    ScrollArea {
        id: releaseNotesFlickable
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        contentWidth: parent.width
        contentHeight: image.height

        clip: true

        Image {
            id: image
            source: root.imageSource
            width: parent.width
            fillMode: Image.PreserveAspectFit
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Home) {
            root.close();
            event.accepted = true;
        }
    }
}
