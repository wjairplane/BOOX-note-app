import QtQuick
import QtQuick.Layouts
import com.remarkable
import common
import device.global
import device.ui.controls
import device.view.experimental as ExperimentalSettings // name conflict

import xofm.libs.ghostbuster // GhostBuster
import xofm.libs.qtgui
import xofm.libs.pincode
import xofm.libs.onboarding
import xofm.libs.settings // SettingsPage

import ark.tokens as ArkTokens
import ark.controls as ArkControls

DeviceKeyboardNavigationHandler {
    id: settings
    objectName: "Settings"

    required property WindowNavigator windowNavigator
    required property var wifiWidget
    required property var generalPaperTabletCells
    required property var generalPersonalCells
    required property var generalHelpCells
    required property var paperTabletInfoMessage
    required property var generalAccountInfo
    required property var iSettings
    required property var securityPanels
    required property var settingsHelpWidgets
    required property var settingsDisplayWidgets
    required property var ghostBuster
    required property var accessibilityWidgets
    required property var cloudPanels
    required property var internalBuildCells

    property int _selectedIndex: SettingsPage.General
    readonly property int _backIndex: SettingsPage.General - 1

    signal tooltipsReset
    signal close

    navigationModel: []
    canAcceptTabActivation: true
    firstNavigationIndex: 1 // skip back button
    keyOverrideHandler: overrideNavigation.bind(this)

    function onOpened(configuration) {
        ghostBuster.viewChange(GhostBuster.SettingsOpened);

        settings.windowNavigator.open("retail/window/retail-restricted", {
            accept: () => {},
            reject: () => { settings.close() }
        });

        const {action, index} = configuration;
        if (action && action === "showSubscription") {
            contentItem.showSubscription();
            return;
        }
        if (action && action === "showCloudSettings") {
            _selectedIndex = SettingsPage.Cloud;
            highlightedIndex = _selectedIndex;
            return;
        }


        _selectedIndex = index ?? SettingsPage.General;
        highlightedIndex = _selectedIndex;
    }

    readonly property bool showLabels: width > 1200

    CloseShortcut {
        onActivated: settings.close()
    }

    onActivated: (element) => {
        if (element) {
            element.activate();
        }
    }

    // Home button
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Home) {
            settings.close();
            event.accepted = true;
        }
    }

    function showSubscription() {
        sideBarItemClicked(SettingsPage.General, () => {
            payloadLoader.item.showSubscription();
        });
    }

    function overrideNavigation(event) {
        // Handle going from the sidebar to the main layout
        if (event.key === Qt.Key_Right) {
            if (payloadLoader.item) {
                settings.firstNavigationIndex = settings.index;
                settings.resetFocusIndex();
                payloadLoader.item.forceActiveFocus();
                // Not all settings pages support keyboard navigation
                // yet, so check if they do first.
                if (typeof payloadLoader.item.navigate === "function") {
                    payloadLoader.item.navigate();
                }
                return true;
            }
        }
        return false;
    }

    // Please do not remove this section as it improves the _percieved_
    // responsiveness. Yes, it looks a bit janky, but it serves a purpouse.
    property int highlightedIndex: settings._selectedIndex
    Timer {
        id: sidebarTimer
        interval: 200
        onTriggered: {
            settings.sideBarItemClicked(settings.highlightedIndex);
        }
    }

    function sideBarItemClicked(_index, _callback) {
        _selectedIndex = _index;
        if (_callback) {
            _callback();
        }
    }

    property SettingsModel model: SettingsModel {}

    property Component delegate: ArkControls.SidebarItem {
        id: item

        required property var model

        type: ArkTokens.Sidebar.primary
        text: showLabels ? qsTranslate("SettingsModel", model.title) : ""
        iconSource: "qrc:/ark/icons/" + model.icon
        highlighted: settings.highlightedIndex === model.index
        visible: model.visible
        Layout.fillWidth: true
        // keyboard navigation start
        showFocus: settings.current === item
        Component.onCompleted: {
            navigationModel.push(item);
            // FIXME (SW-21990): Dirty hack until the fix has landed in a released version of Ark
            if (contentItem && contentItem.children && contentItem.children.length > 1) {
               let target = contentItem.children[1];
               if (target && ("textFormat" in target)) {
                   target.textFormat = Text.StyledText;
               } else {
                   console.warn("contentItem.children[1] moved or lacks textFormat; skipping");
               }
           }
        }
        // keyboard navigation end

        onTriggered: activate()
        function activate() {
            settings.highlightedIndex = model.index;
            sidebarTimer.running = true;
        }
    }

    Item {
        id: settingsSidebar
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        implicitWidth: settingsColumn.width + sidebarDivider.width

        ColumnLayout {
            id: settingsColumn
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            spacing: 0
            width: showLabels ? implicitWidth : back.height

            ArkControls.SidebarItem {
                id: back
                type: ArkTokens.Sidebar.primary
                text: showLabels ? qsTr("Back") : ""
                iconSource: "qrc:/ark/icons/chevron_left"
                Layout.fillWidth: true
                bottomDivider: true
                // keyboard navigation start
                showFocus: settings.current === back
                Component.onCompleted: navigationModel.unshift(back);
                // keyboard navigation end
                onTriggered: settings.close();
            }
            Repeater {
                id: settingsRepeater
                delegate: settings.delegate
                model: settings.model
            }
            Item {
                Layout.fillHeight: true
            }
        }
        Rectangle {
            id: sidebarDivider
            color: ArkControls.Sidebar.borderColor(ArkTokens.Sidebar.primary)
            width:ArkControls.Sidebar.borderWidth(ArkTokens.Sidebar.primary)
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: settingsColumn.right
            }
        }
    }

    ArkControls.PlaceholderBar {
        id: placeholder
    }

    // Generic loader to which can be used for all the settings pages.
    // To reduce memory footprint and force avoid storing state in QML
    Loader {
        id: payloadLoader
        anchors {
            left: !!payloadLoader.item?.fullscreen ? parent.left : settingsSidebar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        sourceComponent: {
            switch (settings._selectedIndex) {
            case settings._backIndex:
            case SettingsPage.General:
                return general;
            case SettingsPage.Wifi:
                return wifi;
            case SettingsPage.Cloud:
                return cloud;
            case SettingsPage.Security:
                return lockScreen;
            case SettingsPage.Display:
                return display;
            case SettingsPage.Accessibility:
                return accessibility;
            case SettingsPage.Help:
                return help;
            case SettingsPage.Developer:
                return developer;
            case SettingsPage.Experimental:
                return experimental;
            default: return null;
            }
        }
    }

    Component {
        id: general
        General {
            generalPaperTabletCells: settings.generalPaperTabletCells
            personalCells: settings.generalPersonalCells
            paperTabletInfoMessage: settings.paperTabletInfoMessage
            generalAccountInfo: settings.generalAccountInfo
            internalBuildCells: settings.internalBuildCells
            onWifiClicked: settings.sideBarItemClicked(SettingsPage.Wifi)
            windowNavigator: settings.windowNavigator
            secureSettings: Settings
        }
    }

    Component {
        id: wifi
        Item {
            anchors.fill: parent
            WidgetLoader {
                anchors.fill: parent
                widget: settings.wifiWidget.count > 0 ? settings.wifiWidget.get(0).widget : null
            }
        }
    }

    Component {
        id: cloud
        Cloud {
            cloudPanels: settings.cloudPanels
            onWifiClicked: settings.sideBarItemClicked(SettingsPage.Wifi)
        }
    }

    Component {
        id: lockScreen
        Security {
            iSettings: settings.iSettings
            windowNavigator: settings.windowNavigator
            securityPanels: settings.securityPanels
        }
    }

    Component {
        id: display
        Display {
            displayItems: settings.settingsDisplayWidgets
            windowNavigator: settings.windowNavigator
        }
    }

    Component {
        id: accessibility
        Accessibility {
            accessibilityWidgets: settings.accessibilityWidgets
        }
    }

    Component {
        id: help
        Help {
            settingsHelpWidgets: settings.settingsHelpWidgets
            windowNavigator: settings.windowNavigator
        }
    }
}
