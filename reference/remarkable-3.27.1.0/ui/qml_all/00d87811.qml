import QtQuick
import ark.controls as ArkControls

ArkControls.Toggle {
    id: root

    property int mouseAreaPadding: 20
    property alias extendedMouseArea: extendedMouseArea

    MouseArea {
        id: extendedMouseArea
        anchors.fill: parent
        anchors.margins: -root.mouseAreaPadding
    }
}
