import QtQuick
import com.remarkable
import xofm.libs.controls

Item {
    id: root

    signal activated

    ContextShortcut {
        keys: ["Esc"]
        enabled: root.enabled
        modifiers: Qt.NoModifier
        onActivated: root.activated()
        target: root.parent
    }

    ContextShortcut {
        keys: ["W"]
        modifiers: Qt.ControlModifier
        enabled: root.enabled
        onActivated: root.activated()
        target: root.parent
    }

    // On the rM1, the center key is mapped to 'Home', so as a keyboard
    // shortcut this needs to trigger closing.
    ContextShortcut {
        keys: ["Home"]
        modifiers: Qt.NoModifier
        enabled: root.enabled && DeviceInfo.deviceType == DeviceInfo.RM100
        onActivated: root.activated()
        target: root.parent
    }
}
