import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtQuickControls
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import ark.tokens as ArkTokens
import ark.controls as ArkControls

import xofm.libs.qtgui

Background {
    id: root

    required property var settingsHelpWidgets
    required property WindowNavigator windowNavigator

    signal close

    function goBack() {
        root.close();
    }

    ScrollArea {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: itemWrapper.childrenRect.height + (itemWrapper.children.length - 1) * ArkControls.Values.spacing.xlarge
        enableScrollbar: true
        permanentScrollbar: true
        scrollbarTopMargin: header.y

        Item {
            id: itemWrapper
            implicitWidth: flickable.width

            ArkControls.PlaceholderBar {
                // keep this navigation bar for the sake of alignment
                id: navigationBar
                type: ArkTokens.NavigationBar.secondary
            }

            ArkControls.Title {
                id: header
                text: qsTr("Help")
                type: ArkControls.Title.Large
                anchors {
                    top: navigationBar.bottom
                    left: parent.left
                    leftMargin: ArkControls.Values.margin.horizontal.large
                }
            }

            ColumnLayout {
                id: column
                anchors {
                    top: header.bottom
                    topMargin: ArkControls.Values.platform.spacing.x2large
                    left: parent.left
                    leftMargin: ArkControls.Values.margin.horizontal.large
                    right: parent.right
                    rightMargin: ArkControls.Values.margin.horizontal.large
                }
                spacing: ArkControls.Values.platform.spacing.x2large

                Repeater {
                    id: repeater
                    model: root.settingsHelpWidgets
                    delegate: WidgetLoader {
                        id: widgetLoader
                        Layout.fillWidth: true
                    }
                }

                ArkControls.Body {
                    id: supportText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: qsTr("For troubleshooting, support, and FAQ go to <b>https://support.remarkable.com</b>")
                }

                Item {
                    Layout.preferredHeight: 300
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignLeft

                    QRCodeProvider {
                        id: provider
                        text: "https://support.remarkable.com/"
                    }

                    Image {
                        id: qrcode
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: provider.imageUrl
                    }
                }
            }
        }
    }
}
