import xofm.libs.qtgui // BaseView
import device.view.settings as LegacySettings

BaseView {
    id: root

    required property var keyboardItems
    required property var languageSettings

    contentItem: LegacySettings.LanguageAndKeyboard {
        windowNavigator: root.windowNavigator
        keyboardItems: root.keyboardItems
        languageSettings: root.languageSettings
        onClose: {
            root.windowNavigator.close();
        }
    }
}
