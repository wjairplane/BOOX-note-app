import QtQuick
import QtQuick.Layouts

import xofm.libs.controls

import ark.tokens as ArkTokens
import ark.controls as ArkControls

Item {
    id: root
    required property var model
    required property int selectedIndex
    required property string title

    signal selected(var selection)
    signal rejected

    property var display: (text) => { return text; } // Allow to be ovewritten

    // Easier to test with InputBlocker as a child item, because then
    // we don't depend on number of children of InputBlocker
    InputBlocker {
        anchors.fill: parent
    }

    ArkControls.NavigationBar {
        id: navbar
        type: ArkTokens.NavigationBar.secondary
        title: root.title
        borderPosition: ArkControls.NavigationBar.Border.Bottom

        ArkControls.NavigationBar.Button {
            id: backButton
            objectName: "BackButton"
            text: qsTr("Back")
            textPosition: ArkControls.Button.TextPosition.Right
            iconSource: "qrc:/ark/icons/chevron_left"
            onClicked: root.rejected()
        }

        // This item is used in the component to calculate the available space for the title
        Item {
            Layout.fillWidth: true
        }
    }

    GridView {
        id: selectionGrid
        objectName: "SelectionGrid"
        anchors {
            top: navbar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        topMargin: ArkControls.Values.margin.vertical.medium_static
        bottomMargin: ArkControls.Values.margin.vertical.large
        leftMargin: ArkControls.Values.margin.horizontal.xlarge
        rightMargin: ArkControls.Values.margin.horizontal.xlarge

        cellWidth: (width - leftMargin - rightMargin) / (Math.max(1, Math.ceil((root.model.length * cellHeight) / (height - topMargin - bottomMargin)))) // divider should be minimum 1
        cellHeight: ArkTokens.Style.variable.controlsHeight.small

        interactive: false
        flow: GridView.FlowTopToBottom
        model: root.model

        delegate: ArkControls.SelectableItem {
            required property int index
            required property var modelData

            text: root.display(modelData)
            checked: root.selectedIndex === index
            selected: checked
            onClicked: root.selected(modelData)
        }
    }
}
