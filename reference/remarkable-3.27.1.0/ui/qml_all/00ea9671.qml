import QtQuick

ToolbarTool {
    id: root

    required property QtObject pen

    // tool type can be "primary", "secondary", "eraser", "select"
    required property string penToolType

    // Sticky buttons are those that stay active when the user clicks them to
    // close the foldout. This includes pens, eraser and selection today.
    // Examples of non-sticky buttons are tags and layers, as tapping to
    // close these, will bring you back to what you had selected previously.
    readonly property bool sticky: true

    signal penSelected

    onPressed: {
        if (root.toolbar.selectedPen !== root) {
            root.penSelected();
        }
    }
}
