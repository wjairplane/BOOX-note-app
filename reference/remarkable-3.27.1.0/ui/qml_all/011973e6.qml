import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtQuickControls
import ark.tokens as ArkTokens

/** \addtogroup controls
 *  @{
 */
/*! Item in Foldout component

Consists of an icon, and optional label with optional description
- icon is a fixed size placeholder
- label is placed to the right from the icon
- description is placed under the label

###Usage example
\code
    ArkControls.FoldoutItem {
        iconSource: "path/to/icon"
        label: "Text"
        description: "subtext"
    }
\endcode

See \ref example-Toolbar.qml, \ref example-LayersFoldout.qml and \ref example-ChipsFoldout.qml for examples
*/
Button {
    id: root

    // Toolbar type available in \ref ArkTokens
    type: ArkTokens.Toolbar.primary

    /// label text
    property string label

    /// text under the label
    property string description

    /// path to icon
    property string iconSource

    /// Set to true for divider on top of the item
    property bool topDivider: false

    /// Set to true for divider in the bottom of the item
    property bool bottomDivider: false

    // rest is private and should not be touched
    tokens: Object.assign({}, root.type.foldout.item, {"focus": root.type.foldout.focus})
    buttonSize: Button.Size.Large
    horizontalAlignment: !!root.label ? Qt.AlignLeft : Qt.AlignHCenter

    implicitHeight: ArkTokens.Style.variable.isPaper ? ArkTokens.Style.variable.controlsHeight.large : (implicitContentHeight + topPadding + bottomPadding)
    
    contentItem: Item {
        implicitWidth: _contentRow.implicitWidth
        implicitHeight: _contentRow.implicitHeight
        RowLayout {
            id: _contentRow
            spacing: root.tokens.content.spacing.itemSpacing

            Icon {
                id: iconLabel
                size: root.tokens.content.icon.idle.sizing
                color: root.tokens.content.icon[root.state].fill
                source: root.iconSource
                Layout.alignment: !!root.label ? Qt.AlignVCenter : Qt.AlignCenter
                antialiasing: root.antialiasing
            }
            Column {
                spacing: -4
                TextLabel {
                    text: root.label
                    labelStyle: {
                        "fill": root.tokens.content.label[root.state].fill,
                        "typography": root.tokens.content.label.idle.typography
                    }
                    antialiasing: root.antialiasing
                    visible: !!root.label
                }
                TextLabel {
                    text: root.description
                    labelStyle: {
                        "fill": root.tokens.content.description[root.state].fill,
                        "typography": root.tokens.content.description.idle.typography
                    }
                    antialiasing: root.antialiasing
                    visible: !!root.description
                }
                visible: !!root.label
                Layout.alignment: Qt.AlignVCenter
            }
            Item {
                visible: !!root.label
                Layout.fillWidth: true
            }
        }
        Loader {
            anchors.fill: parent
            active: !root.enabled && ArkTokens.Style.variable.isPaper
            sourceComponent: Image {
                anchors.fill: parent
                source: Details.overlaySource(ditherBackgroundColor)
                fillMode: Image.Tile
            }
        }
    }

    Loader {
        sourceComponent: divider
        active: root.topDivider
        anchors.top: parent.top
        width: parent.width
    }

    Loader {
        sourceComponent: divider
        active: root.bottomDivider
        anchors.bottom: parent.bottom
        width: parent.width
    }

    property Component divider: FoldoutDivider {
        type: root.type
    }

    states: {
        if (ArkTokens.Style.variable.tokens == "paperTablet")
            return ButtonBase.ButtonState.Idle | ButtonBase.ButtonState.Selected | ButtonBase.ButtonState.Disabled;
        return ButtonBase.ButtonState.Active | ButtonBase.ButtonState.Selected | ButtonBase.ButtonState.Disabled | ButtonBase.ButtonState.Hover | ButtonBase.ButtonState.Idle;
    }
}

/** @}*/
