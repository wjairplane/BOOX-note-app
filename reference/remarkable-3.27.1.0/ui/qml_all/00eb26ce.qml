import QtQuick
import QtQuick.Layouts

import common
import com.remarkable // LogoutHandler

import device.ui.controls

import xofm.libs.qtgui
import xofm.libs.batterymanager // ShutdownCommand
import xofm.libs.controls
import xofm.libs.retail
import xofm.libs.localization // LanguageSettings

import ark.controls as ArkControls
import ark.tokens as ArkTokens

Background {
    id: root

    required property ShutdownCommand shutdownCommand
    required property RetailSettings retailSettings
    required property LanguageSettings languageSettings
    required property var logoutHandler
    property int _currentResellerIndex: 0

    signal close

    function enterRetail() {
        root.logoutHandler.logout();
        root.retailSettings.reseller = resellersModel.get(_currentResellerIndex).value;
        root.retailSettings.storeId = storeIdTitle.inputText;
        root.retailSettings.setRetailLanguageCode(root.languageSettings.languageCode);
        root.retailSettings.setEnabled(true);
        root.shutdownCommand.execute(ShutdownCommand.Reason.Reboot, "Entered Retail, rebooting");
    }

    ListModel {
        id: resellersModel
        ListElement { key: 0; value: "Best Buy US" }
        ListElement { key: 1; value: "Staples CA" }
        ListElement { key: 2; value: "Elkjøp / Elgiganten / Gigantti Nordics" }
        ListElement { key: 3; value: "MediaMarkt / Saturn DE" }
        ListElement { key: 4; value: "MediaMarkt NL" }
        ListElement { key: 5; value: "Boulanger FR" }
        ListElement { key: 6; value: "John Lewis UK" }
        ListElement { key: 7; value: "JB Hi-Fi AU/NZ" }
        ListElement { key: 8; value: "Dubai Duty Free UAE" }
        ListElement { key: 9; value: "Other" }
    }

    ArkControls.NavigationBar {
        id: navBar
        type: ArkTokens.NavigationBar.secondary
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        title: qsTr("Store information")
        borderPosition: ArkControls.NavigationBar.Border.Bottom

        ArkControls.NavigationBar.Button {
            id: backButton
            text: qsTr("Back")
            textPosition: ArkControls.Button.TextPosition.Right
            iconSource: "qrc:/ark/icons/chevron_left"
            onClicked: root.close();
        }

        Item {
            Layout.fillWidth: true
        }

        ArkControls.NavigationBar.Button {
            text: qsTr("Enter retail")
            textPosition: ArkControls.Button.TextPosition.Right
            onClicked: {
                root.enterRetail();
            }
        }
    }

    Item {
        id: dropdownContainer
        anchors.fill: parent
    }

    Column {
        anchors {
            top: navBar.bottom
            topMargin: 152
            horizontalCenter: parent.horizontalCenter
        }
        width: Values.fixedWidthInputField
        spacing: ArkControls.Values.platform.spacing.x2large

        TitleTextInputComponent {
            id: storeIdTitle
            objectName: "storeIdTitle"
            title: qsTr("Store id")
            textColor: Values.colorBlack
            height: 100
            width: parent.width
            focus: true
            maximumLength: 100
        }

        Column {
            width: parent.width
            spacing: ArkControls.Values.spacing.small

            ArkControls.Label {
                text: qsTr("Reseller")
            }

            Dropdown {
                id: dropdown
                objectName: "resellerDropdown"
                model: resellersModel
                boxSize: Qt.size(parent.width, 80)
                container: dropdownContainer
                currentIndex: root._currentResellerIndex
                onSelect: (key) => {
                    root._currentResellerIndex = key;
                }
            }
        }
    }
}
