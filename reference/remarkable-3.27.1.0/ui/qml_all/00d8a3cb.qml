import QtQuick
import com.remarkable
import common
import device.ui.controls

/**
    HeaderContainer is the base for various headers that are shown on top of the Navigator.
*/
DeviceKeyboardNavigationHandler {
    id: root
    objectName: "HeaderContainer"

    default property alias containerForward: root.data

    property alias timeout: timeoutTimer.interval
    property alias timer: timeoutTimer
    property alias rejectText: leftButton.title
    property alias rejectIconSource: leftButton.iconSource
    property alias rejectItem: leftButton
    property bool rejectEnabled: true
    property bool blackOnWhite: true
    property bool hideOnDismiss: false
    property bool modal: false

    signal rejected
    signal timedOut

    function show() {
        root.visible = true;
        if (timeout > 0) {
            timeoutTimer.start();
        }
    }

    function reject() {
        dismiss();
        rejected();
    }

    function dismiss() {
        root.focus = false;
        if (hideOnDismiss) {
            hide();
        }
    }

    function hide() {
        root.visible = false;
    }

    navigationModel: []
    canAcceptTabActivation: true

    visible: false
    implicitHeight: Values.navigatorSidebarItemHeight
    width: parent.width

    onVisibleChanged: {
        if (visible && timeout > 0) {
            timeoutTimer.start();
        }
    }

    MouseArea {
        anchors.fill: parent
    }

    Timer {
        id: timeoutTimer
        interval: 0
        repeat: false
        onTriggered: {
            dismiss();
            root.timedOut();
        }
    }

    Background {
        id: header
        anchors.fill: parent
        color: blackOnWhite ? Values.colorWhite : Values.colorBlack

        // Left button
        IconButton {
            id: leftButton
            anchors.left: parent.left
            releasable: true
            onClicked: activate()
            inverted: !blackOnWhite
            title: qsTr("Cancel")
            wrapMode: Text.NoWrap
            navigationHandler: root
            visible: root.rejectEnabled

            function activate() {
                root.reject();
            }
        }
    }

    MouseArea {
        id: modalBlock
        enabled: modal
        visible: enabled
        y: parent.height
        width: parent.width
        height: Values.deviceHeight - parent.height
        onPressed: (mouse) => {
            mouse.accepted = true;
            reject();
        }
    }
}
