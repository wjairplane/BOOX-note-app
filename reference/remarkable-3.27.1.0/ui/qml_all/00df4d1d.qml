import QtQuick
import xofm.libs.qtgui
import xofm.libs.onboarding
import xofm.libs.analytics.ui // Analytics
import com.remarkable

BaseView {
    id: root
    required property Settings settings
    required property Analytics analytics

    contentItem: HelpBrowser {
        onClose: root.windowNavigator.close()
        onResetTooltips: (id) => {
            OnboardingManager.setCompletedForKeysInGroup(OnboardingManager.Group.Tooltips, false);
            root.windowNavigator.open("legacydevice/window/main", {documentId: id, openedFrom: "guides"});
            root.windowNavigator.close();
        }
        onShowGestures: {
            windowNavigator.open("onboarding-ui/window/gestures");
        }
        onShowTutorial : {

            windowNavigator.open("legacydevice/window/main");
            windowNavigator.open("onboarding-ui/window/tutorial");
            windowNavigator.close();
        }
        onShowCalendarDialog: {
            root.analytics.sendEvent("Calendar Interacted", {
                "trigger": "guides",
                "type": "no_integration_set_up_onboarding"
            });
            root.windowNavigator.open("integrations-calendar/window/connect-calendar-dialog", { hideButtonOptionVisible: false });
        }
    }
}
