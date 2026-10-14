import QtQuick

import xofm.libs.qtgui
import xofm.modules.sendmail
import xofm.libs.orientation
import xofm.libs.ghostbuster

import com.remarkable

BaseView {
    id: root

    required property Orientation orientation
    required property GhostBuster ghostBuster

    onVisibleChanged: {
        if (!visible) {
            ghostBuster.viewChange(GhostBuster.ShareByEmailClosed);
        }
    }

    onOpened: (args) => {
        const { document, pages, password } = args;
        if(!document) {
            console.error("SendMailWindow requires a document");
            return;
        }
        shareEmailDialog.document = document;
        shareEmailDialog.pages = pages ?? [];
        shareEmailDialog.password = password ?? "";

        shareEmailDialog.open();

        ghostBuster.viewChange(GhostBuster.ShareByEmailOpened);
    }

    Connections {
        target: RetailDemo
        function onResourcesUnloaded() {
            root.windowNavigator.close();
        }
    }

    contentItem: ShareEmailDialog {
        id: shareEmailDialog
        orientation: root.orientation
        windowNavigator: root.windowNavigator
        onClose: root.windowNavigator.close();
    }
}
