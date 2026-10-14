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
   
    /// set to false to hide step dividers
    property bool showDividers: true

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
        // Pill-shape
        Rectangle {
            antialiasing: root.antialiasing
            anchors {
                fill: parent
                leftMargin: root.vertical ? root.padding : 0
                rightMargin: root.vertical ? root.padding : 0
                topMargin: root.vertical ? 0 : root.padding
                bottomMargin: root.vertical ? 0 : root.padding
            }
            border {
                width: root.type.container.borderWidth 
                color: root.type.container.borderColor
            }
            radius: root.type.container.borderRadius

            // Selected fill
            Rectangle {
                anchors.bottom: parent.bottom
                color: root.type.container.borderColor
                radius: root.type.container.borderRadius
                height: root.vertical ? (_.position * parent.height) : parent.height
                width: root.vertical ? parent.width : (_.position * parent.width)
                
                // Hide round shape
                Rectangle {
                    anchors.top: parent.top 
                    anchors.right: parent.right
                    color: parent.color
                    height: root.vertical ? (parent.width / 2) : parent.height
                    width: root.vertical ? parent.width : (parent.height / 2) 
                    visible: root.from < root.value && root.value < root.to
                }
            }

            Grid {
                anchors.fill: parent
                columns: root.vertical ? 1 : root.steps - 1

                readonly property int lineWidth: ArkTokens.Divider.primary.horizontal.height
                columnSpacing: width/root.steps - lineWidth
                rowSpacing: height/root.steps - lineWidth
                topPadding: root.vertical ? rowSpacing + lineWidth/2 : 0
                leftPadding: root.vertical ? 0 : columnSpacing + lineWidth/2
                visible: root.showDividers
                
                Repeater {
                    model: root.steps - 1
                    Rectangle {
                        color: _.lineColor(modelData)
                        height: root.vertical ? parent.lineWidth : parent.height
                        width: root.vertical ? parent.width : parent.lineWidth
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            property var previousValue
            onPressed: (mouse)=> {
                const v = _.mouseValue(mouse, parent.width, parent.height);
                if (v === root.value && v > 0) {
                    // Capture the state where we started the drag
                    previousValue = root.value;
                    root.move(v - _.stepValue); // unselect this step
                } else {
                    root.move(v);
                }
            }
            onPositionChanged: (mouse)=> {
                const v = _.mouseValue(mouse, parent.width, parent.height);
                if (v === previousValue) { 
                    return;
                }
                // Invalidate it after we've moved outside the threshold
                previousValue = undefined;
                root.move(v);
            }
            onReleased: {
                root.released();
            }
        }
    }

    IconButton {
        id: _icon
        anchors {
            bottom: root.vertical ? parent.bottom : undefined
            horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
            left: root.vertical ? undefined : parent.left
            verticalCenter: root.vertical ? undefined : parent.verticalCenter
        }
        type: ArkTokens.IconButton.primary_inverted
        iconSource: root.iconSource
        antialiasing: root.antialiasing
        visible: !!root.iconSource
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

        function mouseValue(mouse, width, height) {
            return positionToValue(mousePosition(mouse, width, height));
        }

        function mousePosition(mouse, width, height) {
            const p =  root.vertical ? 1 - (mouse.y/height) : mouse.x/width;
            return Math.min(Math.max(0, p), 1);
        }

        function positionToValue(p) {
            return root.from + (Math.ceil(p*root.steps))*(_.stepValue)
        }  

        function lineColor(index) {
            const linePosition = (vertical ? root.steps - index - 1 : index + 1)/root.steps
            return positionToValue(linePosition) >= root.value ? ArkTokens.Divider.primary.horizontal.fill : ArkTokens.Divider.primary_inverted.horizontal.fill
        }      

        Component.onCompleted: {
            console.assert(range > 0, "Invalid slider range [", from , "-", to, "]");
            console.assert(root.steps > 0, "Invalid number of slider steps (", root.steps, ")");
        }
    }
}

/** @}*/
