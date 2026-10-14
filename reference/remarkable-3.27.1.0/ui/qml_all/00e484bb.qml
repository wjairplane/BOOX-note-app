import QtQuick
import xofm.modules.virtualkeyboard

import xofm.libs.epaper as Epaper

Item {
    id: root
    required property VirtualKeyboard virtualKeyboard
    property bool keyboardConnected: false
    property bool portrait

    readonly property alias languagePopup: _languagePopup
    readonly property alias keyPopup: keyPopup
    property int longPressDelay: 300

    readonly property bool actionPanelEnabled: virtualKeyboard.keyboardSettings ? virtualKeyboard.keyboardSettings.actionPanelEnabled : false

    property bool _symbolsPopupMode: false

    signal longPressed(var key)
    signal keyPressed(var key)

    onLongPressed: (key) => {
        if (key.type === VirtualKeyboardKey.Shift) {
            virtualKeyboard.capslockSelected = true;
        } else {
            virtualKeyboard.insertText("", -1, 1); // remove last key entered on keyboard
            // mark the long press key inverted while the popup is open
            virtualKeyboard.setStickyPressed(key, true);
            keyPopup.visible = true;
        }
    }

    // Intercepts clicks in the visible area above
    // the keyboard in order to close the popup
    MouseArea {
        id: popupCloseArea
        anchors.fill: parent
        visible: keyPopup.visible || languagePopup.visible
        onClicked: {
            keyPopup.visible = false;
            languagePopup.visible = false;
        }
    }

    Item {
        id: keyboardContainer
        visible: !root.keyboardConnected || _symbolsPopupMode

        width: visible ? parent.width : 0
        height: visible ? Math.min(root.height * 0.4 + virtualKeyboard.topPadding,
                                   virtualKeyboard.heightForWidth(parent.width)) : 0

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Epaper.ScreenModeItem {
            id: screenMode
            anchors.fill: parent
            mode: Epaper.ScreenModeItem.Animation
            objectName: "keyboard"
        }

        states: [
            State {
                when: root._symbolsPopupMode && root.keyboardConnected
                name: "SymbolsPopup"
                PropertyChanges {
                    target: keyboardContainer
                    height: (portrait ? parent.height / 6 : parent.height / 4) + virtualKeyboard.topPadding
                }
                PropertyChanges {
                    target: virtualKeyboard
                    topPadding: closeButton.visible ? closeButton.height * 1.2 : 8
                    style: VirtualKeyboard.Style.SymbolsPopup
                }
                PropertyChanges {
                    target: root
                    languagePopup.visible: false
                }
                PropertyChanges {
                    target: keyPopup
                    visible: false
                }
            }
        ]

        onVisibleChanged: {
            if (!visible) {
                keyPopup.visible = false;
                languagePopup.visible = false;
                root._symbolsPopupMode = false;
            }
        }

        Binding {
            target: virtualKeyboard
            property: "topPadding"
            value: closeButton.visible ? closeButton.height * 1.2 : 24
        }

        Binding {
            target: virtualKeyboard
            property: "screenMode"
            value: screenMode.mode
        }

        Item {
            id: keyboardLayout
            Component.onCompleted: {
                virtualKeyboard.parent = keyboardLayout;
                virtualKeyboard.anchors.fill = keyboardLayout;
            }

            Text {
                id: _languageText
                parent: virtualKeyboard
                text: virtualKeyboard.languageName(virtualKeyboard.language)
                visible: languageLabelTimer.running && !languagePopup.visible
                color: "white"
                font.pixelSize: 25
                antialiasing: false // Prevent ghosting in VKB overlay
                anchors.horizontalCenter: parent.horizontalCenter

                Timer {
                    id: languageLabelTimer
                    interval: 4000 // Values.popupTimeout
                }
            }

            Item {
                id: toolTipTarget
                anchors {
                    top: parent.top
                    left: parent.left
                    leftMargin: 500
                }
            }

            KeyboardButton {
                id: closeButton
                parent: virtualKeyboard
                visible: root.actionPanelEnabled
                activationDelay: 50
                anchors {
                    right: parent.right
                    rightMargin: 60
                    top: parent.top
                    topMargin: 10
                }
                text: qsTr("Close")
                onClicked: {
                    if (_symbolsPopupMode) {
                        _symbolsPopupMode = false;
                    }
                }
                onActivated: {
                    if (!_symbolsPopupMode) {
                        Qt.inputMethod.hide();
                    }
                }
            }

            KeyboardLanguageSelect {
                id: _languagePopup
                parent: virtualKeyboard
                visible: false
                anchors.fill: parent
                // Extend above the keyboard to cover the format menu bar - menu height + format menu top margin
                formatMenuHeight: closeButton.implicitHeight + 2
                anchors.topMargin: -formatMenuHeight

                model: virtualKeyboard.languages
                display: (modelData) => { return virtualKeyboard.languageName(modelData); }
                onClosed: visible = false
                onSelected: (selection) => {
                    // Fetch spacebar geometry and position the language in the center
                    // Note that this is done just before changing the
                    // language which clears all key geometry until next repaint
                    // so we require that vertical position is consistent across languages
                    const keys = virtualKeyboard.keys();
                    for (const key of keys) {
                        if (key.type === VirtualKeyboardKey.Space) {
                            _languageText.y = key.rect.y + key.rect.height / 2 - _languageText.height / 2;
                            break;
                        }
                    }
                    virtualKeyboard.language = selection;
                    visible = false;
                    languageLabelTimer.running = true;
                }
            }

            anchors.centerIn: parent
            z: popupCloseArea.z + 1

            width: parent.width
            height: parent.height

            Timer {
                id: longPressTimer
                interval: longPressDelay
                onTriggered: longPressed(pressedKey)
                property var pressedKey
            }

            KeyPopup {
                id: keyPopup
                parent: virtualKeyboard
                virtualKeyboard: root.virtualKeyboard
                z: 1    // show above undo/redo buttons
                onKeySelected: (symbol) => {
                    virtualKeyboard.insertText(symbol, 0, 0);
                    // clear sticky state when a symbol is chosen
                    if (longPressTimer.pressedKey) {
                        virtualKeyboard.setStickyPressed(longPressTimer.pressedKey, false);
                    }
                }
                onVisibleChanged: {
                    // ensure sticky state is cleared when popup is dismissed
                    if (!visible && longPressTimer.pressedKey) {
                        virtualKeyboard.setStickyPressed(longPressTimer.pressedKey, false);
                    }
                }
            }

            Timer {
                id: backspaceRepeater

                readonly property int initialInterval: 250
                readonly property int minimumInterval: 30
                readonly property int decrement: 40

                interval: initialInterval
                repeat: true

                onRunningChanged: {
                    if (!running) {
                        interval = initialInterval;
                    }
                }

                onTriggered: {
                    // Gradually speed up repeat rate while holding down
                    if (interval > minimumInterval) {
                        interval = Math.max(minimumInterval, interval - decrement);
                    }
                    virtualKeyboard.triggerBackspace();
                }
            }

            Connections {
                target: virtualKeyboard

                function onKeyPressed(key) {
                    root.keyPressed(key);

                    if (key.type === VirtualKeyboardKey.Language) {
                        if (languagePopup.visible) {
                            languagePopup.visible = false;
                        } else {
                            languagePopup.selectedIndex = languagePopup.model.indexOf(virtualKeyboard.language);
                            languagePopup.visible = true;
                        }
                    } else if (key.type === VirtualKeyboardKey.Backspace) {
                        backspaceRepeater.start();
                    }
                    const symbols = virtualKeyboard.shiftSelected ? key.shiftedSymbols : key.symbols;
                    keyPopup.keys = symbols.slice(1); // skip first
                    keyPopup.targetRect = key.rect;
                    if (symbols.length > 1 || key.type === VirtualKeyboardKey.Shift) {
                        longPressTimer.pressedKey = key;
                        longPressTimer.restart();
                    }
                    keyPopup.visible = false;
                }

                function onKeyReleased(key) {
                    longPressTimer.stop();
                    if (key.type === VirtualKeyboardKey.Backspace) {
                        backspaceRepeater.stop();
                    }
                }

                function onCancelPressed() {
                    Qt.inputMethod.hide();
                }

                function onWidthChanged() {
                    // Hide the language label by stopping the running property
                    // as key layout might have changed meaning it is no
                    // longer centered on the spacebar
                    languageLabelTimer.stop();
                }

                function onSymbolKeyboardToggled() {
                    if(!Qt.inputMethod.visible) {
                        return;
                    }

                    root._symbolsPopupMode = !root._symbolsPopupMode;
                }
            }
        }
    }
}
