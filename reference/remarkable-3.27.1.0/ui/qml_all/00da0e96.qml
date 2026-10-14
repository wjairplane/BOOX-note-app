import QtQuick

import common
import com.remarkable

import device.ui.text
import ark.controls as ArkControls

Rectangle {
    id: root

    required property var modelData
    required property int index
    required property bool isCurrent

    property alias templateName: templateNameLabel.text
    property bool isSelected: false

    color: isSelected ? Values.colorBlack : Values.colorWhite
    property string itemColor: isSelected ? Values.colorWhite : Values.colorBlack

    signal applied(var aTemplate)
    signal clicked(var aTemplate)
    signal longPressed(var aTemplate)

    Loader {
        id: templateThumbnail
        sourceComponent: modelData.customTemplate ? thumbnailImg : thumbnailIcon
        anchors {
            top: root.top
            horizontalCenter: root.horizontalCenter
            margins: 40
        }
        height: 150
        width: height
    }

    Item {
        id: templateName
        readonly property int marginSize: dot.width

        width: root.width
        height: templateNameLabel.implicitHeight
        anchors {
            top: templateThumbnail.bottom
            margins: ArkControls.Values.spacing.medium
        }

        SubheaderSmall {
            id: templateNameLabel
            //: Recommended character limit for translation: 14
            text: qsTranslate("Templates", modelData.name)
            property bool shouldElide: width < implicitWidth + templateName.marginSize

            width: parent.width - templateName.marginSize * 2
            anchors {
                centerIn: templateName
                horizontalCenterOffset: modelData.isNew ? -templateName.marginSize / 2 : 0 // make space for the dot
            }
            horizontalAlignment: Text.AlignHCenter
            color: root.itemColor
            elide: Text.ElideRight
        }

        Rectangle {
            id: dot
            color: root.itemColor
            height: templateNameLabel.height / 2.5
            width: dot.height
            radius: 10

            // the dot is first centered and then should be offsetted so it appears to the right of the title
            property int offset: {
                const baseWidth = (templateNameLabel.shouldElide ? templateNameLabel.width : templateNameLabel.implicitWidth) / 2;
                const margin = templateNameLabel.shouldElide ? width / 2 : templateName.marginSize;

                return baseWidth + margin;
            }

            anchors {
                top: templateNameLabel.top
                horizontalCenter: templateName.horizontalCenter
                horizontalCenterOffset: offset
            }
            visible: modelData.isNew
        }
    }

    Rectangle {
        id: currentIndicator
        width: root.width
        height: Values.outlineSize * 4
        anchors {
            top: templateName.bottom
            margins: ArkControls.Values.spacing.small
        }
        color: root.itemColor
        visible: root.isCurrent
    }

    MouseArea {
        anchors.fill: root
        onClicked: root.clicked(modelData)
        onPressAndHold: root.longPressed(modelData)
    }

    /* ======== Template thumbnail components ======== */

    Component {
        id: thumbnailIcon
        Text {
            id: templateIcon
            text: modelData.iconCode
            font.pixelSize: templateThumbnail.height
            horizontalAlignment: Text.AlignHCenter
            color: itemColor
            renderType: Text.NativeRendering
            font.family: "icomoon"
        }
    }

    Component {
        id: thumbnailImg
        Image {
            id: templateImg
            height: templateThumbnail.height
            fillMode: Image.PreserveAspectFit
            source: modelData.iconUrl
        }
    }
}
