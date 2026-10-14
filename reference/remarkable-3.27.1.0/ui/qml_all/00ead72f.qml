import QtQuick
import QtQuick.Layouts

import xofm.libs.toolbar
import xofm.libs.orientation
import xofm.libs.controls
import ark.controls as ArkControls
import xofm.libs.analytics.ui

FocusScope {
    id: root

    required property ToolbarProvider toolbarProvider
    required property int orientation
    required property Item container
    required property Analytics analytics

    ListModel {
        id: positionModel
        ListElement { key: ToolbarPositioner.Position.Top; value: qsTr("Top") }
        ListElement { key: ToolbarPositioner.Position.Bottom; value: qsTr("Bottom") }
        ListElement { key: ToolbarPositioner.Position.Left; value: qsTr("Left") }
        ListElement { key: ToolbarPositioner.Position.Right; value: qsTr("Right") }
    }

    function findCurrentPreference(preference) {
        let currentIndex = 0;
        for ( let i = 0; i < positionModel.count; i++) {
            if (positionModel.get(i).key === preference) {
                return i;
            }
        }
        return currentIndex;
    }

    function reportToolbarPositionChanged(key) {
        analytics.sendEvent("Toolbar Position Changed", {
            "trigger": "settings",
            "position": AnalyticsUtils.enumToString(key, "xofm::libs::toolbar::ToolbarPositioner::Position"),
            "applied_to_orientation": root.orientation === Orientation.Portrait ? "portrait" : "landscape"
        });
    }

    ArkControls.Label {
        id: label
        anchors.top: parent.top
        text: {
            if (root.orientation === Orientation.Portrait) {
                return qsTr("Portrait");
            }
            return qsTr("Landscape");
        }
        antialiasing: root.antialiasing
    }

    Dropdown {
        id: dropdown
        anchors {
            top: label.bottom
            topMargin: ArkControls.Values.spacing.small
        }
        model: positionModel
        boxSize: Qt.size(parent.width, 80)
        container: root.container
        currentIndex: {
            if (root.orientation === Orientation.Landscape)
                return root.findCurrentPreference(root.toolbarProvider.positioner.landscapePreference);
            return root.findCurrentPreference(root.toolbarProvider.positioner.portraitPreference);
        }

        onSelect: (key) => {
            if (root.orientation === Orientation.Landscape) {
                root.toolbarProvider.positioner.landscapePreference = key;
            } else {
                root.toolbarProvider.positioner.portraitPreference = key;
            }

            // Analytics
            root.reportToolbarPositionChanged(key);
        }
    }
}
