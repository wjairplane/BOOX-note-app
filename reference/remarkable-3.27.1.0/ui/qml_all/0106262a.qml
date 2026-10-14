import QtQuick
import QtQuick.Layouts

import com.remarkable

import xofm.libs.settings

import ark.tokens as ArkTokens
import ark.controls as ArkControls

QtObject {
    id: root

    readonly property int _smallPixelSize: 197
    readonly property int _mediumPixelSize: 244
    readonly property int _largePixelSize: 324

    // Enum: ThumbnailSettings.ThumbnailSize
    required property int thumbnailSize
    required property int width
    property bool accessibilityMode: Settings.accessibilityMode
    property int thumbnailMargin: ArkControls.Values.spacing.small
    readonly property int labelHeight: ArkTokens.Style.variable.controlsHeight.small
    readonly property real aspectRatio: 4.0 / 3.0
    readonly property int minimumThumbailWidth: {
        switch(root.thumbnailSize) {
            case ThumbnailSettings.Small:
                return root.accessibilityMode ? _mediumPixelSize : _smallPixelSize;
            case ThumbnailSettings.Medium:
            case ThumbnailSettings.List:
                return root.accessibilityMode ? _largePixelSize : _mediumPixelSize;
            case ThumbnailSettings.Large:
                return _largePixelSize;
        }
    }

    readonly property size _size: {
        const columnNumber = Math.floor(root.width / (root.minimumThumbailWidth + 2 * root.thumbnailMargin));
        // Floor because you cannot have an 1 extra pixel or the thumbnails might not fit inside the available width
        const thumbnailWidth = Math.floor(root.width / columnNumber);
        // Ceil because with one less pixel you might cro the content of the label
        const thumbnailHeight = Math.ceil(thumbnailWidth * root.aspectRatio);
        return Qt.size(thumbnailWidth, thumbnailHeight + root.labelHeight);
    }
    readonly property int gridItemWidth: _size.width
    readonly property int gridItemHeight: _size.height
}
