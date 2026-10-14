import QtQuick
import QtQuick.Layouts

import xofm.libs.setup
import xofm.libs.controls
import xofm.modules.password
import xofm.libs.dialogs

import ark.controls as ArkControls

SetupBasePage {
    id: root

    required property Password password
    property string inputLabel

    stateName: "Password"
    showBackButton: !password.busy
    pageReady: true

    function handleBack() {
        return initialize.handleBack();
    }

    SetupInitializePassword {
        id: initialize
        anchors.fill: parent
        password: root.password
        onDone: root.forward();
    }
}
