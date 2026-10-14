import QtQuick

WritingTool {
    id: root
    objectName: "secondaryPenMenu"
    pen: toolbar.secondaryPen
    label: qsTr("Secondary pen")
    penToolType: "secondary"
}
