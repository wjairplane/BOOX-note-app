import QtQuick
import QtQuick.Layouts

import common
import device.ui.controls
import device.global

import xofm.libs.qtgui
import xofm.modules.systemclock
import xofm.libs.orientation

import ark.tokens as ArkTokens
import ark.controls as ArkControls

import "../DateHelper.js" as Helper

BaseView {
    id: root

    required property SystemClockWrapper clock
    required property Orientation orientation

    onOpened: clock.update();

    property int selection: DateTimePickerWindow.Selection.Date
    property int taskStatus: DateTimePickerWindow.TaskStatus.Idle

    readonly property int _dateTimeContainerTitleHeight: 60
    readonly property int _dateTimeContainerContentHeight: 90
    readonly property int _separatorWidth: 16
    readonly property int _selectedBorder: 4

    // this is our "live" source of truth - should be used for saving
    property date _date: clock.datetime

    // this is the date/time when you open this page - used to know whether an edition is being made
    property date _initialDate
    property bool _dateHasChanged: false

    enum Selection {
        Date,
        Time
    }

    enum TaskStatus {
        Idle,
        Success,
        Error
    }

    function evaluateChange(d) {
        root._dateHasChanged = !Helper.areDatesEqual(d, root._initialDate);
    }

    Component.onCompleted: {
        root._initialDate = root._date;
        // /!\ don't rely on a binding here, because sometimes the time can be changed by the system itself due to NTP sync..
        // but, our goal is to catch and update the UI if the changes were made by the user only !
    }

    contentItem: Background {

        ArkControls.NavigationBar {
            id: navigationBar
            type: ArkTokens.NavigationBar.secondary
            width: parent.width

            ArkControls.NavigationBar.Button {
                id: back
                text: qsTr("Back")
                textPosition: ArkControls.Button.TextPosition.Right
                iconSource: "qrc:/ark/icons/chevron_left"
                onClicked: root.windowNavigator.close()
            }
        }

        ColumnLayout {
            id: displayColumn

            anchors {
                top: navigationBar.bottom
                left: parent.left
                leftMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
                right: parent.right
                rightMargin: ArkControls.Values.settings.horizontalMargin.secondLevel
            }
            spacing: ArkControls.Values.platform.spacing.x2large

            ArkControls.Title {
                text: qsTr("Coordinated Universal Time (UTC)")
                type: ArkControls.Title.Large
            }

            RowLayout {
                Layout.preferredHeight: 150
                spacing: 0

                ColumnLayout {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: 360
                    spacing: 0

                    ArkControls.Label {
                        Layout.preferredHeight: root._dateTimeContainerTitleHeight
                        type: ArkControls.Label.LargeStrong
                        text: qsTr("Date")
                        verticalAlignment: Text.AlignTop
                        horizontalAlignment: Text.AlignLeft
                    }
                    DateTimeContainer {
                        objectName: "dateContainer"
                        Layout.minimumHeight: root._dateTimeContainerContentHeight
                        Layout.preferredWidth: parent.width
                        selectedBorder: _selectedBorder
                        model: [
                            {
                                text: root._date.getUTCDate().toString().padStart(2, '0'),
                                minWidth: 35
                            },
                            {
                                text: "/",
                                separator: root._separatorWidth
                            },
                            {
                                text: Qt.formatDateTime(root._date, "MMM"),
                                minWidth: 78
                            },
                            {
                                text: "/",
                                separator: root._separatorWidth
                            },
                            {
                                text: root._date.getUTCFullYear(),
                                minWidth: 78
                            },
                        ]
                        selected: root.selection === DateTimePickerWindow.Selection.Date
                        onClicked: root.selection = DateTimePickerWindow.Selection.Date;
                    }
                }

                Item {
                    // spacing item
                    Layout.fillHeight: true
                    Layout.preferredWidth: 80
                }

                ColumnLayout {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: 180
                    spacing: 0

                    ArkControls.Label {
                        Layout.preferredHeight: root._dateTimeContainerTitleHeight
                        type: ArkControls.Label.LargeStrong
                        text: qsTr("Time")
                        verticalAlignment: Text.AlignTop
                        horizontalAlignment: Text.AlignLeft
                    }

                    DateTimeContainer {
                        objectName: "timeContainer"
                        Layout.minimumHeight: root._dateTimeContainerContentHeight
                        Layout.preferredWidth: parent.width
                        selectedBorder: _selectedBorder
                        model: [
                            {
                                text: root._date.getUTCHours().toString().padStart(2, '0'),
                                minWidth: 44
                            },
                            {
                                text: ":",
                                separator: root._separatorWidth
                            },
                            {
                                text: root._date.getUTCMinutes().toString().padStart(2, '0'),
                                minWidth: 44
                            }

                        ]
                        selected: root.selection === DateTimePickerWindow.Selection.Time
                        onClicked: root.selection = DateTimePickerWindow.Selection.Time;
                    }
                }

                Item {
                    // filler item
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                ArkControls.Button {
                    id: button
                    Layout.minimumWidth: 142
                    Layout.preferredHeight: root._dateTimeContainerContentHeight
                    Layout.alignment: Qt.AlignBottom
                    text: qsTr("Set")
                    type: ArkTokens.Button.primary
                    visible: root._dateHasChanged && (root.taskStatus === DateTimePickerWindow.TaskStatus.Idle)
                    onClicked: root.clock.datetime = _date;
                }
            }
        }

        SpinnersContainer {
            id: spinnersContainer
            anchors {
                bottom: parent.bottom
            }
            height: parent.height/2
            width: parent.width
            showDate: root.selection === DateTimePickerWindow.Selection.Date
            visible: !closeTimer.running

            year: _date.getUTCFullYear()
            month: _date.getUTCMonth()+1
            date: _date.getUTCDate()
            hours: _date.getUTCHours()
            minutes: _date.getUTCMinutes()
            highlightBorder: _selectedBorder

            onNewYear: (year) => {
                let localDate = new Date(_date);
                localDate.setUTCFullYear(year);
                root.evaluateChange(localDate);
                _date = localDate;
            }
            onNewMonth: (month) => {
                let localDate = new Date(_date);
                localDate.setUTCMonth(month - 1);
                root.evaluateChange(localDate);
                _date = localDate;
            }
            onNewDate: (date) => {
                let localDate = new Date(_date);
                localDate.setUTCDate(date);
                root.evaluateChange(localDate);
                _date = localDate;
            }
            onNewHours: (hours) => {
                let localDate = new Date(_date);
                localDate.setUTCHours(hours);
                root.evaluateChange(localDate);
                _date = localDate;
            }
            onNewMinutes: (minutes) => {
                let localDate = new Date(_date);
                localDate.setUTCMinutes(minutes);
                root.evaluateChange(localDate);
                _date = localDate;
            }
        }

        ArkControls.NotificationBar {
            id: notifBar
            type: root.taskStatus === DateTimePickerWindow.TaskStatus.Success ? ArkTokens.NotificationBar.secondary : ArkTokens.NotificationBar.primary
            visible: root.taskStatus === DateTimePickerWindow.TaskStatus.Success || root.taskStatus === DateTimePickerWindow.TaskStatus.Error
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            ArkControls.NotificationBar.Message {
                type: notifBar.type
                iconSource: root.taskStatus === DateTimePickerWindow.TaskStatus.Success ? "" : "qrc:/ark/icons/warning_circle"
                text: root.taskStatus === DateTimePickerWindow.TaskStatus.Success ?
                          //: Notification shown to confirm system time was successfully changed
                          qsTr("System time set") :
                          //: Notification shown when unable to change system time
                          qsTr("Something went wrong. If the issue persists, contact support.")
                Layout.rightMargin: ArkControls.Values.padding.large
                Layout.leftMargin: ArkControls.Values.padding.large
                Layout.fillWidth: true
            }
        }

        Timer {
            id: closeTimer
            interval: Values.popupTimeout / 2
            running: root.taskStatus === DateTimePickerWindow.TaskStatus.Success || root.taskStatus === DateTimePickerWindow.TaskStatus.Error
            repeat: false
            onTriggered: root.windowNavigator.close()
        }
    }

    Connections {
        target: root.clock
        function onNewDateTime() {
            root.taskStatus = DateTimePickerWindow.TaskStatus.Success
        }
        function onDatetimeFailed() {
            root.taskStatus = DateTimePickerWindow.TaskStatus.Error
        }
    }
}
