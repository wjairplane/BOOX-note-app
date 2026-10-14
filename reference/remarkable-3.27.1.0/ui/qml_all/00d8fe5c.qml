import QtQuick
import QtQuick.Layouts

import com.remarkable
import common
import device.ui.controls
import device.ui.text
import device.view.navigator

import ark.controls as ArkControls

ContentItemBase {
    id: listItem

    property alias title: titleText.text
    property alias tags: _tags.tags
    property alias subtext: infoText.text

    enabled: true

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        anchors.rightMargin: Values.designGridMargin
        anchors.leftMargin: Values.designGridMargin
        spacing: 10

        Loader {
            id: iconLoader
            sourceComponent: folderComponent
            height: listItem.height
            width: ArkControls.Values.iconSize.medium
        }

        ColumnLayout {
            id: columnLayout
            height: contentRow.height + _syncProgress.height
            width: parent.width

            RowLayout {
                id: contentRow
                width: parent.width

                SubheaderSmall {
                    id: titleText
                    Layout.maximumWidth: parent.width * 0.7
                    elide: Text.ElideMiddle
                    textFormat: Text.PlainText
                    color: listItem.itemColor
                }

                ArkControls.Icon {
                    id: statusIcon
                    visible: listItem.isFavorite
                    Layout.minimumWidth: implicitWidth
                    source: "qrc:/ark/icons/star_inverted"
                    size: titleText.font.pixelSize
                    color: listItem.itemColor
                }

                Item {
                    Layout.fillWidth: true
                    ThumbnailTags {
                        id: _tags
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter
                        visible: tags.length > 0
                        vertical: false
                    }
                }

                Item {
                    id: _syncIconItem
                    Layout.minimumWidth: _syncIcon.width
                    SyncStatusIcon {
                        id: _syncIcon
                        anchors.centerIn: parent
                        syncStatus: listItem.syncStatus
                        color: listItem.selected ? Values.colorWhite : Values.colorBlack
                        onAbortExport: listItem.abortExport()
                        onRetrySync: listItem.retrySync()
                    }
                }

                ArkControls.Caption {
                    id: infoText
                    Layout.minimumWidth: text ? contentWidth : 0
                    elide: Text.ElideMiddle
                    textFormat: Text.PlainText
                    color: listItem.itemColor
                    text: listItem.formatDisplayText(listItem.childIndex, listItem.filetype,
                                                     listItem.type, listItem.childCount)
                }
            } //RowLayout
            ProgressIndicator {
                id: _syncProgress
                Layout.fillWidth: true
                backgroundColor: listItem.backgroundColor
                foregroundColor: listItem.itemColor
                visible: listItem.progress > 0
                progress: listItem.progress
            }
        } //ColumnLayout
    } //RowLayout

    Rectangle {
        id: separator
        anchors {
            left: listItem.left
            right: listItem.right
            bottom: listItem.bottom
        }
        height: Values.hairlineSize
        color: listItem.itemColor
    }

    Component {
        id: folderComponent
        Item {
            width: parent.width
            height: parent.height
            ArkControls.Icon {
                id: iconItem
                anchors.centerIn: parent
                size: ArkControls.Values.iconSize.medium
                source: listItem.folderIcon
                color: listItem.itemColor
            }
        }
    }
}
