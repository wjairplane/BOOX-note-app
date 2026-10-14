import QtQuick

import xofm.libs.epaper as Epaper
import xofm.libs.ui as Ui
import xofm.libs.controls as Controls

import ark.controls as ArkControls
import ark.tokens as ArkTokens

FocusScope {
    id: root

    readonly property color textColor: "black"
    property bool showPassword: false
    property bool inverted: false
    property int fontSize: 28
    property bool labelVisible: true
    property alias text: textInput.text
    property alias titleText: titleText.text
    property alias titleFontSize: titleText.font.pixelSize
    property alias validator: textInput.validator
    property string label
    property alias activeFocusOnPress: textInput.activeFocusOnPress

    signal accepted(string input)
    signal cancel
    signal showWarning(string warning)

    function forceFocus() {
        textInput.forceActiveFocus();
    }

    width: parent.width
    implicitHeight: col.implicitHeight

    Column {
        id: col
        width: 716 // From Values.fixedWidthInputField
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            width: parent.width

            ArkControls.Label {
                id: titleText
                type: ArkControls.Label.Medium
                text: qsTr("Password")
                color: root.textColor
            }

            ArkControls.InputField {
                id: textInput

                focus: true
                clip: implicitWidth > width
                echoMode: showPassword ? TextInput.Normal : TextInput.Password
                inputMethodHints: Qt.ImhNoAutoUppercase

                Ui.FontStyleHelper {
                    target: textInput
                    styleStrategy: Ui.FontStyleHelper.NoAntialias // Speeds up typing
                }
                Component.onCompleted: {
                    // Because of partial screen update issues on RM2 when opening the WiFi connect
                    // screen, we need to delay adding the animation screen mode item a bit to let
                    // the screen transition finish first.
                    animationScreenModeTimer.start();
                }

                onTextChanged: {
                    cursorTimeout.restart();
                    if (textInput.text.length > 0) {
                        root.showWarning(textInput.text);
                    }
                }
                onAccepted: root.accepted(textInput.text)
                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Home) {
                                        root.cancel();
                                    }
                                }

                cursorDelegate: Rectangle {
                    width: 2
                    height: textInput.font.pixelSize
                    color: textInput.color
                    // We want the cursor to auto-hide and not blink
                    // similar to what we do in sceneView
                    visible: !cursorTimeout.running && textInput.activeFocus
                }

                Timer {
                    id: cursorTimeout
                    interval: 500
                }

                controlDelegate: ArkControls.IconButton {
                    objectName: "ShowPasswordIcon"
                    focusPolicy: Qt.NoFocus
                    type: ArkTokens.IconButton.primary_inverted
                    iconSource: root.showPassword ? "qrc:/ark/icons/eye" : "qrc:/ark/icons/eye_closed"
                    onClicked: root.showPassword = !root.showPassword
                }

                Loader {
                    id: screenModeItemLoader
                    active: false
                    anchors.fill: parent
                    sourceComponent: Epaper.ScreenModeItem {
                        visible: textInput.visible && textInput.focus
                        mode: Epaper.ScreenModeItem.Animation
                        objectName: "password-input-field"
                    }
                }

                Timer {
                    id: animationScreenModeTimer
                    interval: 300
                    onTriggered: screenModeItemLoader.active = true
                }
            }

            ArkControls.Label {
                id: arkLabel
                width: parent.width
                type: ArkControls.Label.Medium
                color: root.textColor
                text: root.label ?? " "
                opacity: root.labelVisible ? 1 : 0 // use opacity (rather than visible), in order to preserve the height of this label within the containing column
            }
        }
    }
}
