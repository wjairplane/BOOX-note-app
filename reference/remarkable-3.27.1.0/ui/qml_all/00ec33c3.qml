import QtQuick
import com.remarkable
import common
import xofm.libs.setup
import ark.controls as ArkControls

SetupBasePage {
    id: root
    stateName: "GettingStarted"
    showProgressIndicator: false

    //: Title of this setup page
    property string title: qsTr("Before you get started")
    property string description: qsTr("You'll need a smartphone or computer to set up your&#160;paper&#160;tablet.")

    ArkControls.SetupPage {
        anchors.fill: parent
        title: root.title
        description: root.description
        //: Button to move to next page
        primaryButtonText: qsTr("Next")
        onPrimaryClicked: root.forward()
    }

    Image {
        anchors.centerIn: parent
        source: Values.isPortraitOrientation ? "qrc:setup/qml/images/getting_started_portrait.png" : "qrc:setup/qml/images/getting_started_landscape.png"
    }
}
