import QtQuick

import xofm.libs.qtgui
import xofm.libs.localization

BaseView {
    id: root

    required property LanguageSettings languageSettings

    contentItem: RetailSetupLanguage {
        languageSettings: root.languageSettings
        onClose: root.windowNavigator.close();
        onNext: (window) => { root.windowNavigator.open(window); }
    }
}
