import QtQuick
import QtQuick.Layouts
import xofm.libs.qtgui // WidgetLoader
import ark.controls as ArkControls

GridLayout {
    id: root

    required property var toggles

    columns: 2
    columnSpacing: ArkControls.Values.spacing.small * 2
    rowSpacing: ArkControls.Values.spacing.small * 2
    layoutDirection: Qt.RightToLeft

    Repeater {
        model: root.toggles
        delegate: WidgetLoader { }
    }
}
