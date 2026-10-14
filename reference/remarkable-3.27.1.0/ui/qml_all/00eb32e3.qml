import com.remarkable // LogoutHandler

import xofm.libs.qtgui // BaseView
import xofm.libs.retail // RetailSettings
import xofm.libs.pincode // PasscodeHandler

BaseView {
    id: root

    required property RetailSettings retailSettings
    required property var policyEnabled
    required property PasscodeHandler passcodeHandler
    required property var logoutHandler

    contentItem: RetailDemoDialog {
        windowNavigator: root.windowNavigator
        retailSettings: root.retailSettings
        passcodeHandler: root.passcodeHandler
        logoutHandler: root.logoutHandler
        policyEnabled: root.policyEnabled.value
        onClose: {
            root.windowNavigator.close();
        }
    }
}
