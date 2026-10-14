import QtQuick

import common // Values

import xofm.libs.controls // InputBlocker
import xofm.modules.integrations.calendar

import ark.controls as ArkControls

InputBlocker {
    id: root

    required property UpcomingEvents upcomingEvents
    property string emptyViewString: ""
    required property CalendarController calendarController
    readonly property double implicitPopupHeight: popupLoader.height

    signal eventClicked(var event)

    border {
        width: Values.outlineSize
        color: "black"
    }

    Loader {
        id: popupLoader

        width: parent.width
        sourceComponent: root.upcomingEvents.hasEvents ? eventsList : emptyView
    }

    Component {
        id: emptyView
        Item {
            width: parent.width
            height: 312
            ArkControls.Body {
                anchors.fill: parent
                //: Text that will show in the calendar popup when the user has calendar integration added, but no upcoming meetings
                text: root.emptyViewString
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Component {
        id: eventsList

        ListView {
            id: listView

            header: Item {
                width: listView.width
                height: 80
                ArkControls.Label {
                    anchors {
                        left: parent.left
                        top: parent.top
                        right: parent.right
                        leftMargin: 40
                        topMargin: 28
                        rightMargin: 40
                    }
                    type: ArkControls.Label.Medium
                    //: The header of the list showing upcoming calendar events where each can be clicked to create a notebook
                    text: qsTr("Create a meeting note")
                    elide: Text.ElideRight
                }
            }

            footer: Item {
                width: listView.width
                height: 40
            }

            width: parent.width
            height: listView.contentHeight

            clip: true
            orientation: ListView.Vertical
            snapMode: ListView.SnapToItem
            interactive: false
            spacing: 24
            model: root.upcomingEvents

            delegate: EventDelegate {
                onEventClicked: (event) => {
                    root.eventClicked(event);
                }
            }
        }
    }
}
