import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls

ArkControls.Foldout {
    id: root

    signal notebookClicked
    signal searchClicked

    contentItem: ColumnLayout {
        spacing: 0

        ArkControls.FoldoutItem {
            id: notebookFoldoutItem
            objectName: "notebookFoldoutItem"
            highlighted: false
            Layout.fillWidth: true
            label: qsTr("New notebook")
            iconSource: "qrc:/ark/icons/notebook"
            onClicked: root.notebookClicked()
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
}
