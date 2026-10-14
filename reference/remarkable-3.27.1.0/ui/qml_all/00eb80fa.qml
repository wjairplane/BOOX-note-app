import QtQuick
import QtQuick.Layouts

import common
import device.ui.controls

import xofm.libs.qtgui

import ark.tokens as ArkTokens
import ark.controls as ArkControls

BaseView {
    id: root

    required property var iSettings
    readonly property int personalInfoInputHeight: 200

    onOpened: {
        nameTextTitleInput.inputText = iSettings.idleName;
        contactInfoTextTitleInput.inputText = iSettings.idleContact;
    }

    function save() {
        root.iSettings.idleName = nameTextTitleInput.inputText;
        root.iSettings.idleContact = contactInfoTextTitleInput.inputText;
        root.windowNavigator.close();
    }

    contentItem: Background {

        ArkControls.NavigationBar {
            id: securityCredentialsModal
            type: ArkTokens.NavigationBar.secondary
            width: root.width
            title: qsTr("Personal information")
            borderPosition: ArkControls.NavigationBar.Border.Bottom

            ArkControls.NavigationBar.Button {
                id: backButton
                text: qsTr("Back")
                textPosition: ArkControls.Button.TextPosition.Right
                iconSource: "qrc:/ark/icons/chevron_left"
                onClicked: windowNavigator.close();
            }

            Item {
                Layout.fillWidth: true
            }

            ArkControls.NavigationBar.Button {
                id: saveButton
                text: qsTr("Save")
                textPosition: ArkControls.Button.TextPosition.Right
                onClicked: save()
            }
        }

        Column {
            anchors {
                top: securityCredentialsModal.bottom
                topMargin: 152
                horizontalCenter: parent.horizontalCenter
            }
            width: Values.fixedWidthInputField
            spacing: Values.designGridHorizontalHeight

            TitleTextInputComponent {
                id: nameTextTitleInput
                objectName: "nameTextTitleInput"
                //: The device owner's name to show on the (locked) standby screen.
                title: qsTr("Name")
                textColor: Values.colorBlack
                height: root.personalInfoInputHeight
                width: parent.width
                focus: true
                maximumLength: 100
                onAccepted: contactInfoTextTitleInput.focus = true
                KeyNavigation.tab: contactInfoTextTitleInput
            }

            TitleTextInputComponent {
                id: contactInfoTextTitleInput
                objectName: "contactInfoTextTitleInput"
                //: The device owner's contact details to show on the (locked) standby screen.
                title: qsTr("Contact info")
                textColor: Values.colorBlack
                height: root.personalInfoInputHeight
                width: parent.width
                maximumLength: 100
                inputMethodHints: Qt.ImhNoAutoUppercase
                onAccepted: save()
            }
        }
    }
}
