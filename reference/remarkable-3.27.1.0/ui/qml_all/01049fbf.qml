import QtQuick
import QtQuick.Layouts

import xofm.libs.controls
import xofm.libs.notificationbar

import ark.controls as ArkControls
import ark.tokens as ArkTokens

/** \addtogroup notificationbar
 *  @{
 */

/*! NotificationBar

### Usage example
\code{.qml}
    NotificationBar {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        notificationQueue: queue // Of type xofm::libs::notificationbar::NotificationQueue
    }

    Button {
        text: "Show Notification"
        onClicked: queue.enqueue({
            "text": "Hello, World!",
            "actionText": "Dismiss",
            "icon": "qrc:/icons/info.svg",
            "onClicked": () => {
                console.log("Notification action clicked");
            }
        })
    }
\endcode

\note
    Do not change the height of NotificationBar
*/

Loader {
    id: root

    required property NotificationQueue notificationQueue

    active: notificationQueue && notificationQueue.currentNotification
    sourceComponent: ArkControls.NotificationBar {
        id: notificationBar
        objectName: "notificationBar"
        type: notificationQueue.currentNotification.style === Notification.Primary ? ArkTokens.NotificationBar.primary : ArkTokens.NotificationBar.secondary

        ArkControls.NotificationBar.Message {
            objectName: "notification"
            text: notificationQueue.currentNotification.text
            iconSource: notificationQueue.currentNotification.icon
            type: notificationBar.type

            Layout.fillWidth: true
            Layout.leftMargin: ArkControls.Values.padding.large
            Layout.rightMargin: ArkControls.Values.padding.large
        }

        ArkControls.NotificationBar.Divider {
            objectName: "divider"
            visible: actionButton.visible
            type: notificationBar.type
        }

        ArkControls.NotificationBar.Button {
            id: actionButton
            objectName: "actionButton"
            type: notificationBar.type
            visible: notificationQueue.currentNotification.actionText !== ""
            text: notificationQueue.currentNotification.actionText
            onClicked: notificationQueue.currentNotification.clicked()
        }
    }
}
