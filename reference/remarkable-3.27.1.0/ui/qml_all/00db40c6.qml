import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls

ArkControls.Foldout {
    id: root

    signal moveOutClicked

    contentItem: ColumnLayout {
        spacing: 0

        ArkControls.FoldoutItem {
            id: moveOutFoldoutItem
            objectName: "moveOutFoldoutItem"
            highlighted: false
            Layout.fillWidth: true
            label: qsTr("Move out")
            iconSource: "qrc:/ark/icons/notebook_move"
            onClicked: root.moveOutClicked()
        }
    }
}
