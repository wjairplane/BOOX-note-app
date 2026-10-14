import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import xofm.libs.onboarding
import xofm.libs.toolbar

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "layersMenu"
    type: ToolbarTool.Type.FoldoutButton

    // Input properties
    property QtObject model: toolbar.layersModel
    property bool notePage: toolbar.notePage
    property bool noteBook: toolbar.documentType === "note"
    property bool backgroundVisible: toolbar.layersBackgroundVisible
    property bool rootDocumentVisible: toolbar.layersRootDocumentVisible
    property bool rootDocumentAvailable: toolbar.layersRootDocumentAvailable
    property var layersRowBottom: toolbar.layersRowBottom

    // Signals
    signal newLayerSelected
    signal chooseTemplateSelected
    signal toggleBackgroundVisibleSelected
    signal toggleRootDocumentVisibleSelected
    signal setCurrentLayerSelected(index : int)
    signal toggleLayerVisibilitySelected(index : int)
    signal moveLayerUpSelected(index : int)
    signal moveLayerDownSelected(index : int)
    signal mergeLayerSelected(index : int)
    signal deleteLayerSelected(index : int)
    signal renameLayerSelected(index : int, name : string)

    // Reimplemented state from ToolbarTool
    label: qsTr("Layers")
    iconSource: "qrc:/ark/icons/layers"

    property Item _layerBeingRenamed: null

    // The renamed layer overlaps the keyboard, so we need to nudge it as a side effect after the foldout has been repositioned.
    function nudgeFoldout() {
        // consider window activefocusitem instead of keeping track of the renamed layer - however that means assumptions about the layers component structure, which is brittle.
        if(!_layerBeingRenamed?.textInput.visible) {
            return;
        }
        const layerItemBottom = _layerBeingRenamed.mapToItem(root.container, 0, _layerBeingRenamed.height);
        const keyboardHeight = Qt.inputMethod.keyboardRectangle.height;
        const overlap = layerItemBottom.y + keyboardHeight - root.container.height;
        root.foldout.y -= (overlap > 0 ? overlap : 0);
    }

    onFoldoutRepositioned: {
        nudgeFoldout();
    }

    component LayerActionDelegate : ArkControls.LayerComponent.Button {
        required property string key
        required property string iconName
        required property bool hidden
        required property bool disabled
        property string actionKey: key
        antialiasing: root.antialiasing
        iconSource: iconName
        opacity: hidden ? 0 : 1
        enabled: !disabled
    }

    foldoutContent: ColumnLayout {
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            // The repeater will lay out the items top to bottom, so to get
            // them in the right order, we turn it around. We create an
            // intermediate container for the layers and rotate them by 180
            // degrees. Then each item is in turn rotated back to 0 degrees.
            rotation: 180
            spacing: 0

            Repeater {
                model: root.model
                ArkControls.LayerComponent {
                    required property int layerIndex
                    required property string layerName
                    required property bool layerVisible
                    required property bool layerSelected
                    required property bool layerMoveUpEnabled
                    required property bool layerMoveDownEnabled
                    required property bool layerMergeEnabled
                    required property bool layerTrashEnabled

                    visibleIcon: layerVisible ? "qrc:/ark/icons/eye" : "qrc:/ark/icons/eye_closed"
                    selected: layerSelected
                    text: layerName

                    property ListModel actionList: ListModel {}
                    actionsModel: {
                        actionList.clear();
                        actionList.append({
                            iconName: "qrc:/ark/icons/arrow_up",
                            key: "up",
                            hidden: root.model.count == 1,
                            disabled: !layerMoveUpEnabled
                        });
                        actionList.append({
                            iconName: "qrc:/ark/icons/arrow_down",
                            key: "down",
                            hidden: root.model.count == 1,
                            disabled: !layerMoveDownEnabled
                        });
                        actionList.append({
                            iconName: "qrc:/ark/icons/merge",
                            key: "merge",
                            hidden: !layerMergeEnabled,
                            disabled: !layerMergeEnabled
                        });
                        actionList.append({
                            iconName: "qrc:/ark/icons/trashcan",
                            key: "delete",
                            hidden: !layerTrashEnabled,
                            disabled: !layerTrashEnabled
                        });

                        return actionList;
                    }
                    actionDelegate: LayerActionDelegate {
                        onClicked: {
                            if (actionKey === "up") {
                                root.moveLayerUpSelected(layerIndex);
                            } else if (actionKey === "down") {
                                root.moveLayerDownSelected(layerIndex);
                            } else if (actionKey === "merge") {
                                root.mergeLayerSelected(layerIndex);
                            } else if (actionKey === "delete") {
                                root.deleteLayerSelected(layerIndex);
                            }
                        }
                    }
                    onVisibleClicked: {
                        root.toggleLayerVisibilitySelected(layerIndex);
                    }
                    onTextClicked: {
                        root.setCurrentLayerSelected(layerIndex);
                    }

                    // The inversion of the rotation we spoke about above..
                    rotation: 180
                    antialiasing: root.antialiasing
                    Layout.fillWidth: true

                    onTextPressAndHold: {
                        textInput.text = layerName;
                        textInput.selectAll();
                        textInput.visible = true;
                        root._layerBeingRenamed = this;
                        root.nudgeFoldout();
                    }

                    onSelectedChanged: textInput.visible = false;

                    Connections {
                        target: textInput
                        function onVisibleChanged(visible) {
                            if(!visible) {
                                root.repositionFoldout();
                            }
                        }
                    }

                    Connections {
                        target: textInput
                        function onAccepted() {
                            root.renameLayerSelected(layerIndex, textInput.text);
                            textInput.visible = false;
                            textInput.focus = false;
                            root.repositionFoldout();
                        }
                        function onFocusChanged() {
                            if (!textInput.focus) {
                                textInput.visible = false
                            }
                        }
                    }

                    // Hide the text edit if we ourselves get hidden
                    onVisibleChanged: {
                        if (!visible && textInput.activeFocus) {
                            textInput.visible = false;
                            textInput.focus = false;
                        }
                    }
                }
            }
        }

        // The 'text' / rootDocument row
        ArkControls.LayerComponent {
            id: textRow
            visible: root.rootDocumentAvailable
            visibleIcon: root.rootDocumentVisible ? "qrc:/ark/icons/eye" : "qrc:/ark/icons/eye_closed"
            text: qsTr("Text")
            selected: false
            actionsModel: ListModel {}
            onVisibleClicked: root.toggleRootDocumentVisibleSelected()
            onTextClicked: root.toggleRootDocumentVisibleSelected()
            antialiasing: root.antialiasing
            Layout.fillWidth: true
        }

        // The 'template' row
        ArkControls.LayerComponent {
            id: templateRow
            visible: root.notePage
            visibleIcon: root.backgroundVisible ? "qrc:/ark/icons/eye" : "qrc:/ark/icons/eye_closed"
            text: qsTr("Template")
            selected: false

            actionsModel: ListModel {
                ListElement {
                    iconName: "qrc:/ark/icons/template"
                    key: "templates"
                    hidden: false
                    disabled: false
                }
            }
            onVisibleClicked: root.toggleBackgroundVisibleSelected()
            onClicked: root.chooseTemplateSelected()
            onTextClicked: root.chooseTemplateSelected()
            actionDelegate: LayerActionDelegate {
                onClicked: root.chooseTemplateSelected()
            }

            antialiasing: root.antialiasing
            Layout.fillWidth: true
        }

        // The 'epub/pdf' background row
        ArkControls.LayerComponent {
            id: backgroundRow
            visible: !root.notePage && !root.noteBook
            visibleIcon: root.backgroundVisible ? "qrc:/ark/icons/eye" : "qrc:/ark/icons/eye_closed"
            text: qsTr("Background")
            selected: false
            actionsModel: ListModel {}
            onVisibleClicked: root.toggleBackgroundVisibleSelected()
            onTextClicked: root.toggleBackgroundVisibleSelected()
            antialiasing: root.antialiasing
            Layout.fillWidth: true
        }

        ArkControls.FoldoutItem {
            id: newLayerRow
            readonly property bool limitReached: root.model.count >= 5
            label: !limitReached ? qsTr("New layer") : qsTr("Limit of 5 layers reached")
            iconSource: !limitReached ? "qrc:/ark/icons/plus_circle" : "qrc:/ark/icons/information_circle"
            antialiasing: root.antialiasing
            focusPolicy: Qt.NoFocus
            topDivider: true
            onClicked: {
                if (limitReached) {
                    // Prevent adding new layers when reached max.
                    // Previous we disabled the button, but as UX don't want the disabled color
                    // and ARK doesn't support changing colors manually - we need to do it this way for now.
                    return;
                }

                root.newLayerSelected();
            }
            Layout.fillWidth: true
        }
    }

    toolTip: ToolTip {
        id: layersToolTip
        type: ArkTokens.Tooltip.secondary
        readonly property Item source: root.foldout.parent instanceof StackView ? root.foldout : root
        //: Recommended character limit for translation: 20
        caption: qsTr("Layers and templates")
        positionHint: root.toolbar.tooltipPositionHint
        parent: root.toolbar.tooltipOverlay
        container: root.toolbar.tooltipContainer
        pointTo: source.mapToItem(root.toolbar.tooltipOverlay, root.foldout.x, root.foldout.y, root.foldout.width, root.foldout.height)
        OnboardingStateProp.key: "Layers_Introduction"
    }

    onPressed: {
        if (!foldoutVisible) {
            // Only emit if not already open to avoid false reports on multiple clicks.
            root.toolbar.reportLayersFoldoutOpened();
        }
        root.select(root);
    }
    onChooseTemplateSelected: root.toolbar.chooseTemplateSelected()
    onNewLayerSelected: root.toolbar.newLayerSelected()
    onToggleBackgroundVisibleSelected: root.toolbar.toggleBackgroundVisibleSelected()
    onToggleRootDocumentVisibleSelected: root.toolbar.toggleRootDocumentVisibleSelected()
    onSetCurrentLayerSelected: (index) => { root.toolbar.setCurrentLayerSelected(index); }
    onToggleLayerVisibilitySelected: (index) => { root.toolbar.toggleLayerVisibilitySelected(index); }
    onMoveLayerUpSelected: (index) => { root.toolbar.moveLayerUpSelected(index); }
    onMoveLayerDownSelected: (index) => { root.toolbar.moveLayerDownSelected(index); }
    onMergeLayerSelected: (index) => { root.toolbar.mergeLayerSelected(index); }
    onDeleteLayerSelected: (index) => { root.toolbar.deleteLayerSelected(index); }
    onRenameLayerSelected: (index, name) => { root.toolbar.renameLayerSelected(index, name); }
}
