import QtQuick
import QtQuick.Layouts

import xofm.libs.controls
import xofm.libs.qtgui

import ark.controls as ArkControls
import ark.tokens as ArkTokens

InputBlocker {
    id: root

    focus: true
    property int pinInputCircleDiameter: 48

    property alias goBackButton: navigationBar.visible
    property alias headerText: navigationBar.title
    property alias title: pinTitle.text
    property alias description: pincodeDialog.description
    property alias buttonText: actionButton.text

    // Setup has different typography, so we need to make topmargin configurable
    property int topMargin: ArkControls.Values.margin.vertical.xlarge

    property alias warning: pincodeDialog.warning
    property alias showPasscode: pincodeDialog.showPasscode
    property alias showPasscodeWarning: pincodeDialog.showPasscodeWarning
    property alias passcodeLength: pincodeDialog.passcodeLength
    property alias showLengthSelection: pincodeDialog.showLengthSelection
    property alias selectedPasscodeLength: pincodeDialog.selectedPasscodeLength
    required property int minimumPincodeLength
    property var pincodeWidgets: null

    signal goBack
    signal attempt(string text)
    signal action

    function clear() {
        pincodeDialog.clear();
    }

    ArkControls.NavigationBar {
        id: navigationBar
        type: ArkTokens.NavigationBar.secondary
        width: parent.width
        visible: false
        anchors.left: parent.left

        ArkControls.NavigationBar.Button {
            id: backButton
            objectName: "backButton"
            text: qsTr("Back")
            textPosition: ArkControls.Button.TextPosition.Right
            iconSource: "qrc:/ark/icons/chevron_left"
            onClicked: root.goBack()
            visible: root.minimumPincodeLength === 0
        }
    }

    RowLayout {
        id: pincodeWidgetRow

        visible: pincodeWidgets !== null
        height: 120 // Stolen from Values.qml navigationEntriesHeaderHeight
        spacing: ArkTokens.Style.spacing.xsmall
        anchors {
            top: parent.top
            right: parent.right
            rightMargin: ArkTokens.Style.variable.platform.padding.xlarge
        }
        Repeater {
            model: pincodeWidgets
            delegate: WidgetLoader {
            }
        }
    }

    ArkControls.Title {
        id: pinTitle
        type: ArkControls.Title.XLarge
        anchors {
            top: parent.top
            topMargin: root.topMargin
            left: parent.left
            leftMargin: ArkControls.Values.margin.horizontal.large
            right: parent.right
            rightMargin: ArkControls.Values.margin.horizontal.large
            bottomMargin: ArkControls.Values.margin.vertical.xlarge
        }
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        visible: !!text // Setup has its own title
        z: 1 // PincodeDialog has sizes/margins that overlap with the title. Make sure the title is always on top
    }

    PincodeDialog {
        id: pincodeDialog
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: ArkControls.Values.margin.horizontal.large
            rightMargin: ArkControls.Values.margin.horizontal.large
            verticalCenter: parent.verticalCenter
        }
        onAttempt: (text) => root.attempt(text)
        minimumPincodeLength: root.minimumPincodeLength
    }

    ArkControls.Button {
        id: actionButton
        type: ArkTokens.Button.secondary
        anchors.bottom: parent.bottom
        anchors.bottomMargin: ArkControls.Values.margin.vertical.xlarge
        anchors.horizontalCenter: parent.horizontalCenter
        visible: actionButton.text.length !== 0
        onClicked: root.action()
        width: 432
        Layout.alignment: Qt.AlignHCenter
    }
}
