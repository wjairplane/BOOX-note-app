import QtQuick
import QtQuick.Layouts
import xofm.libs.mdm
import xofm.libs.qtgui
import xofm.libs.pincode

import ark.tokens as ArkTokens
import ark.controls as ArkControls


OnboardingPage {
    id: root
    required property WindowNavigator windowNavigator
    required property PasscodeHandler passcodeHandler
    title: qsTr("Keeping work secure")

    canContinue: {
        if(passcodeHandler?.minimumPincodeLength === 0) {
            return true;
        }
        return passcodeHandler?.hasPasscode && passcodeHandler.passcodeLength >= passcodeHandler.minimumPincodeLength;
    }

    actionButtonText: qsTr("Set passcode")
    illustrationSource:"qrc:/onboarding/illustrations/data_safety_and_privacy"
    onActionButtonClicked: {
        windowNavigator.open("security-pincode/window/passcode-update")
    }
    contentItem: ColumnLayout {
        ArkControls.Body {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap

            text: qsTr("Your reMarkable account is associated with an enterprise with enhanced security.")
        }
        ArkControls.Body {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap

            visible: !passcodeHandler?.hasPasscode
            text: qsTr("To make your paper tablet compliant with your workplace, set a passcode with minimum %1 digits.").arg(passcodeHandler?.minimumPincodeLength ?? "")
        }
        ArkControls.Body {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap

            visible: passcodeHandler?.hasPasscode
            text: qsTr("To make your paper tablet compliant with your workplace, update the passcode with minimum %1 digits.").arg(passcodeHandler?.minimumPincodeLength ?? "")
        }
    }
}
