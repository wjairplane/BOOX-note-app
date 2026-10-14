import QtQuick
import common
import com.remarkable
import device.ui.text
import device.ui.controls

import xofm.libs.controls

import ark.controls as ArkControls

/**
    HeaderInput is a header with a TextInput.

    Used for example by ExplorerSearch and DocumentSearch.
*/
HeaderContainer {
    id: root

    property string placeholder: ""
    property alias text: inputField.text
    property alias iconSource: inputIcon.source
    property alias inputField: inputField
    property alias confirmText: confirmButton.title
    property alias confirmItem: confirmButton

    signal inputChanged
    signal accepted(string text)

    ArkControls.Icon {
        id: inputIcon
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Values.navigatorMargin + root.rejectItem.width
        }
        size: ArkControls.Values.iconSize.medium
        color: inputField.color
        source: ""
    }

    GeneralTextInput {
        id: inputField
        focus: true
        KeyboardSettings.actionPanelEnabled: true
        anchors {
            verticalCenter: parent.verticalCenter
            left: inputIcon.right
            leftMargin: Values.navigatorSidebarItemMargin - 5
        }
        width: Values.navigatorContentGridItemWidth * 2
        height: parent.height
        horizontalAlignment: TextInput.AlignLeft
        verticalAlignment: TextInput.AlignVCenter
        font.pixelSize: Values.fontSizeH2
        font.bold: false
        color: Values.colorWhite
        selectedTextColor: Values.colorWhite
        selectionColor: Values.colorBlack
        inputMethodHints: Qt.ImhNoAutoUppercase

        onTextChanged: {
            root.inputChanged();
        }
        Keys.onPressed: (event) => {
            root.Keys.pressed(event);
        }
        onAccepted: {
            root.accepted(text);
        }

        Rectangle {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            height: inputField.font.pixelSize + 10
            color: Values.colorWhite
            width: placeholderText.implicitWidth + 20
            visible: !parent.text && parent.cursorVisible
        }

        Text {
            id: placeholderText
            text: placeholder
            anchors {
                fill: parent
                leftMargin: 10
            }
            horizontalAlignment: parent.horizontalAlignment
            verticalAlignment: parent.verticalAlignment
            font: parent.font
            color: parent.cursorVisible ? Values.colorBlack
                                        : Values.colorWhite
            visible: !parent.text
        }
    }

    // Right button
    HeaderButton {
        id: confirmButton
        onClicked: accepted(inputField.text)
        inverted: !blackOnWhite
        anchors.right: parent.right
        height: parent.height
    }
}
