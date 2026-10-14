import xofm.libs.keyboard

Shortcut {
    required property var settings

    sequence: "Ctrl+Shift+A"
    onActivated: {
        settings.accessibilityMode = !settings.accessibilityMode;
    }
}
