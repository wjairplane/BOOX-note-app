import QtQuick
import common

import ark.controls as ArkControls

Rectangle {
    id: pillCaption
    width: Math.min(maxWidth - margins, Math.max(30, tagLabel.implicitWidth) + margins)
    height: tagLabel.font.pixelSize + Values.thumbnailTagPillCaptionVerticalPadding * 2
    radius: height / 2
    border.width: 2
    border.color: Values.colorBlack
    color: Values.colorWhite
    antialiasing: false

    property real margins: 16
    property int maxWidth: 0
    property alias text: tagLabel.text

    ArkControls.Caption {
        id: tagLabel
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        width: parent.width - margins
    }
}
