import QtQuick
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import device.ui.headers

Background {
    id: dialog

    property var target
    // This is the target text item that will be updated
    property var invokeOnAccepted
    property alias title: inputHeader.text
    property alias header: inputHeader
    property alias text: textEdit.text
    property int maximumLength: -1
    property alias inputMethodHints : textEdit.inputMethodHints
    property bool multiline: false
    // Expects function that takes candidate string as input and returns true if valid
    property var validatorFunction: null
    property string enterKeyText

    visible: false
    focus: visible

    function open(text) {
        textEdit.text = text;
        textEdit.oldText = text;
        visible = true;
    }

    function close(accepted) {
        if (accepted) {
            if (!!target) {
                dialog.target.text = textEdit.text;
            }
            if (!!invokeOnAccepted) {
                invokeOnAccepted();
            }
        }
        target = undefined;
        maximumLength = -1;
        invokeOnAccepted = null;
        dialog.visible = false;
        multiline = false;
        dialog.inputMethodHints = Qt.ImhNone;
    }

    Header {
        id: inputHeader
        visible: true
        width: parent.width
        blackOnWhite: false
        acceptEnabled: dialog.validatorFunction ? dialog.validatorFunction(textEdit.text.trim()) : true
        onRejected: {
            dialog.close(false);
        }
        onAccepted: {
            dialog.close(true);
        }
    }

    ScrollArea {
        id: textFlickable
        clip: true
        focus: true
        anchors {
            top: inputHeader.bottom
            left: inputHeader.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0
        }

        contentHeight: textEdit.implicitHeight + 2 * Values.navigatorMargin

        TextEdit {
            id: textEdit
            y: 2 * Values.navigatorMargin
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Values.navigatorMargin
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: Values.fontSizeH2
            focus: true
            KeyboardSettings.enterKeyText: dialog.enterKeyText
            KeyboardSettings.actionPanelEnabled: false
            property string oldText

            cursorDelegate: Rectangle {
                width: Values.outlineSize
                height: Values.fontSizeH2
                color: Values.colorBlack
                visible: parent.activeFocus
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    if (!multiline) {
                        close(true);
                    } else {
                        event.accepted = false;
                    }
                } else if (event.key === Qt.Key_Home || event.key === Qt.Key_Escape) {
                    event.accepted = true;
                    dialog.close();
                }
            }

            onTextChanged: {
                if (maximumLength > -1) {
                    if (text.length >= maximumLength) {
                        var cursor = cursorPosition;
                        text = oldText;
                        if (cursor > text.length) {
                            cursorPosition = text.length;
                        } else {
                            cursorPosition = cursor - 1;
                        }
                    }
                    oldText = text;
                }
            }
        }
    }
}
