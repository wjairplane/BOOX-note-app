import xofm.libs.qtgui
import xofm.libs.notificationbar
import xofm.libs.homescreen

Action {
    id: root
    objectName: "trash-action"
    required property WindowNavigator windowNavigator
    required property NotificationQueue notificationQueue
    supportedViews: ["trash"]
    iconSource: "qrc:/ark/icons/trashcan_delete"
    onActionClicked: {
        root.windowNavigator.open("library-ui/window/confirm-delete-trash", {
            onAccepted: () => {
                const numFilesTrashed = explorer.removeAllTrashed();
                root.notificationQueue.enqueue({
                    "text": qsTr("%n item(s) were deleted", "", numFilesTrashed),
                    "style": Notification.Secondary,
                });
            },
        });
    }
}
