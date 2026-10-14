import QtQuick
import QtQuick.Layouts
import ark.tokens as ArkTokens
import ark.controls as ArkControls

/** \addtogroup controls
 *  @{
 */
/*! Visual representation of the LayerItem

\image html paperTablet-LayersFoldout.qml.png paperTablet
\image html client-LayersFoldout.qml.png client

\note LayerItem contains TextInput component for editing the label

See \ref example-Toolbar.qml, \ref example-LayersFoldout.qml and \ref Layers.qml for usage examples
*/
ButtonBase {
    id: root

    // Toolbar type available in \ref ArkTokens
    type: ArkTokens.Toolbar.primary

    /// path to the "eye" icon (open or close)
    required property string visibleIcon

    /*! Access textInput proporties, among them
        * text - set original text for editing
        * visible - to show text input in place of the label
        * selectAll() - select whole label for editing
        * ensureVisible(position) - scroll label position in the rectangle
        * onAccepted - take editited text and hide the label 
    */
    property alias textInput: _textInput

    /// Set true when the label may occupy all space available for buttons on the right
    property bool baseLayer: false

    /// Set to true if layer is selected
    required property bool selected

    /// List of action buttons to the right of text label
    required property var actionsModel

    /*! Action button delegate should use LayerComponent.Button component and set
        * iconSource - path to icon source
        * opacity - set to 0 to hide the button
        * enabled - set to false to present action as disabled
    */
    property Component actionDelegate: Button { 
        required property var modelData 
        iconSource: modelData.icon
        opacity: modelData.state == ArkControls.LayerAction.Hidden ? 0 : 1
        enabled: modelData.state == ArkControls.LayerAction.Default
        
        onClicked: {
            root.actionClicked(modelData)
        }

        Image {
            visible: !enabled
            anchors.fill: parent
            source: Details.overlaySource(layerSelected ? "black" : "white")
            fillMode: Image.Tile
        }
    }

    /// PressAndHold on text label
    signal textPressAndHold()

    /// PressAndHold on text label
    signal textClicked()

    /// Click on visibility button
    signal visibleClicked()

    /// Click on action button (with model action item)
    signal actionClicked(var item)

    
    // The rest is private (components can not be documented with doxygen)
    implicitHeight: ArkTokens.Style.variable.isPaper ? ArkTokens.Style.variable.controlsHeight.large : (implicitContentHeight + topPadding + bottomPadding)
    implicitWidth:  implicitContentWidth + leftPadding + rightPadding

    component Button: ButtonBase {
        id: btn
        property bool layerSelected: false
        type: ArkTokens.Toolbar.primary
        tokens: layerSelected ? btn.type.foldout.layer.selected.action : btn.type.foldout.layer.idle.action
        contentItem: Icon {
            id: iconImage
            source: btn.iconSource
            size: btn.tokens.content.icon.idle.sizing
            color: btn.tokens.content.icon[btn.state].fill
        }
    }

    tokens: Object.assign({}, root.type.foldout.item, {"focus": root.type.foldout.focus})
    topPadding: root.type.foldout.layer.idle.container.spacing
    bottomPadding: root.type.foldout.layer.idle.container.spacing
    rightPadding: root.type.foldout.layer.idle.container.spacing
    leftPadding: root.type.foldout.layer.idle.container.spacing

    contentItem: RowLayout {
        id: _buttons  
        spacing: root.type.foldout.layer.idle.container.spacing
        
        Row {
            id: _iconAndText
            spacing: root.type.foldout.layer.idle.container.spacing
           
            Button {
                id: _visibleButton
                layerSelected: root.selected
                iconSource: root.visibleIcon
                onClicked: {
                    root.visibleClicked();
                }
                antialiasing: root.antialiasing
            }

            TextLabel {
                id: _text
                property int fixedWidth: ArkTokens.Settings.accessibility ? 260 : 196
                visible: !_textInput.visible
                width: _actions.visible ? fixedWidth : fixedWidth + _actions.width + _buttons.spacing
                elide: Text.ElideMiddle
                typography: root.tokens.content.label.idle.typography
                color: root.tokens.content.label[root.state].fill
                text: root.text
                MouseArea {
                    id: textArea
                    anchors.fill: parent
                    enabled: _text.visible
                    onPressAndHold: {
                        root.textPressAndHold();
                    }
                    onClicked: {
                        root.textClicked();
                    }
                }
                antialiasing: root.antialiasing
                anchors.verticalCenter: parent.verticalCenter
            }
            TextInput {
                id: _textInput
                visible: false
                clip: true
                width: _text.width
                height: _text.height

                font: inputFont.font
                color: root.tokens.content.label[root.state].fill
                selectionColor : root.tokens.content.label[root.state].fill
                selectedTextColor: root.tokens.background[root.state].fill ?? "transparent"
                verticalAlignment: Text.AlignVCenter

                ArkControls.FontExtender {
                    id: inputFont
                    font {
                        capitalization: root.tokens.content.label.idle.typography.textCase
                        family: root.tokens.content.label.idle.typography.fontFamily
                        letterSpacing: root.tokens.content.label.idle.typography.letterSpacing
                        pixelSize: root.tokens.content.label.idle.typography.fontSize
                        weight: root.tokens.content.label.idle.typography.fontWeight
                    }
                }

                onVisibleChanged: {
                    forceActiveFocus();
                }
                anchors.verticalCenter: parent.verticalCenter
            }
            Layout.alignment: Qt.AlignLeft 
        }

        Item {
            Layout.fillWidth: true
        }

        Row {
            id: _actions
            spacing: root.type.foldout.layer.idle.container.spacing
            visible: !root.baseLayer
            Repeater {
                id: _buttonsRow
                model: actionsModel
                delegate: actionDelegate
                onItemAdded: function (index, item) {
                    item.type = root.type;
                    item.layerSelected = Qt.binding(() =>{ return root.selected })
                }
            }
        }
    }    

    states: ButtonBase.ButtonState.Idle | ButtonBase.ButtonState.Selected
    state: selected ? "selected" : "idle"
}
/** @}*/
