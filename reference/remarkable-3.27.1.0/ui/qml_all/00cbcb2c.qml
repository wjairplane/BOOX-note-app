import QtQuick

import xofm.libs.qtgui
import xofm.libs.controls
import xofm.libs.epaper as Epaper
import xofm.libs.onboarding

import xofm.modules.documentdrawer

BaseView {
    id: root

    required property var library
    required property var drawerVisible
    required property var activeDocument

    property var ignoreIds: []
    // If we have an open document, we will skip selection of it
    // and select the previous open document. This allows for quick
    // document switching.
    property bool skipFirstDocument: false

    function close() {
        root.windowNavigator.close()
    }

    background: Epaper.ScreenModeItem {
        mode: Epaper.ScreenModeItem.Animation
        objectName: "document-drawer-window"
        MouseArea {
            anchors.fill: parent
            onClicked: close()
        }
    }

    contentItem: FocusScope {
        InputBlocker {
            width: parent.width
            anchors.top: parent.top
            height: column.height
        }

        Column {
            id: column
            anchors.top: parent.top
            width: parent.width

            RecentMenu {
                width: parent.width
                library: root.library
                windowNavigator: root.windowNavigator
                ignoreIds: root.ignoreIds
            }

            Rectangle {
                height: 4
                width: parent.width
                color: "black"
            }
        }
    }

    onVisibleChanged: {
        root.drawerVisible.value = visible;
    }

    onOpened: (args) => {
        const { ignoreIds } = args;

        // Avoid writing the property (and rebuilding the model) unnecessarily: test it actually changes.
        let newIgnoreIds = ignoreIds ?? [activeDocument.openedDocumentId];
        if (JSON.stringify(root.ignoreIds) !== JSON.stringify(newIgnoreIds)) {
            root.ignoreIds = newIgnoreIds;
        }

        OnboardingManager.setCompletedForKey(OnboardingManager.Group.Tooltips, "", "DocumentDrawer", true);
    }

    ContextCloseShortcut {
        onActivated: close()
    }
}
