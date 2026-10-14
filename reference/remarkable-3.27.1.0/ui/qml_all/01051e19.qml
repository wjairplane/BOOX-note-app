import QtQuick
import QtQuick.Layouts

import xofm.libs.controls

import ark.tokens as ArkTokens
import ark.controls as ArkControls

InputBlocker {
    id: root
    property var buttons
    property bool gobackButton: true
    property var buttonText: qsTr("Back")

    property alias title: titleField.text
    property alias subtitle: subtitleField.text

    /* Expects an array of strings */
    property alias body: bulletList.model

    property Component optionalComponent
    property Component optionalFooterComponent
    signal goBack
    signal listLinkActivated(string link)

    ArkControls.NavigationBar {
        id: navigationBar
        type: ArkTokens.NavigationBar.secondary
        width: parent.width
        anchors.left: parent.left

        ArkControls.NavigationBar.Button {
            text: root.buttonText
            textPosition: ArkControls.Button.TextPosition.Right
            iconSource: "qrc:/ark/icons/chevron_left"
            visible: root.gobackButton
            onClicked: root.goBack()
        }
    }

    ColumnLayout {
        id: layout
        anchors {
            top: navigationBar.bottom
            left: parent.left
            leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
            right: parent.right
            rightMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
            bottom: parent.bottom
            bottomMargin: ArkControls.Values.margin.vertical.large
        }
        spacing: ArkControls.Values.spacing.large

        ArkControls.Title {
            id: titleField
            type: ArkControls.Title.Large
            Layout.bottomMargin: ArkControls.Values.spacing.large
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }

        ArkControls.Title {
            id: subtitleField
            type: ArkControls.Title.Medium
            Layout.fillWidth: true
            visible: !!subtitle
            enabled: !!subtitle
            wrapMode: Text.Wrap
        }

        ArkControls.List {
            id: bulletList
            type: ArkControls.List.Type.Medium
            Layout.fillWidth: true
            onLinkActivated: (link) => {
                root.listLinkActivated(link);
            }
        }

        Loader {
            Layout.fillWidth: true
            sourceComponent: optionalComponent
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Loader {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width
            sourceComponent: optionalFooterComponent
        }

        RowLayout {
            id: buttonRow
            Layout.alignment: Qt.AlignHCenter
            spacing: ArkControls.Values.spacing.large

            Repeater {
                id: buttons
                model: root.buttons
                ArkControls.Button {
                    required property var modelData
                    objectName: modelData.hasOwnProperty("objectName") ? modelData.objectName : ""
                    type: modelData.highlight ? ArkTokens.Button.primary : ArkTokens.Button.secondary
                    text: modelData.text
                    onClicked: modelData.action()
                    Layout.minimumWidth: 340
                }
            }
        }
    }
}
