import QtQuick
import com.remarkable
import common
import device.ui.controls
import device.ui.text

ButtonBase {
    id: button

    property alias iconSize: iconTitle.size
    property alias title: iconTitle.title
    property alias caption: iconTitle.caption
    property alias font: iconTitle.font
    property alias layoutDirection: iconTitle.layoutDirection
    property alias elideTitle: iconTitle.elideTitle
    property alias elideCaption: iconTitle.elideCaption
    property alias wrapMode: iconTitle.wrapMode
    property alias background: _background
    property bool invertOnClick: false

    property int padding: Values.designGridVerticalGutter
    property int leftPadding: padding
    property int rightPadding: padding
    property alias spacing: iconTitle.rowSpacing
    property alias iconSource: iconTitle.iconSource
    property alias size: iconTitle.size
    readonly property alias titleItem: iconTitle.titleItem

    implicitWidth: iconTitle.implicitWidth
    implicitHeight: Math.max(iconTitle.implicitHeight, Values.navigationEntriesHeaderHeight)

    Rectangle {
        id: _background
        anchors.fill: parent
        color: pressed && invertOnClick ? foregroundColor : "transparent"
    }

    IconTitle {
        id: iconTitle
        color: pressed && invertOnClick ? backgroundColor : foregroundColor
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        leftPadding: layoutDirection === Qt.LeftToRight ? button.leftPadding : button.rightPadding
        rightPadding: layoutDirection === Qt.LeftToRight ? button.rightPadding : button.leftPadding
        antialiasing: parent.antialiasing
    }
}
