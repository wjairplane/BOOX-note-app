import QtQuick
import QtQuick.Layouts

import xofm.libs.controls

import ark.tokens as ArkTokens
import ark.controls as ArkControls

InputBlocker {
    id: root
    property alias iconSource: arkIcon.source
    property var buttons
    signal goBack
    property alias text: itemText.text
    property alias description: description.text
    property alias subDescription: subDescription.text
    property alias footerText: footerText.text
    property bool gobackButton: true
    property Component optionalComponent: null
    property bool accidentalTouchPrevention: false

    ArkControls.NavigationBar {
        id: navigationBar
        type: ArkTokens.NavigationBar.secondary
        width: parent.width
        anchors.left: parent.left

        ArkControls.NavigationBar.Button {
            objectName: "backButton"
            text: qsTr("Back")
            textPosition: ArkControls.Button.TextPosition.Right
            iconSource: "qrc:/ark/icons/chevron_left"
            visible: root.gobackButton
            onClicked: root.goBack()
        }
    }

    ColumnLayout {
        id: layout
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: buttonRow.top
            topMargin: ArkControls.Values.margin.vertical.x2large
            leftMargin: ArkControls.Values.margin.horizontal.x2large
            rightMargin: ArkControls.Values.margin.horizontal.x2large
            bottomMargin: ArkControls.Values.spacing.medium
        }
        spacing: ArkControls.Values.spacing.medium

        ArkControls.Icon {
            id: arkIcon
            size: ArkControls.Values.iconSize.large
            Layout.alignment: Qt.AlignHCenter
        }

        ArkControls.Title {
            id: itemText
            type: ArkControls.Title.Large
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
        }

        ArkControls.Body {
            id: description
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
        }

        ArkControls.Body {
            id: subDescription
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
        }

        Loader {
            Layout.maximumWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
            sourceComponent: optionalComponent
        }

        Item {
            id: spacer
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        ArkControls.Body {
            id: footerText
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
        }
    }

    RowLayout {
        id: buttonRow
        anchors {
            bottom: parent.bottom
            bottomMargin: ArkControls.Values.margin.vertical.large
            horizontalCenter: parent.horizontalCenter
        }
        spacing: ArkControls.Values.spacing.large

        Repeater {
            id: buttons
            model: root.buttons
            delegate: ArkControls.Button {
                required property var modelData
                objectName: modelData.text
		required property int index
                visible: !accidentalTouchSlider.visible && (modelData.visible ?? true)
                type: modelData.highlight ? ArkTokens.Button.primary : ArkTokens.Button.secondary
                text: modelData.text
                Layout.minimumWidth: 340
                onClicked: modelData.action()
                Layout.alignment: Qt.AlignCenter
            }
        }

        AccidentalTouchSlider {
            id: accidentalTouchSlider
            visible: root.accidentalTouchPrevention && !accepted
            Layout.alignment: Qt.AlignCenter
        }
    }
}
