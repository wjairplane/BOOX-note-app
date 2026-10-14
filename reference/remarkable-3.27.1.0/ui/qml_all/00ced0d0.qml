import QtQuick
import QtQuick.Controls

import device.view.main
import com.remarkable

import xofm.libs.qtgui
import xofm.libs.sceneview
import xofm.libs.user
import xofm.libs.pincode
import xofm.libs.orientation
import xofm.libs.documentorientation
import xofm.libs.epub
import xofm.libs.search.ui // SearchIndexStatus
import xofm.libs.sharebyurl
import xofm.libs.notificationbar // NotificationQueue
import xofm.libs.peninput
import xofm.libs.analytics.ui

BaseView {
    id: root

    required property var statusIndicators
    required property var ghostBuster
    required property TextColumn textColumn
    required property var insecureSettings
    required property PenInput penInput
    required property var toolbarConfiguration
    required property var toolbarProvider
    required property PasscodeHandler passcodeHandler
    required property var documentViewListener
    required property Orientation orientation
    required property DocumentOrientation documentOrientation
    required property EpubSettings epubSettings
    required property DocumentState documentState
    required property SearchIndexStatus searchIndexStatus
    required property ShareByUrl shareByUrl
    required property NotificationQueue notificationQueue
    required property var pageSelection
    required property var createWidgets
    required property Analytics analytics


    contentItem: MainView {
        id: mainView
        statusIndicators: root.statusIndicators
        ghostBuster: root.ghostBuster
        textColumn: root.textColumn
        windowNavigator: root.windowNavigator
        windowLayout: root.windowLayout
        insecureSettings: root.insecureSettings
        penInput: root.penInput
        toolbarConfiguration: root.toolbarConfiguration
        toolbarProvider: root.toolbarProvider
        documentViewListener: root.documentViewListener
        orientation: root.orientation
        documentOrientation: root.documentOrientation
        documentState: root.documentState
        createWidgets: root.createWidgets
        epubSettings: root.epubSettings
        searchIndexStatus: root.searchIndexStatus
        shareByUrl: root.shareByUrl
        notificationQueue: root.notificationQueue
        pageSelection: root.pageSelection
        analytics: root.analytics
        passcodeHandler: root.passcodeHandler

        onWindowChanged: {
            if (window) {
                DeviceApp.initAfterQmlLoad();
            }
        }
    }

    onOpened: (args) => {
        mainView.onOpened(args);
    }
}
