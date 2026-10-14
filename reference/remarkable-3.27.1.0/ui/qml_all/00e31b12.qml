import QtQuick
import QtQuick.Layouts

import common // Background
import com.remarkable // BatteryManager

import xofm.libs.qtgui // BaseView, WidgetLoader
import xofm.libs.onboarding // OnboardingManager
import xofm.libs.batterymanager // Battery

import ark.tokens as ArkTokens
import ark.controls as ArkControls

BaseView {
    id: root

    property var columns
    property var grids
    property var labels

    contentItem: Item {
        MouseArea {
            width: parent.width
            height: parent.height

            onPressed: {
                root.windowNavigator.close();
            }
        }

        Keys.onPressed: (event) => {
            root.windowNavigator.close();
            event.accepted = false;
        }

        Background {
            anchors.top: parent.top
            anchors.right: parent.right
            width: _layout.width
            height: _layout.height

            ColumnLayout {
                id: _layout
                spacing: 0

                Item {
                    // This item holds the battery indicator and the separator line
                    // Battery indicator position should be aligned with battery indicator in ContentHeader
                    // where it is positioned using right margin and vertical centering.
                    // ContentHeader is height is Values.navigationEntriesHeaderHeight
                    // So we use the same height here to align properly.
                    Layout.preferredHeight: Values.navigationEntriesHeaderHeight
                    Layout.preferredWidth: _batteryIndicator.implicitWidth
                    Layout.leftMargin: ArkTokens.Style.variable.platform.padding.xlarge
                    Layout.rightMargin: ArkTokens.Style.variable.platform.padding.xlarge
                    Layout.fillWidth: true

                    ArkControls.BatteryIndicator {
                        id: _batteryIndicator
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        highlighted: BatteryManager.battery.percentage <= 10
                        value: BatteryManager.battery.percentage
                        showValue: true
                        showCharging: BatteryManager.battery.chargerState === Battery.Charging

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.windowNavigator.close();
                            }

                            onPressAndHold: {
                                root.windowNavigator.open("settings/window/battery");
                                root.windowNavigator.close();
                            }
                        }
                    }

                    ArkControls.FoldoutDivider {
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                        }
                    }
                }

                // No spacing between battery indicator and labels
                Column {
                    Layout.preferredWidth: Math.max(_toggleGrid.width, _columnRow.width, _batteryIndicator.width)
                    Layout.rightMargin: ArkTokens.Style.variable.platform.padding.xlarge
                    Layout.leftMargin: ArkTokens.Style.variable.platform.padding.xlarge
                    Repeater {
                        width: parent.width
                        model: root.labels
                        delegate: WidgetLoader { width: parent.width }
                    }
                }

                ColumnLayout {
                    id: _toggleGrid
                    Layout.topMargin: ArkTokens.Style.variable.platform.spacing.large
                    Layout.rightMargin: ArkTokens.Style.variable.platform.padding.xlarge
                    Layout.leftMargin: ArkTokens.Style.variable.platform.padding.xlarge
                    spacing: ArkTokens.Style.variable.platform.spacing.large
                    visible: implicitHeight > 0

                    Repeater {
                        model: root.grids
                        delegate: WidgetLoader { }
                    }
                }

                RowLayout {
                    id: _columnRow
                    Layout.topMargin: ArkTokens.Style.variable.platform.spacing.large
                    Layout.rightMargin: ArkTokens.Style.variable.platform.padding.xlarge
                    Layout.leftMargin: ArkTokens.Style.variable.platform.padding.xlarge
                    Layout.fillWidth: true
                    spacing: ArkTokens.Style.variable.platform.spacing.large
                    visible: implicitHeight > 0

                    Repeater {
                        model: root.columns
                        delegate: WidgetLoader {
                            Layout.alignment: Qt.AlignRight | Qt.AlignTop
                        }
                    }
                }

                Item {
                    Layout.preferredHeight: ArkTokens.Style.variable.platform.padding.xlarge
                }
            }

            // Borders
            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Values.outlineSize
                color: Values.colorBlack
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: Values.outlineSize
                color: Values.colorBlack
            }
        }
    }
    onOpened: {
        OnboardingManager.setCompletedForKey(OnboardingManager.Group.Tooltips, "", "QuickSettings", true);
    }
}
