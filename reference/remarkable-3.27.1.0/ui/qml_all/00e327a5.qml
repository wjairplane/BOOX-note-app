import xofm.libs.qtgui // WindowNavigator

import ark.controls as ArkControls

ArkControls.Cell {
    id: root

    required property WindowNavigator windowNavigator
    property var navigationHandler

    function activateComplianceInfo() {
        windowNavigator.open("compliance/window/complianceinfo")
    }

    function activateLicenseInfo() {
        windowNavigator.open("compliance/window/licenseinfo")
    }

    title: qsTr("About")

    ArkControls.CellItem {
        text: qsTr("Compliance statements")
        onClicked: root.activateComplianceInfo();
    }

    ArkControls.CellItem {
        text: qsTr("Copyrights and licenses")
        onClicked: root.activateLicenseInfo();
    }
}
