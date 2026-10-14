import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import ark.tokens as ArkTokens

/** \addtogroup controls
 *  @{
 */
/*!

Onboarding Dialog is a (sic!) full screen item with a dialog box, scaled to screen sizes (portrait and landscape), has 3 buttons:
     
\image html paperTablet-OnboardingDialog.qml.png paperTablet

See \ref example-OnboardingDialog.qml for usage examples
*/
Item {
    id: root

    /// Use OnboardingDialog.Content to add content directly or to the stack
    property Component contentItem
  
    /// Text for primary button
    property string primaryButtonText
    /// Disable primary button
    property bool primaryOption: !!primaryButtonText
    /// Text for secondary button
    property string secondaryButtonText
    /// Disable close button in the top right corner
    property bool closeOption: true
    /// Disable secondary button
    property bool secondaryOption: !!secondaryButtonText
    /// Set number of pages in the content
    property int totalPages: 0
    /// Set current page
    property int currentPage: 0
    /// Set position label
    property string positionLabel

    /// primary button clicked
    signal  primaryClicked()
    /// secondary button clicked
    signal  secondaryClicked()
    /// close button clicked
    signal  closeClicked()

    
    /// contentItem should be created using Content component
    component Content: ColumnLayout {
        /// content title
        property string title
        /// content illustration source
        property string illustrationSource
        /// content body
        property Component contentItem
        /// replace illustration with custom image
        property Component customImage
        /// control customImage visibility
        property bool showCustomImage: true
    
        spacing: Values.platform.spacing.medium

        Loader {
            sourceComponent: customImage
            active: !!customImage && showCustomImage
            visible: active
        }

        Illustration {
            source: illustrationSource
            visible: !ArkTokens.Settings.landscape || ArkTokens.Style.variable.enoughVerticalSpace
            color: ArkTokens.Style.idle.text.primary
        }

        Title {
            type: Title.Type.Large
            text: title
            wrapMode: Text.WordWrap
            antialiasing: root.antialiasing
            Layout.fillWidth: true
            Layout.topMargin: Values.platform.spacing.xlarge - Values.platform.spacing.medium
            color: ArkTokens.Style.idle.text.primary
        }

        Loader {
            sourceComponent: contentItem
            Layout.fillWidth: true
        }
        Item {
            Layout.fillHeight: true
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: ArkTokens.Style.variable.enoughHorizontalSpace ? Values.margin.horizontal.xlarge : Values.margin.horizontal.medium
        anchors.rightMargin: ArkTokens.Style.variable.enoughHorizontalSpace ? Values.margin.horizontal.xlarge : Values.margin.horizontal.medium
        anchors.topMargin: ArkTokens.Style.variable.enoughVerticalSpace ? Values.margin.vertical.xlarge : Values.margin.vertical.medium
        anchors.bottomMargin: ArkTokens.Style.variable.enoughVerticalSpace ? Values.margin.vertical.xlarge : Values.margin.vertical.medium

        border.color: root.style.border.borderColor
        border.width: root.style.border.borderWidth
    

        Body {
            id: _position
            type: Body.Type.Large
            anchors {
                verticalCenter: _closeButton.verticalCenter
                horizontalCenter: parent.horizontalCenter
                
            }
            text: root.positionLabel
            color: ArkTokens.Style.idle.text.primary
            visible: root.totalPages > 1
            antialiasing: root.antialiasing
        }

        IconButton {
            id: _closeButton
            anchors {
                top: parent.top
                topMargin: Values.padding.xsmall
                right: parent.right
                rightMargin: Values.padding.xsmall
            }
            visible: root.closeOption
            enabled: visible
            type: ArkTokens.IconButton.primary_inverted
            iconSource: "qrc:/ark/icons/x_medium"
            onClicked: root.closeClicked()
            antialiasing: root.antialiasing
        }
    }
        
    Item {
        anchors {
            fill: parent
            leftMargin: ArkTokens.Style.variable.enoughHorizontalSpace ? Values.margin.horizontal.x2large : Values.margin.horizontal.xlarge
            rightMargin: ArkTokens.Style.variable.enoughHorizontalSpace ? Values.margin.horizontal.x2large : Values.margin.horizontal.xlarge
            topMargin: ArkTokens.Style.variable.enoughVerticalSpace ? Values.margin.vertical.x2large : Values.margin.vertical.xlarge
            bottomMargin: ArkTokens.Style.variable.enoughVerticalSpace ? Values.margin.vertical.x2large : Values.margin.vertical.xlarge
        }
        
        Loader {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: _buttonsgrid.top
                bottomMargin: (ArkTokens.Settings.landscape ?  1 : 0.5) * Values.platform.spacing.x2large
            }
            sourceComponent: contentItem
        }

        Grid {
            id: _buttonsgrid
            visible: root.primaryOption || root.secondaryOption

            property real minButtonsWidth: Math.max(346, _btn1.visible ? _btn1.implicitWidth : 0, _btn2.visible ? _btn2.implicitWidth : 0)  // desired min width for each button
            property int visibleButtons: _btn1.visible && _btn2.visible ? 2 : 1
            property real buttonsWidth: minButtonsWidth*visibleButtons + spacing*(visibleButtons-1)
    
            columns: buttonsWidth > parent.width ? 1 : visibleButtons
            layoutDirection: Qt.RightToLeft
            columnSpacing: ArkTokens.ButtonSet.primary.spacing.itemSpacing
            rowSpacing: ArkTokens.ButtonSet.primary.spacing.itemSpacing

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            Button {
                id: _btn1
                type: ArkTokens.Button.primary
                text: primaryButtonText
                visible: root.primaryOption
                width: Math.max(_buttonsgrid.minButtonsWidth, _buttonsgrid.columns === 1 ? 432 : 0)
                enabled: visible
                onClicked: root.primaryClicked()
                antialiasing: root.antialiasing
            }

            Button {
                id: _btn2
                type: ArkTokens.Button.secondary
                text: secondaryButtonText
                width: Math.max(_buttonsgrid.minButtonsWidth, _buttonsgrid.columns === 1 ? 432 : 0)
                visible: root.secondaryOption
                enabled: visible
                onClicked: root.secondaryClicked()
                antialiasing: root.antialiasing
            }
        }
    }
    /// Access component style
    readonly property var style: {
        return ArkTokens.OnboardingDialog.primary;
    }
}
/** @}*/
