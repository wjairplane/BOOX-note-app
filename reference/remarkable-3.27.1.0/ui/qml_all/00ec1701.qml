import xofm.libs.qtgui
import device.view.settings as LegacySettings

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.user
import common
import xofm.libs.settings // SettingsPage

BaseView {
    id: root
    required property AuthWrapper auth
    required property AuthHelper authHelper
    required property var logoutPolicy
    required property var metrics

    contentItem: LegacySettings.Account {
        auth: root.auth
        authHelper: root.authHelper
        logoutPolicy: root.logoutPolicy
        metrics: root.metrics

        windowNavigator: root.windowNavigator

        onClose: {
            root.windowNavigator.close(root.objectName);
        }

        onWifiClicked: {
            root.windowNavigator.open("settings/window/main", { index: SettingsPage.Wifi });
            root.windowNavigator.close(root.objectName);
        }
    }
}
