import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import ark.tokens as ArkTokens

/** \addtogroup controls
 *  @{
 */
/*!  Appear in the bottom of the screen, and can be persistent or temporary. 

There are two variants: Primary (black) and Secondary (white). 
They can have an icon, a ProgressBar, Button and a text message

\image html paperTablet-NotificationBar.qml.png paperTablet
\image html client-NotificationBar.qml.png client


\note default contentItem is a RowLayout with 0 spacing between item.
\note height is determined by the tallest item
\note width should be set by the user
\note use ProgressBar from ark.
\note items should be spaced with padding.large on paperTablet and padding.medium on clients

\note NotificationBar.Button is an inline type that should not be used outside NotificationBar
- NotificationBar.Button is a button with text
*- type: NotificationBar type
*- text

\note NotificationBar.Message is an inline type that should not be used outside NotificationBar
- NotificationBar.Message is a RowLayout with icon and text
*- type: NotificationBar type
*- text
*- iconSource

\note NotificationBar.Divider is an inline type that should not be used outside NotificationBar
- NotificationBar.Divider
*- type: NotificationBar type

See \ref example-NotificationBar.qml for usage examples
*/
T.Container {
    id: root

    /*!
        NotificationBar type from ArkTokens. Default is primary

        - ArkTokens.NotificationBar.primary
        - ArkTokens.NotificationBar.secondary
        - ArkTokens.NotificationBar.tertiary is a temporary type for clients
    */
    property var type: ArkTokens.NotificationBar.primary

    /// type:color Access background color (experimental)
    property alias arkalias_color: background.color

    /// type:color Access border color (experimental)
    property alias arkalias_borderColor: border.color

    /// type:real Access border height (experimental)
    property alias arkalias_borderHeight: border.height

    /// NotificationBar.Button is a small Button of either tertiary or tertiary_inverted  type
    component Button: ButtonBase {
        /// provide NotificationBar type to get correct styling. Alt use ArkControls.Button directly
        type: ArkTokens.NotificationBar.primary

        // rest is private
        tokens:  {
            if (!ArkTokens.Style.variable.isPaper) {
                const buttonType = (type === ArkTokens.NotificationBar.primary) ? ArkTokens.Button.tertiary_inverted : ArkTokens.Button.tertiary
                return buttonType.small ?? buttonType
            }
            const buttonType = (type === ArkTokens.NotificationBar.primary) ? ArkTokens.ButtonSmall.tertiary_inverted : ArkTokens.ButtonSmall.tertiary
            return buttonType.small ?? buttonType
        }
    }

    /// Divider separates items in the NotificationBar
    component Divider: Rectangle {
        property var type: ArkTokens.NotificationBar.primary
        color: type.divider.background.fill
        width: type.divider.background.width

        Layout.fillHeight: true
        Layout.topMargin: type.divider.spacing.verticalPadding
        Layout.bottomMargin: type.divider.spacing.verticalPadding
        Layout.rightMargin: type.divider.spacing.paddingRight
    }

    /// NotificationBar.Message contains an icon and a text
    component Message: Item {
        id: message

        /// provide NotificationBar type to get correct styling
        property var type: ArkTokens.NotificationBar.primary
        /// path to icon source 
        property alias iconSource: icon.source
        /// text to display
        property alias text: label.text

        // rest is private
        implicitWidth: {
            if (label.visible && icon.visible) {
                return label.implicitWidth + icon.implicitWidth + message.type.message.background.itemSpacing;
            }
            return icon.visible ? icon.implicitWidth : label.implicitWidth;
        }

        // label lineheight is smaller than implicitHeight and we need to compensate for that
        implicitHeight: Math.max(Math.max(icon.implicitHeight, label.implicitHeight) + 2 * message.type.message.background.verticalPadding -
                                          (label.implicitHeight - label.lineHeight*label.lineCount),
                                    ArkTokens.Style.variable.controlsHeight.small ?? 0)

        Icon {
            id: icon
            style: message.type.message.icon
            visible: !!message.iconSource
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }
        TextLabel {
            id: label
            labelStyle: message.type.message.text
            wrapMode: Text.WordWrap
            anchors.right: parent.right
            anchors.left: icon.visible ? icon.right : parent.left
            anchors.leftMargin: icon.visible ? message.type.message.background.itemSpacing : 0
            visible: !!message.text
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // rest is private (components can not be documented with doxygen)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)
    spacing: 0
    background: Rectangle {
        id: background
        color: root.type.background.fill
        Rectangle {
            id: border
            height: root.type.background.borderWidthTop ?? 0
            anchors.left: parent.left
            anchors.right: parent.right
            color: root.type.background.borderColor ?? "transparent"
            anchors.top: parent.top
        }
    }

    contentItem: RowLayout {
        spacing: 0
        Repeater {
            model: root.contentModel
        }
    }

    leftPadding: 0
    rightPadding: root.type.background.paddingRight ?? 0
    topPadding: (root.type.background.borderWidthTop ?? 0) + (root.type.background.verticalPadding ?? 0)
    bottomPadding: root.type.background.verticalPadding ?? 0
}

/** @}*/
