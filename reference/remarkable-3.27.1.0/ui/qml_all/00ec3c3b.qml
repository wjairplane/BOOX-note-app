import QtQuick
import QtQuick.Controls as QtQuickControls
import common
import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.setup

SetupBasePage {
    id: root

    property bool forcedRefresh
    required property var ghostBuster

    stateName: "ScreenInfo"

    Timer {
        id: delayedforceClearNow
        interval: 500
        repeat: false
        onTriggered: root.ghostBuster.forceClearNow("Setup refresh page");
    }

    onVisibleChanged: {
        _page.primaryOption = false;
        if (visible) {
            delayedforceClearNow.start();
        }
    }

    ArkControls.SetupPage {
        id: _page
        anchors.fill: parent
        //: Title of screen blink setup page"
        title: qsTr("Did you see that?")
        //: Translations must preserve non-breaking spaces around "digital paper display" adaptation.
        description: qsTr("Traces of previous images appear occasionally, so your display refreshes to clear them. This is completely normal for a digital&#160;paper&#160;display.")
        //: Button to trigger another screen blink
        secondaryButtonText: qsTr("Refresh again")
        //: Button to move to next page
        primaryButtonText: qsTr("Next")
        primaryOption: false

        onSecondaryClicked: {
            ghostBuster.forceClearNow("Setup user initiated refresh");
            root.forcedRefresh = true;
            _page.primaryOption = true;
        }
        onPrimaryClicked: root.forward();
    }

    Image {
        id: image
        anchors.centerIn: parent
        source: Values.isPortraitOrientation ? "qrc:setup/qml/images/blink_portrait.png" : "qrc:setup/qml/images/blink_landscape.png"
    }
}
