import ark.tokens as ArkTokens
import ark.controls as ArkControls

ArkControls.OnboardingDialog.Content {

    //! This property tells the onboarding dialog wether we are allowed to
    //continue the onboarding.
    required property bool canContinue

    //! This property sets the text of the primary button of the onboarding
    //dialog. The primary button is only visible when `canContinue` evaluates to
    //false
    property var actionButtonText: null

    //! Signal for then the actionButton is clicked
    signal actionButtonClicked
}
