import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.qtgui
import xofm.libs.controls
import xofm.libs.epaper as Epaper
import xofm.libs.orientation
import xofm.modules.sleepscreen

BaseView {
    id: root

    required property var isettings
    required property Orientation orientation
    required property int carouselLandscapeWidth
    required property int carouselWidth
    required property var carousel

    function makeSleepScreenPath() {
        // default image might not have file://, so add it
        // if it is missing.
        let path = root.isettings.sleepScreenPath;
        if (!path.startsWith("file:")) {
            path = "file://" + path;
        }
        return path;
    }

    contentItem: InputBlocker {

        Image {
            id: logo
            source: root.makeSleepScreenPath()
            fillMode: Image.PreserveAspectFit
            width: root.isettings.isCustomSleepScreenPath ? parent.width : implicitWidth
            height: root.isettings.isCustomSleepScreenPath ? parent.height : implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Image {
            id: illustration
            source: root.carousel.imagePath
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            width: root.orientation.isPortraitOrientation ? root.carouselWidth : root.carouselLandscapeWidth
            height: width
            visible: !root.isettings.isCustomSleepScreenPath
        }

        ColumnLayout {
            anchors {
                bottom: parent.bottom
                bottomMargin: ArkControls.Values.margin.horizontal.large
                left: parent.left
                leftMargin:  ArkControls.Values.margin.horizontal.large
                right: parent.right
                rightMargin:  ArkControls.Values.margin.horizontal.large
            }
            visible: root.isettings.idleDetailsVisible

            ArkControls.Body {
                id: contactName
                text: root.isettings.idleName
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.width
                elide: Qt.ElideRight
            }
            ArkControls.Body {
                id: contactNumber
                text: root.isettings.idleContact
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.width
                elide: Qt.ElideRight
            }
        }

        Rectangle {
            id: errorPlaceholder
            anchors.fill: parent
            visible: logo.status === Image.Error

            ArkControls.Title {
                type: ArkControls.Title.Large
                anchors.centerIn: errorPlaceholder
                text: qsTr("reMarkable is sleeping")
            }
        }

        Epaper.ScreenModeItem {
            anchors.fill: parent
            mode: Epaper.ScreenModeItem.Sleep
            objectName: "sleep-window"
        }
    }
}
