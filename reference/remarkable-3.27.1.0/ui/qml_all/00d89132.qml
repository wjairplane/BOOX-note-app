import QtQuick
import common
import com.remarkable
import device.ui.text

Item {
    id: expandableSection
    property alias title: header.text
    property alias model: repeater.model
    property Component delegate
    property Component footer
    readonly property bool expanded: expandableSection === _expandedSection
    property bool canExpand: true
    property alias headerItem: headerItem.sourceComponent
    property int unexpandedHeight: root.orientation.isPortraitOrientation ? 300 : 220
    property int itemHeight: 60

    width: parent.width
    height: expandableSection === _expandedSection ? parent.height - expandableSection.y : unexpandedHeight

    TextHeaderRegular {
        id: header
        font.pixelSize: Values.fontSizeH2
        color: Values.colorBlack
        font.bold: true
    }

    Loader {
        id: headerItem
        anchors.topMargin: 30
        anchors.top: header.bottom
    }

    Flow {
        id: flow
        clip: implicitHeight > height
        spacing: 20
        anchors {
            topMargin: headerItem.item ? 30 : 0
            top: headerItem.bottom
            bottom: parent.bottom
            bottomMargin: 30
            left: parent.left
            right: showAllbutton.left
            rightMargin: 6
        }

        Repeater {
            id: repeater
            Loader {
                id: loader
                readonly property var model: modelData
                readonly property int idx: index
                sourceComponent: expandableSection.delegate
            }
        }
    }

    TextParagraph {
        id: showAllbutton
        text: expanded ? qsTr("Show less") : qsTr("Show all")
        font.underline: true
        font.bold: true
        anchors.right: parent.right
        anchors.bottomMargin: 20
        font.pixelSize: Values.fontSizeH3
        anchors.top: flow.top
        visible: canExpand && (flow.implicitHeight > flow.height || expanded)
        MouseArea {
            anchors.fill: parent
            anchors.margins: -Values.designGridVerticalGutter
            onClicked: {
                if (!expanded) {
                    _expandedSection = expandableSection;
                } else {
                    _expandedSection = null;
                }
            }
        }
    }

    Loader {
        id: footer
        anchors.top: flow.bottom
        width: parent.width
        sourceComponent: expandableSection.footer
    }
}
