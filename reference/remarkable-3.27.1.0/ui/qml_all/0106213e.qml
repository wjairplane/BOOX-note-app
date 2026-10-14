import QtQuick
import ark.tokens as ArkTokens
import ark.controls as ArkControls

import xofm.libs.qtgui

ArkControls.CellItem {
    id: cellItem
    property WindowNavigator windowNavigator
    property var navigationHandler
    showFocus: !!navigationHandler && navigationHandler.current === cellItem
}
