import QtQuick
import com.remarkable
import common
import device.ui.text
import ark.controls as ArkControls

import xofm.libs.setup

Item {
    id: root

    readonly property bool hasSelection: row.selected !== "none"

    /** Map modifier keys to input flavor, accounting for any special mapping
        Qt applies when in Mac mode.
     */
    function keyToFlavor(key) {
        if (key === Qt.Key_Control) {
            return (Settings.inputFlavor === Settings.InputFlavorType.Apple) ? "Mac" : "PC";
        }
        if (key === Qt.Key_Alt) {
            return (Settings.inputFlavor === Settings.InputFlavorType.Apple) ? "None" : "Mac";
        }
        if (key === Qt.Key_Meta) {
            return (Settings.inputFlavor === Settings.InputFlavorType.Apple) ? "PC" : "None";
        }
        return "None";
    }

    Keys.onPressed: (event) => {
        event.accepted = (root.keyToFlavor(event.key) !== "None");
    }

    Keys.onReleased: (event) => {
        let newFlavor = root.keyToFlavor(event.key);
        if (newFlavor === "PC") {
            Settings.inputFlavor = Settings.InputFlavorType.Windows;
            row.selected = "PC";
            event.accepted = true;
        } else if (newFlavor === "Mac") {
            Settings.inputFlavor = Settings.InputFlavorType.Apple;
            row.selected = "Mac";
            event.accepted = true;
        }
    }

    onVisibleChanged: {
        if (visible) {
            root.forceActiveFocus();
        }
    }

    Row {
        id: row

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        spacing: Values.shortcutSelectionSpacing

        property string selected: "none"

        Column {
            spacing: Values.navigatorContentGridItemMargin

            Image {
                id: oneCircle
                width: 120
                height: 90
                source: {
                    if (row.selected === "PC") {
                        return "qrc:qml/device/view/settings/images/ctrlOn.svg";
                    } else {
                        return "qrc:qml/device/view/settings/images/ctrlOff.svg";
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        row.selected = "PC";
                        Settings.inputFlavor = Settings.InputFlavorType.Windows;
                    }
                }
            }

            ArkControls.Label {
                text: qsTr("PC")
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Column {
            spacing: Values.navigatorContentGridItemMargin

            Image {
                id: twoCircle
                width: 90
                height: 90
                source: {
                    if (row.selected === "Mac") {
                        return "qrc:qml/device/view/settings/images/altOn.svg";
                    } else {
                        return "qrc:qml/device/view/settings/images/altOff.svg";
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        row.selected = "Mac";
                        Settings.inputFlavor = Settings.InputFlavorType.Apple;
                    }
                }
            }

            ArkControls.Label {
                text: qsTr("Mac")
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    ArkControls.Body {
        anchors.horizontalCenter: row.horizontalCenter
        anchors.top: row.bottom
        anchors.topMargin: ArkControls.Values.spacing.xlarge
        width: row.width + (2 * ArkControls.Values.spacing.xlarge)
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: qsTr("The shortcuts menu will open when you press and hold this key for 3 seconds")
    }
}
