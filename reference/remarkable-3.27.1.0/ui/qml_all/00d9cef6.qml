import QtQuick
import com.remarkable
import common
import device.view.navigator
import device.ui.controls
import device.ui.text

import ark.controls as ArkControls

PagesItem {
    id: root
    height: GridView.view.cellHeight
    width: GridView.view.cellWidth

    property bool portrait: document.orientation === Qt.Vertical
    required property int cellMargin

    PageThumbnail {
        id: thumbnailImage
        anchors {
            top: parent.top
            topMargin: root.cellMargin
            bottom: visibleNameText.top
            bottomMargin: ArkControls.Values.spacing.small
            left: parent.left
            leftMargin: root.cellMargin
            right: parent.right
            rightMargin: root.cellMargin
            alignWhenCentered: true
        }

        document: root.document
        asynchronous: true
        cache: true
        page: root.page
        selected: root.selected
        sourceSize: Qt.size(width, height)
        borderColor: Values.colorBlack
        borderWidth: Values.hairlineSize
    }

    ThumbnailTags {
        id: tagItem
        anchors.fill: thumbnailImage
        anchors.margins: root.cellMargin
        tags: pageTags
        maxItems: 3
    }

    ArkControls.Label {
        id: visibleNameText
        type: ArkControls.Label.Medium
        anchors {
            bottom: parent.bottom
            bottomMargin: root.cellMargin + ArkControls.Values.spacing.medium
            horizontalCenter: parent.horizontalCenter
        }
        text: root.pageCaption
        elide: Text.ElideMiddle
        color: selected ? Values.colorWhite : Values.colorBlack
    }

    Rectangle {
        id: currentIndicator
        anchors.bottom: thumbnailImage.bottom
        anchors.left: thumbnailImage.left
        width: thumbnailImage.width
        height: Values.outlineSize * 4
        color: Values.colorBlack
        visible: (current && !selected) || highlighted
    }
}
