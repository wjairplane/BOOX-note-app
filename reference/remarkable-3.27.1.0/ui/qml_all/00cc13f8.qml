import QtQuick
import QtQuick.Controls

import xofm.libs.qtgui

import common
import com.remarkable

BaseView {
    id: root

    onOpened: (args) => {
        const { documentToUnlock, action } = args;

        loader.document = documentToUnlock;
        loader.acceptAction = action;
        loader.active = true;
    }

    contentItem: Loader {
        id: loader
        property Document document
        property var acceptAction

        sourceComponent: PasswordEntryDialog {
            id: entryDialog
            focus: true
            document: loader.document
            acceptAction: loader.acceptAction
            onCloseDialog: root.windowNavigator.close()
        }
    }
}
