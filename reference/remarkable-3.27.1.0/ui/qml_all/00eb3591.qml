import common

import xofm.libs.localization // LanguageSelector, LanguageSettings

import ark.controls as ArkControls
import ark.tokens as ArkTokens

Background {
    id: root

    required property LanguageSettings languageSettings

    signal close
    signal next(string window)

    ArkControls.NavigationBar.Button {
        text: qsTr("Back")
        iconSource: "qrc:/ark/icons/chevron_left"
        onClicked: root.close();
    }

    ArkControls.SetupPage {
        anchors.fill: parent
        title: qsTr("Welcome to retail")
        description: qsTr("Choose your language to begin.")
        primaryButtonText: qsTr("Next")
        onPrimaryClicked: root.next("retail/window/retail-setup-info")

        LanguageSelector {
            objectName: "languageSelector"
            languageSettings: root.languageSettings
            width: 336
            anchors.centerIn: parent
        }
    }
}
