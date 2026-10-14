import xofm.libs.keyboard
import ark.tokens as ArkTokens

Shortcut {
    sequence: "Ctrl+Shift+P"    // for purple! (not deep though)
    onActivated: {
        ArkTokens.Settings.usingDebugColors = !ArkTokens.Settings.usingDebugColors;
    }
}
