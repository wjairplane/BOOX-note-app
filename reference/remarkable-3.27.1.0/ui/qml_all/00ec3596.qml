import QtQuick

import com.remarkable
import common

import xofm.libs.setup
import xofm.libs.epaper as Epaper
import xofm.libs.ghostbuster
import xofm.libs.localization

import ark.controls as ArkControls
import ark.tokens as ArkTokens

SetupBasePage {
    id: root

    required property var languageSettings
    required property string platformName
    required property var ghostBuster

    //: Title of language setup page, expands to "Welcome to your<br/>reMarkable Paper Pro"
    readonly property string title: qsTr("Welcome to your<br/>%1").arg(platformName)
    readonly property string description: qsTr("Choose your language to begin.")

    stateName: "Language"
    showProgressIndicator: false
    showBackButton: true

    onVisibleChanged: {
        if (visible) {
            root.ghostBuster.viewChange(GhostBuster.SetupStarted);
        }
    }

    ArkControls.SetupPage {
        id: page
        anchors.fill: parent
        title: root.title
        description: root.description
        //: Button to move to the next setup page
        primaryButtonText: qsTr("Next")
        onPrimaryClicked: root.forward()
    }

    LanguageSelector {
        languageSettings: root.languageSettings
        width: 336
        anchors.centerIn: parent
    }
}
