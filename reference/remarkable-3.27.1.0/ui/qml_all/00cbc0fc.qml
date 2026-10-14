import xofm.libs.keyboard
import xofm.libs.pincode
import xofm.libs.qtgui

Shortcut {
    required property PasscodeHandler passcodeHandler
    required property var drawerVisible
    required property WindowNavigator windowNavigator
    sequence: "F8"
    enabled: !passcodeHandler.userLocked
    onActivated: {
        if (drawerVisible.value === true) {
            windowNavigator.close("documentdrawer/window/main");
            return;
        }
        windowNavigator.open("documentdrawer/window/main");
    }
}
