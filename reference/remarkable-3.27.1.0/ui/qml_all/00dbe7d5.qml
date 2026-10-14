import QtQuick
import com.remarkable
import common

import ark.controls as ArkControls

Image {
    id: root

    property alias document: provider.document
    property alias page: provider.page
    property alias monochrome: provider.monochrome

    property color borderColor: "transparent"
    property int borderWidth: 0

    property bool listMode: false
    property bool selected: false

    property color screenShareBorderColor: Values.colorBlack
    property int screenShareBorderWidth: 7

    property string documentId: ""

    property bool enableScreenShareIndicator: false

    property var errorMessageFunc: errorMessage
    property int errorIconSize: Values.iconSizeLarge

    function errorMessage(document, page) {
        if (document && document.loadErrorType === DocumentIO.LoadErrorType.UnsupportedFormatVersion) {
            return qsTr("Update software to view");
        }
        return qsTr("Unable to view");
    }

    function errorIcon(document, page) {
        if (document && document.loadErrorType === DocumentIO.LoadErrorType.UnsupportedFormatVersion) {
            return "qrc:/ark/icons/restore";
        }
        return "qrc:/ark/icons/warning_circle";
    }

    source: provider.source
    asynchronous: true

    fillMode: Image.PreserveAspectFit
    verticalAlignment: Image.AlignVCenter
    sourceSize: Qt.size(width, height)

    Rectangle {
        id: border
        color: "transparent"
        border.color: root.borderColor
        border.width: root.borderWidth
        anchors.fill: parent
    }

    // screenShare indicators
    Loader {
        anchors.fill: parent
        active: enableScreenShareIndicator && ScreenShare.serverActive && ScreenShare.documentId === documentId
        sourceComponent: Item {
            anchors.fill: parent

            // border
            Rectangle {
                color: "transparent"
                border.color: root.screenShareBorderColor
                border.width: root.screenShareBorderWidth
                anchors.fill: parent
            }

            // icon background
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: icon.implicitWidth + 24 * Values.scale
                height: icon.implicitHeight + 24 * Values.scale
                color: Values.colorBlack

                // icon
                ArkControls.Icon {
                    id: icon
                    source: "qrc:/ark/icons/screen_share"
                    color: Values.colorWhite
                    anchors.centerIn: parent
                    size: Values.iconSizeSmall
                }
            }
        }
    }

    // document load error overlay
    Loader {
        id: errorOverlay
        anchors.fill: parent
        active: document && document.loadError && !document.archived
        sourceComponent: Item {
            id: errorOverlay
            anchors.fill: parent

            // cover thumbnail with error icon and text
            Rectangle {
                id: frame
                color: Values.colorWhite
                border.color: root.borderColor
                border.width: root.borderWidth
                anchors.fill: parent

                // icon
                ArkControls.Icon {
                    id: error_icon_1
                    source: root.errorIcon(document, page)
                    size: root.errorIconSize
                    color: Values.colorBlack
                    anchors.verticalCenter: frame.verticalCenter
                    anchors.horizontalCenter: frame.horizontalCenter
                    visible: error_text.text.length == 0
                }
                ArkControls.Icon {
                    id: error_icon_2
                    source: root.errorIcon(document, page)
                    size: root.errorIconSize
                    color: Values.colorBlack
                    anchors.bottom: frame.verticalCenter
                    anchors.horizontalCenter: frame.horizontalCenter
                    visible: error_text.text.length > 0
                }

                ArkControls.Caption {
                    id: error_text
                    anchors.top: error_icon_2.bottom
                    anchors.topMargin: font.pixelSize * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - (2 * 8)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: root.errorMessageFunc(document, page)
                    color: Values.colorBlack
                    font.pixelSize: 18 * Values.scale
                }
            }
        }
    }

    ThumbnailProvider {
        id: provider
    }
}
