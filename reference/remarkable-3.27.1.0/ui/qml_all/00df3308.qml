import QtQuick
import QtQuick.Layouts
import ark.controls as ArkControls

MouseArea {
    property alias iconSource: createIcon.source
    property alias title: createTitle.text
    property alias caption: createCaption.text
    implicitHeight: createTitle.height + createCaption.height
    implicitWidth: createIcon.width + createTitle.anchors.leftMargin + createCaption.width
    Layout.fillWidth: true
    Layout.topMargin: 40

    ArkControls.Icon {
        id: createIcon
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        size: ArkControls.Values.iconSize.medium
        source: "qrc:/ark/icons/placeholder"
    }

    ArkControls.Label {
        id: createTitle
        anchors.left: createIcon.right
        anchors.leftMargin: 20
        type: ArkControls.Label.LargeStrong
    }

    ArkControls.Caption {
        id: createCaption
        anchors.top: createTitle.bottom
        anchors.left: createTitle.left
    }
}
