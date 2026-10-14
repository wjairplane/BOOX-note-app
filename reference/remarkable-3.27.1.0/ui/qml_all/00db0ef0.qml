import QtQuick
import QtQuick.Layouts

import com.remarkable
import common

import device.ui.controls

import ark.controls as ArkControls

FoldoutOverlay {
    id: root

    signal clicked(string action)
    signal foldoutOverlayClicked

    component LocalFoldoutItem : ArkControls.FoldoutItem {
        antialiasing: true
        Layout.fillWidth: true
        topDivider: true
    }

    contentItem: ColumnLayout {
        spacing: 0

        LocalFoldoutItem {
            id: positionTop
            label: qsTr("With edits")
            iconSource: "qrc:/ark/icons/duplicate_edits"
            selected: false
            onClicked: root.clicked("copy")
        }
        LocalFoldoutItem {
            id: positionBottom
            label: qsTr("Original document")
            iconSource: "qrc:/ark/icons/duplicate_original"
            selected: false
            onClicked: root.clicked("clean")
        }
    }

    onOverlayClicked: root.foldoutOverlayClicked()
}
