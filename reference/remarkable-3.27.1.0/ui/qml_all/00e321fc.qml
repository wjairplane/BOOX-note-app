import device.view.settings // HandednessChooser
import xofm.libs.setup // SetupBasePage

import ark.controls as ArkControls

SetupBasePage {
    id: root

    property string title: qsTr("Choose your writing&#160;hand")
    property bool _didAutoSelect

    stateName: "Handedness"

    onVisibleChanged: {
        if (visible && !root._didAutoSelect) {
            // Select right hand by default
            root._didAutoSelect = true;
            Settings.rightHandMode = true;
        }
    }

    ArkControls.SetupPage {
        id: _page
        anchors.fill: parent
        title: root.title
        primaryButtonText: qsTr("Next")
        onPrimaryClicked: root.forward();
    }

    HandednessChooser {
        id: chooser
        anchors {
            top: parent.top
            topMargin: ArkControls.Values.margin.vertical.x3large + ArkControls.Values.platform.spacing.x2large
            horizontalCenter: parent.horizontalCenter
        }
        spacing: ArkControls.Values.spacing.x2large
    }
}
