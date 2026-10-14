import QtQuick
import QtQuick.Layouts
import com.remarkable
import common
import device.view.navigator
import device.ui.text
import device.ui.controls

import xofm.libs.settings

import ark.controls as ArkControls

MouseArea {
    id: gridItem
    objectName: "ContentEntriesGridItem"
    property Entry entry
    property bool selecting: false
    property bool selected: Library.documentSelection.isSelected(entry.id)
    property bool isDownloading: entry.status === Entry.Downloading
    property bool isUploading: entry.status === Entry.Uploading
    property int squishGridIndex
    property PageSelection movePageSelection
    readonly property int iconInset: (statusIcon.visible ? statusIcon.width : 0) + (errorIcon.visible ? errorIcon.width : 0)
    readonly property int titleInset: (pin.visible ? pin.width + Values.navigatorContentGridItemMargin : 0) + iconInset + Values.navigatorContentGridItemMargin
    readonly property color foregroundColor: selected ? Values.colorWhite : Values.colorBlack
    readonly property bool lockedByPassword: entry ? entry.lockedByPassword : false
    readonly property string name: entry ? entry.visibleName : ""
    property var navigationHandler
    property bool drawFocus: !!navigationHandler && navigationHandler.current && (navigationHandler.current === gridItem || navigationHandler.current.item === gridItem)
    property int thumbnailSize

    Keys.onReturnPressed: clicked(undefined)

    onPressAndHold: {
        Library.documentSelection.toggle(entry.id);
    }

    Connections {
        target: Library.documentSelection
        function onSelectionChanged() {
            selected = Library.documentSelection.isSelected(entry.id);
        }
    }

    function getCoverPage() {
        if (entry.coverPageNumber < 0) {
            return entry.lastOpenedPage;
        } else {
            return entry.coverPageNumber;
        }
    }

    Rectangle {
        id: selectionIndicator
        anchors.fill: parent
        color: Values.colorBlack
        visible: selected
    }

    FocusFrame {
        anchors.fill: parent
        visible: gridItem.drawFocus
        borderColor: gridItem.selected ? Values.colorWhite : Values.colorBlack
    }

    Item {
        id: preview
        width: parent.width
        height: parent.height

        Rectangle {
            visible: !thumbnail.loaded
            anchors.centerIn: thumbnail
            opacity: entry.archived ? Values.archivedThumbnailOpacity : 1.0

            ArkControls.Icon {
                id: icon
                source: {
                    if (!entry || isDownloading) {
                        return "";
                    }
                    if (entry.type === Entry.Collection) {
                        return "qrc:/ark/icons/folder";
                    }
                    if (entry.lockedByPassword) {
                        return "qrc:/ark/icons/padlock";
                    }
                    switch (entry.fileType) {
                        case Document.Pdf:
                            return "qrc:/ark/icons/document";
                        case Document.Ebook:
                            return "qrc:/ark/icons/ebook";
                        // fallback, covering Document.Notebook
                        default:
                            return "qrc:/ark/icons/notebook";
                    }
                }

                size: ArkControls.Values.iconSize.large
                anchors.horizontalCenter: parent.horizontalCenter
                color: foregroundColor
            }
        }

        Rectangle {
            id: thumbnail

            anchors {
                fill: parent
                margins: Values.designGridHorizontalSpacing
                bottomMargin: Values.navigatorContentGridItemLabelHeight
            }
            property bool loaded: _image.status === Image.Ready

            PageThumbnail {
                id: _image
                anchors.fill: parent
                document: lockedByPassword ? null : entry
                documentId: entry.id
                page: entry ? getCoverPage() : 0
                asynchronous: false
                enableScreenShareIndicator: true
                sourceSize: Qt.size(width, height)

                errorIconSize: ArkControls.Values.iconSize.large

                selected: gridItem.selected

                opacity: entry.archived ? Values.archivedThumbnailOpacity : 1.0
            }

            DocumentCover {
                anchors.fill: parent
                smooth: Values.desktopSimulator
                backgroundColor: selected ? Values.colorBlack : Values.colorWhite
                documentType:  {
                    switch (entry.fileType) {
                    case Document.Pdf:
                        return DocumentCover.Pdf;
                    case Document.Ebook:
                        return DocumentCover.Ebook;
                    case Document.Notebook:
                        return DocumentCover.Notebook;
                    default:
                        return DocumentCover.Undefined;
                    }
                }
            }

            ThumbnailTags {
                id: thumbnailTags
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: archiveWarning.visible ? archiveWarning.left : parent.right
                anchors.bottom: inactiveWarning.visible ? inactiveWarning.top : parent.bottom
                anchors.margins: Values.designGridMargin
                tags: entry.tags
            }

            InactiveWarning {
                id: inactiveWarning
                anchors.bottom: thumbnail.bottom
                anchors.right: thumbnail.right
                width: thumbnail.width
                height: Values.inactiveWarningHeight
                iconRightMargin: 12
                visible: entry.status === Entry.ExcludedFromSync
            }
            ArchivedWarning {
                id: archiveWarning
                anchors.bottom: thumbnail.bottom
                anchors.right: thumbnail.right
                anchors.bottomMargin: 1
                anchors.rightMargin: 1
                visible: entry.archived
            }
        }

        RowLayout {
            id: contentRow
            anchors {
                top: thumbnail.bottom
                topMargin: 10
                left: thumbnail.left
                right: thumbnail.right
            }
            spacing: 10

            SubheaderSmall {
                id: visibleNameText
                text: entry.visibleName
                elide: Text.ElideMiddle
                color: foregroundColor
                Layout.fillWidth: true
            }
            ArkControls.Icon {
                id: pin
                source: "qrc:/ark/icons/star_inverted"
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                size: ArkControls.Values.iconSize.small
                color: visibleNameText.color
                visible: entry.isPinned
            }
        }

        ArkControls.Caption {
            id: subtitleText
            anchors {
                top: contentRow.bottom
                left: contentRow.left
                right: contentRow.right
                rightMargin: titleInset
            }
            text: entry.subtext
            color: foregroundColor
            visible: !progressBar.visible && gridItem.thumbnailSize !== ThumbnailSettings.Small
        }
    }

    EntryStatusIcon {
        id: statusIcon
        entry: gridItem.entry
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Values.navigatorContentGridItemMargin
        anchors.right: parent.right
        anchors.rightMargin: Values.navigatorContentGridItemMargin
        color: foregroundColor
    }

    EntryErrorIcon {
        id: errorIcon
        anchors.fill: statusIcon
        entry: gridItem.entry
        selected: gridItem.selected
        visible: errorIcon.active && !statusIcon.active
    }

    EntryProgress {
        id: progressBar
        entry: gridItem.entry
        anchors {
            left: parent.left
            leftMargin: Values.designGridMargin
            right: statusIcon.left
            rightMargin: Values.designGridMargin
            verticalCenter: statusIcon.verticalCenter
        }
        visible: statusIcon.active
    }
}
