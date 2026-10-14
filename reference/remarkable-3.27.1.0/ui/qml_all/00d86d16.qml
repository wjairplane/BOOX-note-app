import QtQuick
import com.remarkable


Item
{
    id: root

    signal activated(string sequence)

    enabled: visible

    Shortcut {
        sequence: "Escape"
        enabled: root.enabled
        onActivated: root.activated(sequence)
    }

    Shortcut {
        sequence: "Ctrl+W"
        enabled: root.enabled
        onActivated: root.activated(sequence)
    }

    // On the rM1, the center key is mapped to 'Home', so as a keyboard
    // shortcut this needs to trigger closing.
    Shortcut {
        sequence: "Home"
        enabled: root.enabled && DeviceInfo.deviceType == DeviceInfo.RM100
        onActivated: root.activated(sequence)
    }
}
