import QtQuick
import QtQuick.Layouts

import xofm.libs.qtgui
import xofm.libs.controls

import ark.controls as ArkControls

BaseView {
    id: root
    contentItem: InputBlocker {
        color: "transparent"

        ArkControls.ActionBar {
            objectName: "banner-no-actions"
            title: qsTr("Press power button to continue")
            height: 120 // ActionBar height depends on its buttons and here we have none
            width: parent.width
        }
    }
}
