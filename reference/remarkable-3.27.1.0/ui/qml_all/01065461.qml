import QtQuick
import com.remarkable
import QtQuick.Controls as QtQuickControls
import xofm.libs.setup

import ark.controls as ArkControls

SetupBasePage {
    id: root

    required property var insecureSettings
    readonly property bool showingCustomBackButton: seabirdLanguageLoader.languageSelectionActive
    property bool showedLanguageSelection

    stateName: "SeabirdSetup"
    showBackButton: !showingCustomBackButton

    onVisibleChanged: {
        if (visible && !KeyboardInfo.keyboardConnected) {
            root.forward();
        }
    }

    showProgressIndicator: !seabirdLanguageLoader.languageSelectionActive
    includeInProgressCount: KeyboardInfo.keyboardConnected
    pageReady: KeyboardInfo.keyboardConnected

    Connections {
        target: KeyboardInfo
        function onKeyboardConnectedChanged() {
            if (!KeyboardInfo.keyboardConnected) {
                root.forward();
            }
        }
    }

    function handleBack() {
        if (state === "seabirdIntro") {
            return false;
        }

        if (state === "seabirdLanguage") {
            state = "seabirdIntro";
        } else {  // state === "seabirdPreference"
            state = showedLanguageSelection ? "seabirdLanguage" : "seabirdIntro";
        }
        return true;
    }

    state: "seabirdIntro"
    states: [
        State {
            name: "seabirdIntro"
            PropertyChanges {
                target: _page
                title: qsTr("A keyboard just as focused as you are")
                description: qsTr("You've successfully connected a Type Folio. Set up the keyboard exactly how you like it.")
                primaryButtonText: qsTr("Choose preferences")
                onPrimaryClicked: {
                    // Always reset when setting up
                    Settings.inputLocale = "";
                    root.showedLanguageSelection = false;

                    const fileLocale = Settings.readFileLocale();
                    Settings.inputLocale = Settings.fileLocaleToInputLocale(fileLocale);
                    if (fileLocale !== "NO") {
                        root.state = "seabirdPreference";
                    } else {
                        root.state = "seabirdLanguage";
                        root.showedLanguageSelection = true;
                    }
                }
            }
        },
        State {
            name: "seabirdLanguage"
            PropertyChanges {
                target: _page
                title: qsTr("Hei! Your Type Folio has a Nordic&#160;layout")
                description: qsTr("Choose the right language for you from the list below. You can always change this again later in Settings.")
                visible: !seabirdLanguageLoader.languageSelectionActive
                primaryButtonText: qsTr("Next")
                onPrimaryClicked: {
                    // Always reset when setting up
                    Settings.inputFlavor = Settings.InputFlavorType.Windows;
                    root.state = "seabirdPreference";
                }
            }
            PropertyChanges {
                target: seabirdLanguageLoader
                active: true
            }
        },
        State {
            name: "seabirdPreference"
            PropertyChanges {
                target: _page
                title: qsTr("Keyboard shortcuts")
                description: qsTr("Choose a style of key combinations. Your preference can be updated in Settings anytime.")
                primaryOption: seabirdPreferenceLoader.hasSelection
                primaryButtonText: qsTr("Next")
                onPrimaryClicked: {
                    if (insecureSettings.setup) {
                        // If showing this page during the full setup, set seabirdSetup=true so
                        // that user won't have to run the seabird-only setup later on.
                        Settings.seabirdSetup = true;
                    }
                    root.forward();
                }
            }
            PropertyChanges {
                target: seabirdPreferenceLoader
                active: true
            }
        }
    ]

    ArkControls.SetupPage {
        id: _page
        anchors.fill: parent
    }

    Loader {
        id: seabirdLanguageLoader

        readonly property bool languageSelectionActive: active && !!item && item.languageSelectionActive

        anchors.fill: parent
        active: false
        sourceComponent: SeabirdLanguage {
            inputTopMargin: _page.contentPosition.topMargin + ArkControls.Values.spacing.x2large
            anchors.fill: parent
        }
    }

    Loader {
        id: seabirdPreferenceLoader

        readonly property bool hasSelection: active && !!item && item.hasSelection

        anchors {
            top: parent.top
            topMargin: _page.contentPosition.topMargin + ArkControls.Values.spacing.x2large
            horizontalCenter: parent.horizontalCenter
        }
        focus: active
        active: false
        sourceComponent: SeabirdPreference {
            anchors.fill: parent
        }
    }
}
