import QtQuick
import com.remarkable
import common
import device.ui.text

import xofm.libs.controls

FocusScope {
    id: root
    property bool textVisible: true
    property alias title: titleText.text
    property string textColor: Values.colorWhite
    property alias inputText: textInput.text
    property bool showTextButton: false
    property alias validator: textInput.validator
    property alias maximumLength: textInput.maximumLength
    property alias inputMethodHints: textInput.inputMethodHints
    property alias wrapMode: textInput.wrapMode
    property alias autoSelectOnFocus: textInput.autoSelectOnFocus
    property alias acceptableInput: textInput.acceptableInput

    signal accepted(var identity)
    signal cancel
    signal showWarning(var warning)

    function forceFocus() {
        textInput.forceActiveFocus();
    }

    function text() {
        return textInput.text;
    }

    function selectAll() {
        textInput.selectAll();
    }

    TextHeaderRegular {
        id: titleText
        lineHeight: Values.lineHeight
        color: textColor
        anchors.left: parent.left
    }

    GeneralTextInput {
        id: textInput
        property bool invalidInput: false
        anchors {
            left: parent.left
            bottom: parent.bottom
            bottomMargin: root.showTextButton ? 54 : 0
            top: titleText.bottom
            topMargin: 8
        }
        focus: true
        width: parent.width
        height: font.pixelSize * 3
        wrapMode: TextInput.Wrap
        verticalAlignment: TextInput.AlignBottom
        font.pixelSize: Values.fontSizeH1
        color: textColor
        echoMode: root.textVisible ? TextInput.Normal : TextInput.Password
        onAccepted: root.accepted(textInput.text)
        Keys.onPressed: (event) => {
            if (!textInput.acceptableInput) {
                root.showWarning(textInput.text);
            }
            if (event.key === Qt.Key_Home) {
                root.cancel();
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: Values.outlineSize
        color: textColor
    }
}
