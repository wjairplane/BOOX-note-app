import QtQuick
import QtQuick.Layouts
import xofm.libs.qtgui // WidgetLoader
import ark.controls as ArkControls

ColumnLayout {
    id: root
    required property var toggles

    spacing: ArkControls.Values.spacing.small * 2

    Repeater {
        model: root.toggles
        delegate: WidgetLoader { }
    }
}
