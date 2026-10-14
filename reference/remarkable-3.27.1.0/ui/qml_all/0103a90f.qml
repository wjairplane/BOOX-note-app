import QtQuick

import com.remarkable // QrCodeProvider

import xofm.libs.qtgui
import xofm.libs.onboarding
import xofm.modules.integrations.calendar

import ark.controls as ArkControls

BaseView {
    id: root

    required property CalendarSettings calendarSettings
    property bool hideCalendarButtonOption: false
    readonly property bool breakpoint: parent.height < 800

    function close() {
        if (hideButtonCheckBox.checked) {
            root.calendarSettings.buttonVisible = false;
        }

        root.windowNavigator.close();
    }

    onOpened: (args) => {
        const { hideButtonOptionVisible = false } = args;
        root.hideCalendarButtonOption = hideButtonOptionVisible;
    }

    contentItem: OnboardingDialogue {
        id: dialog

        initialModel: [{
            "title": qsTr("Create meeting note"),
            "body": [
                { "description": qsTr("Start focused, stay engaged, and get organized with create meeting note.") },
                { "description": qsTr("Visit <b>my.remarkable.com/&#8288;integrations</b> to add your Outlook or Google calendar, so you can view upcoming meetings, create prefilled meeting notes, and automatically store them in a meeting notes folder.") },
                { "description": qsTr("* Please note, you'll need a Connect subscription to use this feature. ") },
            ],
            "additionalItems": checkboxModel
        }]
        customImage: Image {
            source: qrProvider.imageUrl
            fillMode: Image.PreserveAspectFit
            // FIXME: this is a workaround to hide the QR code in landscape where there isn't enough space,
            // until it's fixed in Ark, see: SW-24893. Should be removed from here when it's fixed, see: SW-24894
            height: root.breakpoint ? 0 : 160
            width: height
        }

        rightButtonText: qsTr("Close")
        closeOption: true
        onFinished: root.close()

        QRCodeProvider {
            id: qrProvider
            text: "https://my.remarkable.com/integrations?utm_source=rm_device&utm_medium=qr_code&utm_campaign=calendar_3_27"
        }
    }

    ObjectModel {
        id: checkboxModel
        ArkControls.CheckBox {
            id: hideButtonCheckBox

            visible: root.hideCalendarButtonOption
            checked: !root.calendarSettings.buttonVisible
            width: parent?.width ?? 0
            text: qsTr("Hide create meeting note button")
        }
    }
}
