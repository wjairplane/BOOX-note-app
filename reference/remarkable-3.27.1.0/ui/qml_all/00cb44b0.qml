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
    required property var retailSettings
    required property var retailSshText
    required property var alternateSshText
    required property var defaultSshText
    required property var mdmSshText
    required property var mdmEnabled

    LinkDetails {
        id: networkAddresses
    }
    // avoid multiple calls to the network interface
    property string hardwareAddress: networkAddresses.hardwareAddress

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
        Rectangle {
            id: licensesItem
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                leftMargin: Values.navigatorHeaderTitleMargin
                topMargin: Values.navigatorHeaderTitleMargin
                bottomMargin: Values.navigatorHeaderTitleMargin
            }

            ScrollArea {
                id: licensedSoftwareFlickable
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Values.navigatorSidebarWidth

                clip: true
                contentWidth: licensedSoftwareColumn.width
                contentHeight: licensedSoftwareColumn.height

                Column {
                    id: licensedSoftwareColumn

                    Repeater {
                        id: licensedSoftwareRepeater
                        model: root.licenseInfo.licenses

                        delegate: MouseArea {
                            width: licensedSoftwareFlickable.width
                            height: licenseName.height + Values.navigatorMargin
                            onClicked: licensesFlickable.currentLicense = modelData

                            Rectangle {
                                height: parent.height
                                width: parent.width
                            }

                            TextParagraph {
                                id: licenseName
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData
                                wrapMode: Text.Wrap
                                font.bold: licensesFlickable.currentLicense === modelData
                                width: parent.width - Values.navigatorHeaderTitleMargin
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors {
                    left: licensedSoftwareFlickable.right
                }

                width: Values.outlineSize
                height: parent.height
                color: Values.colorBlack
            }

            ScrollArea {
                id: licensesFlickable
                anchors {
                    left: licensedSoftwareFlickable.right
                    leftMargin: Values.navigatorMargin
                    right: parent.right
                }
                height: parent.height

                property string currentLicense: licensedSoftwareRepeater.model[0]

                clip: true
                contentWidth: licensesColumn.width
                contentHeight: licensesColumn.height
                enableScrollbar: true
                permanentScrollbar: true
                scrollbarRightMargin: ArkControls.Values.margin.horizontal.small_static

                Column {
                    id: licensesColumn

                    // Add space for the scrollbar
                    rightPadding: ArkControls.Values.margin.horizontal.medium_static

                    TextParagraph {
                        id: licenseText
                        width: licensesFlickable.width - licensesColumn.rightPadding
                        text: root.licenseInfo.licenseText(licensesFlickable.currentLicense)
                        wrapMode: Text.WordWrap
                        font.family: "Noto Serif"
                    }

                    WidgetLoader {
                        active: licensesFlickable.currentLicense === licensedSoftwareRepeater.model[0]
                        width: licensesFlickable.width - licensesColumn.rightPadding
                        id: loader
                        widget: {
                            if (root.mdmEnabled.value) {
                                return root.mdmSshText.get(0).widget;
                            } else if (retailSettings.enabled) {
                                return root.retailSshText.get(0).widget;
                            }
                            if (root.alternateSshText.rowCount() > 0) {
                                return root.alternateSshText.get(0).widget;
                            }
                            return root.defaultSshText.get(0).widget;
                        }
                    }

                    Item {
                        // MAC address is visually part of the networks list if we use the defaultSshText widget
                        id: spacer
                        height: 50
                        width: 1
                        visible: loader.widget !== root.defaultSshText.get(0).widget;
                    }

                    TextParagraph {
                        id: macAddress
                        visible: !!hardwareAddress
                        text: "MAC: " + hardwareAddress
                    }
               }
            }
        }
    }
}
