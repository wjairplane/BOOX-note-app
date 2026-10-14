import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls
import xofm.libs.controls // InputBlocker
import xofm.modules.integrations.calendar

Item {
    id: root

    required property string title
    required property string time
    required property string location
    required property var response
    required property event event

    signal eventClicked(var event)

    function indicatorColor () {
        switch(response) {
            case EventResponse.NoResponse:
            case EventResponse.Tentative:
                return "transparent"; // allow pattern shining through
            case EventResponse.Accepted:
                return "black";
            default:
                return "white";
        }
    }

    width: listView.width
    height: column.height + 16

    Image {
        anchors.fill: indicatorBar
        source: "qrc:calendar/qml/crosshatch_pattern.png"
        fillMode: Image.Tile
    }
    Rectangle {
        id: indicatorBar
        color: indicatorColor()
        x: 42
        width: 8
        height: parent.height
    }

    MouseArea {
        anchors.fill: parent

        onClicked: root.eventClicked(root.event)
    }

    Column {
        id: column
        spacing: 8
        anchors {
            verticalCenter: parent.verticalCenter
            left: indicatorBar.left
            right: parent.right
            margins: 32
        }

        ArkControls.Label {
            width: parent.width
            type: ArkControls.Label.LargeStrong
            text: root.title
            elide: Text.ElideRight
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
        }

        RowLayout {
            width: parent.width
            spacing: 5
            ArkControls.Caption {
                id: timeText
                text: root.time
                elide: Text.ElideRight
                Layout.preferredWidth: contentWidth
            }
            ArkControls.Caption {
                id: timeLocationSeparator
                text: " · "
                Layout.preferredWidth: contentWidth
                visible: locationText.visible
            }
            ArkControls.Caption {
                id: locationText
                Layout.fillWidth: true
                visible: root.location.length > 0
                text: root.location
                elide: Text.ElideRight
            }
        }
    }
}
