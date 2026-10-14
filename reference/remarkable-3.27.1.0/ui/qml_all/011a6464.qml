import QtQuick
import QtQuick.Layouts

import ark.tokens as ArkTokens

/** \addtogroup controls
 *  @{
 */
/*!  BatteryIcon is an icon that shows the battery level.

\image html paperTablet-BatteryIndicator.qml.png paperTablet

\code
ArkControls.BatteryIcon {
    value: 4
}
\endcode

More examples in \ref example-BatteryIndicator.qml
*/
Item {
    id: root

    /// value in range [0, 100]
    property int value: 0

    /// highlighted indicator is inverted (black background and white bars)
    property bool highlighted: false

    /// Limit the number of bars shown in the indicator. Default is all bars shown
    property int showBars: bars

    /// BatteryIcon orientation. Default is Qt.Horizontal
    property int orientation: Qt.Horizontal

    /// Overwrite the function that handles new coming value for the indicator.
    property var updateValue: newvalue => {
        value = newvalue;
    }

    // rest is private and should not be touched
    property var type: ArkTokens.BatteryIndicator.primary
    readonly property bool vertical: orientation === Qt.Vertical
    readonly property int bars: 5
    readonly property int halfBarValue: 5 // Up to 5% is considered as 0 bars, halfbar will be shown instead
    readonly property int valueInBars: root.value < halfBarValue ? 0 : Math.min(root.bars, Math.ceil(root.value / (100 / root.bars)))

    readonly property int batteryHeight: 2*(root.type.item.container.borderWidth + root.type.item.container.verticalPadding) + root.type.item.segment.height
    readonly property int batteryWidth: 2*(root.type.item.container.borderWidth + root.type.item.container.horizontalPadding) + (root.type.item.segment.width * root.bars) + (root.type.item.container.itemSpacing * (root.bars - 1)) + root.type.item.notch.width

    implicitWidth: vertical ? batteryHeight : batteryWidth
    implicitHeight: vertical ? batteryWidth : batteryHeight

    Rectangle {
        anchors.fill: parent
        anchors.rightMargin: root.vertical ? 0 : root.type.item.notch.width // notch on the right for horizontal battery
        anchors.topMargin: root.vertical ? root.type.item.notch.width : 0 // notch on the top for vertical battery
        color: root.highlighted  ? root.type.item.container.borderColor : "transparent"
        border.color: root.type.item.container.borderColor
        border.width: root.type.item.container.borderWidth

        Item {
            anchors {
                fill: parent
                leftMargin: root.type.item.container.borderWidth + (root.vertical ? root.type.item.container.verticalPadding : root.type.item.container.horizontalPadding)
                topMargin: root.type.item.container.borderWidth + (root.vertical ? root.type.item.container.horizontalPadding : root.type.item.container.verticalPadding)
                rightMargin: root.type.item.container.borderWidth + (root.vertical ? root.type.item.container.verticalPadding : root.type.item.container.horizontalPadding)
                bottomMargin: root.type.item.container.borderWidth + (root.vertical ? root.type.item.container.horizontalPadding: root.type.item.container.verticalPadding)
            }

            Rectangle {
                width: root.vertical ? root.type.item.segment.height : root.type.item.segment.width/2
                height: root.vertical ? root.type.item.segment.width/2  : root.type.item.segment.height
                color: root.highlighted ? root.type.background.fill : root.type.item.segment.fill
                visible: root.value <= halfBarValue
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                }
            }

            Grid {
                anchors.fill: parent
                columnSpacing: root.type.item.container.itemSpacing
                rowSpacing: root.type.item.container.itemSpacing
                columns: root.vertical ? 1 : root.bars
                layoutDirection: root.vertical ? Qt.LeftToRight : Qt.RightToLeft
                Repeater {
                    id: _repeater
                    model: root.bars
                    delegate: Rectangle {
                        width: root.vertical ? root.type.item.segment.height : root.type.item.segment.width
                        height: root.vertical ? root.type.item.segment.width : root.type.item.segment.height
                        color: root.highlighted ? root.type.background.fill : root.type.item.segment.fill
                        opacity: {
                            if (index <= root.bars - 1 - Math.min(root.showBars, root.valueInBars)) {
                                return 0;
                            }
                            return 1.0;
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        color: root.type.item.container.borderColor
        width: root.vertical ? root.type.item.notch.height : root.type.item.notch.width
        height: root.vertical ? root.type.item.notch.width : root.type.item.notch.height
        anchors {
            top: parent.top
            right: parent.right
            topMargin: root.vertical ? 0 : (root.height - root.type.item.notch.height )/2
            rightMargin: root.vertical ? (root.width - root.type.item.notch.height )/2 : 0
        }
    }
   
    Icon {
        style: {
            "borderColor": root.type.item.container.borderColor,
            "fill": root.type.item.container.borderColor
        }
        source: "qrc:/ark/batteryindicator/battery" + (root.vertical ? "_vertical" : "")
        anchors {
            bottom: root.vertical ? parent.bottom : undefined
            top: root.vertical ? undefined : parent.top
            left: parent.left
        } 
    }
}
/** @}*/
