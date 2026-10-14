import QtQuick
import com.remarkable
import common
import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.setup

SetupBasePage {
    id: root

    stateName: "Complete"
    showBackButton: false
    showProgressIndicator: false

    ArkControls.SetupPage{
        anchors.fill: parent
        //: Title of the final setup page
        title: qsTr("You're good to go")
        description: qsTr("Your paper tablet is all set up and ready to use.")
        //: Button to finish (and leave) the setup flow
        primaryButtonText: qsTr("Get started")
        onPrimaryClicked: root.forward()
    }

    Image {
        anchors.centerIn: parent
        source: Values.isPortraitOrientation ? "qrc:setup/qml/images/summary_portrait.png" : "qrc:setup/qml/images/summary_landscape.png"
    }
}
