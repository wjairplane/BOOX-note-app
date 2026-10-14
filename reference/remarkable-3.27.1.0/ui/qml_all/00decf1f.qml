import QtQuick

import com.remarkable   // PageSelection

import device.view.navigator
import device.view.syncserviceexplorer
import device.ui.controls   // PopupOverlay

import xofm.libs.qtgui
import xofm.libs.orientation
import xofm.libs.retail
import xofm.libs.search.ui
import xofm.libs.notificationbar
import xofm.libs.analytics.ui

BaseView {
    id: root

    required property PageSelection movePageSelection
    required property Orientation orientation
    required property RetailSettings retailSettings
    required property SearchIndexStatus searchIndexStatus
    required property NotificationQueue notificationQueue
    required property var statusIndicators
    required property Analytics analytics

    onOpened: (args) => {
        const { folderId } = args;

        if (folderId) {
            navigator.openFolderFromMyFiles(folderId);
        }
    }

    PopupOverlay {
        id: popupOverlay
        anchors.fill: parent
        focus: true
    }

    contentItem: Navigator {
        id: navigator

        movePageSelection: root.movePageSelection
        orientation: root.orientation
        retailSettings: root.retailSettings
        searchIndexStatus: root.searchIndexStatus
        notificationQueue: root.notificationQueue
        windowNavigator: root.windowNavigator
        popupOverlay: popupOverlay
        statusIndicators: root.statusIndicators
        analytics: root.analytics
    }
}
