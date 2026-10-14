import QtQuick

import xofm.libs.qtgui
import xofm.libs.setup
import xofm.libs.wifi
import xofm.modules.wifi

BaseView {
    id: root

    required property NetworkAdapter networkAdapter
    required property WifiNetworks wifiNetworks
    required property WifiConnection wifiConnection
    required property var secureSettings
    property var onFinish: (windowNavigator) => {}

    onOpened: (args) => {
        const { onFinish } = args;
        root.onFinish = onFinish;
    }

    contentItem: Setup {
        initialPages: [ networkSetupPageComponent.createObject(root) ]
        showBackButton: true
        showSkipButton: false

        onSetupFinished: {
            // Setup triggers this signal when you press the back button with 1 page
            // or after SetupPage.onForward is triggered
            root.windowNavigator.close();
        }
    }

    Component {
        id: networkSetupPageComponent
        WifiSetupPage {
            networkAdapter: root.networkAdapter
            wifiConnection: root.wifiConnection
            wifiNetworks: root.wifiNetworks
            windowNavigator: root.windowNavigator
            secureSettings: root.secureSettings
            showWifiToggle: true
            onForward: root.onFinish(root.windowNavigator)
        }
    }
}
