import QtQuick

FocusScope {
    id: dashedCodeInput
    width: dashesRow.width
    height: 36 // No need for this to scale with accessibility

    signal accepted
    signal close
    property alias text: input.text
    property alias input: input
    property alias dashes: dashesRow
    property bool clearOnFullInput: true
    property alias maximumLength: input.maximumLength

    function clearInputText() {
        input.text = "";
    }

    TextInput {
        id: input
        anchors.fill: parent
        font.pixelSize: parent.height
        color: "transparent"
        maximumLength: 8
        inputMethodHints: Qt.ImhNoAutoUppercase
        activeFocusOnPress: true
        focus: true
        cursorDelegate: Item {}
        onTextChanged: {
            if (input.text.length === maximumLength ){
                dashedCodeInput.accepted();
                if (dashedCodeInput.clearOnFullInput) {
                    dashedCodeInput.clearInputText();
                }
            }
        }

        Keys.onPressed: (event) => {
            switch (event.key) {
            case Qt.Key_Home:
                dashedCodeInput.close();
                break;
            case Qt.Key_Undo:
                input.undo();
                break;
            case Qt.Key_Redo:
                input.redo();
                break;
            default:
                break;
            }
        }
    }

    Row {
        id: dashesRow
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: 10

        Repeater {
            id: codeInputRepeater
            model: input.maximumLength

            Item {
                width: 2 * parent.height / 3
                height: parent.height

                // Cursor line. Use this instead of input.cursorDelegate, as the dashes do not line
                // up with the TextInput characters.
                Rectangle {
                    x: 2
                    y: 2
                    width: 2
                    height: parent.height - 10
                    color: "black"
                    visible: input.text.length === index
                }

                Rectangle {
                    width: parent.width
                    height: 2
                    color: "black"
                    anchors.bottom: parent.bottom
                }

                Text {
                    anchors.centerIn: parent
                    text: input.text.length > index ? input.text[index] : ""
                    font.pixelSize: parent.height
                }
            }
        }
    }

    // Work around a bug where the text input does not receive focus when pressed, possibly related
    // to QTBUG-116606, after upgrade to Qt 6.5. See GeneralTextInput comments for details.
    MouseArea {
        anchors.fill: parent
        enabled: !input.activeFocus
        onPressed: (mouse) => {
            input.forceActiveFocus();
            mouse.accepted = false;
        }
    }
}
