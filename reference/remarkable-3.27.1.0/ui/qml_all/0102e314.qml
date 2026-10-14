import QtQuick
import QtQuick.Controls

import xofm.libs.qtgui
import xofm.libs.controls

import ark.tokens as ArkTokens
import ark.controls as ArkControls

BaseView {
    id: root
    required property var enterpriseOnboarding

    contentItem: InputBlocker {
        color: "#99FFFFFF"

        ArkControls.OnboardingDialog {
            id: onboarding
            anchors.fill: parent

            secondaryButtonText: qsTr("Next")
            onSecondaryClicked: {
                currentPage = currentPage + 1;
            }
            secondaryOption: completed
            closeOption: false
            currentPage: 1
            totalPages: root.enterpriseOnboarding.rowCount()

            // Binds to the widgets canContinue
            property bool completed: false
            onCompletedChanged: {
                if(currentPage < totalPages) {
                    return;
                }
                // When the final widget sets canContinue to true, we close the
                // current windown and open the `completed` window
                root.windowNavigator.open("mdm/window/completed")
                root.windowNavigator.close()
            }

            contentItem: WidgetLoader {
                id: onboardingWidget
                widget: root.enterpriseOnboarding.get(onboarding.currentPage - 1).widget
                Binding {
                    target: onboarding
                    property: "completed"
                    value: onboardingWidget.item.canContinue
                    when: onboardingWidget.status == Loader.Ready
                }
                Binding {
                    target: onboarding
                    property: "primaryOption"
                    value: !onboardingWidget.item.canContinue
                    when: onboardingWidget.status == Loader.Ready
                }
                Binding {
                    target: onboarding
                    property: "primaryButtonText"
                    value: onboardingWidget.item.actionButtonText
                    when: onboardingWidget.status == Loader.Ready
                }
                Connections {
                    target: onboarding
                    function onPrimaryClicked() {
                        onboardingWidget.item.actionButtonClicked();
                    }
                }
            }

        }
    }
}
