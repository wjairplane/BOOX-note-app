import QtQuick

import xofm.libs.qtgui // BaseView
import xofm.libs.retail
import xofm.libs.gestures // GestureInhibitorWrapper

BaseView {
    id: root

    required property var retailSettings
    required property GestureInhibitorWrapper gestureInhibitor

    Binding {
        target: gestureInhibitor
        property: "enabled"
        value: root.visible
    }

    property var reject: (() => {})
    property var accept: (() => {})

    function _close() {
        root.reject();
        root.windowNavigator.close();
    }

    function _continue() {
        root.accept();
        root.windowNavigator.close();
    }

    onOpened: (args) => {
        const { accept, reject } = args;

        if(typeof accept !== "function" || typeof reject !== "function") {
            console.error("Retail restricted without valid accept and reject functions");
            root.windowNavigator.close();
            return;
        }

        root.accept = accept;
        root.reject = reject;

        if(!retailSettings.enabled) {
            root._continue();
        }
    }

    contentItem: RetailRestrictedDialog {
        retailSettings: root.retailSettings
        onAccepted: root._continue()
        onClose: root._close()
    }
}
