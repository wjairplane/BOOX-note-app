import QtQuick

import xofm.libs.qtgui
import xofm.libs.onboarding

import com.remarkable
import common

BaseView {
    id: root

    required property var screenShare

    onOpened: (args) => {
        if (!Authentication.loggedIn && !RetailDemo.enabled) {
            windowNavigator.open("userfrontend/window/cloud-feature-popup");
            root.windowNavigator.close();
        }
    }

    Connections {
        target: RetailDemo
        function onResourcesUnloaded() {
            root.windowNavigator.close();
        }
    }

    contentItem: OnboardingDialogue {
        property bool _canStart: Authentication.loggedIn && (LinkProvider.availability !== LinkProvider.Offline) && (!RetailDemo.enabled)
        readonly property string _description: RetailDemo.enabled ? qsTr("Stream your notes and ideas directly on a big screen. Turn your paper&#160;tablet into the perfect digital whiteboard to sketch and demonstrate concepts live. A must-have for video meetings and presentations.") :
            qsTr("Instantly share your thoughts in meetings with Screen Share.")
        readonly property string _connectionAmendment: qsTr("To start mirroring, accept the connection by either opening the desktop app or visiting <b>app.remarkable.com/&#8288;screenshare</b>")
        readonly property string _retailAmendment: Strings.notAvailableInRetailString

        initialModel: [{
                "image": "qrc:/onboarding/illustrations/share_and_collaborate",
                "title": qsTr("Share your screen"),
                "body": [
                    { "description": _description },
                    _canStart ? { "description": _connectionAmendment } : undefined,
                    RetailDemo.enabled ? { "description": _retailAmendment } : undefined ].filter(item => !!item),
            }]
        leftButtonText: _canStart ? qsTr("Cancel") : ""
        rightButtonText: _canStart ? qsTr("Share screen") : qsTr("Close")
        onQuit: {
            root.windowNavigator.close();
        }
        onFinished: {
            if (LinkProvider.availability !== LinkProvider.Offline) {
                screenShare.startServer();
            }
            root.windowNavigator.close();
        }
    }
}
