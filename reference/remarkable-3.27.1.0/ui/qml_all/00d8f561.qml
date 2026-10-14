import QtQuick
import QtQuick.Layouts

import com.remarkable
import common
import device.ui.controls
import device.ui.text
import device.view.navigator

import ark.controls as ArkControls

import xofm.libs.navigation // Entity

ContentItemBase {
    id: listItem
    property alias title: titleText.text
    property alias subtext: infoText.text
    property alias tags: _tags.tags
    property bool showMetadata: true
    property string path
    property string size
    property string thumbnail
    property bool asynchronousThumbnail
    property bool isNew
    property int wordHits
    property int documentWordHits

    readonly property string folderIcon: hasChildren ? "qrc:/ark/icons/folder_inverted" : "qrc:/ark/icons/folder"

    height: Values.navigatorContentListItemHeight + Values.navigatorMargin
    width: parent.width

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: ArkControls.Values.spacing.small
        spacing: ArkControls.Values.spacing.small

        Rectangle {
            id: thumbnailBackground
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            height: parent.height
            width: Math.floor(height / 1.33)
            ArkControls.Icon {
                objectName: "thumbnailIcon"
                source: {
                    if (listItem.type === Entity.Type.Folder) {
                        return listItem.folderIcon;
                    }
                    if (listItem.passwordProtected) {
                        return "qrc:/ark/icons/padlock";
                    }
                    if (!listItem.supported) {
                        return "qrc:/ark/icons/not_compatible";
                    }

                    return "qrc:/ark/icons/notebook";
                }
                color: listItem.itemColor
                anchors.centerIn: thumbnailImage
                visible: thumbnailImage.status !== Image.Ready
                opacity: archivedWarningVisible ? Values.archivedThumbnailOpacity : 1.0
            }

            Image {
                id: thumbnailImage
                property bool portrait: sourceSize.height >= sourceSize.width
                anchors.fill: parent
                fillMode: parent.portrait ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                verticalAlignment: parent.portrait ? Image.AlignTop : Image.AlignVCenter
                source: listItem.supported && !listItem.passwordProtected ? listItem.thumbnail : ""
                asynchronous: listItem.asynchronousThumbnail
                opacity: archivedWarningVisible ? Values.archivedThumbnailOpacity : 1.0

                DocumentCover {
                    id: documentCover
                    objectName: "thumbnailCover"
                    visible: listItem.type !== Entity.Type.Folder
                    anchors.fill: parent
                    smooth: Values.desktopSimulator
                    backgroundColor: selected ? Values.colorBlack : Values.colorWhite
                    documentType:  {
                        if (listItem.type === Entity.Type.Page) {
                            return DocumentCover.Undefined;
                        }
                        if (listItem.type === Entity.Type.Content) {
                            return DocumentCover.Undefined;
                        }

                        switch (listItem.filetype) {
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
            }
        }

        ColumnLayout {
            id: column

            Layout.fillWidth: true
            Layout.fillHeight: true
            RowLayout {
                id: titleRow
                // Individually tested icon transformation to 30px
                // must not scale with accessibility
                readonly property int iconHeight: 30
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: ArkControls.Values.spacing.small

                ArkControls.Label {
                    id: titleText
                    type: ArkControls.Label.Medium
                    // 220 is the offset approved by design and just slightly bigger than the size
                    // of other items in the layout, if we use their width it creates a binding loop :D
                    Layout.maximumWidth: Math.max(0, listItem.width - thumbnailBackground.width - 220)
                    Layout.alignment: Qt.AlignVCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    color: listItem.itemColor
                }

                ArkControls.Icon {
                    source: "qrc:/ark/icons/star_inverted"
                    visible: listItem.isFavorite
                    Layout.alignment: Qt.AlignVCenter
                    color: listItem.itemColor
                    size: titleRow.iconHeight
                }

                Rectangle {
                    id: newIcon
                    Layout.alignment: Qt.AlignVCenter
                    height: titleRow.iconHeight / 2
                    width: newIcon.height
                    radius: 10
                    color: Values.colorBlack
                    visible: listItem.isNew
                }

                ArkControls.Icon {
                    source: "qrc:/ark/icons/cloud"
                    visible: listItem.archivedWarningVisible
                    Layout.alignment: Qt.AlignVCenter
                    color: listItem.itemColor
                    size: titleRow.iconHeight
                }

                Item {
                    Layout.fillWidth: true
                }

                ArkControls.Label {
                    text: qsTr("Not syncing")
                    type: ArkControls.Label.SmallSubtle
                    visible: listItem.inactiveWarningVisible
                    Layout.minimumWidth: implicitWidth
                    Layout.alignment: Qt.AlignVCenter
                    verticalAlignment: Text.AlignVCenter
                    color: listItem.itemColor
                }

                ArkControls.Icon {
                    source: "qrc:/ark/icons/cloud_not_synced"
                    visible: listItem.inactiveWarningVisible
                    Layout.alignment: Qt.AlignVCenter
                    color: listItem.itemColor
                    size: titleRow.iconHeight
                }

                RowLayout {
                    objectName: "hwsRow"
                    visible: listItem.wordHits > 0 && !listItem.inactiveWarningVisible

                    ArkControls.Icon {
                        id: hwsIcon
                        source: "qrc:/ark/icons/hwc"
                        Layout.alignment: Qt.AlignVCenter
                        color: listItem.itemColor
                    }

                    Rectangle {
                        id: hwsHits
                        readonly property int size: 40

                        color: listItem.itemColor
                        height: size
                        width:  size * 1.6
                        radius: size

                        ArkControls.Body {
                            objectName: "hwsHitsText"
                            type: ArkControls.Body.Small
                            text: listItem.wordHits > 99 ? qsTr("99+") : listItem.wordHits
                            color: listItem.backgroundColor
                            anchors.centerIn: parent
                        }
                    }
                }
            }

            ThumbnailTags {
                id: _tags
                Layout.fillWidth: true
                Layout.fillHeight: true
                vertical: false
            }

            RowLayout {
                id: _metadataRow
                spacing: ArkControls.Values.spacing.large

                ArkControls.Caption {
                    id: pathText
                    elide: Text.ElideMiddle
                    color: Values.colorBlack
                    text: listItem.path
                    Layout.fillWidth: true
                    visible: !!text
                    Layout.alignment: Qt.AlignVCenter
                }

                ArkControls.Caption {
                    id: authorText
                    visible: !_syncProgress.visible && !pathText.visible
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    elide: Text.ElideRight
                    color: listItem.itemColor
                    maximumLineCount: 1 // Don't allow ebooks with \n for their author names to elongate
                    text: {
                        if (listItem.passwordProtected) {
                            return qsTr("Password protected PDF");
                        }
                        if (!listItem.supported) {
                            return listItem.notCompatibleText;
                        }

                        return listItem.author;
                    }
                }

                ProgressIndicator {
                    id: _syncProgress
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    visible: listItem.progress > 0 && !pathText.visible
                    height: 10
                    backgroundColor: listItem.backgroundColor
                    foregroundColor: listItem.itemColor
                    progress: listItem.progress
                }

                Item {
                    Layout.fillWidth: true
                }

                SyncStatusIcon {
                    id: _syncIcon
                    visible: !pathText.visible && source
                    Layout.alignment: Qt.AlignVCenter
                    syncStatus: listItem.syncStatus
                    color: listItem.selected ? Values.colorWhite : Values.colorBlack
                    onAbortExport: listItem.abortExport()
                    onRetrySync: listItem.retrySync()
                }

                ArkControls.Caption {
                    id: publicationText
                    Layout.alignment: Qt.AlignVCenter
                    color: listItem.itemColor
                    text: {
                        if (listItem.publicationDate === "") {
                            return listItem.filetype === Entity.FileType.Epub ? "\u2014" : "";
                        }
                        return new Date(listItem.publicationDate).getUTCFullYear();
                    }
                }

                ArkControls.Caption {
                    id: publisherText
                    Layout.alignment: Qt.AlignVCenter
                    color: listItem.itemColor
                    text: listItem.publisher
                }

                ArkControls.Caption {
                    id: sizeText
                    objectName: "sizeText"
                    visible: listItem.showMetadata && listItem.type === Entity.Type.File
                    Layout.alignment: Qt.AlignVCenter
                    color: listItem.itemColor
                    text: listItem.size
                }

                ArkControls.Caption {
                    id: infoText
                    Layout.alignment: Qt.AlignVCenter
                    visible: listItem.showMetadata
                    text: listItem.formatDisplayText(listItem.childIndex, listItem.filetype,
                                                     listItem.type, listItem.childCount)
                    color: listItem.itemColor
                }
            }
        }
    }

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
}
