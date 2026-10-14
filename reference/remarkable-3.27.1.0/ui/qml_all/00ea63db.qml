import QtQuick

import xofm.libs.toolbar
import xofm.libs.onboarding

import ark.controls as ArkControls

Loader {
    id: root

    enum Type {
        ToolbarButton,
        FoldoutButton
    }

    required property int type

    property Item content
    onContentChanged: content.parent = _childrenContainer

    // input
    // The toolbar that this button belongs to. This is a required property
    required property Item toolbar

    // Optional tooltip item.
    property ToolTip toolTip

    // button state
    // Using down instead of pressed to avoid confusion with the pressed signal
    property bool down: false
    property string iconSource: ""
    property string label: ""
    property string description: ""
    property bool shown: true
    // When set, this is the actively selected item in the toolbar
    property bool selected: false
    // when set, this item shows as selected, even though it is not the
    // actively selected item.
    property bool implicitlySelected: false
    // Used to show and hide the foldout submenu
    readonly property bool foldoutVisible: hasFoldout && root.foldout.visible
    readonly property real totalHeight: height + (root.foldoutVisible ? root.foldout.height : 0)

    // output
    // Returns true if this item has a foldout submenu.
    readonly property bool hasFoldout: root.foldout.contentItem !== null

    // Layout properties
    property int topInset: root.toolbar.position === ToolbarPositioner.Position.Top ? -toolbar.gestureMargin : 0
    property int bottomInset: root.toolbar.position === ToolbarPositioner.Position.Bottom ? -toolbar.gestureMargin : 0
    readonly property Item container: toolbar.container

    // Group width/height to avoid double eval
    readonly property size containerSize: container ? Qt.size(container.width, container.height) : Qt.size(0, 0)
    // A bit contrived to have this on the button - however the foldout is required to specify both align and position.
    // We don't want align (since foldouts fold towards the center) - hence position is maintained elsewhere.
    property int foldoutPosition: {
        switch(root.toolbar.position) {
        case ToolbarPositioner.Position.Top:
            return ToolbarFoldout.Position.Bottom;
        case ToolbarPositioner.Position.Bottom:
            return ToolbarFoldout.Position.Top;
        case ToolbarPositioner.Position.Left:
            return ToolbarFoldout.Position.Right;
        case ToolbarPositioner.Position.Right:
            return ToolbarFoldout.Position.Left;
        default:
            return ToolbarFoldout.Position.Absolute;
        }
    }

    property bool hasMinimumFoldoutWidth: true
    property int minimumFoldoutWidth: 400
    property bool foldoutTopDivider: false
    property bool foldoutBottomDivider: false

    signal canceled
    signal released
    signal clicked
    signal pressed
    signal foldoutRepositioned
    signal select(var item)

    visible: shown
    onFoldoutPositionChanged: repositionFoldout()
    onContainerSizeChanged: repositionFoldout()

    function repositionFoldout() {
        foldout.repositionFoldout();
    }

    sourceComponent: type === ToolbarTool.Type.ToolbarButton ? toolbarButton : foldoutButton

    Component {
        id: toolbarButton
        ArkControls.ToolButton {
            topInset: root.toolbar.position === ToolbarPositioner.Position.Top ? -toolbar.gestureMargin : 0
            bottomInset: root.toolbar.position === ToolbarPositioner.Position.Bottom ? -toolbar.gestureMargin : 0
            // internal state
            state: enabled ? (root.selected || root.implicitlySelected? "selected" : "idle") : "disabled"
            antialiasing: root.antialiasing
            focusPolicy: Qt.NoFocus
            iconSource: root.iconSource
            ditherOnDisabled: false // use thiner icons to avoid dither

            onReleased: root.released()
            onPressed: root.pressed()
            onCanceled: root.canceled()
            onClicked: root.clicked()

            Component.onCompleted: {
                root.down = Qt.binding(function() { return down });
            }
        }
    }

    Component {
        id: foldoutButton
        ArkControls.FoldoutItem {
            antialiasing: root.antialiasing
            focusPolicy: Qt.NoFocus
            selected: root.selected || root.implicitlySelected
            topDivider: root.foldoutTopDivider
            bottomDivider: root.foldoutBottomDivider
            label: parent.label
            description: parent.description
            iconSource: root.iconSource

            // FIXME: Adding this mouse area to capture events as there's currently a bug
            // tied to Button's pressed state when becoming not visible and being pressed
            // More info: https://bugreports.qt.io/browse/QTBUG-141483
            // The FoldoutItem's handler are removed.

            // onClicked: root.clicked()
            // onPressed: root.pressed()

            MouseArea {
                anchors.fill: parent
                onPressed: root.pressed()
                onClicked: root.clicked()
                onReleased: root.released()
                onCanceled: root.canceled()
            }
        }
    }

    Item {
        id: _childrenContainer
        anchors.fill: parent
        z: root.item ? root.item.z + 1 : 0
    }

    property Item foldoutContent
    property Item foldout: ToolbarFoldout {
        toolbar: root.toolbar
        position: root.foldoutPosition
        contentItem: root.foldoutContent
        visible: false
        parent: root.item
        onFoldoutRepositioned: {
            root.foldoutRepositioned();
        }
        width: root.hasMinimumFoldoutWidth ? Math.max(root.minimumFoldoutWidth, implicitWidth) : implicitWidth
    }
}
