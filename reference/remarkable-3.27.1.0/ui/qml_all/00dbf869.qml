import QtQuick
import com.remarkable

import ark.controls as ArkControls

Rectangle {
    id: archivedMarker
    color: Values.colorWhite
    width: 80 //?? From values?
    height: 80 // ?? From values?

    ArkControls.Icon {
        id: icon
        anchors.centerIn: parent
        size: Values.iconSizeSmall
        color: Values.colorBlack
        source: "qrc:/ark/icons/cloud"
    }
}
