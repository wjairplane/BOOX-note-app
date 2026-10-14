import QtQuick
import com.remarkable

QtObject {
    id: root

    property string group: ""
    property string key: ""
    property bool defaultState
    property bool enabled: Settings.rawValue(group, key) ?? defaultState

    onEnabledChanged: {
        Settings.setRawValue(group, key, enabled);
    }
}
