import QtQuick
import com.remarkable
import common
import device.ui.text
import device.ui.controls

import ark.controls as ArkControls

/**
  HeaderButton is a button that can be placed in headers.
*/
ButtonBase {
    id: root

    property string iconSource
    property string title ///< text of the button
    property bool disabled ///< makes the button grey
    readonly property bool hasSource: iconSource && iconSource.length > 0
    property alias align: titleText.horizontalAlignment
    property alias text: titleText
    property alias background: _background

    visible: title.length > 0 || iconSource.length > 0
    height: Values.navigatorSidebarItemHeight
    baselineOffset: height / 2
    width: Math.max(height, titleText.width)
    releasable: true

    focusFrame.z: _background.z + 1

    Rectangle {
        id: _background
        anchors.fill: parent
        anchors.margins: Values.outlineSize
        color: root.backgroundColor
    }

    Column {
        id: _buttonColumn
        anchors.centerIn: parent
        width: parent.width
        spacing: 10

        ArkControls.Icon {
            id: arkIcon
            x: Math.floor((parent.width - width) / 2)
            size: ArkControls.Values.iconSize.medium
            color: root.disabled ? "gray" : foregroundColor
            source: root.iconSource
            visible: !!root.iconSource
        }

        ArkControls.Label {
            type: ArkControls.Label.SmallStrong
            text: root.title
            x: Math.floor((parent.width - width) / 2)
            color: root.disabled ? "gray" : foregroundColor
            visible: arkIcon.visible
            font.bold: true
        }

        TextHeaderRegular {
            id: titleText
            text: root.title
            visible: !arkIcon.visible
            color: root.disabled ? "gray" : foregroundColor
            horizontalAlignment: Text.AlignHCenter
            padding: horizontalAlignment === Text.AlignCenter || !visible ? 0 : Values.designGridVerticalGutter
        }
    }
}
