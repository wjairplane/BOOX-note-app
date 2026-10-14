import QtQuick
import QtQuick.Layouts
import QtQml.Models
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import ark.tokens as ArkTokens
import ark.controls as ArkControls

import xofm.libs.qtgui

BaseView {
    id: root
    required property var licenseInfo

    contentItem: Background {

        ArkControls.NavigationBar {
            id: header
            type: ArkTokens.NavigationBar.secondary
            width: parent.width
            anchors.left: parent.left

            ArkControls.NavigationBar.Button {
                text: qsTr("Back")
                textPosition: ArkControls.Button.TextPosition.Right
                iconSource: "qrc:/ark/icons/chevron_left"
                onClicked: root.windowNavigator.close()
            }
        }

        Rectangle {
            anchors.top: header.bottom
            width: parent.width
            height: Values.outlineSize
            color: Values.colorBlack
        }

        Item {
            id: complianceTab
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            ScrollArea {
                id: complianceFlickable
                anchors.fill: parent

                clip: true
                contentWidth: width
                contentHeight: complianceColumn.height
                enableScrollbar: true
                permanentScrollbar: true
                scrollbarRightMargin: ArkControls.Values.margin.horizontal.small_static

                ColumnLayout {
                    id: complianceColumn
                    width: complianceTab.width

                    RowLayout {
                        id: aboutDevice
                        Layout.margins: 64
                        spacing: 48

                        Item {
                            Layout.preferredHeight: 160
                            Layout.preferredWidth: height
                            Layout.alignment: Qt.AlignLeft

                            QRCodeProvider {
                                id: provider
                                text: DeviceInfo.deviceId
                            }

                            Image {
                                id: qrcode
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                source: provider.imageUrl
                            }
                        }

                        ColumnLayout {
                            TextHeaderRegular {
                                text: qsTr("About this device")
                            }

                            ArkControls.Caption {
                                id: serialNumberText
                                width: parent.width
                                text: qsTr("Model number: %1<br>Serial number: %2").arg(DeviceInfo.modelNumber).arg(DeviceInfo.deviceId)
                            }
                        }
                    }

                    Rectangle {
                        id: lineSeparator
                        Layout.fillWidth: true
                        height: 2
                        color: "black"
                    }

                    RowLayout {
                        id: complianceLogos
                        Layout.topMargin: 76

                        Item {
                            // Left spacer
                            Layout.fillWidth: true
                        }

                        GridLayout {
                            id: gridLayout
                            rowSpacing: 100
                            columnSpacing: 60
                            columns: 2

                            Repeater {
                                model: root.licenseInfo.certifications

                                ColumnLayout {
                                    Layout.fillHeight: true

                                    TextHeaderSmall {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.region
                                    }

                                    Item {
                                        id: logoContainer
                                        width: 400
                                        height: logo.height
                                        Layout.fillHeight: true // Fill the height of the row
                                        Image {
                                            id: logo
                                            source: modelData.logo
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            states: State {
                                                when: logoContainer.height - logo.height < 100
                                                AnchorChanges {
                                                    target: logo
                                                    anchors.verticalCenter: logoContainer.verticalCenter
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            // Right spacer
                            Layout.fillWidth: true
                        }
                    }


                    Item {
                        id: spacer
                        width: parent.width; height: 1
                    }

                    EmptyViewItem {
                        id: noComplianceInfo
                        Layout.fillWidth: true
                        topPadding: root.height * Values.emptyViewTopMarginRatio
                        visible: root.licenseInfo.certifications.length === 0
                        leftMargin: Values.navigatorHeaderTitleMargin

                        emptyViewKey: "noComplianceStatements"
                    }

                    Repeater {
                        model: root.licenseInfo.certifications

                        ArkControls.Caption {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.margins: Values.navigatorHeaderTitleMargin
                            visible: modelData.text.length > 0
                            text: modelData.text
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}
