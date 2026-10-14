import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import ark.tokens as ArkTokens

/** \addtogroup controls
 *  @{
 */
/*!

SetupPage is a (sic!) full screen item with a dialog box, scaled to screen sizes (portrait and landscape), has 3 buttons:
- primary button
- secondary button
- skip button

\image html paperTablet-SetupPage.qml.png paperTablet
*/
Item {
    id: root

    property var type: ArkTokens.SetupPage.primary

    /// Text for primary button
    property string primaryButtonText
    /// Disable primary button
    property bool primaryOption: !!primaryButtonText
    /// Text for secondary button
    property string secondaryButtonText
    /// Disable secondary button
    property bool secondaryOption: !!secondaryButtonText
    /// Skip button will be visible if this property is set
    property string skipButtonText
    /// Disable skip button
    property string skipOption: !!skipButtonText
    
    /// primary button clicked
    signal  primaryClicked()
    /// secondary button clicked
    signal  secondaryClicked()
    /// skip button clicked
    signal  skipClicked()

    /// content title
    property string title
    /// content description
    property string description
    /// Add animated ellipses to the title. This works only if the title is one-liner
    property bool ellipse: false
    /// Animation interval
    property int animationInterval: 400

    
    /// In many cases content of fixed size (i.e. illustration) will be placed in the center of the screen
    /// but sometimes the page content should be limited by size and anchored differently   
    /// Use contentPosition.top|bottom|left|rightMargin to position content on the screen
    property QtObject contentPosition: QtObject {
        property real topMargin: Values.margin.vertical.x3large
        property real bottomMargin: Values.margin.vertical.x2large
        property real leftMargin: ArkTokens.Settings.landscape ? Values.margin.horizontal.x2large : Values.margin.horizontal.xlarge
        property real rightMargin: ArkTokens.Settings.landscape ? Values.margin.horizontal.x2large : Values.margin.horizontal.xlarge
        property real narrowLeftMargin: getNarrowMargin()
        property real narrowRightMargin: getNarrowMargin()
    }

    // Current step in the animation
    property int ellipseCount: 0

    property var style: ArkTokens.Settings.landscape ? type.landscape : type

    Item {
        anchors {
            fill: parent
            leftMargin: root.style.background.paddingLeft
            rightMargin: root.style.background.paddingRight
            topMargin: root.style.background.paddingTop
            bottomMargin: root.style.background.paddingBottom
        }

        ColumnLayout {
            id: _header
            spacing: Values.padding.large
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            RowLayout {
                spacing: 0
                TextLabel {
                    id: _title
                    labelStyle: root.style.content.title
                    text: root.title
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignRight
                    Layout.fillWidth: !root.ellipse
                    antialiasing: root.antialiasing
                }
                TextLabel {
                    id: _ellipsis
                    visible: root.ellipse
                    labelStyle: root.style.content.title
                    text: getEllipsis(root.ellipseCount)
                    horizontalAlignment: Text.AlignHCenter
                    antialiasing: root.antialiasing
                }
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
            }
            TextLabel {
                labelStyle: root.style.content.description
                text: root.description
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter  
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                antialiasing: root.antialiasing
            }
        }
       
        ButtonRow {
            id: _buttonsrow
            visible: root.primaryOption || root.secondaryOption
            width: root.primaryOption && root.secondaryOption ? 716 : 432
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            Button {
                type: ArkTokens.Button.secondary
                text: secondaryButtonText
                visible: root.secondaryOption
                enabled: visible
                onClicked: root.secondaryClicked()
                antialiasing: root.antialiasing
            }
            Button {
                type: ArkTokens.Button.primary
                text: primaryButtonText
                visible: root.primaryOption
                enabled: visible
                onClicked: root.primaryClicked()
                antialiasing: root.antialiasing
            }
        }
    }

    Button {
        id: _skipButton
        type: ArkTokens.Button.tertiary
        anchors {
            bottom: parent.bottom
            bottomMargin: Values.padding.large
            right: parent.right
            rightMargin: Values.padding.large
        }
        visible: !!text
        enabled: visible
        text: skipButtonText
        onClicked: root.skipClicked()
        antialiasing: root.antialiasing
    }

    Timer {
        running: root.visible && root.ellipse && _title.lineCount === 1
        repeat: true
        interval: root.animationInterval
        onTriggered: {
            root.ellipseCount = (root.ellipseCount + 1)%4
        }
    }

    function getEllipsis(count) {
        switch(count) {
            case 0: return "<font color=\"white\">...</font>"
            case 1: return "." + "<font color=\"white\">..</font>"
            case 2: return ".." + "<font color=\"white\">.</font>"
            case 3: return "..."
        }
    }

    function getNarrowMargin() {
        if (!ArkTokens.Style.variable.enoughHorizontalSpace) {
            return Values.margin.horizontal.medium;
        }
        if(ArkTokens.Settings.landscape) {
            return Values.margin.horizontal.x2large;
        }
        return Values.margin.horizontal.xlarge
    }
}
/** @}*/
