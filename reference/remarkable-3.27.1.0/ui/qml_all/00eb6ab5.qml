import xofm.libs.keyboard
import xofm.libs.pincode

Shortcut {
    required property PasscodeHandler passcodeHandler
    sequence: "Ctrl+Shift+L"
    enabled: passcodeHandler.hasPasscode
    onActivated: {
      passcodeHandler.setLocked(true);
    }
}
