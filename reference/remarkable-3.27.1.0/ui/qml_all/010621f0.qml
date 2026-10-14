import QtQuick
import ark.controls as ArkControls

import xofm.libs.qtgui

ArkControls.StateSwitch {
    id: root

    property WindowNavigator windowNavigator

    selected: false
    iconSource: "qrc:/ark/icons/placeholder"
}
