import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls
import ark.tokens as ArkTokens

FocusScope {
    id: root
    focus: true
    height: layout.height
    width: layout.width

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Backspace) {
            root.backspacePressed();
        } else if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
            root.keyPressed(event.text);
        }
        event.accepted = true;
    }

    signal keyPressed(string key)
    signal backspacePressed

    component PinKey: Item {
        id: keyItem
        required property string text
        objectName: `key_${text}`
        width: 134
        height: keyItem.width
        Layout.alignment: Qt.AlignHCenter

        Rectangle {
            id: key
            width: keyItem.width - 20
            height: width
            radius: width / 2
            border.width: 2
            anchors.centerIn: parent
            color: "transparent"
            antialiasing: false

            ArkControls.Label {
                anchors.centerIn: parent
                type: ArkControls.Label.LargeStrong
                text: keyItem.text
                antialiasing: false
                font.pixelSize: 40
                color: "black"
            }
        }

        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            onPressed: root.keyPressed(keyItem.text)
        }
    }

    GridLayout {
        id: layout
        columns: 3
        rows: 3
        columnSpacing: 36
        rowSpacing: 36
        anchors.centerIn: parent

        Repeater {
            model: [ "1", "2", "3", "4", "5", "6", "7", "8", "9" ]
            delegate: PinKey {
                required property string modelData
                text: modelData
            }
        }

        Item { }

        PinKey { text: "0" }

        Rectangle {
            width: 112
            height: width
            objectName: "key_backspace"
            Layout.alignment: Qt.AlignCenter
            radius: width / 2
            color: "transparent"
            antialiasing: false

            MouseArea {
                id: backspaceArea
                anchors.fill: parent
                onPressed: root.backspacePressed()
            }

            ArkControls.Icon {
                source: "qrc:/ark/keyboard/backspace"
                anchors.centerIn: parent
                color: "black"
            }
        }
    }
}
