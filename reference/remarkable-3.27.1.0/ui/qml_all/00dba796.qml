import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls

FoldoutOverlay {
    id: root

    signal newFolderClicked
    signal searchClicked
    signal foldoutOverlayClicked

    contentItem: ColumnLayout {
        spacing: 0

        ArkControls.FoldoutItem {
            id: newFolderFoldoutItem
            objectName: "newFolderFoldoutItem"
            highlighted: false
            Layout.fillWidth: true
            label: qsTr("New folder")
            iconSource: "qrc:/ark/icons/folder"
            onClicked: root.newFolderClicked()
        }
        ArkControls.FoldoutItem {
            id: searchFoldoutItem
            objectName: "searchFoldoutItem"
            highlighted: false
            Layout.fillWidth: true
            label: qsTr("Search")
            iconSource: "qrc:/ark/icons/lens"
            onClicked: root.searchClicked()
        }
    }

    onOverlayClicked: root.foldoutOverlayClicked()
}
