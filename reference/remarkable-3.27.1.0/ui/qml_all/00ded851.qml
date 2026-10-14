import xofm.libs.keyboard
import xofm.libs.manualrotation

Shortcut {
    required property ManualRotation manualRotation
    sequence: "Ctrl+Shift+R"
    onActivated: {
        manualRotation.rotate();
    }
}
