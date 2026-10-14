import QtQuick

import common

import device.view.dialogs

import xofm.libs.qtgui
import xofm.libs.factoryreset
import xofm.modules.password

BaseView {
    id: root

    required property bool isDiskEncrypted
    required property Password password
    property int _state: SecurityLevelWindow.States.Idle

    enum States { Idle, Dialog, Confirmation }

    Connections {
        target: subpageLoader.item
        ignoreUnknownSignals: true

        function onNewState(state) {
            root._state = state;
        }

        function onGoBack() {
            if (SecurityLevelWindow.States.Confirmation) {
                // the user changed his mind during the confirmation => we must remove the marker file
                password.abortEncryption();
            }

            _state = SecurityLevelWindow.States.Idle;
            root.windowNavigator.close(SecurityLevelWindow.objectName);
        }

        function onNext() {
            if (_state === SecurityLevelWindow.States.Dialog)
                _state = SecurityLevelWindow.States.Confirmation;
            else if (_state === SecurityLevelWindow.States.Confirmation) {
                if (!root.isDiskEncrypted) {
                    password.encrypt();
                }
                root.windowNavigator.open("settings/window/factory-reset");
            }
        }
    }

    Component.onCompleted: _state = SecurityLevelWindow.States.Dialog

    contentItem: Background {
        Loader {
            id: subpageLoader
            anchors.fill: parent
            source: {
                if (_state === SecurityLevelWindow.States.Dialog)
                    return Qt.resolvedUrl("../EncryptionDialog.qml");
                if (_state === SecurityLevelWindow.States.Confirmation)
                    return Qt.resolvedUrl("../EncryptionConfirmation.qml");
                return "";
            }
            active: _state !== SecurityLevelWindow.States.None
            onLoaded: item.isDiskEncrypted = root.isDiskEncrypted;
        }
    }

}
