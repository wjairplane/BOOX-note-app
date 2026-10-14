import QtQuick
import QtQuick.Layouts

import com.remarkable
import common
import device.ui.controls
import device.ui.text

import ark.controls as ArkControls

ContentItemBase {
    id: gridItem
    objectName: "ContentItemBase"

    enabled: true

    property alias title: _title.text
    property var tags: []

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        anchors.leftMargin: Values.designGridMargin
        anchors.rightMargin: Values.designGridMargin
        spacing: 10
        clip: true

        Item {
            id: icon
            width: ArkControls.Values.iconSize.medium
            height: gridItem.height

            ArkControls.Icon {
                id: iconItem
                anchors.centerIn: parent
                size: ArkControls.Values.iconSize.medium
                color: gridItem.itemColor
                source: gridItem.folderIcon
            }
        }

        SubheaderSmall {
            id: _title
            Layout.maximumWidth: {
                let max = parent.width - parent.spacing;
                if (icon.visible) {
                    max = max - icon.width - parent.spacing;
                }
                if (favoriteIcon.visible) {
                    max = max - favoriteIcon.width - parent.spacing;
                }
                if (tagIcon.visible) {
                    max = max - tagIcon.width - parent.spacing;
                }
                if (_syncIcon.visible) {
                    max = max - _syncIcon.width - parent.spacing;
                }

                return max;
            }
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideMiddle
            textFormat: Text.PlainText
            color: gridItem.itemColor
        }

        Item {
            Layout.fillWidth: true
        }

        SyncStatusIcon {
            id: _syncIcon
            syncStatus: gridItem.syncStatus
            Layout.alignment: Qt.AlignVCenter
            size: ArkControls.Values.iconSize.small
            color: gridItem.itemColor
            onAbortExport: gridItem.abortExport()
            onRetrySync: gridItem.retrySync()
        }

        ArkControls.Icon {
            id: favoriteIcon
            Layout.alignment: Qt.AlignVCenter
            size: ArkControls.Values.iconSize.small
            color: gridItem.itemColor
            source: "qrc:/ark/icons/star_inverted"
            visible: gridItem.isFavorite
        }

        ArkControls.Icon {
            id: tagIcon
            Layout.alignment: Qt.AlignVCenter
            source: "qrc:/ark/icons/tag_inverted"
            size: ArkControls.Values.iconSize.small
            color: gridItem.itemColor
            visible: tags.length > 0
        }
    }

    ProgressIndicator {
        id: _syncProgress
        anchors.bottom: rowLayout.bottom
        anchors.left: rowLayout.left
        anchors.right: rowLayout.right
        visible: gridItem.progress > 0
        backgroundColor: gridItem.backgroundColor
        foregroundColor: gridItem.itemColor
        progress: gridItem.progress
    }
}
