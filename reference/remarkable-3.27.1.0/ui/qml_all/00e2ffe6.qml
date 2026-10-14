import QtQuick
import QtQuick.Layouts
import device.ui.controls
import ark.controls as ArkControls
import xofm.modules.softwareupdate
import xofm.libs.qtgui

ArkControls.Panel  {
    id: root
    property bool showAdvanced: false
    required property var advancedCells

    label: qsTr("Advanced")
    iconSource: "qrc:/ark/icons/cog"

    action: ArkControls.Toggle {
        checked: showAdvanced
        onToggled: {
            showAttachment = checked
        }
    }
    attachment: ArkControls.Cell {
        id: advancedOptions
        Repeater {
            id: repeater
            model: root.advancedCells
            delegate: WidgetLoader {
            }
        }
    }
    height: implicitHeight
}
