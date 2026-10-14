import com.remarkable // LogoutHandler

import xofm.libs.qtgui
import xofm.libs.batterymanager // ShutdownCommand
import xofm.libs.retail // RetailSettings
import xofm.libs.localization // LanguageSettings

BaseView {
    id: root

    required property ShutdownCommand shutdownCommand
    required property RetailSettings retailSettings
    required property var logoutHandler
    required property LanguageSettings languageSettings

    contentItem: RetailSetupInfo {
        focus: true
        shutdownCommand: root.shutdownCommand
        retailSettings: root.retailSettings
        logoutHandler: root.logoutHandler
        languageSettings: root.languageSettings
        onClose: root.windowNavigator.close();
    }
}
