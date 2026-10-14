import xofm.libs.keyboard as KYBD
import xofm.libs.localization as L10N

KYBD.Shortcut {
    id: root
    required property L10N.LanguageSettings languageSettings

    sequence: "Ctrl+Shift+T"
    onActivated: {
        const languages = root.languageSettings.availableLanguageCodes;
        const index = languages.indexOf(root.languageSettings.languageCode);
        const next = languages[index + 1] ?? languages[0];
        root.languageSettings.languageCode = next;
    }
}
