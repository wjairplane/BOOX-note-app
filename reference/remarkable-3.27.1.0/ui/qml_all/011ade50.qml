import QtQuick
import QtQuick.Layouts

import ark.tokens as ArkTokens

/** \addtogroup controls
 *  @{
 */
/*!  Slider 

Discrete slider

\image html paperTablet-Slider.qml.png paperTablet

\code
ArkControls.Slider {
    iconSource: "path/to/icon"
    steps: 3
    from: 0
    to: 10
    value: 6
}
\endcode

More examples in \ref example-Slider.qml
*/
Item {
    id: root

    /// Slider type. Default is primary
    property var type: ArkTokens.Slider.primary
    
    /// Slider start value. Default is 0
    property real from: 0

    /// Slider end value. Default is 1
    property real to: 1

    /// number of steps. Default is 5
    property int steps: 5
   
    /// Slider orientation. Default is Qt.Vertical
    property int orientation: Qt.Vertical

    /// path to icon that will be placed to the left or in the bottom of the slider
    property string iconSource

    /// value in range [from, to]
    property real value: 0

    /// Slider value was moved
    signal moved()

    /// Slider value was released
    signal released()

    /// Icon was pressed and held
    signal pressAndHold()

    /// Icon was clicked
    signal clicked()


    /// Overwrite the function that handles new coming value for the slider.
    property var updateValue: (newvalue) => {
        value = newvalue;
    }

    // rest is private
    readonly property bool vertical: orientation ===  Qt.Vertical
    readonly property int padding: type.background.horizontalPadding
    readonly property int iconSpace: !!iconSource ? _icon.width + type.background.itemSpacing : 0
    readonly property int defaultStepSize: type.container.width + 2*padding
    readonly property int defaultContainerSize: defaultStepSize*steps + iconSpace
        
    width: vertical ? defaultStepSize : defaultContainerSize 
    height: vertical ? defaultContainerSize : defaultStepSize
   
    // Interaction area 
    Item {
        anchors {
            fill: parent
            leftMargin: root.vertical ? 0 : root.iconSpace
            bottomMargin: root.vertical ? root.iconSpace : 0
        }
        Item {
            anchors.centerIn: parent
            width: root.vertical ? 16 : parent.width
            height: root.vertical ? parent.height : 16

        
            Rectangle {
                anchors.bottom: parent.bottom
                color: root.type.container.borderColor
                radius: root.type.container.borderRadius
                height: root.vertical ?  _.positionLength(parent.height) : parent.height
                width: root.vertical ? parent.width : _.positionLength(parent.width)
            }

            Grid {
                anchors.fill: parent
                columns: root.vertical ? 1 : root.steps + 1
                columnSpacing: _.segmentLength(width) - 16
                rowSpacing: _.segmentLength(height) - 16
                
                Repeater {
                    model: root.steps + 1
                    Icon {
                        source: "qrc:/ark/slider/stepIndicator"
                        color: "black"
                        antialiasing: root.antialiasing
                    }
                }
            }

            Grid {
                width: root.vertical ? root.type.container.borderWidth  : parent.width
                height: root.vertical ? parent.height : root.type.container.borderWidth 
                anchors.centerIn: parent
                columns: root.vertical ? 1 : root.steps

                columnSpacing: 24
                rowSpacing: 24
                topPadding: root.vertical ? 20 : 0 
                leftPadding: root.vertical ? 0 : 20 

                Repeater {
                    model: root.steps
                    Rectangle {
                        color: root.type.container.borderColor
                        width: root.vertical ? parent.width : _.dashLength(parent.width)
                        height: root.vertical ? _.dashLength(parent.height) : parent.height
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onPressed: (mouse)=> {
                let v = _.mouseValue(mouse, parent.width, parent.height);
                if (v === root.value && v > 0) {
                    root.move(v - _.stepValue); // unselect this step
                } else {
                    root.move(v);
                }
            }
            onPositionChanged: (mouse)=> {
                root.move(_.mouseValue(mouse, parent.width, parent.height));
            }
            onReleased: {
                root.released();
            }
        }
    }

    IconButton {
        id: _icon
        visible: !!iconSource
        anchors {
            bottom: root.vertical ? parent.bottom : undefined
            horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
            left: root.vertical ? undefined : parent.left
            verticalCenter: root.vertical ? undefined : parent.verticalCenter
        }
        type: ArkTokens.IconButton.primary_inverted
        iconSource: root.iconSource
        antialiasing: root.antialiasing

        onClicked: root.clicked();
        onReleased: root.released();
        onPressAndHold: root.pressAndHold()
    }

    function move(v) {
        if (v != value) {
            updateValue(v); 
            moved();
        }
    }

    QtObject {
        id: _
        readonly property real range: root.to - root.from
        readonly property real stepValue: range/root.steps
        property real position: Math.ceil(((value - from)/range)*root.steps)/root.steps
        
        function mouseValue(mouse, width, height) { /// @todo change to token when available
            return positionToValue(mousePosition(mouse, width, height));
        }

        function mousePosition(mouse, width, height) {
            const p =  root.vertical ? 1 - (mouse.y/height) : mouse.x/width;
            return Math.min(Math.max(0, p), 1);
        }

        function positionToValue(p) {
            return root.from + (Math.ceil(p*root.steps))*(_.stepValue)
        }  

        function segmentLength(totalLength) {
            return  Math.round((totalLength - 16)/root.steps);
        } 

        function dashLength(totalLength) {
            return  segmentLength(totalLength) - 24;
        } 

        function positionLength(totalLength) {
            if (position === 0) {
                return 0;
            }
            return position * (totalLength - 16) + 16;
        }

        Component.onCompleted: {
            console.assert(range > 0, "Invalid slider range [", from , "-", to, "]");
            console.assert(root.steps > 0, "Invalid number of slider steps (", root.steps, ")");
        }
    }
}
/** @}*/
