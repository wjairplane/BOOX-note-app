import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls
import ark.tokens as ArkTokens

FocusScope {
    id: root

    focus: true
    property int pinInputCircleDiameter: 48

    property alias description: description.text

    property string warning: ""
    property bool showPasscode: false
    property bool showPasscodeWarning: false
    property int passcodeLength: 6
    property bool showLengthSelection: false
    property alias selectedPasscodeLength: lengthMenu.selectedLength
    required property int minimumPincodeLength

    implicitHeight: columnLayout.implicitHeight
    implicitWidth: columnLayout.implicitWidth

    signal attempt(string text)

    function clear() {
        _internal.inputText = "";
        root.showPasscodeWarning = false;
    }

    function buildPincodeLengthModel(minimumPincodeLength) {
        let model = [
                { value: 4, label: qsTr("Four digits") },
                { value: 6, label: qsTr("Six digits") },
                { value: 8, label: qsTr("Eight digits") }
            ];

        if (minimumPincodeLength) {
            model = model.filter(item => item.value >= minimumPincodeLength);
        }
        return model;
    }

    onShowPasscodeWarningChanged: {
        if (root.showPasscodeWarning) {
            // clear the input, ready for next try
            _internal.inputText = "";
        }
    }

    Item {
        id: _internal
        property string inputText: ""

        function updateText(keyStroke) {
            _internal.inputText += keyStroke;
            const inputLength = _internal.inputText.length;
            const max = root.passcodeLength
            if (inputLength > max) {
                // Too long, start a new pin
                root.clear();
                _internal.inputText += keyStroke;
            } else if (inputLength < max) {
                root.showPasscodeWarning = false;
            } else if (inputLength === max) {
                acceptTimer.start()
            }
        }

        Timer {
            id: acceptTimer
            // Add a small delay so there is visual feedback about the last key being pressed
            interval: 100
            onTriggered: root.attempt(_internal.inputText)
        }
    }

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent

        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 160

            ArkControls.Body {
                id: description
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                visible: {
                    if(!!text && lengthMenu.visible) {
                        console.error("description and lengthMenu cannot be used at once")
                    }
                    return !!text && !lengthMenu.visible
                }
            }
            ArkControls.SegmentedControl {
                id: lengthMenu
                objectName: "pin-length-menu"
                anchors.centerIn: parent
                visible: root.showLengthSelection
                type: ArkTokens.SegmentedControl.secondary
                property int selectedLength: Math.max(root.passcodeLength, root.minimumPincodeLength)
                property var model: {
                    const newModel = root.buildPincodeLengthModel(root.minimumPincodeLength);
                    lengthMenu.selectedLength = Qt.binding(() => Math.max(root.passcodeLength, root.minimumPincodeLength));
                    return newModel;
                }
                onSelectedLengthChanged: {
                    root.clear();
                }

                Repeater {
                    model: lengthMenu.model
                    ArkControls.SegmentedControl.Button {
                        required property var modelData
                        type: lengthMenu.type
                        checked: modelData.value === lengthMenu.selectedLength
                        focusPolicy: Qt.NoFocus
                        text: modelData.label
                        onClicked: lengthMenu.selectedLength = modelData.value
                    }
                }
            }
        }

        Item {
            Layout.preferredWidth: passCodeInput.implicitWidth
            Layout.preferredHeight: passCodeInput.implicitHeight
            Layout.alignment: Qt.AlignHCenter

            RowLayout {
                id: passCodeInput
                spacing: ArkControls.Values.spacing.medium

                Repeater {
                    id: repeater
                    model: root.passcodeLength
                    delegate: Rectangle {
                        required property var modelData
                        width: root.pinInputCircleDiameter
                        radius: root.pinInputCircleDiameter
                        height: root.pinInputCircleDiameter
                        border.color: "black"
                        antialiasing: false
                        border.width: 2
                        color: _internal.inputText.length - 1 >= modelData
                               ? "black"
                               : "transparent"

                        ArkControls.Label {
                            anchors.centerIn: parent
                            text: _internal.inputText.charAt(modelData)
                            color: "white"
                            visible: root.showPasscode
                            antialiasing: false
                        }
                    }
                }
            }

            Item {
                id: showPasscodeArea
                width: 112
                height: root.pinInputCircleDiameter
                anchors {
                    left: passCodeInput.right
                }

                MouseArea {
                    anchors.centerIn: parent
                    // Intentionally larger click area to comply with accessibility guidelines
                    width: parent.width
                    height: Math.max(parent.height, 80)
                    onPressed: root.showPasscode = !root.showPasscode
                }

                ArkControls.Icon {
                    source: root.showPasscode ? "qrc:/ark/icons/eye" : "qrc:/ark/icons/eye_closed"
                    anchors.centerIn: parent
                }
            }
        }

        ArkControls.Body {
            id: warning
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            horizontalAlignment: Text.AlignHCenter
            type: ArkControls.Body.Medium
            text: root.showPasscodeWarning ? root.warning : ""
        }

        PinKeyboard {
            Layout.alignment: Qt.AlignHCenter
            onBackspacePressed: _internal.inputText = _internal.inputText.substring(0, _internal.inputText.length - 1);
            onKeyPressed: (key) => {
                _internal.updateText(key);
            }
        }
    }
}
