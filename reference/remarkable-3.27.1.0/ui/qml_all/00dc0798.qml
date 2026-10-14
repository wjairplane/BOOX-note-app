import QtQuick
import com.remarkable
import common

import ark.controls as ArkControls

Item {
    id: root
    /*
      Component to show an icon with a message below. Used for tags view etc.
      Be careful changing these defaults as they are used implicitly on some platforms.
     */
    property string message
    property color color: Values.colorBlack
    property int fontSize: Values.fontSizeLarge
    property int iconSize: Values.iconSizeExtraLarge
    property string iconSource: "qrc:/ark/icons/tag"
    property bool bold: false

    anchors {
        left: parent.left
        right: parent.right
        centerIn: parent
    }

    ArkControls.Icon {
        size: iconSize
        anchors.bottomMargin: Values.navigatorMargin
        anchors.bottom: noTagsText.top
        anchors.horizontalCenter: parent.horizontalCenter
        color: root.color
        source: iconSource
    }

    Text {
        id: noTagsText
        font.pixelSize: fontSize
        font.bold: bold
        text: message
        color: root.color
        width: parent.width * 0.75
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        lineHeight: Values.lineHeight
        horizontalAlignment: Text.AlignHCenter
        anchors.topMargin: Values.navigatorMargin
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.centerIn: parent
    }
}
