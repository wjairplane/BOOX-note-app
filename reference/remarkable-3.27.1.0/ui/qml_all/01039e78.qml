import QtQuick
import QtQuick.Layouts

import com.remarkable   // Library, LinkProvider

import device.view.experimental

import xofm.libs.analytics.ui // Analytics
import xofm.libs.explorer
import xofm.libs.homescreen // Action
import xofm.libs.user   // AuthWrapper
import xofm.libs.qtgui  // WindowNavigator
import xofm.modules.integrations.calendar

Action {
    id: root

    required property UpcomingEvents upcomingEvents
    required property Library library
    required property EventController eventController
    readonly property TreeExplorer explorer: NavigationManager.treeExplorerForNavigation
    required property CalendarController calendarController
    required property CalendarSettings calendarSettings
    required property AuthWrapper auth
    required property LinkProvider linkProvider
    required property WindowNavigator windowNavigator
    required property Analytics analytics

    readonly property bool isIntegrationConfigured: root.calendarController.integrationsCount > 0
    property bool _hidePopup: false

    objectName: "calendar-actions"
    iconSource: root.popupActive ? "qrc:/ark/icons/x_medium" : "qrc:/ark/icons/calendar"
    supportedViews: (root.isIntegrationConfigured || root.calendarSettings.buttonVisible)
                    ? ["myfiles"] : []

    Connections {
        target: root
        function onPopupActiveChanged() {
            root.calendarController.invalidateTimerActive = root.popupActive;
        }
    }

    onActionClicked: {

        if (!root.auth.loggedIn) {
            root.windowNavigator.open("integrations-calendar/window/unpaired-dialog");
            root._hidePopup = true;
            root.analytics.sendEvent("Calendar Interacted", {
                "trigger": "homescreen",
                "type": "not_paired_onboarding"
            });
        } else if (!root.isIntegrationConfigured) {
            if (root.linkProvider.isOnline) {
                // Connect dialog only makes sense if the user is online
                root.windowNavigator.open("integrations-calendar/window/connect-calendar-dialog",
                    { hideButtonOptionVisible: true } );
                root._hidePopup = true;
                root.analytics.sendEvent("Calendar Interacted", {
                    "trigger": "homescreen",
                    "type": "no_integration_set_up_onboarding"
                });
            } else {
                // If offline, let the emptyView be displayed
                root.analytics.sendEvent("Calendar Interacted", {
                    "trigger": "homescreen",
                    "type": "no_internet_connection"
                });
            }
        } else {
            root.windowNavigator.open("integrations-calendar/window/calendar-onboarding-dialog");
            // No need to hide the popup after this dialog
            root._hidePopup = false;
            root.upcomingEvents.requestReload();
            if (root.upcomingEvents.hasEvents) {
                // EventList displayed with events
                root.analytics.sendEvent("Calendar Interacted", {
                    "trigger": "homescreen",
                    "type": "meeting_list",
                    "meeting_count": root.upcomingEvents.rowCount()
                });
            } else if (root.calendarController.hasErrorString) {
                // EmptyView displayed with integration error
                root.analytics.sendEvent("Calendar Interacted", {
                    "trigger": "homescreen",
                    "type": "configuration_error"
                });
            } else if (!root.linkProvider.isOnline) {
                // EmptyView displayed with no active internet connection
                root.analytics.sendEvent("Calendar Interacted", {
                    "trigger": "homescreen",
                    "type": "no_internet_connection"
                });
            } else {
                // EmptyView displayed due to no events
                root.analytics.sendEvent("Calendar Interacted", {
                    "trigger": "homescreen",
                    "type": "meeting_list",
                    "meeting_count": 0
                });
            }
        }
    }

    popup: root._hidePopup ? null : popupComponent

    Component {
        id: popupComponent

        EventsPopup {
                id: eventsPopup

                upcomingEvents: root.upcomingEvents
                emptyViewString: calendarController.emptyViewString
                calendarController: root.calendarController

                width: 600
                height: eventsPopup.implicitPopupHeight

                onEventClicked: (event) => {
                    const inFolderId = Experimental.storeCalendarNotesInCurrent.enabled ?
                        root.explorer.currentFolderId.toString() :
                        root.library.meetingNotesId();
                    root.eventController.createFromEvent(event, inFolderId)
                    root.popupOverlay.hideAllPopups();
                }
        }
    }
}
