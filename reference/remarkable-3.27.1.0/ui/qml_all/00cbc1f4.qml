import xofm.libs.keyboard
import xofm.libs.pincode

Shortcut {
    id: root
    required property PasscodeHandler passcodeHandler
    sequence: "Ctrl+Tab"
    enabled: !passcodeHandler.userLocked
    onActivated: {
        windowNavigator.open("documentdrawer/window/main");
    }
}
