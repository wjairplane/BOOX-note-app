import QtQuick
import QtQuick.Layouts

import xofm.libs.toolbar
import xofm.libs.orientation

import xofm.libs.analytics.ui

import device.ui.controls

import ark.controls as ArkControls

ArkControls.Panel {
    id: root

    property var navigationHandler
    property ToolbarProvider toolbarProvider
    property Item container: root
    property Analytics analytics

    label: qsTr("Toolbar position")
    description: qsTr("Choose your preferred toolbar position.")
    showAttachment: true

    attachment: ColumnLayout {
        spacing: 0
        RowLayout {
            uniformCellSizes: true
            spacing: ArkControls.Values.spacing.medium
            z: 1
            ToolbarPositionDropDown {
                id: portraitDropDown
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                orientation: Orientation.Portrait
                toolbarProvider: root.toolbarProvider
                container: root.container
                analytics: root.analytics
            }

            ToolbarPositionDropDown {
                id: landscapeDropDown
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                orientation: Orientation.Landscape
                toolbarProvider: root.toolbarProvider
                container: root.container
                analytics: root.analytics
            }
        }
        ArkControls.Caption {
            text: qsTr("To reposition the toolbar while in a document, drag the hide/show button to any edge of the screen.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }
}
