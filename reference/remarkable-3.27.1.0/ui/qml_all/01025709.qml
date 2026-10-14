import QtQuick

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.qtgui

ArkControls.Cell {
    id: root

    required property var helpClockCellItems

    title: qsTr("System time")

    Repeater {
        id: repeater
        model: root.helpClockCellItems
        delegate: WidgetLoader {}
    }
}
