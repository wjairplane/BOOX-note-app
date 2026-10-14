import QtQuick

import common
import device.view.experimental

import ark.controls as ArkControls

SidebarFoldoutContentItem {
    id: root

    font.pixelSize: Values.fontSizeH2

    active: isOpen || !!activeChild
    showBorder: false

    property bool isOpen
    property var activeChild
    property alias foldoutItems: foldoutColumn.children
    property var subItemNavigationHandler
    property alias foldoutArrowVisible: chevron.visible

    property var model: []
    property var delegatesErrorHandler: () => ""

    ArkControls.Icon {
        id: chevron
        source: "qrc:/ark/icons/chevron_small_right"
        color: parent.active ? Values.colorWhite : Values.colorBlack
        anchors {
            right: parent.right
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        id: foldoutBackground
        width: parent.width
        height: foldoutColumn.height
        anchors.left: parent.right
        anchors.top: parent.top
        visible: isOpen && root.model.count > 1
        anchors.leftMargin: -border.width

        border {
            width: 2
            color: Values.colorBlack
        }

        Column {
            id: foldoutColumn
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            height: childrenRect.height

            Repeater {
                id: foldoutRepeater
                model: visible ? root.model : null
                width: parent.width
                delegate: SidebarFoldoutContentItem {
                    required property var modelData

                    title: modelData.name ?? qsTr("Undefined")
                    active: model && !!activeChild && modelData.id === activeChild.id
                    iconSource: modelData.iconSource ?? ""
                    onClicked: activate()
                    errorText: root.delegatesErrorHandler(modelData.navigationState, modelData.isDisabled)
                    navigationHandler: root.subItemNavigationHandler
                    elideCaption: Text.ElideRight

                    function activate() {
                        root.subItemNavigationHandler.focus = false;
                        root.model.onClicked(title, modelData.id);
                    }
                }
            }
        }
    }
}
