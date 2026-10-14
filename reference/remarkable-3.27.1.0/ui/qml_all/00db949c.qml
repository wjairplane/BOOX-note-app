import QtQuick
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import device.view.experimental

import ark.controls as ArkControls

// Used to render tags on top of a document or page thumbnail
// Supports both vertical and horizontal layout

Item {
    id : thumbnailTags
    property bool vertical: true // vertical grid layout or horizontal list layout
    property var tags: []
    property var slicedTags: tags.slice(0, maxItems)
    property int maxItems: vertical ? 3 : 8
    // 8 should be enough to always fill the space in list mode
    // but not enough to damage performance
    property int hiddenItems: tags.length - slicedTags.length

    height: vertical ? parent.height : hiddenTagsLabel.height
    width: vertical ? parent.width : parent.width * 0.7

    Grid {
        id: itemGrid
        columns: vertical ? 1 : 0
        rows: vertical ? 0 : 1
        flow: vertical ? Grid.TopToBottom : Grid.LeftToRight

        anchors.verticalCenter: vertical ? undefined : parent.verticalCenter
        anchors.bottom: vertical ? parent.bottom : undefined
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: hiddenTagsLabel.width - spacing
        spacing: 10

        Repeater {
            id: tagRepeater
            model: slicedTags
            delegate: TagPillCaption {
                required property var modelData
                maxWidth: itemGrid.width
                visible: vertical || (x + width < itemGrid.width - tagLabel.width)
                text: modelData
            }
        }
    }

    Rectangle {
        id: hiddenTagsLabel

        anchors.verticalCenter: vertical ? undefined : parent.verticalCenter
        anchors.bottom: vertical ? parent.bottom : undefined
        anchors.right: parent.right
        height: tagLabel.font.pixelSize + Values.thumbnailTagPillCaptionVerticalPadding * 2
        width: Values.thumbnailTagPillCountWidth
        radius: height / 2
        border.width: 2
        border.color: Values.colorBlack
        visible: hiddenItems > 0
        ArkControls.Caption {
            id: tagLabel
            anchors.verticalCenterOffset: 2
            anchors.centerIn: parent
            color: Values.colorBlack
            text: "+" + hiddenItems
            font.weight: Font.Medium
        }
    }
}
