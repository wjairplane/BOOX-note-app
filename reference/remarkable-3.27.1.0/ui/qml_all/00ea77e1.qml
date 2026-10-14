import QtQuick

WritingTool {
    id: root
    objectName: "primaryPenMenu"
    pen: toolbar.primaryPen
    label: qsTr("Primary pen")
    penToolType: "primary"
}
