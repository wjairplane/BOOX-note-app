import QtQuick
import com.remarkable
import common
import device.view.navigator
import device.ui.controls
import device.ui.text

import ark.controls as ArkControls

PagesItem {
    id: listItem
    width: parent.width
    height: Values.navigatorContentListItemHeight
    property bool portraitThumbnail: document.orientation === Qt.Vertical

    PageThumbnail {
        id: preview
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            margins: Values.designGridHorizontalSpacing
            leftMargin: !document || portraitThumbnail ? Values.designGridHorizontalSpacing : Values.designGridHorizontalSpacing + (height - width)
        }
        width: Math.floor(height / 1.33)
        document: listItem.document
        page: listItem.page
        fillMode: Image.PreserveAspectCrop
        borderColor: Values.colorBlack
        borderWidth: Values.hairlineSize

        listMode: true
        selected: listItem.selected
    }

    ArkControls.Label {
        id: entryName
        anchors {
            left: preview.right
            leftMargin: portraitThumbnail ? Values.designGridVerticalSpacing : 40
            top: preview.top
            right: parent.right
            rightMargin: Values.designGridMargin
        }
        type: ArkControls.Label.Medium
        text: listItem.pageCaption
        color: selected ? Values.colorWhite : Values.colorBlack
        elide: Text.ElideMiddle
    }

    ThumbnailTags {
        anchors {
            left: entryName.left
            bottom: preview.bottom
        }
        vertical: false
        tags: pageTags
    }

    Rectangle {
        anchors {
            left: parent.left
            leftMargin: Values.designGridMargin
            bottom: parent.bottom
            right: parent.right
            rightMargin: Values.designGridMargin
        }
        height: Values.hairlineSize
        color: selected ? Values.colorWhite : Values.colorBlack
    }

    Rectangle {
        id: currentIndicator
        color: Values.colorBlack
        height: parent.height
        width: visible ? 10 : 0
        anchors.left: parent.left
        anchors.leftMargin: Values.designGridMargin - Values.designGridVerticalGutter
        anchors.bottom: parent.bottom
        visible: current
    }
}
