
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ArkControls.NotificationBar {
    id: root

    required property var notification
    type: notification?.type ?? ArkTokens.NotificationBar.primary

    signal dismissed

    ArkControls.NotificationBar.Message {
        id: notificationMessage
        objectName: "message"
        type: root.type
        text: root.notification?.message ?? ""
        iconSource: root.notification?.messageIconSource ?? ""
        Layout.fillWidth: true
        Layout.rightMargin: ArkControls.Values.padding.large
        Layout.leftMargin: ArkControls.Values.padding.large
        visible: !!root.notification?.message
    }

    ArkControls.NotificationBar.Divider {
        id: notificationDivider
        objectName: "divider"
        type: root.type
        visible: notificationActionButton.visible
    }

    ArkControls.NotificationBar.Button {
        id: notificationActionButton
        objectName: "actionButton"
        type: root.type
        text: root.notification?.action ?? ""
        visible: !!root.notification?.action
        onClicked: {
            if (root.notification?.onClicked) {
                const ok = root.notification.onClicked();

                if (ok === false) {
                    // onClicked with explicit return false means we want to keep the message around.
                    // Strict type checking to avoid other falsy values (as no return is undefined).
                    return;
                }

                root.dismissed();
            }
        }
    }
}
