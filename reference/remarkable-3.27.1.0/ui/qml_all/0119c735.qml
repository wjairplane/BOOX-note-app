import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import ark.tokens as ArkTokens

/** \addtogroup controls
 *  @{
 */
/*!  

Container that organize buttons in a row

\image html paperTablet-SegmentedControl.qml.png paperTablet

See \ref example-SegmentedControl.qml for usage examples
*/
Container {
    id: root

    /*!
        SegmentedControl type from ArkTokens. Default is primary
    */
    property var type: ArkTokens.SegmentedControl.primary
   
    /// Set to false if you do not wish all buttons to be of the same width
    property bool uniformSize: false

    /// Button for SegmentedControl
    component Button: ButtonBase {
        id: button
        /// Set button size with Button.Size values (paperTablet only). Default is Small
        buttonSize: ButtonBase.Size.XSmall // size is small but typography is even smaller

        // rest is private
        type: ArkTokens.Button.tertiary
        tokens: {
            if (!ArkTokens.Style.variable.isPaper) {
                return root.type.button;
            }
            const buttonType = ArkTokens.Button.tertiary
            const iconButtonType = ArkTokens.IconButton.primary_inverted
            
            let path = ""
            switch (buttonSize) {
                case ButtonBase.Size.Large: path = !!text ? buttonType.large : iconButtonType.large; break;
                case ButtonBase.Size.Medium: path = !!text ? buttonType.medium : iconButtonType.medium; break;
                case ButtonBase.Size.Small: path = !!text ? buttonType.small : iconButtonType.small; break;
                case ButtonBase.Size.XSmall: path = !!text ? buttonType.xsmall : iconButtonType.small; break;
            }
            let t = path.split('.').reduce((acc, c) => acc && acc[c], ArkTokens);
            return t;
        }
        states: { // do not use selected state
            if (ArkTokens.Style.variable.isPaper)
                return ButtonBase.ButtonState.Idle | ButtonBase.ButtonState.Disabled;
            return ButtonBase.ButtonState.Active | ButtonBase.ButtonState.Disabled | ButtonBase.ButtonState.Hover | ButtonBase.ButtonState.Idle;
        }

        property var underlineTokens

        Loader {
            active: button.checked && !!button.underlineTokens?.idle
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            sourceComponent: Rectangle {
                color: button.underlineTokens.idle.fill ?? "transparent"
                height: button.underlineTokens.idle.height ?? 0
                anchors {
                    left: parent.left
                    leftMargin: button.underlineTokens.spacing.horizontalPadding ?? 0
                    right: parent.right
                    rightMargin: button.underlineTokens.spacing.horizontalPadding ?? 0
                    bottom: parent.bottom
                    bottomMargin: button.underlineTokens.spacing.paddingBottom ?? 0
                }
            }
        }

        state: {
            if (!enabled && !!tokens.background.disabled && (states & ButtonBase.ButtonState.Disabled)) {
                return "disabled";
            }
            if (checked && !!tokens.background.selected) {
                return !!underlineTokens ? "idle" : "selected";
            }
            if (checked && !!tokens.background.active) {
                return "active";
            }
            if (!down && (hovered || highlighted) && !!tokens.background.hover && (states & ButtonBase.ButtonState.Hover)) {
                return "hover";
            }
            if (down && !!tokens.background.active && (states & ButtonBase.ButtonState.Active)) {
                return "active";
            }
            return "idle";
        }
    }  

    // rest is private
    style: root.type.container

    contentItem: ButtonRow {
        uniformCellSizes: root.uniformSize
        spacing: root.style.itemSpacing ?? 0
        Repeater {
            model: root.contentModel
            onItemAdded: function (index, item) {
                item.underlineTokens = root.type.item?.underline;
            }
        }
    }  
}

/** @}*/
