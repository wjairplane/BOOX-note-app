import QtQuick
import QtQuick.Layouts

import xofm.libs.controls
import xofm.modules.password
import xofm.libs.dialogs
import xofm.libs.setup

import ark.tokens as ArkTokens
import ark.controls as ArkControls

Item {
    id: root

    property Password password
    property string recoveryCodeAttempt
    property bool resetPassword: false
    property bool wrongPuk: false
    property string _puk // to share the puk between pages

    signal done()
    signal failed()

    function handleBack() {
        if (loader.sourceComponent === recoveryComponent) {
            return false; // let Setup.qml deal with "back"
        }
        return loader.item.handleBack();
    }

    Loader {
        id: loader
        focus: true // this makes it possible for the loadees to get the focus
        anchors.fill: parent
        sourceComponent: inputComponent
    }

    Component {
        id: inputComponent

        SetupPasswordInput {
            password: root.password
            wrongPuk: root.wrongPuk
            recoveryCodeAttempt: root.recoveryCodeAttempt
            resetPassword: root.resetPassword
            onNext: (puk) => {
                loader.sourceComponent = recoveryComponent;
                root._puk = puk;
            }
            onFailed: root.failed();
        }
    }

    Component {
        id: recoveryComponent

        SetupRecoveryKeyDialog {
            puk: _puk
            onConfirm: root.done()
        }
    }
}
