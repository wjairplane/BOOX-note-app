import QtQuick
import QtQuick.Layouts
import com.remarkable
import common
import device.global
import device.system
import device.ui.controls
import device.view.experimental
import xofm.libs.qtgui

import ark.controls as ArkControls
import ark.tokens as ArkTokens

DeviceKeyboardNavigationHandler {
    id: header
    objectName: "ContentHeader"
    navigationModel: [menuButton]
    canAcceptTabActivation: true

    height: Values.navigationEntriesHeaderHeight

    onTabCycle: {
        Global.keyboardNavigationController.focusOtherHandler(header);
    }
    onActivated: (element) => {
        if (element) {
            element.clicked(null);
        }
    }

    // Expose it for onboarding purposes
    readonly property var topStatusIndication: topStatusIndication
    readonly property real topStatusIndicationRightMargin: ArkTokens.Style.variable.platform.padding.xlarge

    signal menuClicked(var fromKeyboard)
    signal logoClicked
    signal statusIndicatorClicked

    Component.onCompleted: {
        if (Global.keyboardNavigationController) {
            Global.keyboardNavigationController.registerHandler(header);
        }
    }
    Component.onDestruction: {
        if (Global.keyboardNavigationController) {
            Global.keyboardNavigationController.unregisterHandler(header);
        }
    }

    Background {
        anchors.fill: parent
        color: Values.colorWhite
    }

    IconButton {
        id: menuButton
        iconSource: "qrc:/ark/icons/burger"
        releasable: true
        onClicked: menuClicked(header.current === menuButton)
        navigationHandler: header
    }

    Image {
        fillMode: Image.PreserveAspectFit
        source: "qrc:/qml/images/logo_remarkable_full.png"
        anchors.centerIn: parent
        height: 32

        MouseArea {
            anchors.fill: parent
            anchors.margins: -50
            onClicked: {
                header.logoClicked();
            }
        }
    }

    Loader {
        id: topStatusIndication
        anchors {
            right: parent.right
            rightMargin: header.topStatusIndicationRightMargin
            verticalCenter: parent.verticalCenter
        }
        sourceComponent: MouseArea {
            height: 64
            width: indicatorRow.width
            onClicked: {
                header.statusIndicatorClicked();
            }

            RowLayout {
                id: indicatorRow
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                spacing: ArkTokens.Style.spacing.xsmall

                ArkControls.Icon {
                    size: ArkControls.Values.iconSize.small
                    visible: DocumentSync.isSyncing
                    source: "qrc:/ark/icons/rotate"
                    Layout.alignment: Qt.AlignVCenter
                }

                ArkControls.Icon {
                    size: ArkControls.Values.iconSize.small
                    visible: !Notifications.notificationsAvailable && Notifications.hasError
                    source: "qrc:/ark/icons/cloud_x"
                    Layout.alignment: Qt.AlignVCenter
                }

                ArkControls.Icon {
                    size: ArkControls.Values.iconSize.small
                    visible: !LinkProvider.isOnline
                    source: {
                        if(Settings.airplaneMode) {
                            return "qrc:/ark/icons/airplane_fill";
                        }
                        return "qrc:/ark/icons/wifi_off";
                    }
                    Layout.alignment: Qt.AlignVCenter
                }

                Repeater {
                    id: statusIndicators
                    model: navigator.statusIndicators
                    delegate: WidgetLoader {
                        Layout.alignment: Qt.AlignVCenter
                        id: loader
                    }
                }
            }
        }
    }

}
