import QtQuick

import common
import xofm.libs.setup
import xofm.libs.user
import ark.controls as ArkControls

Item {
    id: root

    property string skipTitle: qsTr("Pair your device later")

    signal skipCanceled()

    ArkControls.SetupPage {
        anchors.fill: parent
        title: root.skipTitle
        //: &nbsp; is a non-breaking space, to ensure "Settings > Account" is not cut
        description: qsTr("Create an account and pair your device later by going to Settings&nbsp;>&nbsp;Account.")
        primaryButtonText: qsTr("Pair now")
        onPrimaryClicked: root.skipCanceled()
    }

    Image {
        anchors.centerIn: parent
        source: Values.isPortraitOrientation ? "qrc:userfrontend/qml/images/pairing_incomplete_portrait" : "qrc:userfrontend/qml/images/pairing_incomplete_landscape"
    }
}
