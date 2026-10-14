import QtQuick
import QtQuick.Layouts

import com.remarkable
import common
import device.ui.controls
import device.ui.text
import device.view.navigator
import device.view.experimental

import xofm.libs.settings
import xofm.libs.navigation // Entity

import ark.controls as ArkControls

ContentItemBase {
    id: gridItem

    property alias thumbnailLoaded: _thumbnail.loaded
    property alias tags: _tags.tags
    property alias title: _title.text
    property alias subtext: _infoText.text
    property bool showMetadata: true
    property string thumbnail
    property bool asynchronousThumbnail
    property bool isNew
    required property int cellMargin
    property int thumbnailSize

    // Used to reset the state for recycling
    function reset() {
        isSelecting = false;
        inactiveWarningVisible = false;
        archivedWarningVisible = false;
    }

    Item {
        id: _defaultIcon
        anchors.centerIn: _thumbnail
        anchors.verticalCenterOffset: -icon.size / 2
        visible: !parent.thumbnailLoaded

        ArkControls.Icon {
            id: icon
            anchors.horizontalCenter: parent.horizontalCenter
            size: ArkControls.Values.iconSize.large
            source: {
                if (gridItem.type === Entity.Type.Folder) {
                    return gridItem.folderIcon;
                }
                if (gridItem.passwordProtected) {
                    return "qrc:/ark/icons/padlock";
                }
                if (!gridItem.supported) {
                    return "qrc:/ark/icons/not_compatible";
                }

                return "qrc:/ark/icons/notebook";
            }
            opacity: archivedWarningVisible ? Values.archivedThumbnailOpacity : 1.0
        }

        ArkControls.Caption {
            id: _unsupportedText
            anchors.top: icon.bottom
            anchors.topMargin: Values.designGridMargin * 2
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !gridItem.supported
            textFormat: Text.PlainText
            text: gridItem.notCompatibleText
            color: gridItem.itemColor
        }
    }

    Item {
        id: _thumbnail
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: textColumn.top
            margins: gridItem.cellMargin
            bottomMargin: ArkControls.Values.spacing.small / 2
        }

        property bool loaded: _image.status === Image.Ready
        Image {
            id: _image
            property bool portrait: sourceSize.height >= sourceSize.width
            anchors.fill: parent
            fillMode: portrait ? Image.PreserveAspectCrop : Image.PreserveAspectFit
            mipmap: true
            source: supported && !passwordProtected ? gridItem.thumbnail : ""
            asynchronous: gridItem.asynchronousThumbnail
            opacity: archivedWarningVisible ? Values.archivedThumbnailOpacity : 1.0
        }

        ThumbnailTags {
            id: _tags
            anchors {
                top: parent.top
                left: parent.left
                right: _archiveWarning.visible ? _archiveWarning.left : parent.right
                bottom: _inactiveWarning.top
                margins: Values.designGridMargin
            }
        }

        ArchivedWarning {
            id: _archiveWarning
            anchors.bottom: _thumbnail.bottom
            anchors.right: _thumbnail.right
            anchors.bottomMargin: 1
            anchors.rightMargin: 1
            visible: gridItem.archivedWarningVisible
        }

        DocumentCover {
            id: border
            anchors.fill: parent
            color: Values.colorWhite
            borderColor: Values.colorBlack
            backgroundColor: selected ? Values.colorBlack : Values.colorWhite
            smooth: Values.desktopSimulator
            documentType:  {
                if (type === Entity.Type.Page) {
                    return DocumentCover.Undefined;
                }

                switch (filetype) {
                case Entity.FileType.Pdf:
                    return DocumentCover.Pdf;
                case Entity.FileType.Epub:
                    return DocumentCover.Ebook;
                case Entity.FileType.RmDocument:
                    return DocumentCover.Notebook;
                default:
                    return DocumentCover.Undefined;
                }
            }
        }

        InactiveWarning {
            id: _inactiveWarning
            anchors {
                bottom: _thumbnail.bottom
                left: _thumbnail.left
                leftMargin: 2   // avoid overwriting the border of the parent
            }
            width: _thumbnail.width - 4
            height: visible ? Values.inactiveWarningHeight : 0
            iconRightMargin: 12
            color: Values.colorWhite
            visible: gridItem.inactiveWarningVisible
        }
    }

    Column {
        id: textColumn
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: gridItem.cellMargin
            bottomMargin: ArkControls.Values.spacing.small
        }

        RowLayout {
            id: contentRow
            width: parent.width
            spacing: ArkControls.Values.spacing.small

            ArkControls.Label {
                id: _title
                type: ArkControls.Label.Medium
                elide: Text.ElideMiddle
                maximumLineCount: 1 // User input, make sure there are no linebreaks in it
                textFormat: Text.PlainText
                color: gridItem.itemColor
                Layout.fillWidth: true
            }

            ArkControls.Icon {
                id: favoriteIcon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                size: ArkControls.Values.iconSize.small
                color: gridItem.itemColor
                source: "qrc:/ark/icons/star_inverted"
                visible: gridItem.isFavorite
            }

            Rectangle {
                id: newIcon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                height: ArkControls.Values.iconSize.small / 2.5
                width: newIcon.height
                radius: 10
                color: Values.colorBlack
                visible: gridItem.isNew
            }
        }

        Column {
            // This column exists so we always have space for the sync Row, even when we are in small grid
            height: _infoText.implicitHeight
            width: parent.width

            ArkControls.Caption {
                id: _infoText
                width: parent.width
                visible: gridItem.passwordProtected || (!_statusRow.visible && gridItem.showMetadata && gridItem.thumbnailSize !== ThumbnailSettings.Small)
                maximumLineCount: 1 // User input, make sure there are no linebreaks in it
                elide: Text.ElideMiddle
                textFormat: Text.PlainText
                text: gridItem.passwordProtected ? qsTr("Password protected PDF")
                                                 : gridItem.formatDisplayText(gridItem.childIndex, gridItem.filetype,
                                                                              gridItem.type, gridItem.childCount)
                color: gridItem.itemColor
            }

            Row {
                id: _statusRow
                width: parent.width
                height: parent.height
                visible: gridItem.syncStatus || gridItem.progress
                spacing: 10
                ProgressIndicator {
                    id: _syncProgress
                    anchors.verticalCenter: parent.verticalCenter
                    visible: gridItem.progress > 0
                    width: parent.width - _syncIcon.width
                    backgroundColor: gridItem.backgroundColor
                    foregroundColor: gridItem.itemColor
                    progress: gridItem.progress
                }

                SyncStatusIcon {
                    id: _syncIcon
                    anchors.verticalCenter: parent.verticalCenter
                    syncStatus: gridItem.syncStatus
                    color: gridItem.selected ? Values.colorWhite : Values.colorBlack
                    onAbortExport: gridItem.abortExport(entityId)
                    onRetrySync: gridItem.retrySync(entityId)
                }
            }
        }
    }
}
