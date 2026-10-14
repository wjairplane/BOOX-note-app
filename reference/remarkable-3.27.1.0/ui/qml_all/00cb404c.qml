import QtQuick
import xofm.libs.qtgui
import xofm.libs.epaper as Epaper

BaseView {
    id: root

    required property var library
    required property bool firstBoot
    required property var splashPath

    readonly property int _progressWidth: 420
    readonly property int _progressY: 420
    property rect progressRect: Qt.rect((splash.width - root._progressWidth)/2, root._progressY, root._progressWidth, 10)

    Image {
        id: splash
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        source: splashPath
        fillMode: Image.Pad
        clip: true

        Item {
            x: root.progressRect.x
            y: root.progressRect.y
            height: root.progressRect.height
            width: root.progressRect.width
            visible: !root.firstBoot
            Rectangle {
                height: parent.height
                width: parent.width * library.progress / 100;
                color: "black"
            }

            Rectangle {
                height: 2
                width: parent.width
                anchors.bottom: parent.bottom
                color: "black"
            }

            Epaper.ScreenModeItem {
                id: screenMode
                objectName: "bootprogress-screen-mode"
                anchors.fill: parent
                mode: Epaper.ScreenModeItem.Pen
                visible: true
            }
        }
    }
}
