import QtQuick
import QtQuick.Controls as QtQuickControls
import ark.tokens as ArkTokens

/** \addtogroup controls
 *  @{
 */
/*! SidebarFoldoutItem in a SidebarFoldout component

Contains icon on the left and label on the right from the icon and optional arrow on the left

See Sidebar for usage example
*/
QtQuickControls.MenuItem {
    id: root

    /// Sidebar type
    property var type: ArkTokens.Sidebar.primary

    /// String with text to present
    property string label

    /// String with path to icon
    property string iconSource

    /// Set true for divider on the top of the item
    property bool topDivider: false

    /// Set true for divider in the bottom of the item
    property bool bottomDivider: false

    /// Set true for arrow icon on the left
    property bool unfoldable: false

    /*! Get control over focusFrame visibility
    By default focus frame is controlled by visualFocus read-only property
    */
    property alias showFocus: focusFrame.visible

    /// Unset antialiasing. Default is true
    antialiasing: true

    // rest is private and should not be touched
    state: {
        if (highlighted)
            return "selected";
        return "idle";
    }

    property var tokens: root.type.foldout.item

    leftPadding: root.tokens.background.idle.horizontalPadding
    rightPadding: root.tokens.background.idle.horizontalPadding

    implicitHeight: ArkTokens.Style.variable.isPaper ? ArkTokens.Style.variable.controlsHeight.large : itemHeight()

    background: Rectangle {
        implicitWidth: root.tokens.background.idle.width ??  0
        implicitHeight: root.tokens.background.idle.height ??  0
        color: root.tokens.background[root.state].fill ?? "transparent"
        radius: root.tokens.background[root.state].borderRadius ?? 0
        border.width: root.tokens.background[root.state].borderWidth ?? 0
        border.color: root.tokens.background[root.state].border ?? "transparent"
    }

    contentItem: Row {
        id: label
        spacing: root.tokens.content.spacing.itemSpacing
        Icon {
            id: iconLabel
            size: root.tokens.content.icon.idle.sizing
            color: root.tokens.content.icon[root.state].fill
            source: root.iconSource
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: root.antialiasing
        }

        TextLabel {
            id: textLabel
            text: root.text
            typography: root.tokens.content.label.idle.typography
            color: root.tokens.content.label[root.state].fill
            antialiasing: root.antialiasing
            anchors.verticalCenter: parent.verticalCenter
        }

        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
    }

    arrow: Icon {
        size: root.tokens.content.icon.idle.sizing
        color: root.tokens.content.icon[root.state].fill
        source: root.unfoldable ? "qrc:/ark/icons/chevron_right" : ""
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: root.type.item.content.spacing.paddingRight
        visible: root.unfoldable
        antialiasing: root.antialiasing
    }

    Loader {
        sourceComponent: divider
        anchors.top: parent.top
        width: parent.width
        active: topDivider
    }

    Loader {
        sourceComponent: divider
        anchors.bottom: parent.bottom
        width: parent.width
        active: bottomDivider
    }

    property Component divider: Rectangle {
        height: root.type.item.divider.height
        color: root.type.item.divider.fill
    }

    FocusFrame {
        id: focusFrame
        tokens: root.tokens.focus
        state: root.state
        visible: root.visualFocus
    }

    function itemHeight() {
        return Math.max(root.type.item.icon.idle.sizing,
        Math.round(root.type.item.label.idle.typography.fontSize * root.type.item.label.idle.typography.lineHeight)) +
        root.type.item.background.idle.verticalPadding*2
    }
}

/** @}*/
