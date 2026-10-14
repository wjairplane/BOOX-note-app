import QtQuick
import QtQuick.Layouts

import xofm.libs.onboarding

import ark.controls as ArkControls
import ark.tokens as ArkTokens

ToolbarTool {
    id: root
    objectName: "adjustViewMenu"

    readonly property bool fitToWidth: toolbar.fitMode === "width"
    readonly property bool fitToHeight: toolbar.fitMode === "height"
    readonly property bool fitToCustom: toolbar.fitMode === "custom"

    shown: toolbar.pdfPage
    type: ToolbarTool.Type.FoldoutButton
    label: qsTr("Adjust view")
    iconSource: {
        if (root.fitToHeight) {
            return "qrc:/ark/icons/fit_to_height";
        } else if (root.fitToCustom) {
            return "qrc:/ark/icons/fit_custom";
        }
        return "qrc:/ark/icons/fit_to_width";
    }

    onPressed: root.select(root)

    foldoutContent: ColumnLayout {
        spacing: 0
        ArkControls.FoldoutItem {
            id: fitToWidth
            label: qsTr("Fit to width")
            iconSource: "qrc:/ark/icons/fit_to_width"
            selected: root.fitToWidth
            antialiasing: root.antialiasing
            focusPolicy: Qt.NoFocus
            Layout.fillWidth: true
            onClicked: {
                if (!highlighted) {
                    root.toolbar.fitToWidthSelected();
                }
            }
        }
        ArkControls.FoldoutItem {
            id: fitToHeight
            label: qsTr("Fit to height")
            iconSource: "qrc:/ark/icons/fit_to_height"
            selected: root.fitToHeight
            antialiasing: root.antialiasing
            focusPolicy: Qt.NoFocus
            Layout.fillWidth: true
            onClicked: {
                if (!highlighted) {
                    root.toolbar.fitToHeightSelected();
                }
            }
        }
        ArkControls.FoldoutItem {
            id: fitToCustom
            label: qsTr("Fit to custom view")
            iconSource: "qrc:/ark/icons/fit_custom"
            selected: root.fitToCustom
            antialiasing: root.antialiasing
            focusPolicy: Qt.NoFocus
            Layout.fillWidth: true
            onClicked: {
                root.toolbar.fitToCustomSelected();
            }
        }
    }
}
