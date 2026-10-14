import QtQuick
import QtQuick.Layouts

import com.remarkable
import common

import device.ui.controls

import ark.controls as ArkControls

RowLayout {
    id: root

    property var navigationModel
    property var navigationHandler
    property int navigationIndex: 0

    function activate(selector) {
        Values.accessibilityRightHanded = selector === rightHandSelector;
        Settings.rightHandMode = Values.accessibilityRightHanded;
    }

    ArkControls.Selector {
        id: leftHandSelector
        text: qsTr("Left")
        objectName: "LeftRadioButton"
        illustration: "qrc:/settings/illustrations/handedness_left"
        Layout.alignment: Qt.AlignHCenter
        checked: !Values.accessibilityRightHanded
        onClicked: root.activate(leftHandSelector);

        Component.onCompleted: {
            if (navigationModel) {
                root.navigationModel[navigationIndex] = leftHandSelector;
            }
        }

        FocusFrame {
            anchors.fill: parent
            visible: !!root.navigationHandler && root.navigationHandler.current === leftHandSelector
        }
    }

    ArkControls.Selector {
        id: rightHandSelector
        text: qsTr("Right")
        objectName: "RightRadioButton"
        illustration: "qrc:/settings/illustrations/handedness_right"
        Layout.alignment: Qt.AlignHCenter
        checked: Values.accessibilityRightHanded
        onClicked: root.activate(rightHandSelector);

        Component.onCompleted: {
            if (navigationModel) {
                root.navigationModel[navigationIndex + 1] = rightHandSelector;
            }
        }

        FocusFrame {
            anchors.fill: parent
            visible: !!root.navigationHandler && root.navigationHandler.current === rightHandSelector
        }
    }
}
