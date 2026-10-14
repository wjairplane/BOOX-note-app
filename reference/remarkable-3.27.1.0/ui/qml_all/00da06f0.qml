import QtQuick

import ark.tokens as ArkTokens

import xofm.libs.system     // StatusIndicatorNotification
import xofm.libs.controls   // InputBlocker
import xofm.libs.gestures   // SwipeFilterFastControll

Rectangle {
    id: root

    required property string clipboardText
    required property bool showDocumentViewNotifier
    required property bool showClipboardNotifier

    /**
    * notification object containing the relevant details of the notification:
    *   message - string of the message to show ("This feature requires Wi-Fi connection")
    *   messageIconSource = path to the relevant icon to show, or and empty string if no icon is needed
    *   action - string of the button text, or an empty string if no button is needed
    *   onClicked - the function to execute when the button is clicked
    */
    property var notification: {
        "message": "",
        "messageIconSource": "",
        "action": "",
        "onClicked": () => {},
        "type": ArkTokens.NotificationBar.primary
    }

    color: "black" // Values.colorBlack

    signal clipboardActionClicked
    signal swipeGestureActivated

    readonly property int getBackgroundHeight:  Math.max(
            documentViewNotification.visible ? documentViewNotification.implicitHeight : 0,
            clipboardNotification.visible ? clipboardNotification.implicitHeight : 0)


    InputBlocker {
        anchors.fill: parent
    }

    TouchArea {
        id: notifierTouchArea
        anchors.fill: parent

        SwipeFilterFastScroll {
            touchSize: Qt.size(notifierTouchArea.width, notifierTouchArea.height)
            onActivated: root.swipeGestureActivated()
        }
    }


    StatusIndicatorNotification {
        id: documentViewNotification

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        visible: root.showDocumentViewNotifier

        notification: root.notification
    }

    StatusIndicatorNotification {
        id: clipboardNotification
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        visible: root.showClipboardNotifier && !root.showDiskNotifier && !documentViewNotification.visible

        notification: {
            "message": qsTr(root.clipboardText),
            "messageIconSource": "qrc:/ark/icons/paste",
            //: Recommended character limit for translation: 15
            "action": qsTr("Clear clipboard"),
            "onClicked": () => {
                root.clipboardActionClicked();
            }
        }
    }
}
