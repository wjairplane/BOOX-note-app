import QtQuick

import xofm.libs.onboarding

import ark.tokens as ArkTokens
import ark.controls as ArkControls

/*! Tooltip.qml
\ingroup onboarding

Example:

\code
import xofm.libs.onboarding.ToolTip

ToolTip {
    OnboardingStateProp.key: "MyTooltipKey"
    // Do not assign or bind to the `visible` property.
    // since the visibility of  the tooltip is bound to it's completed state and readyToShow property.
    readyToShow: <binding> // Set this property or create a binding to not override the binding on visible.

    // Other ArkControls.Tooltip properties

    OnboardingStateProp.onCompletedChanged: {
        if (OnboardingStateProp.completed) {
            // Do something when the tooltip is completed
        }
    }
}
*/

ArkControls.Tooltip {
    id: toolTip
    type: ArkTokens.Tooltip.secondary

    OnboardingStateProp.group: OnboardingManager.Group.Tooltips
    OnboardingStateProp.domain: ""

    // Allow setting more conditions for not showing the tooltip without
    // breaking the binding on visible.
    property bool readyToShow: false
    property int horizontalAlignment

    closeButtonFocusPolicy: Qt.NoFocus

    description: qsTranslate("xofm::libs::onboarding::ToolTipConfiguration", ToolTipConfiguration.textForKey(OnboardingStateProp.key))
    visible: !OnboardingStateProp.completed && readyToShow

    onClosed: {
        OnboardingStateProp.completed = true;
    }

    Connections {
        target: OnboardingManager
        enabled: readyToShow === true

        function onKeysInGroupSet(group) {
            if (group === OnboardingManager.Group.Tooltips) {
                readyToShow = false;
            }
        }
    }
}
