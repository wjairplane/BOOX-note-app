import QtQuick

import ark.controls as ArkControls

ArkControls.Foldout {
    id: root

    property Item overlayParent

    signal overlayClicked()

    MouseArea {
        id: closeArea
        parent: root.visible ? overlayParent : null
        x: overlayParent?.x
        y: overlayParent?.y
        width: overlayParent?.width
        height: overlayParent?.height
        onClicked: overlayClicked()
    }
}
